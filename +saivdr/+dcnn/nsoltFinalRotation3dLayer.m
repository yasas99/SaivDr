classdef nsoltFinalRotation3dLayer < nnet.layer.Layer
    %NSOLTFINALROTATION2DLAYER
    %
    %   コンポーネント別に入力(nComponents):
    %      nRows x nCols x nLays x nChs x nSamples
    %
    %   コンポーネント別に出力(nComponents):
    %      nRows x nCols x nLays x nDecs x nSamples
    %
    %
    % Requirements: MATLAB R2020a
    %
    % Copyright (c) 2020, Shogo MURAMATSU
    %
    % All rights reserved.
    %
    % Contact address: Shogo MURAMATSU,
    %                Faculty of Engineering, Niigata University,
    %                8050 2-no-cho Ikarashi, Nishi-ku,
    %                Niigata, 950-2181, JAPAN
    %
    % http://msiplab.eng.niigata-u.ac.jp/
        
     properties
        % (Optional) Layer properties.
        NumberOfChannels
        DecimationFactor
        NoDcLeakage
        Mus

        % Layer properties go here.
    end
    
    properties (Learnable)
        Angles
    end
    
    
    methods
        function layer = nsoltFinalRotation3dLayer(varargin)
            % (Optional) Create a myLayer.
            % This function must have the same name as the class.
            import saivdr.dictionary.utility.Direction
            p = inputParser;
            addParameter(p,'NumberOfChannels',[])
            addParameter(p,'DecimationFactor',[])
            addParameter(p,'Mus',[]);
            addParameter(p,'Angles',[]);
            addParameter(p,'Name','')
            addParameter(p,'NoDcLeakage',false);
            parse(p,varargin{:})
            
            % Layer constructor function goes here.
            layer.NumberOfChannels = p.Results.NumberOfChannels;
            layer.DecimationFactor = p.Results.DecimationFactor;
            layer.Mus = p.Results.Mus;
            layer.Angles = p.Results.Angles;
            layer.NoDcLeakage = p.Results.NoDcLeakage;
            layer.Name = p.Results.Name;
            layer.Description = "NSOLT final rotation " ...
                + "(ps,pa) = (" ...
                + layer.NumberOfChannels(1) + "," ...
                + layer.NumberOfChannels(2) + "), "  ...
                + "(mv,mh,md) = (" ...
                + layer.DecimationFactor(Direction.VERTICAL) + "," ...
                + layer.DecimationFactor(Direction.HORIZONTAL) + "," ...                      
                + layer.DecimationFactor(Direction.DEPTH) + ")";
            layer.Type = '';

            nChsTotal = sum(layer.NumberOfChannels);
            nAngles = (nChsTotal-2)*nChsTotal/4;
            if isempty(layer.Angles)
                layer.Angles = zeros(nAngles,1);
            end
            if length(layer.Angles)~=nAngles
                error('Invalid # of angles')
            end
        end
        
        function Z = predict(layer, X)
            % Forward input data through the layer at prediction time and
            % output the result.
            %
            % Inputs:
            %         layer       - Layer to forward propagate through
            %         X1, ..., Xn - Input data (n: # of components)
            % Outputs:
            %         Z           - Outputs of layer forward function
            %  
            import saivdr.dcnn.fcn_orthonormalmatrixgenerate
            
            % Layer forward function for prediction goes here.
            nrows = size(X,1);
            ncols = size(X,2);
            nlays = size(X,3);
            ps = layer.NumberOfChannels(1);
            pa = layer.NumberOfChannels(2);
            nSamples = size(X,5);
            stride = layer.DecimationFactor;
            nDecs = prod(stride);
            %
            if isempty(layer.Mus)
                layer.Mus = ones(ps+pa,1);
            elseif isscalar(layer.Mus)
                layer.Mus = layer.Mus*ones(ps+pa,1);
            end
            if layer.NoDcLeakage
                layer.Mus(1) = 1;
                layer.Angles(1:ps-1) = ...
                    zeros(ps-1,1,'like',layer.Angles);
            end            
            muW = layer.Mus(1:ps);
            muU = layer.Mus(ps+1:end);
            anglesW = layer.Angles(1:length(layer.Angles)/2);
            anglesU = layer.Angles(length(layer.Angles)/2+1:end);
            W0T = transpose(fcn_orthonormalmatrixgenerate(anglesW,muW));
            U0T = transpose(fcn_orthonormalmatrixgenerate(anglesU,muU));
            
            Y = permute(X,[4 1 2 3 5]);
            Ys = reshape(Y(1:ps,:,:,:,:),ps,nrows*ncols*nlays*nSamples);
            Ya = reshape(Y(ps+1:ps+pa,:,:,:,:),pa,nrows*ncols*nlays*nSamples);
            Zsa = [ W0T(1:nDecs/2,:)*Ys; U0T(1:nDecs/2,:)*Ya ];
            Z = ipermute(reshape(Zsa,nDecs,nrows,ncols,nlays,nSamples),...
                [4 1 2 3 5]);
        end
        
    end
    

end
