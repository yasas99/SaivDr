classdef SupportExtensionHorizontalTypeII < matlab.System  %#codegen
    %SUPPORTEXTENSIONHORIZONTALTYPEII Type-II horizontal support extension
    %
    % SVN identifier:
    % $Id: SupportExtensionHorizontalTypeII.m 683 2015-05-29 08:22:13Z sho $
    %
    % Requirements: MATLAB R2015b
    %
    % Copyright (c) 2014-2015, Shogo MURAMATSU
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

    properties (Access=protected,Nontunable)
        hLen
    end    
    
    methods
        function obj = SupportExtensionHorizontalTypeII(varargin)
            setProperties(obj,nargin,varargin{:});
        end
    end    
    
    methods ( Access = protected )
        
                
        function validateInputsImpl(~,~,~,~,paramMtx1,paramMtx2,~)
            if all(size(paramMtx1) == size(paramMtx2))
                error('ps and pa must be differnt from each other.')
            end
        end                   

         function setupImpl(obj,~,~,~,paramMtx1,paramMtx2,~)
             obj.hLen = [ size(paramMtx1,1) size(paramMtx2,1) ];            
         end
        
        function arrayCoefs = stepImpl(obj,arrayCoefs,nRows,nCols,paramMtx1,paramMtx2,isPeriodicExt)
            %obj.hLen = [ size(paramMtx1,1) size(paramMtx2,1) ];            
            % Phase 1 for horizontal symtif.Direction
            Ux = paramMtx2;            
            I = eye(size(Ux));
            arrayCoefs = blockButterfly_(obj,arrayCoefs);
            arrayCoefs = rightShiftLowerCoefs_(obj,arrayCoefs,nRows,nCols);
            arrayCoefs = blockButterfly_(obj,arrayCoefs);
            arrayCoefs = arrayCoefs/2.0;
            for iRow = 1:nRows
                for iCol = 1:nCols
                    if iCol == 1 && ~isPeriodicExt
                        U = -I;
                    else
                        U = Ux;
                    end
                    arrayCoefs = lowerBlockRot_(obj,arrayCoefs,nRows,iRow,iCol,U);
                end
            end
            
            % Phase 2 for horizontal symtif.Direction
            Wx = paramMtx1;
            arrayCoefs = blockButterfly_(obj,arrayCoefs);
            arrayCoefs = leftShiftUpperCoefs_(obj,arrayCoefs,nRows,nCols);
            arrayCoefs = blockButterfly_(obj,arrayCoefs);
            arrayCoefs = arrayCoefs/2.0;
            for iRow = 1:nRows
                for iCol = 1:nCols
                    arrayCoefs = upperBlockRot_(obj,arrayCoefs,nRows,iRow,iCol,Wx);
                end
            end
        end

        function numIn = getNumInputsImpl(~)
            numIn = 6;
        end
        
        function numOut = getNumOutputsImpl(~)
            numOut = 1;
        end
        
    end
    
    methods ( Access = private )
        
        function arrayCoefs = rightShiftLowerCoefs_(obj,arrayCoefs,nRows,nCols)
            for iRow = 1:nRows
                indexCol1 = iRow;
                colData0 = arrayCoefs(:,indexCol1);
                lowerCoefsPre = colData0(obj.hLen(1)+1:end);
                for iCol = 2:nCols
                    indexCol = (iCol-1)*nRows+iRow;
                    colData = arrayCoefs(:,indexCol);
                    lowerCoefsCur = colData(obj.hLen(1)+1:end);
                    colData(obj.hLen(1)+1:end) = lowerCoefsPre;
                    arrayCoefs(:,indexCol) = colData;
                    lowerCoefsPre = lowerCoefsCur;
                end
                colData0(obj.hLen(1)+1:end) = lowerCoefsPre;
                arrayCoefs(:,indexCol1) = colData0;
            end
        end
        
        function arrayCoefs = leftShiftUpperCoefs_(obj,arrayCoefs,nRows,nCols)
            for iRow = 1:nRows
                indexCol1 = iRow;
                colData0 = arrayCoefs(:,indexCol1);
                upperCoefsPost = colData0(1:obj.hLen(2));
                for iCol = nCols:-1:2
                    indexCol = (iCol-1)*nRows+iRow;
                    colData = arrayCoefs(:,indexCol);
                    upperCoefsCur = colData(1:obj.hLen(2));
                    colData(1:obj.hLen(2)) = upperCoefsPost;
                    arrayCoefs(:,indexCol) = colData;
                    upperCoefsPost = upperCoefsCur;
                end
                colData0(1:obj.hLen(2)) = upperCoefsPost;
                arrayCoefs(:,indexCol1) = colData0;
            end
        end
        
        function arrayCoefs = blockButterfly_(obj,arrayCoefs)
            nChMx = max(obj.hLen);
            nChMn = min(obj.hLen);
            upper = arrayCoefs(1:nChMn,:);
            middle = arrayCoefs(nChMn+1:nChMx,:);
            lower = arrayCoefs(nChMx+1:end,:);
            arrayCoefs = [
                upper + lower;
                1.414213562373095*middle;
                upper - lower ];
        end
        
        function arrayCoefs = lowerBlockRot_(obj,arrayCoefs,nRows,iRow,iCol,U)
            indexCol = (iCol-1)*nRows+iRow;
            colData = arrayCoefs(:,indexCol);
            colData(obj.hLen(1)+1:end) = U*colData(obj.hLen(1)+1:end); 
            arrayCoefs(:,indexCol) = colData;
        end     
        
        function arrayCoefs = upperBlockRot_(obj,arrayCoefs,nRows,iRow,iCol,W)
            indexCol = (iCol-1)*nRows+iRow;
            colData = arrayCoefs(:,indexCol);
            colData(1:obj.hLen(1)) = W*colData(1:obj.hLen(1)); 
            arrayCoefs(:,indexCol) = colData;
        end        
        
    end
    
end
