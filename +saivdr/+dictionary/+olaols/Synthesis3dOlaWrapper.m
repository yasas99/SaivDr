classdef Synthesis3dOlaWrapper < saivdr.dictionary.AbstSynthesisSystem
    %SYNTHESIS3DOLAWRAPPER OLA wrapper for 3-D synthesis system
    %
    % Reference:
    %   Shogo Muramatsu and Hitoshi Kiya,
    %   ''Parallel Processing Techniques for Multidimensional Sampling
    %   Lattice Alteration Based on Overlap-Add and Overlap-Save Methods,'' 
    %   IEICE Trans. on Fundamentals, Vol.E78-A, No.8, pp.939-943, Aug. 1995
    %
    % Requirements: MATLAB R2018a
    %
    % Copyright (c) 2018, Shogo MURAMATSU
    %
    % All rights reserved.
    %
    % Contact address: Shogo MURAMATSU,
    %                Faculty of Engineering, Niigata University,
    %                8050 2-no-cho Ikarashi, Nishi-ku,
    %                Niigata, 950-2181, JAPAN
    %
    % http://msiplab.eng.niigata-u.ac.jp/
    %
    
    properties (Nontunable)
        Synthesizer
        BoundaryOperation
        PadSize = [0 0 0]
    end
    
    properties (Logical)
        UseParallel = false
    end
    
    properties (Nontunable)
        SplitFactor = []
    end
    
    properties (Nontunable, PositiveInteger, Hidden)
        VerticalSplitFactor = 1
        HorizontalSplitFactor = 1
        DepthSplitFactor = 1        
    end
    
    properties (Hidden, Transient)
        BoundaryOperationSet = ...
            matlab.system.StringSet({'Circular'});
    end
    
    properties (Access = private, Nontunable)
        refSize
        refSubSize
        refSynthesizer
        subPadSize
        synthesizers
        nWorkers
    end
    
    methods
        
        % Constractor
        function obj = Synthesis3dOlaWrapper(varargin)
            import saivdr.dictionary.utility.Direction
            setProperties(obj,nargin,varargin{:})
            if ~isempty(obj.Synthesizer)
                obj.BoundaryOperation = obj.Synthesizer.BoundaryOperation;
            end
            if ~isempty(obj.SplitFactor)
                obj.VerticalSplitFactor = obj.SplitFactor(Direction.VERTICAL);
                obj.HorizontalSplitFactor = obj.SplitFactor(Direction.HORIZONTAL);    
                obj.DepthSplitFactor = obj.SplitFactor(Direction.DEPTH);
            end            
        end
        %{
        function setFrameBound(obj,frameBound)
            obj.FrameBound = frameBound;
        end
        %}
    end
    
    methods (Access = protected)
        
         function flag = isInactivePropertyImpl(obj,propertyName)
            if strcmp(propertyName,'VerticalSplitFactor') || ...
                    strcmp(propertyName,'HorizontalSplitFactor') || ...
                    strcmp(propertyName,'DepthSplitFactor')
                flag = ~isempty(obj.SplitFactor);
            else
                flag = false;
            end
         end       
        
        function s = saveObjectImpl(obj)
            s = saveObjectImpl@saivdr.dictionary.AbstSynthesisSystem(obj);
            s.Synthesizer = matlab.System.saveObject(obj.Synthesizer);
        end
        
        function loadObjectImpl(obj,s,wasLocked)
            obj.Synthesizer = matlab.System.loadObject(s.Synthesizer);
            loadObjectImpl@saivdr.dictionary.AbstSynthesisSystem(obj,s,wasLocked);
        end

        function setupImpl(obj,coefs,scales)
            obj.Synthesizer.release();
            obj.refSynthesizer = obj.Synthesizer.clone();
            recImg = step(obj.refSynthesizer,coefs,scales);
            obj.refSize = size(recImg);            
            obj.refSubSize = obj.refSize*...
                diag(1./[obj.VerticalSplitFactor,...
                obj.HorizontalSplitFactor,...
                obj.DepthSplitFactor ]);
            %
            scaleRatio = scales*diag(1./obj.refSize);
            obj.subPadSize = scaleRatio*diag(obj.PadSize);
            %
            nSplit = obj.VerticalSplitFactor*...
                obj.HorizontalSplitFactor*...
                obj.DepthSplitFactor;
            obj.synthesizers = cell(nSplit,1);
            if obj.UseParallel
                pool = gcp;
                obj.nWorkers = pool.NumWorkers;
                for iSplit=1:nSplit
                    obj.synthesizers{iSplit} = clone(obj.Synthesizer);
                end
            else
                obj.nWorkers = 0;
                for iSplit=1:nSplit
                    obj.synthesizers{iSplit} = obj.Synthesizer;
                end
            end
                        
            % Evaluate
            % Check if scales are divisible by split factors
            exceptionId = 'SaivDr:IllegalSplitFactorException';            
            message = 'Split factor must be a divisor of array size.';
            if sum(mod(obj.refSubSize,1)) ~= 0
                throw(MException(exceptionId,message))                
            end
            % Check if subPadSizes are integer
            %exceptionId = 'SaivDr:IllegalSplitFactorException';            
            %message = 'Split factor must be a divisor of array size.';            
            if sum(mod(obj.subPadSize,1)) ~= 0
                throw(MException('SaivDr','Illegal Pad Size.'))                
            end            
            % Check identity
            exceptionId = 'SaivDr:ReconstructionFailureException';            
            message = 'Failure occurs in reconstruction. Please check the split and padding size.';
            diffImg = recImg - stepImpl(obj,coefs,scales);
            if norm(diffImg(:))/numel(diffImg) > 1e-6
                throw(MException(exceptionId,message))
            end
            % Delete reference synthesizer
            obj.refSynthesizer.delete()
        end
        
        function recImg = stepImpl(obj,coefs,scales)
            % 1. Split
            subCoefArrays = split_(obj,coefs,scales);
            % 2. Zero Padding
            subCoefArrays = padding_(obj,subCoefArrays); 
            [subCoefs,subScales] = convert_(obj,subCoefArrays);
            % 3. Synthesize
            nSplit = length(subCoefs);
            subRecImg = cell(nSplit,1);
            %
            synthesizers_ = obj.synthesizers;
            parfor (iSplit=1:nSplit,obj.nWorkers)
               subCoefs_ = subCoefs{iSplit};
               subRecImg{iSplit} = step(synthesizers_{iSplit},subCoefs_,subScales);            
            end
            % 4. Overlap add (Circular)
            recImg = circular_ola_(obj,subRecImg);
        end
        
    end
    
    methods(Access = private)

        function recImg = circular_ola_(obj,subRecImg)
            import saivdr.dictionary.utility.Direction
            stepsize = obj.refSubSize;
            overlap = size(subRecImg{1})-stepsize;
            recImg = zeros(obj.refSize+overlap);
            % Overlap add
            iSplit = 0;
            tIdxDep = 0;
            for iDepSplit = 1:obj.DepthSplitFactor
                sIdxDep = tIdxDep + 1;
                tIdxDep = sIdxDep + stepsize(Direction.DEPTH) - 1;
                eIdxDep = tIdxDep + overlap(Direction.DEPTH);
                tIdxHor = 0;
                for iHorSplit = 1:obj.HorizontalSplitFactor
                    sIdxHor = tIdxHor + 1;
                    tIdxHor = sIdxHor + stepsize(Direction.HORIZONTAL) - 1;
                    eIdxHor = tIdxHor + overlap(Direction.HORIZONTAL);
                    tIdxVer = 0;
                    for iVerSplit = 1:obj.VerticalSplitFactor
                        iSplit = iSplit + 1;
                        sIdxVer = tIdxVer + 1;
                        tIdxVer = sIdxVer + stepsize(Direction.VERTICAL) - 1;
                        eIdxVer = tIdxVer + overlap(Direction.VERTICAL);
                        recImg(sIdxVer:eIdxVer,sIdxHor:eIdxHor,sIdxDep:eIdxDep) = ...
                            recImg(sIdxVer:eIdxVer,sIdxHor:eIdxHor,sIdxDep:eIdxDep) + ...
                            subRecImg{iSplit};
                    end
                end
            end
            % Folding
            recImg(1:overlap(Direction.VERTICAL),:,:) = ...
                recImg(1:overlap(Direction.VERTICAL),:,:) + ...
                recImg(end-overlap(Direction.VERTICAL)+1:end,:,:);
            recImg(:,1:overlap(Direction.HORIZONTAL),:) = ...
                recImg(:,1:overlap(Direction.HORIZONTAL),:) + ...
                recImg(:,end-overlap(Direction.HORIZONTAL)+1:end,:);
            recImg(:,:,1:overlap(Direction.DEPTH)) = ...
                recImg(:,:,1:overlap(Direction.DEPTH)) + ...
                recImg(:,:,end-overlap(Direction.DEPTH)+1:end);
            % Cropping & circular shift
            recImg = circshift(recImg(...
                1:obj.refSize(Direction.VERTICAL),...
                1:obj.refSize(Direction.HORIZONTAL),...
                1:obj.refSize(Direction.DEPTH)),-overlap/2);
        end
        
        function [subCoefs,subScales] = convert_(~,subCoefArrays)
            nSplit = size(subCoefArrays,1);
            nChs = size(subCoefArrays,2);
            subScales = zeros(nChs,3);
            subCoefs = cell(nSplit,1);
            for iSplit = 1:nSplit
                tmpCoefs = [];
                for iCh = 1:nChs
                    tmpArray = subCoefArrays{iSplit,iCh};
                    if iSplit == 1
                        subScales(iCh,:) = size(tmpArray);
                    end
                    tmpCoefs = [ tmpCoefs tmpArray(:).' ];
                end
                subCoefs{iSplit} = tmpCoefs;
            end
        end
        
        function subCoefArrays = padding_(obj,subCoefArrays)
            nSplit = size(subCoefArrays,1);
            nChs = size(subCoefArrays,2);
            for iSplit = 1:nSplit
                for iCh = 1:nChs
                    subCoefArrays{iSplit,iCh} = ...
                        padarray(subCoefArrays{iSplit,iCh},...
                        obj.subPadSize(iCh,:),0,'both');
                end
            end
        end
        
        function subCoefArrays = split_(obj,coefs,scales)
            import saivdr.dictionary.utility.Direction
            nSplit = obj.VerticalSplitFactor*...
                obj.HorizontalSplitFactor*...
                obj.DepthSplitFactor;
            % # of channels
            nChs = size(scales,1);
            subScales = scales*diag(...
                [1/obj.VerticalSplitFactor,...
                1/obj.HorizontalSplitFactor,...
                1/obj.DepthSplitFactor]);
            subCoefArrays = cell(nSplit,nChs);
            %
            eIdx = 0;
            for iCh = 1:nChs
                sIdx = eIdx + 1;
                eIdx = sIdx + prod(scales(iCh,:)) - 1;                
                nRows = scales(iCh,Direction.VERTICAL);
                nCols = scales(iCh,Direction.HORIZONTAL);                
                nLays = scales(iCh,Direction.DEPTH);
                coefArrays = reshape(coefs(sIdx:eIdx),[nRows nCols nLays]);                
                %
                nSubRows = subScales(iCh,Direction.VERTICAL);
                nSubCols = subScales(iCh,Direction.HORIZONTAL);
                nSubLays = subScales(iCh,Direction.DEPTH);
                iSplit = 0;
                for iDepSplit = 1:obj.DepthSplitFactor
                    sLayIdx = (iDepSplit-1)*nSubLays + 1;
                    eLayIdx = iDepSplit*nSubLays;
                    for iHorSplit = 1:obj.HorizontalSplitFactor
                        sColIdx = (iHorSplit-1)*nSubCols + 1;
                        eColIdx = iHorSplit*nSubCols;
                        for iVerSplit = 1:obj.VerticalSplitFactor
                            iSplit = iSplit + 1;
                            sRowIdx = (iVerSplit-1)*nSubRows + 1;
                            eRowIdx = iVerSplit*nSubRows;
                            subCoefArrays{iSplit,iCh} = ...
                                coefArrays(sRowIdx:eRowIdx,...
                                sColIdx:eColIdx,...
                                sLayIdx:eLayIdx);
                        end
                    end
                end
            end
        end
    end
end