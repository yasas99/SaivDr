classdef OvsdLpPuFb2dTypeIVm1SystemTestCase < matlab.unittest.TestCase
    %OVSDLPPUFB2DTYPEIVM1TESTCASE Test case for OvsdLpPuFb2dTypeIVm1System
    %
    % SVN identifier:
    % $Id: OvsdLpPuFb2dTypeIVm1SystemTestCase.m 683 2015-05-29 08:22:13Z sho $
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
    
    properties
        lppufb
    end
    
    methods (TestMethodTeardown)
        function deleteObject(testCase)
            delete(testCase.lppufb);
        end
    end
    
    methods (Test)
        
        % Test for default construction
        function testConstructor(testCase)
            
            % Expected values
            coefExpctd = 1/2 * [
                1  1  1  1 ;
                1 -1 -1  1 ;
                -1  1 -1  1 ;
                -1 -1  1  1 ];
            
            % Instantiation of target class
            import saivdr.dictionary.nsolt.*
            testCase.lppufb = OvsdLpPuFb2dTypeIVm1System();
            
            % Actual values
            coefActual = step(testCase.lppufb,[],[]);
            
            % Evaluation
            testCase.verifySize(coefActual,size(coefExpctd));
            coefDist = max(abs(coefExpctd(:)-coefActual(:))./abs(coefExpctd(:)));
            testCase.verifyEqual(coefActual,coefExpctd,'RelTol',1e-15,...
                sprintf('%g',coefDist));
            
        end
        
        % Test for default construction
        function testConstructorWithDeepCopy(testCase)
            
            % Instantiation of target class
            import saivdr.dictionary.nsolt.*
            testCase.lppufb = OvsdLpPuFb2dTypeIVm1System();
            cloneLpPuFb = clone(testCase.lppufb);

            % Evaluation
            testCase.verifyEqual(cloneLpPuFb,testCase.lppufb);
            testCase.verifyFalse(cloneLpPuFb == testCase.lppufb);
            prpOrg = get(testCase.lppufb,'ParameterMatrixSet');
            prpCln = get(cloneLpPuFb,'ParameterMatrixSet');
            testCase.verifyEqual(prpCln,prpOrg);
            testCase.verifyFalse(prpCln == prpOrg);
            
            % Expected values
            coefExpctd = step(testCase.lppufb,[],[]);
            
            % Actual values
            coefActual = step(cloneLpPuFb,[],[]);
            
            % Evaluation
            coefDist = max(abs(coefExpctd(:)-coefActual(:))./abs(coefExpctd(:)));
            testCase.verifyEqual(coefActual,coefExpctd,'RelTol',1e-15,...
                sprintf('%g',coefDist));
            
            % Change angles
            angles = randn(size(get(cloneLpPuFb,'Angles')));
            
            % Actual values
            coefActual = step(cloneLpPuFb,angles,[]);
            
            % Evaluation
            import matlab.unittest.constraints.IsGreaterThan
            coefDist = max(abs(coefExpctd(:)-coefActual(:))./abs(coefExpctd(:)));
            testCase.verifyThat(coefDist,IsGreaterThan(1e-15),...
                sprintf('%g',coefDist));
        end

        % Test for construction
        function testConstructorWithOrd00(testCase)
            
            % Parameters
            dec = [ 2 2 ];
            ord = [ 0 0 ];
            
            % Expected values
            coefExpctd(:,:,1,1) = 1/2 * [
                1  1  1  1 ;
                1 -1 -1  1 ;
                -1  1 -1  1 ;
                -1 -1  1  1 ];
            
            % Instantiation of target class
            import saivdr.dictionary.nsolt.*
            testCase.lppufb = OvsdLpPuFb2dTypeIVm1System(...
                'DecimationFactor',dec,...
                'PolyPhaseOrder',ord);
            
            % Actual values
            coefActual = step(testCase.lppufb,[],[]);
            
            % Evaluation
            coefDist = max(abs(coefExpctd(:)-coefActual(:))./abs(coefExpctd(:)));
            testCase.verifyEqual(coefActual,coefExpctd,'RelTol',1e-15,...
                sprintf('%g',coefDist));
            
        end

        % Test for construction
        function testConstructorWithDec44Ord00(testCase)
            
            % Parameters
            dec = [ 4 4 ];
            ord = [ 0 0 ];
            
            % Expected values
            dimExpctd = [16 16];
            
            % Instantiation of target class
            import saivdr.dictionary.nsolt.*
            testCase.lppufb = OvsdLpPuFb2dTypeIVm1System(...
                'DecimationFactor',dec,...
                'PolyPhaseOrder',ord);
            
            % Actual values
            coefActual = step(testCase.lppufb,[],[]);
            
            % Evaluation
            testCase.verifySize(coefActual,dimExpctd);
            
            % Check symmetry
            import matlab.unittest.constraints.IsLessThan
            coefEvn = coefActual(1:ceil(end/2),:);
            coefDiff = coefEvn-fliplr(coefEvn);
            coefDist = norm(coefDiff(:))/sqrt(numel(coefDiff));
            testCase.verifyThat(coefDist,IsLessThan(1e-15),...
                sprintf('%g',coefDist));
            coefOdd = coefActual(ceil(end/2)+1:end,:);
            coefDiff = coefOdd+fliplr(coefOdd);
            coefDist = norm(coefDiff(:))/sqrt(numel(coefDiff));
            testCase.verifyThat(coefDist,IsLessThan(1e-15),...
                sprintf('%g',coefDist));
            
            % Check orthogonality
            coefDist = norm((coefActual.'*coefActual)-eye(dimExpctd))...
                /sqrt(numel(coefActual));
            testCase.verifyThat(coefDist,IsLessThan(1e-15),...
                sprintf('%g',coefDist));
            
        end
       
        % Test for construction
        function testConstructorWithDec22Ch4Ord00(testCase)
            
            % Parameters
            decch = [ 2 2 4 ];
            ord = [ 0 0 ];
            
            % Expected values
            coefExpctd(:,:,1,1) = 1/2 * [
                1  1  1  1 ;
                1 -1 -1  1 ;
                -1  1 -1  1 ;
                -1 -1  1  1 ];
            
            % Instantiation of target class
            import saivdr.dictionary.nsolt.*
            testCase.lppufb = OvsdLpPuFb2dTypeIVm1System(...
                'DecimationFactor',decch(1:2),...
                'NumberOfChannels',decch(3:end),...
                'PolyPhaseOrder',ord);
            
            % Actual values
            coefActual = step(testCase.lppufb,[],[]);
            
            % Evaluation
            coefDist = max(abs(coefExpctd(:)-coefActual(:))./abs(coefExpctd(:)));
            testCase.verifyEqual(coefActual,coefExpctd,'RelTol',1e-15,...
                sprintf('%g',coefDist));

        end

        % Test for construction
        function testConstructorWithDec22Ch4Ord01(testCase)
            
            % Parameters
            decch = [ 2 2 4 ];
            ord = [ 0 1 ];
            ang = 0;
            
            % Expected values
            coefExpctd(:,:,1,1) = 1/2 * [...
                0 0  1  1;
                0 0 -1  1;
                0 0 -1  1;
                0 0  1  1];
            
            coefExpctd(:,:,1,2) = 1/2 * [...
                1  1 0 0;
                1 -1 0 0;
                -1  1 0 0;
                -1 -1 0 0];
            
            % Instantiation of target class
            import saivdr.dictionary.nsolt.*
            testCase.lppufb = OvsdLpPuFb2dTypeIVm1System(...
                'DecimationFactor',decch(1:2),...
                'NumberOfChannels',decch(3:end),...
                'PolyPhaseOrder',ord);
            
            % Actual values
            coefActual = step(testCase.lppufb,ang,[]);
            
            % Evaluation
            coefDist = max(abs(coefExpctd(:)-coefActual(:)));
            testCase.verifyEqual(coefActual,coefExpctd,'AbsTol',1e-15,...
                sprintf('%g',coefDist));            
            
        end

        % Test for construction with order 0 1
        function testConstructorWithDec22Ch6Ord01(testCase)
            
            % Parameters
            decch = [ 2 2 6 ];
            ord = [ 0 1 ];
            ang = 2*pi*rand(3,3);
            
            % Expected values
            nChs = decch(3);
            nDec = decch(1)*decch(2);
            dimExpctd = [nChs nDec ord(1)+1 ord(2)+1];
            
            % Instantiation of target class
            import saivdr.dictionary.nsolt.*
            testCase.lppufb = OvsdLpPuFb2dTypeIVm1System(...
                'DecimationFactor',decch(1:2),...
                'NumberOfChannels',decch(3:end),...
                'PolyPhaseOrder',ord);
            
            % Actual values
            coefActual = step(testCase.lppufb,ang,[]);
            
            % Evaluation
            testCase.verifySize(coefActual,dimExpctd);
            
            % Check symmetry
            import matlab.unittest.constraints.IsLessThan
            coefEvn = coefActual(1:ceil(end/2),:);
            coefDiff = coefEvn-fliplr(coefEvn);
            coefDist = norm(coefDiff(:))/sqrt(numel(coefDiff));
            testCase.verifyThat(coefDist,IsLessThan(1e-15),...
                sprintf('%g',coefDist));
            coefOdd = coefActual(ceil(end/2)+1:end,:);
            coefDiff = coefOdd+fliplr(coefOdd);
            coefDist = norm(coefDiff(:))/sqrt(numel(coefDiff));
            testCase.verifyThat(coefDist,IsLessThan(1e-15),...
                sprintf('%g',coefDist));
            
            % Check tightness
            coefE = step(testCase.lppufb,[],[]);
            E = saivdr.dictionary.utility.PolyPhaseMatrix2d(coefE);
            coefActual = double(E.'*E);
            coefActual(1:nDec,1:nDec,ord(1)+1,ord(2)+1) = ...
                coefActual(1:nDec,1:nDec,ord(1)+1,ord(2)+1) - eye(nDec);
            coefDist = norm(coefActual(:))/sqrt(numel(coefActual));
            testCase.verifyThat(coefDist,IsLessThan(1e-15),...
                sprintf('%g',coefDist));
            
        end

         % Test for construction with order 1 0
        function testConstructorWithDec22Ch6Ord10(testCase)
            
            % Parameters
            decch = [ 2 2 6 ];
            ord = [ 1 0 ];
            ang = 2*pi*rand(3,3);
            
            % Expected values
            nChs = decch(3);
            nDec = decch(1)*decch(2);
            dimExpctd = [nChs nDec ord(1)+1]; 
            
            % Instantiation of target class
            import saivdr.dictionary.nsolt.*
            testCase.lppufb = OvsdLpPuFb2dTypeIVm1System(...
                'DecimationFactor',decch(1:2),...
                'NumberOfChannels',decch(3:end),...
                'PolyPhaseOrder',ord);
            
            % Actual values
            coefActual = step(testCase.lppufb,ang,[]);
            
            % Evaluation
            testCase.verifySize(coefActual,dimExpctd);
            
            % Check symmetry
            import matlab.unittest.constraints.IsLessThan
            coefEvn = coefActual(1:ceil(end/2),:);
            coefDiff = coefEvn-fliplr(coefEvn);
            coefDist = norm(coefDiff(:))/sqrt(numel(coefDiff));
            testCase.verifyThat(coefDist,IsLessThan(1e-15),...
                sprintf('%g',coefDist));
            coefOdd = coefActual(ceil(end/2)+1:end,:);
            coefDiff = coefOdd+fliplr(coefOdd);
            coefDist = norm(coefDiff(:))/sqrt(numel(coefDiff));
            testCase.verifyThat(coefDist,IsLessThan(1e-15),...
                sprintf('%g',coefDist));
            
            % Check tightness
            coefE = step(testCase.lppufb,[],[]);
            E = saivdr.dictionary.utility.PolyPhaseMatrix2d(coefE);
            coefActual = double(E.'*E);
            coefActual(1:nDec,1:nDec,ord(1)+1,ord(2)+1) = ...
                coefActual(1:nDec,1:nDec,ord(1)+1,ord(2)+1) - eye(nDec);
            coefDist = norm(coefActual(:))/sqrt(numel(coefActual));
            testCase.verifyTrue(coefDist<1e-15,sprintf('%g',coefDist));
            
        end

         % Test for construction with order 1 0
        function testConstructorWithDec22Ch6Ord20(testCase)
            
            % Parameters
            decch = [ 2 2 6 ];
            ord = [ 2 0 ];
            ang = 2*pi*rand(3,4);
            
            % Expected values
            nChs = decch(3);
            nDec = decch(1)*decch(2);
            dimExpctd = [nChs nDec ord(1)+1]; 
            
            % Instantiation of target class
            import saivdr.dictionary.nsolt.*
            testCase.lppufb = OvsdLpPuFb2dTypeIVm1System(...
                'DecimationFactor',decch(1:2),...
                'NumberOfChannels',decch(3:end),...
                'PolyPhaseOrder',ord);
            
            % Actual values
            coefActual = step(testCase.lppufb,ang,[]);
            
            % Evaluation
            testCase.verifySize(coefActual,dimExpctd);
            
            % Check symmetry
            import matlab.unittest.constraints.IsLessThan
            coefEvn = coefActual(1:ceil(end/2),:);
            coefDiff = coefEvn-fliplr(coefEvn);
            coefDist = norm(coefDiff(:))/sqrt(numel(coefDiff));
            testCase.verifyThat(coefDist,IsLessThan(1e-15),...
                sprintf('%g',coefDist));
            coefOdd = coefActual(ceil(end/2)+1:end,:);
            coefDiff = coefOdd+fliplr(coefOdd);
            coefDist = norm(coefDiff(:))/sqrt(numel(coefDiff));
            testCase.verifyThat(coefDist,IsLessThan(1e-15),...
                sprintf('%g',coefDist));
            
            % Check tightness
            coefE = step(testCase.lppufb,[],[]);
            E = saivdr.dictionary.utility.PolyPhaseMatrix2d(coefE);
            coefActual = double(E.'*E);
            coefActual(1:nDec,1:nDec,ord(1)+1,ord(2)+1) = ...
                coefActual(1:nDec,1:nDec,ord(1)+1,ord(2)+1) - eye(nDec);
            coefDist = norm(coefActual(:))/sqrt(numel(coefActual));
            testCase.verifyTrue(coefDist<1e-15,sprintf('%g',coefDist));
            
        end

        % Test for construction with order 0 2
        function testConstructorWithDec22Ch6Ord02(testCase)
            
            % Parameters
            decch = [ 2 2 6 ];
            ord = [ 0 2 ];
            ang = 2*pi*rand(3,4);
            
            % Expected values
            nChs = decch(3);
            nDec = decch(1)*decch(2);
            dimExpctd = [nChs nDec ord(1)+1 ord(2)+1];
            
            % Instantiation of target class
            import saivdr.dictionary.nsolt.*
            testCase.lppufb = OvsdLpPuFb2dTypeIVm1System(...
                'DecimationFactor',decch(1:2),...
                'NumberOfChannels',decch(3:end),...
                'PolyPhaseOrder',ord);
                
            % Actual values
            coefActual = step(testCase.lppufb,ang,[]);
            
            % Evaluation
            testCase.verifySize(coefActual,dimExpctd);
            
            % Check symmetry
            import matlab.unittest.constraints.IsLessThan
            coefEvn = coefActual(1:ceil(end/2),:);
            coefDiff = coefEvn-fliplr(coefEvn);
            coefDist = norm(coefDiff(:))/sqrt(numel(coefDiff));
            testCase.verifyThat(coefDist,IsLessThan(1e-15),...
                sprintf('%g',coefDist));
            coefOdd = coefActual(ceil(end/2)+1:end,:);
            coefDiff = coefOdd+fliplr(coefOdd);
            coefDist = norm(coefDiff(:))/sqrt(numel(coefDiff));
            testCase.verifyThat(coefDist,IsLessThan(1e-15),...
                sprintf('%g',coefDist));
            
            % Check tightness
            coefE = step(testCase.lppufb,[],[]);
            E = saivdr.dictionary.utility.PolyPhaseMatrix2d(coefE);
            coefActual = double(E.'*E);
            coefActual(1:nDec,1:nDec,ord(1)+1,ord(2)+1) = ...
                coefActual(1:nDec,1:nDec,ord(1)+1,ord(2)+1) - eye(nDec);
            coefDist = norm(coefActual(:))/sqrt(numel(coefActual));
            testCase.verifyTrue(coefDist<1e-15,sprintf('%g',coefDist));
            
        end
        
        
         % Test for construction with order 0 1
        function testConstructorWithDec22Ch8Ord01(testCase)
            
            % Parameters
            decch = [ 2 2 8 ];
            ord = [ 0 1 ];
            ang = 2*pi*rand(6,3);
            
            % Expected values
            nChs = decch(3);
            nDec = decch(1)*decch(2);
            dimExpctd = [nChs nDec ord(1)+1 ord(2)+1];
            
            % Instantiation of target class
            import saivdr.dictionary.nsolt.*
            testCase.lppufb = OvsdLpPuFb2dTypeIVm1System(...
                'DecimationFactor',decch(1:2),...
                'NumberOfChannels',decch(3:end),...
                'PolyPhaseOrder',ord);
                            
            % Actual values
            coefActual = step(testCase.lppufb,ang,[]);
            
            % Evaluation
            testCase.verifySize(coefActual,dimExpctd);
            
            % Check symmetry
            import matlab.unittest.constraints.IsLessThan
            coefEvn = coefActual(1:ceil(end/2),:);
            coefDiff = coefEvn-fliplr(coefEvn);
            coefDist = norm(coefDiff(:))/sqrt(numel(coefDiff));
            testCase.verifyThat(coefDist,IsLessThan(1e-15),...
                sprintf('%g',coefDist));
            coefOdd = coefActual(ceil(end/2)+1:end,:);
            coefDiff = coefOdd+fliplr(coefOdd);
            coefDist = norm(coefDiff(:))/sqrt(numel(coefDiff));
            testCase.verifyThat(coefDist,IsLessThan(1e-15),...
                sprintf('%g',coefDist));
            
            % Check tightness
            coefE = step(testCase.lppufb,[],[]);
            E = saivdr.dictionary.utility.PolyPhaseMatrix2d(coefE);
            coefActual = double(E.'*E);
            coefActual(1:nDec,1:nDec,ord(1)+1,ord(2)+1) = ...
                coefActual(1:nDec,1:nDec,ord(1)+1,ord(2)+1) - eye(nDec);
            coefDist = norm(coefActual(:))/sqrt(numel(coefActual));
            testCase.verifyTrue(coefDist<1e-15,sprintf('%g',coefDist));
            
        end
        
         % Test for construction with order 1 0
        function testConstructorWithDec22Ch8Ord10(testCase)
            
            % Parameters
            decch = [ 2 2 8 ];
            ord = [ 1 0 ];
            ang = 2*pi*rand(6,3);
            
            % Expected values
            nChs = decch(3);
            nDec = decch(1)*decch(2);
            dimExpctd = [nChs nDec ord(1)+1 ];
            
            % Instantiation of target class
            import saivdr.dictionary.nsolt.*
            testCase.lppufb = OvsdLpPuFb2dTypeIVm1System(...
                'DecimationFactor',decch(1:2),...
                'NumberOfChannels',decch(3:end),...
                'PolyPhaseOrder',ord);
            
            % Actual values
            coefActual = step(testCase.lppufb,ang,[]);
            
            % Evaluation
            testCase.verifySize(coefActual,dimExpctd);
            
            % Check symmetry
            import matlab.unittest.constraints.IsLessThan
            coefEvn = coefActual(1:ceil(end/2),:);
            coefDiff = coefEvn-fliplr(coefEvn);
            coefDist = norm(coefDiff(:))/sqrt(numel(coefDiff));
            testCase.verifyThat(coefDist,IsLessThan(1e-15),...
                sprintf('%g',coefDist));
            coefOdd = coefActual(ceil(end/2)+1:end,:);
            coefDiff = coefOdd+fliplr(coefOdd);
            coefDist = norm(coefDiff(:))/sqrt(numel(coefDiff));
            testCase.verifyThat(coefDist,IsLessThan(1e-15),...
                sprintf('%g',coefDist));
            
            % Check tightness
            coefE = step(testCase.lppufb,[],[]); 
            E = saivdr.dictionary.utility.PolyPhaseMatrix2d(coefE);
            coefActual = double(E.'*E);
            coefActual(1:nDec,1:nDec,ord(1)+1,ord(2)+1) = ...
                coefActual(1:nDec,1:nDec,ord(1)+1,ord(2)+1) - eye(nDec);
            coefDist = norm(coefActual(:))/sqrt(numel(coefActual));
            testCase.verifyTrue(coefDist<1e-15,sprintf('%g',coefDist));
            
        end
        
         % Test for construction with order 2 0
        function testConstructorWithDec22Ch8Ord20(testCase)
            
            % Parameters
            decch = [ 2 2 8 ];
            ord = [ 2 0 ];
            ang = 2*pi*rand(6,4);
            
            % Expected values
            nChs = decch(3);
            nDec = decch(1)*decch(2);
            dimExpctd = [nChs nDec ord(1)+1 ];
            
            % Instantiation of target class
            import saivdr.dictionary.nsolt.*
            testCase.lppufb = OvsdLpPuFb2dTypeIVm1System(...
                'DecimationFactor',decch(1:2),...
                'NumberOfChannels',decch(3:end),...
                'PolyPhaseOrder',ord);
                            
            % Actual values
            coefActual = step(testCase.lppufb,ang,[]);
            
            % Evaluation
            testCase.verifySize(coefActual,dimExpctd);
            
            % Check symmetry
            import matlab.unittest.constraints.IsLessThan
            coefEvn = coefActual(1:ceil(end/2),:);
            coefDiff = coefEvn-fliplr(coefEvn);
            coefDist = norm(coefDiff(:))/sqrt(numel(coefDiff));
            testCase.verifyThat(coefDist,IsLessThan(1e-15),...
                sprintf('%g',coefDist));
            coefOdd = coefActual(ceil(end/2)+1:end,:);
            coefDiff = coefOdd+fliplr(coefOdd);
            coefDist = norm(coefDiff(:))/sqrt(numel(coefDiff));
            testCase.verifyThat(coefDist,IsLessThan(1e-15),...
                sprintf('%g',coefDist));
            
            % Check tightness
            coefE = step(testCase.lppufb,[],[]); 
            E = saivdr.dictionary.utility.PolyPhaseMatrix2d(coefE);
            coefActual = double(E.'*E);
            coefActual(1:nDec,1:nDec,ord(1)+1,ord(2)+1) = ...
                coefActual(1:nDec,1:nDec,ord(1)+1,ord(2)+1) - eye(nDec);
            coefDist = norm(coefActual(:))/sqrt(numel(coefActual));
            testCase.verifyTrue(coefDist<1e-15,sprintf('%g',coefDist));
            
        end
        
        % Test for construction with order 0 2
        function testConstructorWithDec22Ch8Ord02(testCase)
            
            % Parameters
            decch = [ 2 2 8 ];
            ord = [ 0 2 ];
            ang = 2*pi*rand(6,4);
            
            % Expected values
            nChs = decch(3);
            nDec = decch(1)*decch(2);
            dimExpctd = [nChs nDec ord(1)+1 ord(2)+1];
            
            % Instantiation of target class
            import saivdr.dictionary.nsolt.*
            testCase.lppufb = OvsdLpPuFb2dTypeIVm1System(...
                'DecimationFactor',decch(1:2),...
                'NumberOfChannels',decch(3:end),...
                'PolyPhaseOrder',ord);
                            
            % Actual values
            coefActual = step(testCase.lppufb,ang,[]);
            
            % Evaluation
            testCase.verifySize(coefActual,dimExpctd);
            
            % Check symmetry
            import matlab.unittest.constraints.IsLessThan
            coefEvn = coefActual(1:ceil(end/2),:);
            coefDiff = coefEvn-fliplr(coefEvn);
            coefDist = norm(coefDiff(:))/sqrt(numel(coefDiff));
            testCase.verifyThat(coefDist,IsLessThan(1e-15),...
                sprintf('%g',coefDist));
            coefOdd = coefActual(ceil(end/2)+1:end,:);
            coefDiff = coefOdd+fliplr(coefOdd);
            coefDist = norm(coefDiff(:))/sqrt(numel(coefDiff));
            testCase.verifyThat(coefDist,IsLessThan(1e-15),...
                sprintf('%g',coefDist));
            
            % Check tightness
            coefE = step(testCase.lppufb,[],[]);
            E = saivdr.dictionary.utility.PolyPhaseMatrix2d(coefE);
            coefActual = double(E.'*E);
            coefActual(1:nDec,1:nDec,ord(1)+1,ord(2)+1) = ...
                coefActual(1:nDec,1:nDec,ord(1)+1,ord(2)+1) - eye(nDec);
            coefDist = norm(coefActual(:))/sqrt(numel(coefActual));
            testCase.verifyTrue(coefDist<1e-15,sprintf('%g',coefDist));
            
        end
        
        % Test for construction
        function testConstructorWithDec22Ch8Ord00(testCase)
            
            % Parameters
            decch = [ 2 2 8 ];
            ord = [ 0 0 ];
            
            % Expected values
            dimExpctd = [8 4];
            
            % Instantiation of target class
            import saivdr.dictionary.nsolt.*
            testCase.lppufb = OvsdLpPuFb2dTypeIVm1System(...
                'DecimationFactor',decch(1:2),...
                'NumberOfChannels',decch(3:end),...
                'PolyPhaseOrder',ord);
            
            % Actual values
            coefActual = step(testCase.lppufb,[],[]);
            
            
            % Evaluation
            testCase.verifySize(coefActual,dimExpctd);
            
            % Check symmetry
            import matlab.unittest.constraints.IsLessThan
            coefEvn = coefActual(1:ceil(end/2),:);
            coefDiff = coefEvn-fliplr(coefEvn);
            coefDist = norm(coefDiff(:))/sqrt(numel(coefDiff));
            testCase.verifyThat(coefDist,IsLessThan(1e-15),...
                sprintf('%g',coefDist));
            coefOdd = coefActual(ceil(end/2)+1:end,:);
            coefDiff = coefOdd+fliplr(coefOdd);
            coefDist = norm(coefDiff(:))/sqrt(numel(coefDiff));
            testCase.verifyThat(coefDist,IsLessThan(1e-15),...
                sprintf('%g',coefDist));
            
            % Check orthogonality
            coefDist = norm((coefActual.'*coefActual)-eye(dimExpctd(2)))...
                /sqrt(numel(coefActual));
            testCase.verifyTrue(coefDist<1e-15,sprintf('%g',coefDist));
            
        end
       
       
        % Test for construction
        function testConstructorWithDec22Ch6Ord00(testCase)
            
            % Parameters
            decch = [ 2 2 6 ];
            ord = [ 0 0 ];
            
            % Expected values
            dimExpctd = [6 4];
            
            % Instantiation of target class
            import saivdr.dictionary.nsolt.*
            testCase.lppufb = OvsdLpPuFb2dTypeIVm1System(...
                'DecimationFactor',decch(1:2),...
                'NumberOfChannels',decch(3:end),...
                'PolyPhaseOrder',ord);
            
            % Actual values
            coefActual = step(testCase.lppufb,[],[]);
            
            
            % Evaluation
            testCase.verifySize(coefActual,dimExpctd);
            
            % Check symmetry
            import matlab.unittest.constraints.IsLessThan
            coefEvn = coefActual(1:ceil(end/2),:);
            coefDiff = coefEvn-fliplr(coefEvn);
            coefDist = norm(coefDiff(:))/sqrt(numel(coefDiff));
            testCase.verifyThat(coefDist,IsLessThan(1e-15),...
                sprintf('%g',coefDist));
            coefOdd = coefActual(ceil(end/2)+1:end,:);
            coefDiff = coefOdd+fliplr(coefOdd);
            coefDist = norm(coefDiff(:))/sqrt(numel(coefDiff));
            testCase.verifyThat(coefDist,IsLessThan(1e-15),...
                sprintf('%g',coefDist));
            
            % Check orthogonality
            coefDist = norm((coefActual.'*coefActual)-eye(dimExpctd(2)))...
                /sqrt(numel(coefActual));
            testCase.verifyTrue(coefDist<1e-15,sprintf('%g',coefDist));
            
        end
        
        % Test for construction
        function testConstructorWithOrd00Ang(testCase)
            
            % Parameters
            dec = [ 2 2 ];
            ord = [ 0 0 ];
            ang = [ 0 0 ];
            
            % Expected values
            coefExpctd(:,:,1,1) = 1/2 * [
                1  1  1  1 ;
                1 -1 -1  1 ;
                -1  1 -1  1 ;
                -1 -1  1  1 ];
            
            % Instantiation of target class
            import saivdr.dictionary.nsolt.*
            testCase.lppufb = OvsdLpPuFb2dTypeIVm1System(...
                'DecimationFactor',dec,...
                'PolyPhaseOrder',ord);
                            
            % Actual values
            coefActual = step(testCase.lppufb,ang,[]);
            
            % Evaluation
            coefDist = max(abs(coefExpctd(:)-coefActual(:))./...
                (abs(coefExpctd(:))));
            testCase.verifyEqual(coefActual,coefExpctd,'RelTol',1e-15,...
                sprintf('%g',coefDist));
            
        end
        
        % Test for construction
        function testConstructorWithAng0Pi4(testCase)
            
            % Parameters
            dec = [ 2 2 ];
            ord = [ 0 0 ];
            ang = [ 0 pi/4 ];
            
            % Expected values
            import saivdr.dictionary.utility.*
            omgs = OrthonormalMatrixGenerationSystem();
            matrixW0 = step(omgs,ang(1),1);
            matrixU0 = step(omgs,ang(2),1);
            coefExpctd(:,:,1,1) = 1/2 * ...
                blkdiag(matrixW0, matrixU0) * ...
                [   1  1  1  1 ;
                1 -1 -1  1 ;
                -1  1 -1  1 ;
                -1 -1  1  1 ];
            
            % Instantiation of target class
            import saivdr.dictionary.nsolt.*
            testCase.lppufb = OvsdLpPuFb2dTypeIVm1System(...
                'DecimationFactor',dec,...
                'PolyPhaseOrder',ord);
                            
            % Actual values
            coefActual = step(testCase.lppufb,ang,[]);
            
            % Evaluation
            coefDist = max(abs(coefExpctd(:)-coefActual(:)));
            testCase.verifyEqual(coefActual,coefExpctd,'AbsTol',1e-15,...
                sprintf('%g',coefDist));
            
        end

        % Test for construction
        function testConstructorWithDec44Ord00Ang(testCase)
            
            % Parameters
            dec = [ 4 4 ];
            ord = [ 0 0 ];
            ang = 2*pi*rand(28,2);
            
            % Expected values
            dimExpctd = [16 16];
            
            % Instantiation of target class
            import saivdr.dictionary.nsolt.*
            testCase.lppufb = OvsdLpPuFb2dTypeIVm1System(...
                'DecimationFactor',dec,...
                'PolyPhaseOrder',ord);
                            
            % Actual values
            coefActual = step(testCase.lppufb,ang,[]);
            
            % Evaluation
            testCase.verifySize(coefActual,dimExpctd);
            
            % Check symmetry
            import matlab.unittest.constraints.IsLessThan
            coefEvn = coefActual(1:ceil(end/2),:);
            coefDiff = coefEvn-fliplr(coefEvn);
            coefDist = norm(coefDiff(:))/sqrt(numel(coefDiff));
            testCase.verifyThat(coefDist,IsLessThan(1e-15),...
                sprintf('%g',coefDist));
            coefOdd = coefActual(ceil(end/2)+1:end,:);
            coefDiff = coefOdd+fliplr(coefOdd);
            coefDist = norm(coefDiff(:))/sqrt(numel(coefDiff));
            testCase.verifyThat(coefDist,IsLessThan(1e-15),...
                sprintf('%g',coefDist));
            
            % Check orthogonality
            import matlab.unittest.constraints.IsLessThan
            coefDist = norm((coefActual.'*coefActual)-eye(dimExpctd))...
                /sqrt(numel(coefActual));
            testCase.verifyThat(coefDist,IsLessThan(1e-15),...
                sprintf('%g',coefDist));
            
        end

        % Test for construction
        function testConstructorWithDec22Ch8Ord00Ang(testCase)
            
            % Parameters
            decch = [ 2 2 8 ];
            ord = [ 0 0 ];
            ang = 2*pi*rand(6,2);
            
            % Expected values
            dimExpctd = [8 4];
            
            % Instantiation of target class
            import saivdr.dictionary.nsolt.*
            testCase.lppufb = OvsdLpPuFb2dTypeIVm1System(...
                'DecimationFactor',decch(1:2),...
                'NumberOfChannels',decch(3:end),...
                'PolyPhaseOrder',ord);
                            
            % Actual values
            coefActual = step(testCase.lppufb,ang,[]);
            
            % Evaluation
            testCase.verifySize(coefActual,dimExpctd);
            
            % Check symmetry
            import matlab.unittest.constraints.IsLessThan
            coefEvn = coefActual(1:ceil(end/2),:);
            coefDiff = coefEvn-fliplr(coefEvn);
            coefDist = norm(coefDiff(:))/sqrt(numel(coefDiff));
            testCase.verifyThat(coefDist,IsLessThan(1e-15),...
                sprintf('%g',coefDist));
            coefOdd = coefActual(ceil(end/2)+1:end,:);
            coefDiff = coefOdd+fliplr(coefOdd);
            coefDist = norm(coefDiff(:))/sqrt(numel(coefDiff));
            testCase.verifyThat(coefDist,IsLessThan(1e-15),...
                sprintf('%g',coefDist));
            
            % Check orthogonality
            import matlab.unittest.constraints.IsLessThan
            coefDist = norm((coefActual.'*coefActual)-eye(dimExpctd(2)))...
                /sqrt(numel(coefActual));
            testCase.verifyThat(coefDist,IsLessThan(1e-15),...
                sprintf('%g',coefDist));
            
        end
        
        % Test for construction
        function testConstructorWithDec22Ch6Ord00Ang(testCase)
            
            % Parameters
            decch = [ 2 2 6 ];
            ord = [ 0 0 ];
            ang = 2*pi*rand(3,2);
            
            % Expected values
            dimExpctd = [6 4];
            
            % Instantiation of target class
            import saivdr.dictionary.nsolt.*
            testCase.lppufb = OvsdLpPuFb2dTypeIVm1System(...
                'DecimationFactor',decch(1:2),...
                'NumberOfChannels',decch(3:end),...
                'PolyPhaseOrder',ord);
                            
            % Actual values
            coefActual = step(testCase.lppufb,ang,[]);
            
            % Evaluation
            testCase.verifySize(coefActual,dimExpctd);
            
            % Check symmetry
            import matlab.unittest.constraints.IsLessThan
            coefEvn = coefActual(1:ceil(end/2),:);
            coefDiff = coefEvn-fliplr(coefEvn);
            coefDist = norm(coefDiff(:))/sqrt(numel(coefDiff));
            testCase.verifyThat(coefDist,IsLessThan(1e-15),...
                sprintf('%g',coefDist));
            coefOdd = coefActual(ceil(end/2)+1:end,:);
            coefDiff = coefOdd+fliplr(coefOdd);
            coefDist = norm(coefDiff(:))/sqrt(numel(coefDiff));
            testCase.verifyThat(coefDist,IsLessThan(1e-15),...
                sprintf('%g',coefDist));
            
            % Check orthogonality
            import matlab.unittest.constraints.IsLessThan
            coefDist = norm((coefActual.'*coefActual)-eye(dimExpctd(2)))...
                /sqrt(numel(coefActual));
            testCase.verifyThat(coefDist,IsLessThan(1e-15),...
                sprintf('%g',coefDist));
            
        end
        
        % Test for construction
        function testConstructorWithDec11Ch4Ord00(testCase)
            
            % Parameters
            decch = [ 1 1 4 ];
            ord = [ 0 0 ];
            
           % Expected values
            coefExpctd(:,:,1,1) = [...
                1;
                0;
                0;
                0];
                    
             % Instantiation of target class
             import saivdr.dictionary.nsolt.*
            testCase.lppufb = OvsdLpPuFb2dTypeIVm1System(...
                'DecimationFactor',decch(1:2),...
                'NumberOfChannels',decch(3:end),...
                'PolyPhaseOrder',ord);
            
            % Actual values
            coefActual = step(testCase.lppufb,[],[]);
            
            % Evaluation
            coefDist = max(abs(coefExpctd(:)-coefActual(:))...
                ./(abs(coefExpctd(:))));
            testCase.verifyEqual(coefActual,coefExpctd,'RelTol',1e-15,...
                sprintf('%g',coefDist));
            
        end
        
        % Test for construction
        function testConstructorWithDec11Ch4Ord00Ang(testCase)
            
            % Parameters
            decch = [ 1 1 4 ];
            ord = [ 0 0 ];
            ang = [ 0 0 ];
            
            % Expected values
            coefExpctd(:,:,1,1) = [
                1 ;
                0 ;
                0 ;
                0 ];
            
            % Instantiation of target class
            import saivdr.dictionary.nsolt.*
            testCase.lppufb = OvsdLpPuFb2dTypeIVm1System(...
                'DecimationFactor',decch(1:2),...
                'NumberOfChannels',decch(3:end),...
                'PolyPhaseOrder',ord);
                            
            % Actual values
            coefActual = step(testCase.lppufb,ang,[]);
            
            % Evaluation
            coefDist = max(abs(coefExpctd(:)-coefActual(:))...
                ./(abs(coefExpctd(:))));
            testCase.verifyEqual(coefActual,coefExpctd,'RelTol',1e-15,...
                sprintf('%g',coefDist));
            
        end
          
         % Test for construction
        function testConstructorWithDec11Ch4Ord00Ang0Pi4(testCase)
            
            % Parameters
            decch = [ 1 1 4 ];
            ord = [ 0 0 ];
            ang = [ 0 pi/4 ];
            
            % Expected values
            import saivdr.dictionary.utility.*
            omgs = OrthonormalMatrixGenerationSystem();
            matrixW0 = step(omgs,ang(1),1);
            matrixU0 = step(omgs,ang(2),1);
            coefExpctd(:,:,1,1) = ...
                blkdiag(matrixW0, matrixU0) * ...
                [ 1 0 0 0 ].';
            
            % Instantiation of target class
            import saivdr.dictionary.nsolt.*
            testCase.lppufb = OvsdLpPuFb2dTypeIVm1System(...
                'DecimationFactor',decch(1:2),...
                'NumberOfChannels',decch(3:end),...
                'PolyPhaseOrder',ord);
                            
            % Actual values
            coefActual = step(testCase.lppufb,ang,[]);
            
            % Evaluation
            coefDist = max(abs(coefExpctd(:)-coefActual(:))...
                ./(abs(coefActual(:))));
            testCase.verifyEqual(coefActual,coefExpctd,'RelTol',1e-15,...
                sprintf('%g',coefDist));
            
        end
        
        function testConstructorWithInvalidArguments(testCase)
            
            % Invalid input
            dec = [ 4 4 ];
            ord = [ 0 0 ];
            sizeInvalid = [2 2];
            ang = 2*pi*rand(sizeInvalid);
            
            % Expected value
            sizeExpctd = [28 2];
            
            % Expected values
            exceptionIdExpctd = 'SaivDr:IllegalArgumentException';
            messageExpctd = ...
                sprintf('Size of angles must be [ %d %d ]',...
                sizeExpctd(1), sizeExpctd(2));
            
            % Instantiation of target class
            try
                import saivdr.dictionary.nsolt.*
                testCase.lppufb = OvsdLpPuFb2dTypeIVm1System(...
                    'DecimationFactor',dec,...
                    'PolyPhaseOrder',ord);
                step(testCase.lppufb,ang,[]);
                testCase.verifyFail(sprintf('%s must be thrown.',...
                    exceptionIdExpctd));
            catch me
                exceptionIdActual = me.identifier;
                testCase.verifyEqual(exceptionIdActual,exceptionIdExpctd);
                messageActual = me.message;
                testCase.verifyEqual(messageActual, messageExpctd);
            end
        end
        
        function testConstructorWithOddChannels(testCase)
            
            % Invalid input
            decch = [ 4 4 5 ];
            ord = [ 0 0 ];
            
            % Expected values
            exceptionIdExpctd = 'SaivDr:IllegalArgumentException';
            messageExpctd = '#Channels must be even.';
            
            % Instantiation of target class
            try
                import saivdr.dictionary.nsolt.*
                OvsdLpPuFb2dTypeIVm1System(...
                    'DecimationFactor',decch(1:2),...
                    'NumberOfChannels',decch(3:end),...
                    'PolyPhaseOrder',ord);
                testCase.verifyFail(sprintf('%s must be thrown.',...
                    exceptionIdExpctd));
            catch me
                exceptionIdActual = me.identifier;
                testCase.verifyEqual(exceptionIdActual, exceptionIdExpctd);
                messageActual = me.message;
                testCase.verifyEqual(messageActual, messageExpctd);
            end
        end

        function testConstructorWithUnEqualNsNa(testCase)
            
            % Invalid input
            decch = [ 4 4 7 9 ];
            ord = [ 0 0 ];
            
            % Expected values
            exceptionIdExpctd = 'SaivDr:IllegalArgumentException';
            messageExpctd = 'ps and pa must be the same as each other.';
            
            % Instantiation of target class
            try
                import saivdr.dictionary.nsolt.*
                OvsdLpPuFb2dTypeIVm1System(...
                    'DecimationFactor',decch(1:2),...
                    'NumberOfChannels',decch(3:end),...
                    'PolyPhaseOrder',ord);
                testCase.verifyFail(sprintf('%s must be thrown.',...
                    exceptionIdExpctd));
            catch me
                exceptionIdActual = me.identifier;
                testCase.verifyEqual(exceptionIdActual, exceptionIdExpctd);
                messageActual = me.message;
                testCase.verifyEqual(messageActual, messageExpctd);
            end
        end

        % Test for construction
        function testConstructorWithMusPosNeg(testCase)
            
            % Parameters
            dec = [ 2 2 ];
            ord = [ 0 0 ];
            ang = [ 0 0 ];
            mus = [ 1 1 ; -1 -1 ];
            
            % Expected values
            coefExpctd(:,:,1,1) = 1/2 * [
                1  1  1  1 ;
                -1  1  1 -1 ;
                -1  1 -1  1 ;
                1  1 -1 -1 ];
            
            % Instantiation of target class
            import saivdr.dictionary.nsolt.*
            testCase.lppufb = OvsdLpPuFb2dTypeIVm1System(...
                'DecimationFactor',dec,...
                'PolyPhaseOrder',ord);
            
            % Actual values
            coefActual = step(testCase.lppufb,ang,mus);
            
            % Evaluation
            coefDist = max(abs(coefExpctd(:)-coefActual(:))...
                ./(abs(coefExpctd(:))));
            testCase.verifyEqual(coefActual,coefExpctd,'RelTol',1e-15,...
                sprintf('%g',coefDist));
            
        end
        
        % Test for construction with order 0 1
        function testConstructorWithOrd01(testCase)
            
            % Parameters
            dec = [ 2 2 ];
            ord = [ 0 1 ];
            ang = 0;
            
            % Expected values
            coefExpctd(:,:,1,1) = [
                0         0    0.5000    0.5000
                0         0   -0.5000    0.5000
                0         0   -0.5000    0.5000
                0         0    0.5000    0.5000 ];
            coefExpctd(:,:,1,2) = [
                0.5000    0.5000         0         0
                0.5000   -0.5000         0         0
                -0.5000    0.5000         0         0
                -0.5000   -0.5000         0         0 ];
            
            % Instantiation of target class
            import saivdr.dictionary.nsolt.*
            testCase.lppufb = OvsdLpPuFb2dTypeIVm1System(...
                'DecimationFactor',dec,...
                'PolyPhaseOrder',ord);
                
            % Actual values
            coefActual = step(testCase.lppufb,ang,[]);
            
            % Evaluation
            testCase.verifySize(coefActual,size(coefExpctd));            
            coefDist = max(abs(coefExpctd(:)-coefActual(:)));
            testCase.verifyEqual(coefActual,coefExpctd,'AbsTol',1e-15,...
                sprintf('%g',coefDist));
        end

        % Test for construction with order 1 0
        function testConstructorWithOrd10(testCase)
            
            % Parameters
            dec = [ 2 2 ];
            ord = [ 1 0 ];
            ang = 0;
            
            % Expected values
            coefExpctd(:,:,1) = [
                0    0.5000         0    0.5000
                0   -0.5000         0    0.5000
                0    0.5000         0    0.5000
                0   -0.5000         0    0.5000 ];
            coefExpctd(:,:,2) = [
                0.5000         0    0.5000         0
                0.5000         0   -0.5000         0
                -0.5000         0   -0.5000         0
                -0.5000         0    0.5000         0 ];
            
            % Instantiation of target class
            import saivdr.dictionary.nsolt.*
            testCase.lppufb = OvsdLpPuFb2dTypeIVm1System(...
                'DecimationFactor',dec,...
                'PolyPhaseOrder',ord);
                            
            % Actual values
            coefActual = step(testCase.lppufb,ang,[]);
            
            % Evaluation
            coefDist = max(abs(coefExpctd(:)-coefActual(:)));
            testCase.verifyEqual(coefActual,coefExpctd,'AbsTol',1e-15,...
                sprintf('%g',coefDist));
            
        end

        % Test for construction with order 1 1
        function testConstructorWithOrd11(testCase)
            
            % Parameters
            dec = [ 2 2 ];
            ord = [ 1 1 ];
            ang = 0;
            
            % Expected values
            coefExpctd(:,:,1,1) = [
                0         0         0    0.5000
                0         0         0    0.5000
                0         0         0    0.5000
                0         0         0    0.5000 ];
            coefExpctd(:,:,2,1) = [
                0         0    0.5000         0
                0         0   -0.5000         0
                0         0   -0.5000         0
                0         0    0.5000         0 ];
            coefExpctd(:,:,1,2) = [
                0    0.5000         0         0
                0   -0.5000         0         0
                0    0.5000         0         0
                0   -0.5000         0         0 ];
            coefExpctd(:,:,2,2) = [
                0.5000         0         0         0
                0.5000         0         0         0
                -0.5000         0         0         0
                -0.5000         0         0         0 ];
            
            % Instantiation of target class
            import saivdr.dictionary.nsolt.*
            testCase.lppufb = OvsdLpPuFb2dTypeIVm1System(...
                'DecimationFactor',dec,...
                'PolyPhaseOrder',ord);
                            
            % Actual values
            coefActual = step(testCase.lppufb,ang,[]);
            
            % Evaluation
            coefDist = max(abs(coefExpctd(:)-coefActual(:)));
            testCase.verifyEqual(coefActual,coefExpctd,'AbsTol',1e-15,...
                sprintf('%g',coefDist));            
        end
        
        % Test for construction with order 2 2
        function testConstructorWithOrd22(testCase)
            
            % Parameters
            dec = [ 2 2 ];
            ord = [ 2 2 ];
            ang = 0;
            
            % Expected values
            coefExpctd(:,:,1,1) = [
                0     0     0     0
                0     0     0     0
                0     0     0     0
                0     0     0     0 ];
            coefExpctd(:,:,2,1) = [
                0     0     0     0
                0     0     0     0
                0     0     0     0
                0     0     0     0 ];
            coefExpctd(:,:,3,1) = [
                0     0     0     0
                0     0     0     0
                0     0     0     0
                0     0     0     0 ];
            coefExpctd(:,:,1,2) = [
                0     0     0     0
                0     0     0     0
                0     0     0     0
                0     0     0     0 ];
            coefExpctd(:,:,2,2) = [
                0.5000    0.5000    0.5000    0.5000
                0.5000   -0.5000   -0.5000    0.5000
                -0.5000    0.5000   -0.5000    0.5000
                -0.5000   -0.5000    0.5000    0.5000 ];
            coefExpctd(:,:,3,2) = [
                0     0     0     0
                0     0     0     0
                0     0     0     0
                0     0     0     0 ];
            coefExpctd(:,:,1,3) = [
                0     0     0     0
                0     0     0     0
                0     0     0     0
                0     0     0     0 ];
            coefExpctd(:,:,2,3) = [
                0     0     0     0
                0     0     0     0
                0     0     0     0
                0     0     0     0 ];
            coefExpctd(:,:,3,3) = [
                0     0     0     0
                0     0     0     0
                0     0     0     0
                0     0     0     0 ];
            
            % Instantiation of target class
            import saivdr.dictionary.nsolt.*
            testCase.lppufb = OvsdLpPuFb2dTypeIVm1System(...
                'DecimationFactor',dec,...
                'PolyPhaseOrder',ord);
                            
            % Actual values
            coefActual = step(testCase.lppufb,ang,[]);
            
            % Evaluation
            coefDist = max(abs(coefExpctd(:)-coefActual(:))...
                ./(abs(coefActual(:))));
            testCase.verifyEqual(coefActual,coefExpctd,'RelTol',1e-15,...
                sprintf('%g',coefDist));                        
        end

        % Test for construction with order 3 3
        function testConstructorWithOrd33(testCase)
            
            % Parameters
            dec = [ 2 2 ];
            ord = [ 3 3 ];
            ang = 0;
            
            % Expected values
            coefExpctd(:,:,1,1) = [
                0     0     0     0
                0     0     0     0
                0     0     0     0
                0     0     0     0 ];
            coefExpctd(:,:,2,1) = [
                0     0     0     0
                0     0     0     0
                0     0     0     0
                0     0     0     0 ];
            coefExpctd(:,:,3,1) = [
                0     0     0     0
                0     0     0     0
                0     0     0     0
                0     0     0     0 ];
            coefExpctd(:,:,4,1) = [
                0     0     0     0
                0     0     0     0
                0     0     0     0
                0     0     0     0 ];
            coefExpctd(:,:,1,2) = [
                0     0     0     0
                0     0     0     0
                0     0     0     0
                0     0     0     0 ];
            coefExpctd(:,:,2,2) = [
                0         0         0    0.5000
                0         0         0    0.5000
                0         0         0    0.5000
                0         0         0    0.5000 ];
            coefExpctd(:,:,3,2) = [
                0         0    0.5000         0
                0         0   -0.5000         0
                0         0   -0.5000         0
                0         0    0.5000         0 ];
            coefExpctd(:,:,4,2) = [
                0     0     0     0
                0     0     0     0
                0     0     0     0
                0     0     0     0 ];
            coefExpctd(:,:,1,3) = [
                0     0     0     0
                0     0     0     0
                0     0     0     0
                0     0     0     0 ];
            coefExpctd(:,:,2,3) = [
                0    0.5000         0         0
                0   -0.5000         0         0
                0    0.5000         0         0
                0   -0.5000         0         0 ];
            coefExpctd(:,:,3,3) = [
                0.5000         0         0         0
                0.5000         0         0         0
                -0.5000         0         0         0
                -0.5000         0         0         0 ];
            coefExpctd(:,:,4,3) = [
                0     0     0     0
                0     0     0     0
                0     0     0     0
                0     0     0     0 ];
            coefExpctd(:,:,1,4) = [
                0     0     0     0
                0     0     0     0
                0     0     0     0
                0     0     0     0 ];
            coefExpctd(:,:,2,4) = [
                0     0     0     0
                0     0     0     0
                0     0     0     0
                0     0     0     0 ];
            coefExpctd(:,:,3,4) = [
                0     0     0     0
                0     0     0     0
                0     0     0     0
                0     0     0     0 ];
            coefExpctd(:,:,4,4) = [
                0     0     0     0
                0     0     0     0
                0     0     0     0
                0     0     0     0 ];
            
            % Instantiation of target class
            import saivdr.dictionary.nsolt.*
            testCase.lppufb = OvsdLpPuFb2dTypeIVm1System(...
                'DecimationFactor',dec,...
                'PolyPhaseOrder',ord);
                            
            % Actual values
            coefActual = step(testCase.lppufb,ang,[]);
            
            % Evaluation
            coefDist = max(abs(coefExpctd(:)-coefActual(:)));
            testCase.verifyEqual(coefActual,coefExpctd,'AbsTol',1e-15,....
                sprintf('%g',coefDist));
            
        end

        % Test for construction with order 4 4
        function testConstructorWithOrd44(testCase)
            
            % Parameters
            dec = [ 2 2 ];
            ord = [ 4 4 ];
            ang = 2*pi*rand(1,10);
            
            % Expected values
            nDecs = prod(dec);
            dimExpctd = [nDecs nDecs ord(1)+1 ord(2)+1];
            
            % Instantiation of target class
            import saivdr.dictionary.nsolt.*
            testCase.lppufb = OvsdLpPuFb2dTypeIVm1System(...
                'DecimationFactor',dec,...
                'PolyPhaseOrder',ord);
                            
            % Actual values
            coefActual = step(testCase.lppufb,ang,[]);
            
            % Evaluation
            testCase.verifySize(coefActual,dimExpctd);
            
            % Check symmetry
            import matlab.unittest.constraints.IsLessThan
            coefEvn = coefActual(1:ceil(end/2),:);
            coefDiff = coefEvn-fliplr(coefEvn);
            coefDist = norm(coefDiff(:))/sqrt(numel(coefDiff));
            testCase.verifyThat(coefDist,IsLessThan(1e-15),...
                sprintf('%g',coefDist));
            coefOdd = coefActual(ceil(end/2)+1:end,:);
            coefDiff = coefOdd+fliplr(coefOdd);
            coefDist = norm(coefDiff(:))/sqrt(numel(coefDiff));
            testCase.verifyThat(coefDist,IsLessThan(1e-15),...
                sprintf('%g',coefDist));
            
            % Check orthogonality
            coefE = step(testCase.lppufb,[],[]); 
            E = saivdr.dictionary.utility.PolyPhaseMatrix2d(coefE);
            coefActual = double(E.'*E);
            coefActual(1:nDecs,1:nDecs,ord(1)+1,ord(2)+1) = ...
                coefActual(1:nDecs,1:nDecs,ord(1)+1,ord(2)+1) - eye(nDecs);
            coefDist = norm(coefActual(:))/sqrt(numel(coefActual));
            testCase.verifyTrue(coefDist<1e-15,sprintf('%g',coefDist));
            
        end

        % Test for construction with order 5 5
        function testConstructorWithOrd55(testCase)
            
            % Parameters
            dec = [ 2 2 ];
            ord = [ 5 5 ];
            ang = 2*pi*rand(1,12);
            
            % Expected values
            nDecs = prod(dec);
            dimExpctd = [nDecs nDecs ord(1)+1 ord(2)+1];
            
            % Instantiation of target class
            import saivdr.dictionary.nsolt.*
            testCase.lppufb = OvsdLpPuFb2dTypeIVm1System(...
                'DecimationFactor',dec,...
                'PolyPhaseOrder',ord);
                            
            % Actual values
            coefActual = step(testCase.lppufb,ang,[]);
            
            % Evaluation
            testCase.verifySize(coefActual,dimExpctd);
            
            % Check symmetry
            import matlab.unittest.constraints.IsLessThan
            coefEvn = coefActual(1:ceil(end/2),:);
            coefDiff = coefEvn-fliplr(coefEvn);
            coefDist = norm(coefDiff(:))/sqrt(numel(coefDiff));
            testCase.verifyThat(coefDist,IsLessThan(1e-15),...
                sprintf('%g',coefDist));
            coefOdd = coefActual(ceil(end/2)+1:end,:);
            coefDiff = coefOdd+fliplr(coefOdd);
            coefDist = norm(coefDiff(:))/sqrt(numel(coefDiff));
            testCase.verifyThat(coefDist,IsLessThan(1e-15),...
                sprintf('%g',coefDist));
            
            % Check orthogonality
            coefE = step(testCase.lppufb,[],[]); 
            E = saivdr.dictionary.utility.PolyPhaseMatrix2d(coefE);
            coefActual = double(E.'*E);
            coefActual(1:nDecs,1:nDecs,ord(1)+1,ord(2)+1) = ...
                coefActual(1:nDecs,1:nDecs,ord(1)+1,ord(2)+1) - eye(nDecs);
            coefDist = norm(coefActual(:))/sqrt(numel(coefActual));
            testCase.verifyTrue(coefDist<1e-15,sprintf('%g',coefDist));
            
        end

        % Test for construction with order 0 1
        function testConstructorWithDec44Ord01(testCase)
            
            % Parameters
            dec = [ 4 4 ];
            ord = [ 0 1 ];
            ang = 2*pi*rand(28,3);
            
            % Expected values
            nDecs = prod(dec);
            dimExpctd = [nDecs nDecs ord(1)+1 ord(2)+1];
            
            % Instantiation of target class
            import saivdr.dictionary.nsolt.*
            testCase.lppufb = OvsdLpPuFb2dTypeIVm1System(...
                'DecimationFactor',dec,...
                'PolyPhaseOrder',ord);
                            
            % Actual values
            coefActual = step(testCase.lppufb,ang,[]);
            
            % Evaluation
            testCase.verifySize(coefActual,dimExpctd);
            
            % Check symmetry
            import matlab.unittest.constraints.IsLessThan
            coefEvn = coefActual(1:ceil(end/2),:);
            coefDiff = coefEvn-fliplr(coefEvn);
            coefDist = norm(coefDiff(:))/sqrt(numel(coefDiff));
            testCase.verifyThat(coefDist,IsLessThan(1e-15),...
                sprintf('%g',coefDist));
            coefOdd = coefActual(ceil(end/2)+1:end,:);
            coefDiff = coefOdd+fliplr(coefOdd);
            coefDist = norm(coefDiff(:))/sqrt(numel(coefDiff));
            testCase.verifyThat(coefDist,IsLessThan(1e-15),...
                sprintf('%g',coefDist));
            
            % Check orthogonality
            coefE = step(testCase.lppufb,[],[]); 
            E = saivdr.dictionary.utility.PolyPhaseMatrix2d(coefE);
            coefActual = double(E.'*E);
            coefActual(1:nDecs,1:nDecs,ord(1)+1,ord(2)+1) = ...
                coefActual(1:nDecs,1:nDecs,ord(1)+1,ord(2)+1) - eye(nDecs);
            coefDist = norm(coefActual(:))/sqrt(numel(coefActual));
            testCase.verifyTrue(coefDist<1e-15,sprintf('%g',coefDist));
            
        end

        % Test for construction with order 1 0
        function testConstructorWithDec44Ord10(testCase)
            
            % Parameters
            dec = [ 4 4 ];
            ord = [ 1 0 ];
            ang = 2*pi*rand(28,3);
            
            % Expected values
            nDecs = prod(dec);
            dimExpctd = [nDecs nDecs ord(1)+1];
            
            % Instantiation of target class
            import saivdr.dictionary.nsolt.*
            testCase.lppufb = OvsdLpPuFb2dTypeIVm1System(...
                'DecimationFactor',dec,...
                'PolyPhaseOrder',ord);
                            
            % Actual values
            coefActual = step(testCase.lppufb,ang,[]);
            
            % Evaluation
            testCase.verifySize(coefActual,dimExpctd);
            
            % Check symmetry
            import matlab.unittest.constraints.IsLessThan
            coefEvn = coefActual(1:ceil(end/2),:);
            coefDiff = coefEvn-fliplr(coefEvn);
            coefDist = norm(coefDiff(:))/sqrt(numel(coefDiff));
            testCase.verifyThat(coefDist,IsLessThan(1e-15),...
                sprintf('%g',coefDist));
            coefOdd = coefActual(ceil(end/2)+1:end,:);
            coefDiff = coefOdd+fliplr(coefOdd);
            coefDist = norm(coefDiff(:))/sqrt(numel(coefDiff));
            testCase.verifyThat(coefDist,IsLessThan(1e-15),...
                sprintf('%g',coefDist));
            
            % Check orthogonality
            coefE = step(testCase.lppufb,[],[]); 
            E = saivdr.dictionary.utility.PolyPhaseMatrix2d(coefE);
            coefActual = double(E.'*E);
            coefActual(1:nDecs,1:nDecs,ord(1)+1,ord(2)+1) = ...
                coefActual(1:nDecs,1:nDecs,ord(1)+1,ord(2)+1) - eye(nDecs);
            coefDist = norm(coefActual(:))/sqrt(numel(coefActual));
            testCase.verifyTrue(coefDist<1e-15,sprintf('%g',coefDist));
            
        end

        % Test dec 4 4 order 1 1
        function testConstructorWithDec44Ord11(testCase)
            
            % Parameters
            dec = [ 4 4 ];
            ord = [ 1 1 ];
            ang = 0;
            
            % Expected values
            coefExpctd(:,1:4,1,1) = [
                0.005873803214612  -0.008790767739752  -0.029529602869795  -0.044194173824159
                -0.008790767739752  -0.005873803214612   0.044194173824159  -0.029529602869795
                -0.008790767739752   0.013156313657566   0.044194173824159   0.066141255221477
                0.013156313657566   0.008790767739752  -0.066141255221477   0.044194173824159
                0.005873803214612  -0.008790767739752  -0.029529602869795  -0.044194173824159
                -0.008790767739752  -0.005873803214612   0.044194173824159  -0.029529602869795
                -0.008790767739752   0.013156313657566   0.044194173824159   0.066141255221477
                0.013156313657566   0.008790767739752  -0.066141255221477   0.044194173824159
                0.005873803214612  -0.008790767739752  -0.029529602869795  -0.044194173824159
                -0.008790767739752  -0.005873803214612   0.044194173824159  -0.029529602869795
                -0.008790767739752   0.013156313657566   0.044194173824159   0.066141255221477
                0.013156313657566   0.008790767739752  -0.066141255221477   0.044194173824159
                0.005873803214612  -0.008790767739752  -0.029529602869795  -0.044194173824159
                -0.008790767739752  -0.005873803214612   0.044194173824159  -0.029529602869795
                -0.008790767739752   0.013156313657566   0.044194173824159   0.066141255221477
                0.013156313657566   0.008790767739752  -0.066141255221477   0.044194173824159 ];
            
            coefExpctd(:,5:8,1,1) = [
                -0.008790767739752   0.013156313657566   0.044194173824159   0.066141255221477
                0.013156313657566   0.008790767739752  -0.066141255221477   0.044194173824159
                -0.005873803214612   0.008790767739752   0.029529602869795   0.044194173824159
                0.008790767739752   0.005873803214612  -0.044194173824159   0.029529602869795
                -0.008790767739752   0.013156313657566   0.044194173824159   0.066141255221477
                0.013156313657566   0.008790767739752  -0.066141255221477   0.044194173824159
                -0.005873803214612   0.008790767739752   0.029529602869795   0.044194173824159
                0.008790767739752   0.005873803214612  -0.044194173824159   0.029529602869795
                -0.008790767739752   0.013156313657566   0.044194173824159   0.066141255221477
                0.013156313657566   0.008790767739752  -0.066141255221477   0.044194173824159
                -0.005873803214612   0.008790767739752   0.029529602869795   0.044194173824159
                0.008790767739752   0.005873803214612  -0.044194173824159   0.029529602869795
                -0.008790767739752   0.013156313657566   0.044194173824159   0.066141255221477
                0.013156313657566   0.008790767739752  -0.066141255221477   0.044194173824159
                -0.005873803214612   0.008790767739752   0.029529602869795   0.044194173824159
                0.008790767739752   0.005873803214612  -0.044194173824159   0.029529602869795 ];
            
            coefExpctd(:,9:12,1,1) = [
                -0.029529602869795   0.044194173824159   0.148455338694115   0.222179115388070
                0.044194173824159   0.029529602869795  -0.222179115388070   0.148455338694115
                0.044194173824159  -0.066141255221477  -0.222179115388070  -0.332514544433706
                -0.066141255221477  -0.044194173824159   0.332514544433706  -0.222179115388070
                -0.029529602869795   0.044194173824159   0.148455338694115   0.222179115388070
                0.044194173824159   0.029529602869795  -0.222179115388070   0.148455338694115
                0.044194173824159  -0.066141255221477  -0.222179115388070  -0.332514544433706
                -0.066141255221477  -0.044194173824159   0.332514544433706  -0.222179115388070
                -0.029529602869795   0.044194173824159   0.148455338694115   0.222179115388070
                0.044194173824159   0.029529602869795  -0.222179115388070   0.148455338694115
                0.044194173824159  -0.066141255221477  -0.222179115388070  -0.332514544433706
                -0.066141255221477  -0.044194173824159   0.332514544433706  -0.222179115388070
                -0.029529602869795   0.044194173824159   0.148455338694115   0.222179115388070
                0.044194173824159   0.029529602869795  -0.222179115388070   0.148455338694115
                0.044194173824159  -0.066141255221477  -0.222179115388070  -0.332514544433706
                -0.066141255221477  -0.044194173824159   0.332514544433706  -0.222179115388070 ];
            
            coefExpctd(:,13:16,1,1) = [
                -0.044194173824159   0.066141255221477   0.222179115388070   0.332514544433706
                0.066141255221477   0.044194173824159  -0.332514544433706   0.222179115388070
                -0.029529602869795   0.044194173824159   0.148455338694115   0.222179115388070
                0.044194173824159   0.029529602869795  -0.222179115388070   0.148455338694115
                -0.044194173824159   0.066141255221477   0.222179115388070   0.332514544433706
                0.066141255221477   0.044194173824159  -0.332514544433706   0.222179115388070
                -0.029529602869795   0.044194173824159   0.148455338694115   0.222179115388070
                0.044194173824159   0.029529602869795  -0.222179115388070   0.148455338694115
                -0.044194173824159   0.066141255221477   0.222179115388070   0.332514544433706
                0.066141255221477   0.044194173824159  -0.332514544433706   0.222179115388070
                -0.029529602869795   0.044194173824159   0.148455338694115   0.222179115388070
                0.044194173824159   0.029529602869795  -0.222179115388070   0.148455338694115
                -0.044194173824159   0.066141255221477   0.222179115388070   0.332514544433706
                0.066141255221477   0.044194173824159  -0.332514544433706   0.222179115388070
                -0.029529602869795   0.044194173824159   0.148455338694115   0.222179115388070
                0.044194173824159   0.029529602869795  -0.222179115388070   0.148455338694115 ];
            
            coefExpctd(:,1:4,2,1) = [
                -0.044194173824159  -0.029529602869795  -0.008790767739752   0.005873803214612
                -0.029529602869795   0.044194173824159  -0.005873803214612  -0.008790767739752
                0.066141255221477   0.044194173824159   0.013156313657566  -0.008790767739752
                0.044194173824159  -0.066141255221477   0.008790767739752   0.013156313657566
                0.044194173824159   0.029529602869795   0.008790767739752  -0.005873803214612
                0.029529602869795  -0.044194173824159   0.005873803214612   0.008790767739752
                -0.066141255221477  -0.044194173824159  -0.013156313657566   0.008790767739752
                -0.044194173824159   0.066141255221477  -0.008790767739752  -0.013156313657566
                0.044194173824159   0.029529602869795   0.008790767739752  -0.005873803214612
                0.029529602869795  -0.044194173824159   0.005873803214612   0.008790767739752
                -0.066141255221477  -0.044194173824159  -0.013156313657566   0.008790767739752
                -0.044194173824159   0.066141255221477  -0.008790767739752  -0.013156313657566
                -0.044194173824159  -0.029529602869795  -0.008790767739752   0.005873803214612
                -0.029529602869795   0.044194173824159  -0.005873803214612  -0.008790767739752
                0.066141255221477   0.044194173824159   0.013156313657566  -0.008790767739752
                0.044194173824159  -0.066141255221477   0.008790767739752   0.013156313657566 ];
            
            coefExpctd(:,5:8,2,1) = [
                0.066141255221477   0.044194173824159   0.013156313657566  -0.008790767739752
                0.044194173824159  -0.066141255221477   0.008790767739752   0.013156313657566
                0.044194173824159   0.029529602869795   0.008790767739752  -0.005873803214612
                0.029529602869795  -0.044194173824159   0.005873803214612   0.008790767739752
                -0.066141255221477  -0.044194173824159  -0.013156313657566   0.008790767739752
                -0.044194173824159   0.066141255221477  -0.008790767739752  -0.013156313657566
                -0.044194173824159  -0.029529602869795  -0.008790767739752   0.005873803214612
                -0.029529602869795   0.044194173824159  -0.005873803214612  -0.008790767739752
                -0.066141255221477  -0.044194173824159  -0.013156313657566   0.008790767739752
                -0.044194173824159   0.066141255221477  -0.008790767739752  -0.013156313657566
                -0.044194173824159  -0.029529602869795  -0.008790767739752   0.005873803214612
                -0.029529602869795   0.044194173824159  -0.005873803214612  -0.008790767739752
                0.066141255221477   0.044194173824159   0.013156313657566  -0.008790767739752
                0.044194173824159  -0.066141255221477   0.008790767739752   0.013156313657566
                0.044194173824159   0.029529602869795   0.008790767739752  -0.005873803214612
                0.029529602869795  -0.044194173824159   0.005873803214612   0.008790767739752 ];
            
            coefExpctd(:,9:12,2,1) = [
                0.222179115388070   0.148455338694115   0.044194173824159  -0.029529602869795
                0.148455338694115  -0.222179115388070   0.029529602869795   0.044194173824159
                -0.332514544433706  -0.222179115388070  -0.066141255221477   0.044194173824159
                -0.222179115388070   0.332514544433706  -0.044194173824159  -0.066141255221477
                -0.222179115388070  -0.148455338694115  -0.044194173824159   0.029529602869795
                -0.148455338694115   0.222179115388070  -0.029529602869795  -0.044194173824159
                0.332514544433706   0.222179115388070   0.066141255221477  -0.044194173824159
                0.222179115388070  -0.332514544433706   0.044194173824159   0.066141255221477
                -0.222179115388070  -0.148455338694115  -0.044194173824159   0.029529602869795
                -0.148455338694115   0.222179115388070  -0.029529602869795  -0.044194173824159
                0.332514544433706   0.222179115388070   0.066141255221477  -0.044194173824159
                0.222179115388070  -0.332514544433706   0.044194173824159   0.066141255221477
                0.222179115388070   0.148455338694115   0.044194173824159  -0.029529602869795
                0.148455338694115  -0.222179115388070   0.029529602869795   0.044194173824159
                -0.332514544433706  -0.222179115388070  -0.066141255221477   0.044194173824159
                -0.222179115388070   0.332514544433706  -0.044194173824159  -0.066141255221477 ];
            
            coefExpctd(:,13:16,2,1) = [
                0.332514544433706   0.222179115388070   0.066141255221477  -0.044194173824159
                0.222179115388070  -0.332514544433706   0.044194173824159   0.066141255221477
                0.222179115388070   0.148455338694115   0.044194173824159  -0.029529602869795
                0.148455338694115  -0.222179115388070   0.029529602869795   0.044194173824159
                -0.332514544433706  -0.222179115388070  -0.066141255221477   0.044194173824159
                -0.222179115388070   0.332514544433706  -0.044194173824159  -0.066141255221477
                -0.222179115388070  -0.148455338694115  -0.044194173824159   0.029529602869795
                -0.148455338694115   0.222179115388070  -0.029529602869795  -0.044194173824159
                -0.332514544433706  -0.222179115388070  -0.066141255221477   0.044194173824159
                -0.222179115388070   0.332514544433706  -0.044194173824159  -0.066141255221477
                -0.222179115388070  -0.148455338694115  -0.044194173824159   0.029529602869795
                -0.148455338694115   0.222179115388070  -0.029529602869795  -0.044194173824159
                0.332514544433706   0.222179115388070   0.066141255221477  -0.044194173824159
                0.222179115388070  -0.332514544433706   0.044194173824159   0.066141255221477
                0.222179115388070   0.148455338694115   0.044194173824159  -0.029529602869795
                0.148455338694115  -0.222179115388070   0.029529602869795   0.044194173824159 ];
            
            coefExpctd(:,1:4,1,2) = [
                -0.044194173824159   0.066141255221477   0.222179115388070   0.332514544433706
                0.066141255221477   0.044194173824159  -0.332514544433706   0.222179115388070
                -0.029529602869795   0.044194173824159   0.148455338694115   0.222179115388070
                0.044194173824159   0.029529602869795  -0.222179115388070   0.148455338694115
                0.044194173824159  -0.066141255221477  -0.222179115388070  -0.332514544433706
                -0.066141255221477  -0.044194173824159   0.332514544433706  -0.222179115388070
                0.029529602869795  -0.044194173824159  -0.148455338694115  -0.222179115388070
                -0.044194173824159  -0.029529602869795   0.222179115388070  -0.148455338694115
                -0.044194173824159   0.066141255221477   0.222179115388070   0.332514544433706
                0.066141255221477   0.044194173824159  -0.332514544433706   0.222179115388070
                -0.029529602869795   0.044194173824159   0.148455338694115   0.222179115388070
                0.044194173824159   0.029529602869795  -0.222179115388070   0.148455338694115
                0.044194173824159  -0.066141255221477  -0.222179115388070  -0.332514544433706
                -0.066141255221477  -0.044194173824159   0.332514544433706  -0.222179115388070
                0.029529602869795  -0.044194173824159  -0.148455338694115  -0.222179115388070
                -0.044194173824159  -0.029529602869795   0.222179115388070  -0.148455338694115 ];
            
            coefExpctd(:,5:8,1,2) = [
                -0.029529602869795   0.044194173824159   0.148455338694115   0.222179115388070
                0.044194173824159   0.029529602869795  -0.222179115388070   0.148455338694115
                0.044194173824159  -0.066141255221477  -0.222179115388070  -0.332514544433706
                -0.066141255221477  -0.044194173824159   0.332514544433706  -0.222179115388070
                0.029529602869795  -0.044194173824159  -0.148455338694115  -0.222179115388070
                -0.044194173824159  -0.029529602869795   0.222179115388070  -0.148455338694115
                -0.044194173824159   0.066141255221477   0.222179115388070   0.332514544433706
                0.066141255221477   0.044194173824159  -0.332514544433706   0.222179115388070
                -0.029529602869795   0.044194173824159   0.148455338694115   0.222179115388070
                0.044194173824159   0.029529602869795  -0.222179115388070   0.148455338694115
                0.044194173824159  -0.066141255221477  -0.222179115388070  -0.332514544433706
                -0.066141255221477  -0.044194173824159   0.332514544433706  -0.222179115388070
                0.029529602869795  -0.044194173824159  -0.148455338694115  -0.222179115388070
                -0.044194173824159  -0.029529602869795   0.222179115388070  -0.148455338694115
                -0.044194173824159   0.066141255221477   0.222179115388070   0.332514544433706
                0.066141255221477   0.044194173824159  -0.332514544433706   0.222179115388070 ];
            
            coefExpctd(:,9:12,1,2) = [
                -0.008790767739752   0.013156313657566   0.044194173824159   0.066141255221477
                0.013156313657566   0.008790767739752  -0.066141255221477   0.044194173824159
                -0.005873803214612   0.008790767739752   0.029529602869795   0.044194173824159
                0.008790767739752   0.005873803214612  -0.044194173824159   0.029529602869795
                0.008790767739752  -0.013156313657566  -0.044194173824159  -0.066141255221477
                -0.013156313657566  -0.008790767739752   0.066141255221477  -0.044194173824159
                0.005873803214612  -0.008790767739752  -0.029529602869795  -0.044194173824159
                -0.008790767739752  -0.005873803214612   0.044194173824159  -0.029529602869795
                -0.008790767739752   0.013156313657566   0.044194173824159   0.066141255221477
                0.013156313657566   0.008790767739752  -0.066141255221477   0.044194173824159
                -0.005873803214612   0.008790767739752   0.029529602869795   0.044194173824159
                0.008790767739752   0.005873803214612  -0.044194173824159   0.029529602869795
                0.008790767739752  -0.013156313657566  -0.044194173824159  -0.066141255221477
                -0.013156313657566  -0.008790767739752   0.066141255221477  -0.044194173824159
                0.005873803214612  -0.008790767739752  -0.029529602869795  -0.044194173824159
                -0.008790767739752  -0.005873803214612   0.044194173824159  -0.029529602869795 ];
            
            coefExpctd(:,13:16,1,2) = [
                0.005873803214612  -0.008790767739752  -0.029529602869795  -0.044194173824159
                -0.008790767739752  -0.005873803214612   0.044194173824159  -0.029529602869795
                -0.008790767739752   0.013156313657566   0.044194173824159   0.066141255221477
                0.013156313657566   0.008790767739752  -0.066141255221477   0.044194173824159
                -0.005873803214612   0.008790767739752   0.029529602869795   0.044194173824159
                0.008790767739752   0.005873803214612  -0.044194173824159   0.029529602869795
                0.008790767739752  -0.013156313657566  -0.044194173824159  -0.066141255221477
                -0.013156313657566  -0.008790767739752   0.066141255221477  -0.044194173824159
                0.005873803214612  -0.008790767739752  -0.029529602869795  -0.044194173824159
                -0.008790767739752  -0.005873803214612   0.044194173824159  -0.029529602869795
                -0.008790767739752   0.013156313657566   0.044194173824159   0.066141255221477
                0.013156313657566   0.008790767739752  -0.066141255221477   0.044194173824159
                -0.005873803214612   0.008790767739752   0.029529602869795   0.044194173824159
                0.008790767739752   0.005873803214612  -0.044194173824159   0.029529602869795
                0.008790767739752  -0.013156313657566  -0.044194173824159  -0.066141255221477
                -0.013156313657566  -0.008790767739752   0.066141255221477  -0.044194173824159 ];
            
            coefExpctd(:,1:4,2,2) = [
                0.332514544433706   0.222179115388070   0.066141255221477  -0.044194173824159
                0.222179115388070  -0.332514544433706   0.044194173824159   0.066141255221477
                0.222179115388070   0.148455338694115   0.044194173824159  -0.029529602869795
                0.148455338694115  -0.222179115388070   0.029529602869795   0.044194173824159
                0.332514544433706   0.222179115388070   0.066141255221477  -0.044194173824159
                0.222179115388070  -0.332514544433706   0.044194173824159   0.066141255221477
                0.222179115388070   0.148455338694115   0.044194173824159  -0.029529602869795
                0.148455338694115  -0.222179115388070   0.029529602869795   0.044194173824159
                -0.332514544433706  -0.222179115388070  -0.066141255221477   0.044194173824159
                -0.222179115388070   0.332514544433706  -0.044194173824159  -0.066141255221477
                -0.222179115388070  -0.148455338694115  -0.044194173824159   0.029529602869795
                -0.148455338694115   0.222179115388070  -0.029529602869795  -0.044194173824159
                -0.332514544433706  -0.222179115388070  -0.066141255221477   0.044194173824159
                -0.222179115388070   0.332514544433706  -0.044194173824159  -0.066141255221477
                -0.222179115388070  -0.148455338694115  -0.044194173824159   0.029529602869795
                -0.148455338694115   0.222179115388070  -0.029529602869795  -0.044194173824159 ];
            
            coefExpctd(:,5:8,2,2) = [
                0.222179115388070   0.148455338694115   0.044194173824159  -0.029529602869795
                0.148455338694115  -0.222179115388070   0.029529602869795   0.044194173824159
                -0.332514544433706  -0.222179115388070  -0.066141255221477   0.044194173824159
                -0.222179115388070   0.332514544433706  -0.044194173824159  -0.066141255221477
                0.222179115388070   0.148455338694115   0.044194173824159  -0.029529602869795
                0.148455338694115  -0.222179115388070   0.029529602869795   0.044194173824159
                -0.332514544433706  -0.222179115388070  -0.066141255221477   0.044194173824159
                -0.222179115388070   0.332514544433706  -0.044194173824159  -0.066141255221477
                -0.222179115388070  -0.148455338694115  -0.044194173824159   0.029529602869795
                -0.148455338694115   0.222179115388070  -0.029529602869795  -0.044194173824159
                0.332514544433706   0.222179115388070   0.066141255221477  -0.044194173824159
                0.222179115388070  -0.332514544433706   0.044194173824159   0.066141255221477
                -0.222179115388070  -0.148455338694115  -0.044194173824159   0.029529602869795
                -0.148455338694115   0.222179115388070  -0.029529602869795  -0.044194173824159
                0.332514544433706   0.222179115388070   0.066141255221477  -0.044194173824159
                0.222179115388070  -0.332514544433706   0.044194173824159   0.066141255221477 ];
            
            coefExpctd(:,9:12,2,2) = [
                0.066141255221477   0.044194173824159   0.013156313657566  -0.008790767739752
                0.044194173824159  -0.066141255221477   0.008790767739752   0.013156313657566
                0.044194173824159   0.029529602869795   0.008790767739752  -0.005873803214612
                0.029529602869795  -0.044194173824159   0.005873803214612   0.008790767739752
                0.066141255221477   0.044194173824159   0.013156313657566  -0.008790767739752
                0.044194173824159  -0.066141255221477   0.008790767739752   0.013156313657566
                0.044194173824159   0.029529602869795   0.008790767739752  -0.005873803214612
                0.029529602869795  -0.044194173824159   0.005873803214612   0.008790767739752
                -0.066141255221477  -0.044194173824159  -0.013156313657566   0.008790767739752
                -0.044194173824159   0.066141255221477  -0.008790767739752  -0.013156313657566
                -0.044194173824159  -0.029529602869795  -0.008790767739752   0.005873803214612
                -0.029529602869795   0.044194173824159  -0.005873803214612  -0.008790767739752
                -0.066141255221477  -0.044194173824159  -0.013156313657566   0.008790767739752
                -0.044194173824159   0.066141255221477  -0.008790767739752  -0.013156313657566
                -0.044194173824159  -0.029529602869795  -0.008790767739752   0.005873803214612
                -0.029529602869795   0.044194173824159  -0.005873803214612  -0.008790767739752 ];
            
            coefExpctd(:,13:16,2,2) = [
                -0.044194173824159  -0.029529602869795  -0.008790767739752   0.005873803214612
                -0.029529602869795   0.044194173824159  -0.005873803214612  -0.008790767739752
                0.066141255221477   0.044194173824159   0.013156313657566  -0.008790767739752
                0.044194173824159  -0.066141255221477   0.008790767739752   0.013156313657566
                -0.044194173824159  -0.029529602869795  -0.008790767739752   0.005873803214612
                -0.029529602869795   0.044194173824159  -0.005873803214612  -0.008790767739752
                0.066141255221477   0.044194173824159   0.013156313657566  -0.008790767739752
                0.044194173824159  -0.066141255221477   0.008790767739752   0.013156313657566
                0.044194173824159   0.029529602869795   0.008790767739752  -0.005873803214612
                0.029529602869795  -0.044194173824159   0.005873803214612   0.008790767739752
                -0.066141255221477  -0.044194173824159  -0.013156313657566   0.008790767739752
                -0.044194173824159   0.066141255221477  -0.008790767739752  -0.013156313657566
                0.044194173824159   0.029529602869795   0.008790767739752  -0.005873803214612
                0.029529602869795  -0.044194173824159   0.005873803214612   0.008790767739752
                -0.066141255221477  -0.044194173824159  -0.013156313657566   0.008790767739752
                -0.044194173824159   0.066141255221477  -0.008790767739752  -0.013156313657566 ];
            
            % Instantiation of target class
            import saivdr.dictionary.nsolt.*
            testCase.lppufb = OvsdLpPuFb2dTypeIVm1System(...
                'DecimationFactor',dec,...
                'PolyPhaseOrder',ord);
                            
            % Actual values
            coefActual = step(testCase.lppufb,ang,[]);
            
            % Evaluation
            coefDist = max(abs(coefExpctd(:)-coefActual(:))...
                ./(abs(coefActual(:))));
            testCase.verifyEqual(coefActual,coefExpctd,'RelTol',1e-13,...
                sprintf('%g',coefDist));
            
        end
        
        % Test dec 4 4 order 2 2
        function testConstructorWithDec44Ord22(testCase)
            
            % Parameters
            dec = [ 4 4 ];
            ord = [ 2 2 ];
            ang = 0;
            
            % Expected values
            coefExpctd(:,:,1,1) = [
                0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0
                0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0
                0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0
                0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0
                0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0
                0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0
                0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0
                0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0
                0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0
                0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0
                0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0
                0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0
                0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0
                0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0
                0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0
                0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0
                ];
            
            coefExpctd(:,:,2,1) = [
                0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0
                0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0
                0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0
                0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0
                0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0
                0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0
                0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0
                0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0
                0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0
                0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0
                0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0
                0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0
                0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0
                0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0
                0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0
                0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0
                ];
            
            coefExpctd(:,:,3,1) = [
                0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0
                0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0
                0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0
                0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0
                0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0
                0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0
                0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0
                0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0
                0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0
                0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0
                0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0
                0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0
                0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0
                0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0
                0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0
                0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0
                ];
            
            coefExpctd(:,:,1,2) = [
                0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0
                0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0
                0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0
                0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0
                0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0
                0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0
                0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0
                0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0
                0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0
                0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0
                0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0
                0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0
                0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0
                0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0
                0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0
                0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0
                ];
            
            coefExpctd(:,1:4,2,2) = [
                0.250000000000000   0.250000000000000   0.250000000000000   0.250000000000000
                0.250000000000000  -0.250000000000000  -0.250000000000000   0.250000000000000
                0.250000000000000   0.250000000000000   0.250000000000000   0.250000000000000
                0.250000000000000  -0.250000000000000  -0.250000000000000   0.250000000000000
                0.426776695296637   0.176776695296637  -0.176776695296637  -0.426776695296637
                0.176776695296637  -0.426776695296637   0.426776695296637  -0.176776695296637
                0.176776695296637   0.073223304703363  -0.073223304703363  -0.176776695296637
                0.073223304703363  -0.176776695296637   0.176776695296637  -0.073223304703363
                -0.326640741219094  -0.135299025036549   0.135299025036549   0.326640741219094
                -0.135299025036549   0.326640741219094  -0.326640741219094   0.135299025036549
                -0.326640741219094  -0.135299025036549   0.135299025036549   0.326640741219094
                -0.135299025036549   0.326640741219094  -0.326640741219094   0.135299025036549
                -0.326640741219094  -0.326640741219094  -0.326640741219094  -0.326640741219094
                -0.326640741219094   0.326640741219094   0.326640741219094  -0.326640741219094
                -0.135299025036549  -0.135299025036549  -0.135299025036549  -0.135299025036549
                -0.135299025036549   0.135299025036549   0.135299025036549  -0.135299025036549 ];
            
            coefExpctd(:,5:8,2,2) = [
                0.250000000000000   0.250000000000000   0.250000000000000   0.250000000000000
                0.250000000000000  -0.250000000000000  -0.250000000000000   0.250000000000000
                -0.250000000000000  -0.250000000000000  -0.250000000000000  -0.250000000000000
                -0.250000000000000   0.250000000000000   0.250000000000000  -0.250000000000000
                0.176776695296637   0.073223304703363  -0.073223304703363  -0.176776695296637
                0.073223304703363  -0.176776695296637   0.176776695296637  -0.073223304703363
                -0.426776695296637  -0.176776695296637   0.176776695296637   0.426776695296637
                -0.176776695296637   0.426776695296637  -0.426776695296637   0.176776695296637
                -0.326640741219094  -0.135299025036549   0.135299025036549   0.326640741219094
                -0.135299025036549   0.326640741219094  -0.326640741219094   0.135299025036549
                0.326640741219094   0.135299025036549  -0.135299025036549  -0.326640741219094
                0.135299025036549  -0.326640741219094   0.326640741219094  -0.135299025036549
                -0.135299025036549  -0.135299025036549  -0.135299025036549  -0.135299025036549
                -0.135299025036549   0.135299025036549   0.135299025036549  -0.135299025036549
                0.326640741219094   0.326640741219094   0.326640741219094   0.326640741219094
                0.326640741219094  -0.326640741219094  -0.326640741219094   0.326640741219094 ];
            
            coefExpctd(:,9:12,2,2) = [
                0.250000000000000   0.250000000000000   0.250000000000000   0.250000000000000
                0.250000000000000  -0.250000000000000  -0.250000000000000   0.250000000000000
                -0.250000000000000  -0.250000000000000  -0.250000000000000  -0.250000000000000
                -0.250000000000000   0.250000000000000   0.250000000000000  -0.250000000000000
                -0.176776695296637  -0.073223304703363   0.073223304703363   0.176776695296637
                -0.073223304703363   0.176776695296637  -0.176776695296637   0.073223304703363
                0.426776695296637   0.176776695296637  -0.176776695296637  -0.426776695296637
                0.176776695296637  -0.426776695296637   0.426776695296637  -0.176776695296637
                -0.326640741219094  -0.135299025036549   0.135299025036549   0.326640741219094
                -0.135299025036549   0.326640741219094  -0.326640741219094   0.135299025036549
                0.326640741219094   0.135299025036549  -0.135299025036549  -0.326640741219094
                0.135299025036549  -0.326640741219094   0.326640741219094  -0.135299025036549
                0.135299025036549   0.135299025036549   0.135299025036549   0.135299025036549
                0.135299025036549  -0.135299025036549  -0.135299025036549   0.135299025036549
                -0.326640741219094  -0.326640741219094  -0.326640741219094  -0.326640741219094
                -0.326640741219094   0.326640741219094   0.326640741219094  -0.326640741219094 ];
            
            coefExpctd(:,13:16,2,2) = [
                0.250000000000000   0.250000000000000   0.250000000000000   0.250000000000000
                0.250000000000000  -0.250000000000000  -0.250000000000000   0.250000000000000
                0.250000000000000   0.250000000000000   0.250000000000000   0.250000000000000
                0.250000000000000  -0.250000000000000  -0.250000000000000   0.250000000000000
                -0.426776695296637  -0.176776695296637   0.176776695296637   0.426776695296637
                -0.176776695296637   0.426776695296637  -0.426776695296637   0.176776695296637
                -0.176776695296637  -0.073223304703363   0.073223304703363   0.176776695296637
                -0.073223304703363   0.176776695296637  -0.176776695296637   0.073223304703363
                -0.326640741219094  -0.135299025036549   0.135299025036549   0.326640741219094
                -0.135299025036549   0.326640741219094  -0.326640741219094   0.135299025036549
                -0.326640741219094  -0.135299025036549   0.135299025036549   0.326640741219094
                -0.135299025036549   0.326640741219094  -0.326640741219094   0.135299025036549
                0.326640741219094   0.326640741219094   0.326640741219094   0.326640741219094
                0.326640741219094  -0.326640741219094  -0.326640741219094   0.326640741219094
                0.135299025036549   0.135299025036549   0.135299025036549   0.135299025036549
                0.135299025036549  -0.135299025036549  -0.135299025036549   0.135299025036549 ];
            
            
            coefExpctd(:,:,3,2) = [
                0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0
                0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0
                0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0
                0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0
                0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0
                0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0
                0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0
                0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0
                0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0
                0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0
                0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0
                0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0
                0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0
                0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0
                0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0
                0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0
                ];
            
            coefExpctd(:,:,1,3) = [
                0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0
                0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0
                0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0
                0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0
                0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0
                0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0
                0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0
                0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0
                0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0
                0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0
                0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0
                0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0
                0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0
                0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0
                0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0
                0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0
                ];
            
            coefExpctd(:,:,2,3) = [
                0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0
                0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0
                0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0
                0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0
                0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0
                0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0
                0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0
                0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0
                0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0
                0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0
                0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0
                0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0
                0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0
                0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0
                0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0
                0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0
                ];
            
            coefExpctd(:,:,3,3) = [
                0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0
                0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0
                0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0
                0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0
                0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0
                0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0
                0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0
                0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0
                0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0
                0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0
                0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0
                0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0
                0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0
                0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0
                0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0
                0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0
                ];
            
            % Instantiation of target class
            import saivdr.dictionary.nsolt.*
            testCase.lppufb = OvsdLpPuFb2dTypeIVm1System(...
                'DecimationFactor',dec,...
                'PolyPhaseOrder',ord);
                            
            % Actual values
            coefActual = step(testCase.lppufb,ang,[]);
            
            % Evaluation
            coefDist = max(abs(coefExpctd(:)-coefActual(:))...
                ./(abs(coefActual(:))));
            testCase.verifyEqual(coefActual,coefExpctd,'RelTol',1e-14,...
                sprintf('%g',coefDist));
            
        end
        
        % Test dec 4 4 order 1 1
        function testConstructorWithDec44Ord11Ang(testCase)
            
            % Parameters
            dec = [ 4 4 ];
            ord = [ 1 1 ];
            ang = 2*pi*rand(28,4);
            
            % Expected values
            nDecs = prod(dec);
            dimExpctd = [nDecs nDecs ord(1)+1 ord(2)+1];
            
            % Instantiation of target class
            import saivdr.dictionary.nsolt.*
            testCase.lppufb = OvsdLpPuFb2dTypeIVm1System(...
                'DecimationFactor',dec,...
                'PolyPhaseOrder',ord);
                            
            % Actual values
            coefActual = step(testCase.lppufb,ang,[]);
            
            % Evaluation
            testCase.verifySize(coefActual,dimExpctd);
            
            % Check symmetry
            import matlab.unittest.constraints.IsLessThan
            coefEvn = coefActual(1:ceil(end/2),:);
            coefDiff = coefEvn-fliplr(coefEvn);
            coefDist = norm(coefDiff(:))/sqrt(numel(coefDiff));
            testCase.verifyThat(coefDist,IsLessThan(1e-15),...
                sprintf('%g',coefDist));
            coefOdd = coefActual(ceil(end/2)+1:end,:);
            coefDiff = coefOdd+fliplr(coefOdd);
            coefDist = norm(coefDiff(:))/sqrt(numel(coefDiff));
            testCase.verifyThat(coefDist,IsLessThan(1e-15),...
                sprintf('%g',coefDist));
            
            % Check orthogonality
            coefE = step(testCase.lppufb,[],[]); 
            E = saivdr.dictionary.utility.PolyPhaseMatrix2d(coefE);
            coefActual = double(E.'*E);
            coefActual(1:nDecs,1:nDecs,ord(1)+1,ord(2)+1) = ...
                coefActual(1:nDecs,1:nDecs,ord(1)+1,ord(2)+1) - eye(nDecs);
            coefDist = norm(coefActual(:))/sqrt(numel(coefActual));
            testCase.verifyTrue(coefDist<1e-15,sprintf('%g',coefDist));
            
        end

        % Test dec 4 4 order 2 2
        function testConstructorWithDec44Ord22Ang(testCase)
            
            % Parameters
            dec = [ 4 4 ];
            ord = [ 2 2 ];
            ang = 2*pi*rand(28,6);
            
            % Expected values
            nDecs = prod(dec);
            dimExpctd = [nDecs nDecs ord(1)+1 ord(2)+1];
            
            % Instantiation of target class
            import saivdr.dictionary.nsolt.*
            testCase.lppufb = OvsdLpPuFb2dTypeIVm1System(...
                'DecimationFactor',dec,...
                'PolyPhaseOrder',ord);
                            
            % Actual values
            coefActual = step(testCase.lppufb,ang,[]);
            
            % Evaluation
            testCase.verifySize(coefActual,dimExpctd);
            
            % Check symmetry
            import matlab.unittest.constraints.IsLessThan
            coefEvn = coefActual(1:ceil(end/2),:);
            coefDiff = coefEvn-fliplr(coefEvn);
            coefDist = norm(coefDiff(:))/sqrt(numel(coefDiff));
            testCase.verifyThat(coefDist,IsLessThan(1e-15),...
                sprintf('%g',coefDist));
            coefOdd = coefActual(ceil(end/2)+1:end,:);
            coefDiff = coefOdd+fliplr(coefOdd);
            coefDist = norm(coefDiff(:))/sqrt(numel(coefDiff));
            testCase.verifyThat(coefDist,IsLessThan(1e-15),...
                sprintf('%g',coefDist));
            
            % Check orthogonality
            coefE = step(testCase.lppufb,[],[]); 
            E = saivdr.dictionary.utility.PolyPhaseMatrix2d(coefE);
            coefActual = double(E.'*E);
            coefActual(1:nDecs,1:nDecs,ord(1)+1,ord(2)+1) = ...
                coefActual(1:nDecs,1:nDecs,ord(1)+1,ord(2)+1) - eye(nDecs);
            coefDist = norm(coefActual(:))/sqrt(numel(coefActual));
            testCase.verifyTrue(coefDist<1e-15,sprintf('%g',coefDist));
            
        end

        
        % Test dec 4 4 order 3 3
        function testConstructorWithDec44Ord33Ang(testCase)
            
            % Parameters
            dec = [ 4 4 ];
            ord = [ 3 3 ];
            ang = 2*pi*rand(28,8);
            
            % Expected values
            nDecs = prod(dec);
            dimExpctd = [nDecs nDecs ord(1)+1 ord(2)+1];
            
            % Instantiation of target class
            import saivdr.dictionary.nsolt.*
            testCase.lppufb = OvsdLpPuFb2dTypeIVm1System(...
                'DecimationFactor',dec,...
                'PolyPhaseOrder',ord);
                            
            % Actual values
            coefActual = step(testCase.lppufb,ang,[]);
            
            % Evaluation
            testCase.verifySize(coefActual,dimExpctd);
            
            % Check symmetry
            import matlab.unittest.constraints.IsLessThan
            coefEvn = coefActual(1:ceil(end/2),:);
            coefDiff = coefEvn-fliplr(coefEvn);
            coefDist = norm(coefDiff(:))/sqrt(numel(coefDiff));
            testCase.verifyThat(coefDist,IsLessThan(1e-15),...
                sprintf('%g',coefDist));
            coefOdd = coefActual(ceil(end/2)+1:end,:);
            coefDiff = coefOdd+fliplr(coefOdd);
            coefDist = norm(coefDiff(:))/sqrt(numel(coefDiff));
            testCase.verifyThat(coefDist,IsLessThan(1e-15),...
                sprintf('%g',coefDist));
            
            % Check orthogonality
            coefE = step(testCase.lppufb,[],[]); 
            E = saivdr.dictionary.utility.PolyPhaseMatrix2d(coefE);
            coefActual = double(E.'*E);
            coefActual(1:nDecs,1:nDecs,ord(1)+1,ord(2)+1) = ...
                coefActual(1:nDecs,1:nDecs,ord(1)+1,ord(2)+1) - eye(nDecs);
            coefDist = norm(coefActual(:))/sqrt(numel(coefActual));
            testCase.verifyTrue(coefDist<1e-15,sprintf('%g',coefDist));
            
        end

        % Test: dec 4 4 order 4 4
        function testConstructorWithDec44Ord44Ang(testCase)
            
            % Parameters
            dec = [ 4 4 ];
            ord = [ 4 4 ];
            ang = 2*pi*rand(28,10);
            
            % Expected values
            nDecs = prod(dec);
            dimExpctd = [nDecs nDecs ord(1)+1 ord(2)+1];
            
            % Instantiation of target class
            import saivdr.dictionary.nsolt.*
            testCase.lppufb = OvsdLpPuFb2dTypeIVm1System(...
                'DecimationFactor',dec,...
                'PolyPhaseOrder',ord);
                            
            % Actual values
            coefActual = step(testCase.lppufb,ang,[]);
            
            % Evaluation
            testCase.verifySize(coefActual,dimExpctd);
            
            % Check symmetry
            import matlab.unittest.constraints.IsLessThan
            coefEvn = coefActual(1:ceil(end/2),:);
            coefDiff = coefEvn-fliplr(coefEvn);
            coefDist = norm(coefDiff(:))/sqrt(numel(coefDiff));
            testCase.verifyThat(coefDist,IsLessThan(1e-15),...
                sprintf('%g',coefDist));
            coefOdd = coefActual(ceil(end/2)+1:end,:);
            coefDiff = coefOdd+fliplr(coefOdd);
            coefDist = norm(coefDiff(:))/sqrt(numel(coefDiff));
            testCase.verifyThat(coefDist,IsLessThan(1e-15),...
                sprintf('%g',coefDist));
            
            % Check orthogonality
            coefE = step(testCase.lppufb,[],[]); 
            E = saivdr.dictionary.utility.PolyPhaseMatrix2d(coefE);
            coefActual = double(E.'*E);
            coefActual(1:nDecs,1:nDecs,ord(1)+1,ord(2)+1) = ...
                coefActual(1:nDecs,1:nDecs,ord(1)+1,ord(2)+1) - eye(nDecs);
            coefDist = norm(coefActual(:))/sqrt(numel(coefActual));
            testCase.verifyTrue(coefDist<1e-15,sprintf('%g',coefDist));
            
        end

        % Test for angle setting
        function testSetAngles(testCase)
            
            % Parameters
            dec = [ 2 2 ];
            ord = [ 0 0 ];
            angPre = [ pi/4 pi/4 ];
            angPst = [ 0 0 ];
            
            % Expected values
            coefExpctd(:,:,1,1) = 1/2 * [
                1  1  1  1 ;
                1 -1 -1  1 ;
                -1  1 -1  1 ;
                -1 -1  1  1 ];
            
            % Instantiation of target class
            import saivdr.dictionary.nsolt.*
            testCase.lppufb = OvsdLpPuFb2dTypeIVm1System(...
                'DecimationFactor',dec,...
                'PolyPhaseOrder',ord);
                            
            % Actual values
            coefActual = step(testCase.lppufb,angPre,[]);
            
            % Evaluation
            import matlab.unittest.constraints.IsGreaterThanOrEqualTo
            coefDist = max(abs(coefExpctd(:)-coefActual(:))./...
                (abs(coefExpctd(:))));
            testCase.verifyThat(coefDist,IsGreaterThanOrEqualTo(1e-15),...
                sprintf('%g',coefDist));
            
            % Actual values
            coefActual = step(testCase.lppufb,angPst,[]);
            
            % Evaluation
            coefDist = max(abs(coefExpctd(:)-coefActual(:))./...
                (abs(coefExpctd(:))));
            testCase.verifyEqual(coefActual,coefExpctd,'RelTol',1e-15,...
                sprintf('%g',coefDist));
            
        end

        % Test for angle setting
        function testSetMus(testCase)
            
            % Parameters
            dec = [ 2 2 ];
            ord = [ 0 0 ];
            ang = [ 0 0 ];
            musPre = [ 1 -1 ; 1 -1 ];
            musPst = 1;
            
            % Expected values
            coefExpctd(:,:,1,1) = 1/2 * [
                1  1  1  1 ;
                1 -1 -1  1 ;
                -1  1 -1  1 ;
                -1 -1  1  1 ];
            
            % Instantiation of target class
            import saivdr.dictionary.nsolt.*
            testCase.lppufb = OvsdLpPuFb2dTypeIVm1System(...
                'DecimationFactor',dec,...
                'PolyPhaseOrder',ord);
            
            % Actual values
            coefActual = step(testCase.lppufb,ang,musPre);

            % Evaluation
            import matlab.unittest.constraints.IsGreaterThanOrEqualTo
            coefDist = max(abs(coefExpctd(:)-coefActual(:))./...
                (abs(coefExpctd(:))));
            testCase.verifyThat(coefDist,IsGreaterThanOrEqualTo(1e-15),...
                sprintf('%g',coefDist));
            
            % Actual values
            coefActual = step(testCase.lppufb,[],musPst);
            
            % Evaluation
            coefDist = max(abs(coefExpctd(:)-coefActual(:))./...
                (abs(coefExpctd(:))));
            testCase.verifyEqual(coefActual,coefExpctd,'RelTol',1e-15,...
                sprintf('%g',coefDist));
            
        end
        
        % Test for char
        function testChar(testCase)
            
            % Expected value
            charExpctd = [...
                '[', 10, ...
                9, '0.5 + 0.5*y^(-1) + 0.5*x^(-1) + 0.5*y^(-1)*x^(-1);', 10, ...
                9, '0.5 - 0.5*y^(-1) - 0.5*x^(-1) + 0.5*y^(-1)*x^(-1);', 10, ...
                9, '-0.5 + 0.5*y^(-1) - 0.5*x^(-1) + 0.5*y^(-1)*x^(-1);', 10, ...
                9, '-0.5 - 0.5*y^(-1) + 0.5*x^(-1) + 0.5*y^(-1)*x^(-1)', 10, ...
                ']' ...
                ];
            
            % Instantiation of target class
            import saivdr.dictionary.nsolt.*
            testCase.lppufb = OvsdLpPuFb2dTypeIVm1System(...
                'OutputMode','Char');
            
            % Actual values
            charActual = step(testCase.lppufb,[],[]);
            
            % Evaluation
            testCase.verifyEqual(charActual,charExpctd);
            
        end
        
        % Test for subsref
        function testAnalysisFilterAt(testCase)
            
            % Expected value
            anFiltExpctd1 = 1/2*[ 1 1 ;  1 1 ];
            anFiltExpctd2 = 1/2*[ 1 -1 ; -1 1 ];
            anFiltExpctd3 = 1/2*[-1 -1 ;  1  1 ];
            anFiltExpctd4 = 1/2*[-1  1 ; -1  1 ];
            
            % Instantiation of target class
            import saivdr.dictionary.nsolt.*
            testCase.lppufb = OvsdLpPuFb2dTypeIVm1System(...
                'OutputMode','AnalysisFilterAt');
            
            % Actual values
            anFiltActual1 = step(testCase.lppufb,[],[],1);
            anFiltActual2 = step(testCase.lppufb,[],[],2);
            anFiltActual3 = step(testCase.lppufb,[],[],3);
            anFiltActual4 = step(testCase.lppufb,[],[],4);
            
            % Evaluation
            dist = max(abs(anFiltExpctd1(:)-anFiltActual1(:))./abs(anFiltExpctd1(:)));
            testCase.verifyEqual(anFiltActual1,anFiltExpctd1,'RelTol',1e-15,sprintf('%g',dist));
            dist = max(abs(anFiltExpctd2(:)-anFiltActual2(:))./abs(anFiltExpctd2(:)));
            testCase.verifyEqual(anFiltActual2,anFiltExpctd2,'RelTol',1e-15,sprintf('%g',dist));
            dist = max(abs(anFiltExpctd3(:)-anFiltActual3(:))./abs(anFiltExpctd3(:)));
            testCase.verifyEqual(anFiltActual3,anFiltExpctd3,'RelTol',1e-15,sprintf('%g',dist));
            dist = max(abs(anFiltExpctd4(:)-anFiltActual4(:))./abs(anFiltExpctd4(:)));
            testCase.verifyEqual(anFiltActual4,anFiltExpctd4,'RelTol',1e-15,sprintf('%g',dist));
            
        end
        
        % Test 
        function testAnalysisFilters(testCase)
            
            % Expected value
            anFiltExpctd1 = 1/2*[ 1 1 ;  1 1 ];
            anFiltExpctd2 = 1/2*[ 1 -1 ; -1 1 ];
            anFiltExpctd3 = 1/2*[-1 -1 ;  1  1 ];
            anFiltExpctd4 = 1/2*[-1  1 ; -1  1 ];
            
            % Instantiation of target class
            import saivdr.dictionary.nsolt.*
            testCase.lppufb = OvsdLpPuFb2dTypeIVm1System(...
                'OutputMode','AnalysisFilters');
            
            % Actual values
            anFiltsActual = step(testCase.lppufb,[],[]);
            anFiltActual1 = anFiltsActual(:,:,1);
            anFiltActual2 = anFiltsActual(:,:,2);
            anFiltActual3 = anFiltsActual(:,:,3);
            anFiltActual4 = anFiltsActual(:,:,4);
            
            % Evaluation
            dist = max(abs(anFiltExpctd1(:)-anFiltActual1(:))./abs(anFiltExpctd1(:)));
            testCase.verifyEqual(anFiltActual1,anFiltExpctd1,'RelTol',1e-15,sprintf('%g',dist));
            dist = max(abs(anFiltExpctd2(:)-anFiltActual2(:))./abs(anFiltExpctd2(:)));
            testCase.verifyEqual(anFiltActual2,anFiltExpctd2,'RelTol',1e-15,sprintf('%g',dist));
            dist = max(abs(anFiltExpctd3(:)-anFiltActual3(:))./abs(anFiltExpctd3(:)));
            testCase.verifyEqual(anFiltActual3,anFiltExpctd3,'RelTol',1e-15,sprintf('%g',dist));
            dist = max(abs(anFiltExpctd4(:)-anFiltActual4(:))./abs(anFiltExpctd4(:)));
            testCase.verifyEqual(anFiltActual4,anFiltExpctd4,'RelTol',1e-15,sprintf('%g',dist));
            
        end
        
        % Test dec 1 1 ch 4 order 0 1
        function testConstructorWithDec22Ord01(testCase)
            
            % Parameters
            dec = [ 2 2 ];
            ord = [ 0 1 ];
            ang = 0;
            
            % Expected values
            coefExpctd(:,:,1,1) = 1/2 * [...
                0 0  1  1;
                0 0 -1  1;
                0 0 -1  1;
                0 0  1  1];
            
            coefExpctd(:,:,1,2) = 1/2 * [...
                1  1 0 0;
                1 -1 0 0;
                -1  1 0 0;
                -1 -1 0 0];
            
            % Instantiation of target class
            import saivdr.dictionary.nsolt.*
            testCase.lppufb = OvsdLpPuFb2dTypeIVm1System(...
                'DecimationFactor',dec,...
                'PolyPhaseOrder',ord);
                            
            % Actual values
            coefActual = step(testCase.lppufb,ang,[]);
            
            % Evaluation
            coefDist = max(abs(coefExpctd(:)-coefActual(:)));
            testCase.verifyEqual(coefActual,coefExpctd,'AbsTol',1e-15,...
                sprintf('%g',coefDist));
            
        end
        
        % Test dec 1 1 ch 4 order 0 1
        function testConstructorWithDec11Ch4Ord01(testCase)
            
            % Parameters
            decch = [ 1 1 4 ];
            ord = [ 0 1 ];
            ang = 0;
            
            % Expected values
            coefExpctd(:,:,1,1) = 1/2 * [...
                1;
                0;
                0;
                1];
            
            coefExpctd(:,:,1,2) = 1/2 * [...
                1;
                0;
                0;
                -1];
            
            % Instantiation of target class
            import saivdr.dictionary.nsolt.*
            testCase.lppufb = OvsdLpPuFb2dTypeIVm1System(...
                'DecimationFactor',decch(1:2),...
                'NumberOfChannels',decch(3:end),...
                'PolyPhaseOrder',ord);
                            
            % Actual values
            coefActual = step(testCase.lppufb,ang,[]);
            
            % Evaluation
            coefDist = max(abs(coefExpctd(:)-coefActual(:)));
            testCase.verifyEqual(coefActual,coefExpctd,'AbsTol',1e-15,...
                sprintf('%g',coefDist));
            
        end
        
        % Test dec 1 1 ch 4 order 1 1
        function testConstructorWithDec11Ch4Ord11(testCase)
            
            % Parameters
            decch = [ 1 1 4 ];
            ord = [ 1 1 ];
            ang = 0;
            
            % Expected values
            coefExpctd(:,:,1,1) = 1/4 * [...
                1;
                1;
                1;
                1];
            
            coefExpctd(:,:,2,1) = 1/4 * [...
                1;
                -1;
                -1;
                1];
            
            coefExpctd(:,:,1,2) = 1/4 * [...
                1;
                -1;
                1;
                -1];
            
            coefExpctd(:,:,2,2) = 1/4* [...
                1;
                1;
                -1;
                -1];
            
            % Instantiation of target class
            import saivdr.dictionary.nsolt.*
            testCase.lppufb = OvsdLpPuFb2dTypeIVm1System(...
                'DecimationFactor',decch(1:2),...
                'NumberOfChannels',decch(3:end),...
                'PolyPhaseOrder',ord);
                            
            % Actual values
            coefActual = step(testCase.lppufb,ang,[]);
            
            % Evaluation
            coefDist = max(abs(coefExpctd(:)-coefActual(:))...
                ./(abs(coefExpctd(:))));
            testCase.verifyEqual(coefActual,coefExpctd,'RelTol',1e-15,...
                sprintf('%g',coefDist));
            
        end

        % Test for construction with order 0 1
        function testConstructorWithDec22Ord01Ang(testCase)
            
            % Parameters
            dec = [ 2 2 ];
            ord = [ 0 1 ];
            ang = 2*pi*rand(1,3);
            
            % Expected values
            nDecs = prod(dec);
            dimExpctd = [nDecs nDecs ord(1)+1 ord(2)+1];
            
            % Instantiation of target class
            import saivdr.dictionary.nsolt.*
            testCase.lppufb = OvsdLpPuFb2dTypeIVm1System(...
                'DecimationFactor',dec,...
                'PolyPhaseOrder',ord);
            
            % Actual values
            coefActual = step(testCase.lppufb,ang,[]);
            
            % Evaluation
            testCase.verifySize(coefActual,dimExpctd);
            
            % Check symmetry
            import matlab.unittest.constraints.IsLessThan
            coefEvn = coefActual(1:ceil(end/2),:);
            coefDiff = coefEvn-fliplr(coefEvn);
            coefDist = norm(coefDiff(:))/sqrt(numel(coefDiff));
            testCase.verifyThat(coefDist,IsLessThan(1e-15),...
                sprintf('%g',coefDist));
            coefOdd = coefActual(ceil(end/2)+1:end,:);
            coefDiff = coefOdd+fliplr(coefOdd);
            coefDist = norm(coefDiff(:))/sqrt(numel(coefDiff));
            testCase.verifyThat(coefDist,IsLessThan(1e-15),...
                sprintf('%g',coefDist));
            
            % Check orthogonality
            coefE = step(testCase.lppufb,[],[]); 
            E = saivdr.dictionary.utility.PolyPhaseMatrix2d(coefE);
            coefActual = double(E.'*E);
            coefActual(1:nDecs,1:nDecs,ord(1)+1,ord(2)+1) = ...
                coefActual(1:nDecs,1:nDecs,ord(1)+1,ord(2)+1) - eye(nDecs);
            coefDist = norm(coefActual(:))/sqrt(numel(coefActual));
            testCase.verifyTrue(coefDist<1e-15,sprintf('%g',coefDist));
            
        end
        
        % Test dec 2 2 order 1 0
        function testConstructorWithDec22Ord10(testCase)
            
            % Parameters
            dec = [ 2 2 ];
            ord = [ 1 0 ];
            ang = 0;
            
            % Expected values
            coefExpctd(:,:,1) = 1/2 * [...
                0  1  0  1;
                0 -1  0  1;
                0  1  0  1;
                0 -1  0  1];
            
            coefExpctd(:,:,2) = 1/2 * [...
                1  0  1  0;
                1  0 -1  0;
                -1  0 -1  0;
                -1  0  1  0];
            
            % Instantiation of target class
            import saivdr.dictionary.nsolt.*
            testCase.lppufb = OvsdLpPuFb2dTypeIVm1System(...
                'DecimationFactor',dec,...
                'PolyPhaseOrder',ord);
            
            % Actual values
            coefActual = step(testCase.lppufb,ang,[]);
            
            % Evaluation
            coefDist = max(abs(coefExpctd(:)-coefActual(:)));
            testCase.verifyEqual(coefActual,coefExpctd,'AbsTol',1e-15,...
                sprintf('%g',coefDist));
            
        end
        
        % Test dec 2 2 order 1 0
        function testConstructorWithDec11Ch4Ord10(testCase)
            
            % Parameters
            decch = [ 1 1 4 ];
            ord = [ 1 0 ];
            ang = 0;
            
            % Expected values
            coefExpctd(:,:,1) = 1/2 * [...
                1 ; 
                0 ;
                1 ;
                0 ];
            
            coefExpctd(:,:,2) = 1/2 * [...
                1 ;
                0 ;
                -1 ;
                0 ];
            
            % Instantiation of target class
            import saivdr.dictionary.nsolt.*
            testCase.lppufb = OvsdLpPuFb2dTypeIVm1System(...
                'DecimationFactor',decch(1:2),...
                'NumberOfChannels',decch(3:end),...
                'PolyPhaseOrder',ord);
                            
            % Actual values
            coefActual = step(testCase.lppufb,ang,[]);
            
            % Evaluation
            coefDist = max(abs(coefExpctd(:)-coefActual(:))...
                ./(abs(coefActual(:))));
            testCase.verifyEqual(coefActual,coefExpctd,'RelTol',1e-15,...
                sprintf('%g',coefDist));
            
        end
        
         % Test dec 2 2 order 1 0
        function testConstructorWithDec22Ch4Ord10(testCase)
            
            % Parameters
            decch = [ 2 2 4 ];
            ord = [ 1 0 ];
            ang = 0;
            
            % Expected values
            coefExpctd(:,:,1) = 1/2 * [...
                0  1  0  1;
                0 -1  0  1;
                0  1  0  1;
                0 -1  0  1];
            
            coefExpctd(:,:,2) = 1/2 * [...
                1  0  1  0;
                1  0 -1  0;
                -1  0 -1  0;
                -1  0  1  0];
            
            % Instantiation of target class
            import saivdr.dictionary.nsolt.*
            testCase.lppufb = OvsdLpPuFb2dTypeIVm1System(...
                'DecimationFactor',decch(1:2),...
                'NumberOfChannels',decch(3:end),...
                'PolyPhaseOrder',ord);
                            
            % Actual values
            coefActual = step(testCase.lppufb,ang,[]);
            
            % Evaluation
           coefDist = max(abs(coefExpctd(:)-coefActual(:)));
            testCase.verifyEqual(coefActual,coefExpctd,'AbsTol',1e-15,...
                sprintf('%g',coefDist));
            
        end
        
        
        % Test for construction with order 1 0
        function testConstructorWithDec22Ord10Ang(testCase)
            
            % Parameters
            dec = [ 2 2 ];
            ord = [ 1 0 ];
            ang = 2*pi*rand(1,3);
            
            % Expected values
            nDecs = prod(dec);
            dimExpctd = [nDecs nDecs ord(1)+1];
            
            % Instantiation of target class
            import saivdr.dictionary.nsolt.*
            testCase.lppufb = OvsdLpPuFb2dTypeIVm1System(...
                'DecimationFactor',dec,...
                'PolyPhaseOrder',ord);
                            
            % Actual values
            coefActual = step(testCase.lppufb,ang,[]);
            
            % Evaluation
            testCase.verifySize(coefActual,dimExpctd);
            
            % Check symmetry
            import matlab.unittest.constraints.IsLessThan
            coefEvn = coefActual(1:ceil(end/2),:);
            coefDiff = coefEvn-fliplr(coefEvn);
            coefDist = norm(coefDiff(:))/sqrt(numel(coefDiff));
            testCase.verifyThat(coefDist,IsLessThan(1e-15),...
                sprintf('%g',coefDist));
            coefOdd = coefActual(ceil(end/2)+1:end,:);
            coefDiff = coefOdd+fliplr(coefOdd);
            coefDist = norm(coefDiff(:))/sqrt(numel(coefDiff));
            testCase.verifyThat(coefDist,IsLessThan(1e-15),...
                sprintf('%g',coefDist));
            
            % Check orthogonality
            coefE = step(testCase.lppufb,[],[]); 
            E = saivdr.dictionary.utility.PolyPhaseMatrix2d(coefE);
            coefActual = double(E.'*E);
            coefActual(1:nDecs,1:nDecs,ord(1)+1,ord(2)+1) = ...
                coefActual(1:nDecs,1:nDecs,ord(1)+1,ord(2)+1) - eye(nDecs);
            coefDist = norm(coefActual(:))/sqrt(numel(coefActual));
            testCase.verifyTrue(coefDist<1e-15,sprintf('%g',coefDist));
            
        end
        
        % Test dec 2 2 order 1 1
        function testConstructorWithDec22Ord11(testCase)
            
            % Parameters
            dec = [ 2 2 ];
            ord = [ 1 1 ];
            ang = 0;
            
            % Expected values
            coefExpctd(:,:,1,1) = [...
                0 0 0  1;
                0 0 0  1;
                0 0 0  1;
                0 0 0  1]/2;
            
            coefExpctd(:,:,2,1) = [...
                0 0  1 0;
                0 0 -1 0;
                0 0 -1 0;
                0 0  1 0]/2;
            
            coefExpctd(:,:,1,2) = [...
                0  1 0 0;
                0 -1 0 0;
                0  1 0 0;
                0 -1 0 0]/2;
            
            coefExpctd(:,:,2,2) = [...
                1 0 0 0;
                1 0 0 0;
                -1 0 0 0;
                -1 0 0 0]/2;
            
            % Instantiation of target class
            import saivdr.dictionary.nsolt.*
            testCase.lppufb = OvsdLpPuFb2dTypeIVm1System(...
                'DecimationFactor',dec,...
                'PolyPhaseOrder',ord);
                            
            % Actual values
            coefActual = step(testCase.lppufb,ang,[]);
            
            % Evaluation
            coefDist = max(abs(coefExpctd(:)-coefActual(:)));
            testCase.verifyEqual(coefActual,coefExpctd,'AbsTol',1e-15,...
                sprintf('%g',coefDist));
            
        end
        
        % Test dec 2 2 ch 4 order 1 1
        function testConstructorWithDec22Ch4Ord11(testCase)
            
            % Parameters
            decch = [ 2 2 4 ];
            ord = [ 1 1 ];
            ang = 0;
            
            % Expected values
            coefExpctd(:,:,1,1) = [...
                0 0 0  1;
                0 0 0  1;
                0 0 0  1;
                0 0 0  1]/2;
            
            coefExpctd(:,:,2,1) = [...
                0 0  1 0;
                0 0 -1 0;
                0 0 -1 0;
                0 0  1 0]/2;
            
            coefExpctd(:,:,1,2) = [...
                0  1 0 0;
                0 -1 0 0;
                0  1 0 0;
                0 -1 0 0]/2;
            
            coefExpctd(:,:,2,2) = [...
                1 0 0 0;
                1 0 0 0;
                -1 0 0 0;
                -1 0 0 0]/2;
            
            % Instantiation of target class
            import saivdr.dictionary.nsolt.*
            testCase.lppufb = OvsdLpPuFb2dTypeIVm1System(...
                'DecimationFactor',decch(1:2),...
                'NumberOfChannels',decch(3:end),...
                'PolyPhaseOrder',ord);
                            
            % Actual values
            coefActual = step(testCase.lppufb,ang,[]);
            
            % Evaluation
            coefDist = max(abs(coefExpctd(:)-coefActual(:)));
            testCase.verifyEqual(coefActual,coefExpctd,'AbsTol',1e-15,...
                sprintf('%g',coefDist));
        end
        
        % Test dec 2 2 order 1 1
        function testConstructorWithDec22Ord11Ang(testCase)
            
            % Parameters
            dec = [ 2 2 ];
            ord = [ 1 1 ];
            ang = 2*pi*rand(1,4);
            
            % Expected values
            nDecs = prod(dec);
            dimExpctd = [nDecs nDecs ord(1)+1 ord(2)+1];
            
            % Instantiation of target class
            import saivdr.dictionary.nsolt.*
            testCase.lppufb = OvsdLpPuFb2dTypeIVm1System(...
                'DecimationFactor',dec,...
                'PolyPhaseOrder',ord);                
                        
            % Actual values
            coefActual = step(testCase.lppufb,ang,[]);
            
            % Evaluation
            testCase.verifySize(coefActual,dimExpctd);
            
            % Check symmetry
            import matlab.unittest.constraints.IsLessThan
            coefEvn = coefActual(1:ceil(end/2),:);
            coefDiff = coefEvn-fliplr(coefEvn);
            coefDist = norm(coefDiff(:))/sqrt(numel(coefDiff));
            testCase.verifyThat(coefDist,IsLessThan(1e-15),...
                sprintf('%g',coefDist));
            coefOdd = coefActual(ceil(end/2)+1:end,:);
            coefDiff = coefOdd+fliplr(coefOdd);
            coefDist = norm(coefDiff(:))/sqrt(numel(coefDiff));
            testCase.verifyThat(coefDist,IsLessThan(1e-15),...
                sprintf('%g',coefDist));
            
            % Check orthogonality
            coefE = step(testCase.lppufb,[],[]); 
            E = saivdr.dictionary.utility.PolyPhaseMatrix2d(coefE);
            coefActual = double(E.'*E);
            coefActual(1:nDecs,1:nDecs,ord(1)+1,ord(2)+1) = ...
                coefActual(1:nDecs,1:nDecs,ord(1)+1,ord(2)+1) - eye(nDecs);
            coefDist = norm(coefActual(:))/sqrt(numel(coefActual));
            testCase.verifyTrue(coefDist<1e-15,sprintf('%g',coefDist));
            
        end
        
        % Test dec 2 2 order 0 2
        function testConstructorWithDec22Ord02(testCase)
            
            % Parameters
            dec = [ 2 2 ];
            ord = [ 0 2 ];
            ang = 0;
            
            % Expected values
            coefExpctd(:,:,1,1) = [
                0  0  0  0 ;
                0  0  0  0 ;
                0  0  0  0 ;
                0  0  0  0 ];
            
            coefExpctd(:,:,1,2) = 1/2 * [
                1  1  1  1 ;
                1 -1 -1  1 ;
                -1  1 -1  1 ;
                -1 -1  1  1 ];
            
            coefExpctd(:,:,1,3) = [
                0  0  0  0 ;
                0  0  0  0 ;
                0  0  0  0 ;
                0  0  0  0 ];
            
            % Instantiation of target class
            import saivdr.dictionary.nsolt.*
            testCase.lppufb = OvsdLpPuFb2dTypeIVm1System(...
                'DecimationFactor',dec,...
                'PolyPhaseOrder',ord);
                            
            % Actual values
            coefActual = step(testCase.lppufb,ang,[]);
            
            % Evaluation
            coefDist = max(abs(coefExpctd(:)-coefActual(:))...
                ./(abs(coefActual(:))));
            testCase.verifyEqual(coefActual,coefExpctd,'RelTol',1e-15,...
                sprintf('%g',coefDist));
            
        end
        
        % Test dec 2 2 order 0 2
        function testConstructorWithDec11Ch4Ord02(testCase)
            
            % Parameters
            decch = [ 1 1 4 ];
            ord = [ 0 2 ];
            ang = 0;
            
            % Expected values
            coefExpctd(:,:,1,1) = [
                0  ;
                0  ;
                0  ;
                0  ];
            
            coefExpctd(:,:,1,2) = [
                1 ;
                0 ;
                0 ;
                0 ];
            
            coefExpctd(:,:,1,3) = [
                0  ;
                0  ;
                0  ;
                0  ];
            
            % Instantiation of target class
            import saivdr.dictionary.nsolt.*
            testCase.lppufb = OvsdLpPuFb2dTypeIVm1System(...
                'DecimationFactor',decch(1:2),...
                'NumberOfChannels',decch(3:end),...
                'PolyPhaseOrder',ord);
                            
            % Actual values
            coefActual = step(testCase.lppufb,ang,[]);
            
            % Evaluation
            coefDist = max(abs(coefExpctd(:)-coefActual(:))...
                ./(abs(coefExpctd(:))));
            testCase.verifyEqual(coefActual,coefExpctd,'RelTol',1e-15,...
                sprintf('%g',coefDist));
            
        end     
        
        % Test dec 1 1 ch 4 order 2 2
        function testConstructorWithDec11Ch4Ord22(testCase)
            
            % Parameters
            decch = [ 1 1 4 ];
            ord = [ 2 2 ];
            ang = 0;
            
            % Expected values
            coefExpctd(:,:,1,1) = [...
                0;
                0;
                0;
                0];
            
            coefExpctd(:,:,2,1) =  [...
                0;
                0;
                0;
                0];

            coefExpctd(:,:,3,1) = [...
                0;
                0;
                0;
                0];
            
            coefExpctd(:,:,2,1) =  [...
                0;
                0;
                0;
                0];

            coefExpctd(:,:,2,2) = [...
                1;
                0;
                0;
                0];
            
            coefExpctd(:,:,2,3) =  [...
                0;
                0;
                0;
                0];
            
            coefExpctd(:,:,3,1) = [...
                0;
                0;
                0;
                0];
            
            coefExpctd(:,:,3,2) =  [...
                0;
                0;
                0;
                0];
            
            coefExpctd(:,:,3,3) = [...
                0;
                0;
                0;
                0];
            
            % Instantiation of target class
            import saivdr.dictionary.nsolt.*
            testCase.lppufb = OvsdLpPuFb2dTypeIVm1System(...
                'DecimationFactor',decch(1:2),...
                'NumberOfChannels',decch(3:end),...
                'PolyPhaseOrder',ord);
                            
            % Actual values
            coefActual = step(testCase.lppufb,ang,[]);
            
            % Evaluation
            coefDist = max(abs(coefExpctd(:)-coefActual(:))...
                ./(abs(coefExpctd(:))));
            testCase.verifyEqual(coefActual,coefExpctd,'RelTol',1e-15,...
                sprintf('%g',coefDist));
            
        end
        
        % Test dec 2 2 order 0 2
        function testConstructorWithDec22Ch4Ord02(testCase)
            
            % Parameters
            decch = [ 2 2 4 ];
            ord = [ 0 2 ];
            ang = 0;
            
            % Expected values
            coefExpctd(:,:,1,1) = [
                0  0  0  0 ;
                0  0  0  0 ;
                0  0  0  0 ;
                0  0  0  0 ];
            
            coefExpctd(:,:,1,2) = 1/2 * [
                1  1  1  1 ;
                1 -1 -1  1 ;
                -1  1 -1  1 ;
                -1 -1  1  1 ];
            
            coefExpctd(:,:,1,3) = [
                0  0  0  0 ;
                0  0  0  0 ;
                0  0  0  0 ;
                0  0  0  0 ];
            
            % Instantiation of target class
            import saivdr.dictionary.nsolt.*
            testCase.lppufb = OvsdLpPuFb2dTypeIVm1System(...
                'DecimationFactor',decch(1:2),...
                'NumberOfChannels',decch(3:end),...
                'PolyPhaseOrder',ord);
                            
            % Actual values
            coefActual = step(testCase.lppufb,ang,[]);
            
            % Evaluation
            coefDist = max(abs(coefExpctd(:)-coefActual(:))...
                ./(abs(coefExpctd(:))));
            testCase.verifyEqual(coefActual,coefExpctd,'RelTol',1e-15,...
                sprintf('%g',coefDist));
            
        end
        
         % Test dec 2 2 order 2 0
        function testConstructorWithDec22Ch4Ord20(testCase)
            
            % Parameters
            decch = [ 2 2 4 ];
            ord = [ 2 0 ];
            ang = 0;
            
            % Expected values
            coefExpctd(:,:,1,1) = [
                0  0  0  0 ;
                0  0  0  0 ;
                0  0  0  0 ;
                0  0  0  0 ];
            
            coefExpctd(:,:,2,1) = 1/2 * [
                1  1  1  1 ;
                1 -1 -1  1 ;
                -1  1 -1  1 ;
                -1 -1  1  1 ];
            
            coefExpctd(:,:,3,1) = [
                0  0  0  0 ;
                0  0  0  0 ;
                0  0  0  0 ;
                0  0  0  0 ];
            
            % Instantiation of target class
            import saivdr.dictionary.nsolt.*
            testCase.lppufb = OvsdLpPuFb2dTypeIVm1System(...
                'DecimationFactor',decch(1:2),...
                'NumberOfChannels',decch(3:end),...
                'PolyPhaseOrder',ord);
                            
            % Actual values
            coefActual = step(testCase.lppufb,ang,[]);
            
            % Evaluation
            coefDist = max(abs(coefExpctd(:)-coefActual(:))...
                ./(abs(coefExpctd(:))));
            testCase.verifyEqual(coefActual,coefExpctd,'RelTol',1e-15,...
                sprintf('%g',coefDist));
            
        end
        
        
        
        % Test for construction with order 0 2
        function testConstructorWithDec22Ord02Ang(testCase)
            
            % Parameters
            dec = [ 2 2 ];
            ord = [ 0 2 ];
            ang = 2*pi*rand(1,4);
            
            % Expected values
            nDecs = prod(dec);
            dimExpctd = [nDecs nDecs ord(1)+1 ord(2)+1];
            
            % Instantiation of target class
            import saivdr.dictionary.nsolt.*
            testCase.lppufb = OvsdLpPuFb2dTypeIVm1System(...
                'DecimationFactor',dec,...
                'PolyPhaseOrder',ord);
                            
            % Actual values
            coefActual = step(testCase.lppufb,ang,[]);
            
            % Evaluation
            testCase.verifySize(coefActual,dimExpctd);
            
            % Check symmetry
            import matlab.unittest.constraints.IsLessThan
            coefEvn = coefActual(1:ceil(end/2),:);
            coefDiff = coefEvn-fliplr(coefEvn);
            coefDist = norm(coefDiff(:))/sqrt(numel(coefDiff));
            testCase.verifyThat(coefDist,IsLessThan(1e-15),...
                sprintf('%g',coefDist));
            coefOdd = coefActual(ceil(end/2)+1:end,:);
            coefDiff = coefOdd+fliplr(coefOdd);
            coefDist = norm(coefDiff(:))/sqrt(numel(coefDiff));
            testCase.verifyThat(coefDist,IsLessThan(1e-15),...
                sprintf('%g',coefDist));
            
            % Check orthogonality
            coefE = step(testCase.lppufb,[],[]); 
            E = saivdr.dictionary.utility.PolyPhaseMatrix2d(coefE);
            coefActual = double(E.'*E);
            coefActual(1:nDecs,1:nDecs,ord(1)+1,ord(2)+1) = ...
                coefActual(1:nDecs,1:nDecs,ord(1)+1,ord(2)+1) - eye(nDecs);
            coefDist = norm(coefActual(:))/sqrt(numel(coefActual));
            testCase.verifyTrue(coefDist<1e-15,sprintf('%g',coefDist));
            
        end
         % Test dec 2 2 order 2 0
        function testConstructorWithDec22Ord20(testCase)
            
            % Parameters
            dec = [ 2 2 ];
            ord = [ 2 0 ];
            ang = 0;
            
            % Expected values
            coefExpctd(:,:,1) = [
                0  0  0  0 ;
                0  0  0  0 ;
                0  0  0  0 ;
                0  0  0  0 ];
            
            coefExpctd(:,:,2) = 1/2 * [
                1  1  1  1 ;
                1 -1 -1  1 ;
                -1  1 -1  1 ;
                -1 -1  1  1 ];
            
            coefExpctd(:,:,3) = [
                0  0  0  0 ;
                0  0  0  0 ;
                0  0  0  0 ;
                0  0  0  0 ];
            
            % Instantiation of target class
            import saivdr.dictionary.nsolt.*            
            testCase.lppufb = OvsdLpPuFb2dTypeIVm1System(...
                'DecimationFactor',dec,...
                'PolyPhaseOrder',ord);
                            
            % Actual values
            coefActual = step(testCase.lppufb,ang,[]);
            
            % Evaluation
            coefDist = max(abs(coefExpctd(:)-coefActual(:))...
                ./(abs(coefExpctd(:))));
            testCase.verifyEqual(coefActual,coefExpctd,'RelTol',1e-15,...
                sprintf('%g',coefDist));

        end
        
        % Test dec 2 2 order 2 0
        function testConstructorWithDec11Ch4Ord20(testCase)
            
            % Parameters
            decch = [ 1 1 4 ];
            ord = [ 2 0 ];
            ang = 0;
            
            % Expected values
            coefExpctd(:,:,1) = [
                0  ;
                0  ;
                0  ;
                0  ];
            
            coefExpctd(:,:,2) = [
                1 ;
                0 ;
                0 ;
                0 ];
            
            coefExpctd(:,:,3) = [
                0  ;
                0  ;
                0  ;
                0  ];
            
            % Instantiation of target class
            import saivdr.dictionary.nsolt.*
            testCase.lppufb = OvsdLpPuFb2dTypeIVm1System(...
                'DecimationFactor',decch(1:2),...
                'NumberOfChannels',decch(3:end),...
                'PolyPhaseOrder',ord);
                            
            % Actual values
            coefActual = step(testCase.lppufb,ang,[]);
            
            % Evaluation
            coefDist = max(abs(coefExpctd(:)-coefActual(:))...
                ./(abs(coefExpctd(:))));
            testCase.verifyEqual(coefActual,coefExpctd,'RelTol',1e-15,...
                sprintf('%g',coefDist));
            
        end
        
        % Test for construction with order 2 0
        function testConstructorWithDec22Ord20Ang(testCase)
            
            % Parameters
            dec = [ 2 2 ];
            ord = [ 2 0 ];
            ang = 2*pi*rand(1,4);
            
            % Expected values
            nDecs = prod(dec);
            dimExpctd = [nDecs nDecs ord(1)+1];
            
            % Instantiation of target class
            import saivdr.dictionary.nsolt.*            
            testCase.lppufb = OvsdLpPuFb2dTypeIVm1System(...
                'DecimationFactor',dec,...
                'PolyPhaseOrder',ord);
                            
            % Actual values
            coefActual = step(testCase.lppufb,ang,[]);
            
            % Evaluation
            testCase.verifySize(coefActual,dimExpctd);
            
            % Check symmetry
            import matlab.unittest.constraints.IsLessThan
            coefEvn = coefActual(1:ceil(end/2),:);
            coefDiff = coefEvn-fliplr(coefEvn);
            coefDist = norm(coefDiff(:))/sqrt(numel(coefDiff));
            testCase.verifyThat(coefDist,IsLessThan(1e-15),...
                sprintf('%g',coefDist));
            coefOdd = coefActual(ceil(end/2)+1:end,:);
            coefDiff = coefOdd+fliplr(coefOdd);
            coefDist = norm(coefDiff(:))/sqrt(numel(coefDiff));
            testCase.verifyThat(coefDist,IsLessThan(1e-15),...
                sprintf('%g',coefDist));
            
            % Check orthogonality
            coefE = step(testCase.lppufb,[],[]); 
            E = saivdr.dictionary.utility.PolyPhaseMatrix2d(coefE);
            coefActual = double(E.'*E);
            coefActual(1:nDecs,1:nDecs,ord(1)+1,ord(2)+1) = ...
                coefActual(1:nDecs,1:nDecs,ord(1)+1,ord(2)+1) - eye(nDecs);
            coefDist = norm(coefActual(:))/sqrt(numel(coefActual));
            testCase.verifyTrue(coefDist<1e-15,sprintf('%g',coefDist));
            
        end
        
        % Test dec 2 2 order 2 2
        function testConstructorWithDec22Ord22(testCase)
            
            % Parameters
            dec = [ 2 2 ];
            ord = [ 2 2 ];
            ang = 0;
            
            % Expected values
            coefExpctd(:,:,1,1) = [
                0  0  0  0 ;
                0  0  0  0 ;
                0  0  0  0 ;
                0  0  0  0 ];
            
            coefExpctd(:,:,2,1) = [
                0  0  0  0 ;
                0  0  0  0 ;
                0  0  0  0 ;
                0  0  0  0 ];
            
            coefExpctd(:,:,3,1) = [
                0  0  0  0 ;
                0  0  0  0 ;
                0  0  0  0 ;
                0  0  0  0 ];
            
            coefExpctd(:,:,1,2) = [
                0  0  0  0 ;
                0  0  0  0 ;
                0  0  0  0 ;
                0  0  0  0 ];
            
            coefExpctd(:,:,2,2) = 1/2 * [
                1  1  1  1 ;
                1 -1 -1  1 ;
                -1  1 -1  1 ;
                -1 -1  1  1 ];
            
            coefExpctd(:,:,3,2) = [
                0  0  0  0 ;
                0  0  0  0 ;
                0  0  0  0 ;
                0  0  0  0 ];
            
            coefExpctd(:,:,1,3) = [
                0  0  0  0 ;
                0  0  0  0 ;
                0  0  0  0 ;
                0  0  0  0 ];
            
            coefExpctd(:,:,2,3) = [
                0  0  0  0 ;
                0  0  0  0 ;
                0  0  0  0 ;
                0  0  0  0 ];
            
            coefExpctd(:,:,3,3) = [
                0  0  0  0 ;
                0  0  0  0 ;
                0  0  0  0 ;
                0  0  0  0 ];
            
            % Instantiation of target class
            import saivdr.dictionary.nsolt.*            
            testCase.lppufb = OvsdLpPuFb2dTypeIVm1System(...
                'DecimationFactor',dec,...
                'PolyPhaseOrder',ord);
                            
            % Actual values
            coefActual = step(testCase.lppufb,ang,[]);
            
            % Evaluation
            coefDist = max(abs(coefExpctd(:)-coefActual(:))...
                ./(abs(coefExpctd(:))));
            testCase.verifyEqual(coefActual,coefExpctd,'RelTol',1e-15,...
                sprintf('%g',coefDist));
            
        end
        
        % Test dec 2 2 order 2 2
        function testConstructorWithDec22Ord22Ang(testCase)
            
            % Parameters
            dec = [ 2 2 ];
            ord = [ 2 2 ];
            ang = 2*pi*rand(1,6);
            
            % Expected values
            nDecs = prod(dec);
            dimExpctd = [nDecs nDecs ord(1)+1 ord(2)+1];
            
            % Instantiation of target class
            import saivdr.dictionary.nsolt.*            
            testCase.lppufb = OvsdLpPuFb2dTypeIVm1System(...
                'DecimationFactor',dec,...
                'PolyPhaseOrder',ord);
                            
            % Actual values
            coefActual = step(testCase.lppufb,ang,[]);
            
            % Evaluation
            testCase.verifySize(coefActual,dimExpctd);
            
            % Check symmetry
            import matlab.unittest.constraints.IsLessThan
            coefEvn = coefActual(1:ceil(end/2),:);
            coefDiff = coefEvn-fliplr(coefEvn);
            coefDist = norm(coefDiff(:))/sqrt(numel(coefDiff));
            testCase.verifyThat(coefDist,IsLessThan(1e-15),...
                sprintf('%g',coefDist));
            coefOdd = coefActual(ceil(end/2)+1:end,:);
            coefDiff = coefOdd+fliplr(coefOdd);
            coefDist = norm(coefDiff(:))/sqrt(numel(coefDiff));
            testCase.verifyThat(coefDist,IsLessThan(1e-15),...
                sprintf('%g',coefDist));
            
            % Check orthogonality
            coefE = step(testCase.lppufb,[],[]); 
            E = saivdr.dictionary.utility.PolyPhaseMatrix2d(coefE);
            coefActual = double(E.'*E);
            coefActual(1:nDecs,1:nDecs,ord(1)+1,ord(2)+1) = ...
                coefActual(1:nDecs,1:nDecs,ord(1)+1,ord(2)+1) - eye(nDecs);
            coefDist = norm(coefActual(:))/sqrt(numel(coefActual));
            testCase.verifyTrue(coefDist<1e-15,sprintf('%g',coefDist));
            
        end
        
        % Test dec 1 1 ch 4 order 3 3
        function testConstructorWithDec11Ch4Ord33(testCase)
            
            % Parameters
            decch = [ 1 1 4 ];
            ord = [ 3 3 ];
            ang = 2*pi*rand(1,8);
            
            % Expected values
              % Expected values
            nChs = decch(3);
            nDec = decch(1)*decch(2);
            dimExpctd = [nChs nDec ord(1)+1 ord(2)+1];
            
            % Instantiation of target class
            import saivdr.dictionary.nsolt.*            
            testCase.lppufb = OvsdLpPuFb2dTypeIVm1System(...
                'DecimationFactor',decch(1:2),...
                'NumberOfChannels',decch(3:end),...
                'PolyPhaseOrder',ord);
                            
            % Actual values
            coefActual = step(testCase.lppufb,ang,[]);
            
            % Evaluation
            testCase.verifySize(coefActual,dimExpctd);
            
            % Check symmetry
            import matlab.unittest.constraints.IsLessThan
            coefEvn = coefActual(1:ceil(end/2),:);
            coefDiff = coefEvn-fliplr(coefEvn);
            coefDist = norm(coefDiff(:))/sqrt(numel(coefDiff));
            testCase.verifyThat(coefDist,IsLessThan(1e-15),...
                sprintf('%g',coefDist));
            coefOdd = coefActual(ceil(end/2)+1:end,:);
            coefDiff = coefOdd+fliplr(coefOdd);
            coefDist = norm(coefDiff(:))/sqrt(numel(coefDiff));
            testCase.verifyThat(coefDist,IsLessThan(1e-15),...
                sprintf('%g',coefDist));
            
            % Check tightness
            coefE = step(testCase.lppufb,[],[]); 
            E = saivdr.dictionary.utility.PolyPhaseMatrix2d(coefE);
            coefActual = double(E.'*E);
            coefActual(1:nDec,1:nDec,ord(1)+1,ord(2)+1) = ...
                coefActual(1:nDec,1:nDec,ord(1)+1,ord(2)+1) - eye(nDec);
            coefDist = norm(coefActual(:))/sqrt(numel(coefActual));
            testCase.verifyTrue(coefDist<1e-15,sprintf('%g',coefDist));
            
        end     
        
        % Test dec 1 1 ch 4 order 4 4
        function testConstructorWithDec11Ch4Ord44(testCase)
            
            % Parameters
            decch = [ 1 1 4 ];
            ord = [ 4 4 ];
            ang = 2*pi*rand(1,10);
            
            % Expected values
              % Expected values
            nChs = decch(3);
            nDec = decch(1)*decch(2);
            dimExpctd = [nChs nDec ord(1)+1 ord(2)+1];
            
            % Instantiation of target class
            import saivdr.dictionary.nsolt.*            
            testCase.lppufb = OvsdLpPuFb2dTypeIVm1System(...
                'DecimationFactor',decch(1:2),...
                'NumberOfChannels',decch(3:end),...
                'PolyPhaseOrder',ord);
                            
            % Actual values
            coefActual = step(testCase.lppufb,ang,[]);
            
            % Evaluation
            testCase.verifySize(coefActual,dimExpctd);
            
            % Check symmetry
            import matlab.unittest.constraints.IsLessThan
            coefEvn = coefActual(1:ceil(end/2),:);
            coefDiff = coefEvn-fliplr(coefEvn);
            coefDist = norm(coefDiff(:))/sqrt(numel(coefDiff));
            testCase.verifyThat(coefDist,IsLessThan(1e-15),...
                sprintf('%g',coefDist));
            coefOdd = coefActual(ceil(end/2)+1:end,:);
            coefDiff = coefOdd+fliplr(coefOdd);
            coefDist = norm(coefDiff(:))/sqrt(numel(coefDiff));
            testCase.verifyThat(coefDist,IsLessThan(1e-15),...
                sprintf('%g',coefDist));
            
            % Check tightness
            coefE = step(testCase.lppufb,[],[]); 
            E = saivdr.dictionary.utility.PolyPhaseMatrix2d(coefE);
            coefActual = double(E.'*E);
            coefActual(1:nDec,1:nDec,ord(1)+1,ord(2)+1) = ...
                coefActual(1:nDec,1:nDec,ord(1)+1,ord(2)+1) - eye(nDec);
            coefDist = norm(coefActual(:))/sqrt(numel(coefActual));
            testCase.verifyTrue(coefDist<1e-15,sprintf('%g',coefDist));
            
        end     
        
        
         % Test dec 2 2 ch 4 order 2 2
        function testConstructorWithDec22Ch4Ord22Ang(testCase)
            
            % Parameters
            decch = [ 2 2 4 ];
            ord = [ 2 2 ];
            ang = 2*pi*rand(1,6);
            
            % Expected values
              % Expected values
            nChs = decch(3);
            nDec = decch(1)*decch(2);
            dimExpctd = [nChs nDec ord(1)+1 ord(2)+1];
            
            % Instantiation of target class
            import saivdr.dictionary.nsolt.*            
            testCase.lppufb = OvsdLpPuFb2dTypeIVm1System(...
                'DecimationFactor',decch(1:2),...
                'NumberOfChannels',decch(3:end),...
                'PolyPhaseOrder',ord);
            
            % Actual values
            coefActual = step(testCase.lppufb,ang,[]);
            
            % Evaluation
            testCase.verifySize(coefActual,dimExpctd);
            
            % Check symmetry
            import matlab.unittest.constraints.IsLessThan
            coefEvn = coefActual(1:ceil(end/2),:);
            coefDiff = coefEvn-fliplr(coefEvn);
            coefDist = norm(coefDiff(:))/sqrt(numel(coefDiff));
            testCase.verifyThat(coefDist,IsLessThan(1e-15),...
                sprintf('%g',coefDist));
            coefOdd = coefActual(ceil(end/2)+1:end,:);
            coefDiff = coefOdd+fliplr(coefOdd);
            coefDist = norm(coefDiff(:))/sqrt(numel(coefDiff));
            testCase.verifyThat(coefDist,IsLessThan(1e-15),...
                sprintf('%g',coefDist));
            
            % Check tightness
            coefE = step(testCase.lppufb,[],[]);
            E = saivdr.dictionary.utility.PolyPhaseMatrix2d(coefE);
            coefActual = double(E.'*E);
            coefActual(1:nDec,1:nDec,ord(1)+1,ord(2)+1) = ...
                coefActual(1:nDec,1:nDec,ord(1)+1,ord(2)+1) - eye(nDec);
            coefDist = norm(coefActual(:))/sqrt(numel(coefActual));
            testCase.verifyTrue(coefDist<1e-15,sprintf('%g',coefDist));
            
        end
        
        % Test dec 2 2 order 0 4
        function testConstructorWithDec22Ord04(testCase)
            
            % Parameters
            dec = [ 2 2 ];
            ord = [ 0 4 ];
            ang = 0;
            
            % Expected values
            coefExpctd(:,:,1,1) = [
                0  0  0  0 ;
                0  0  0  0 ;
                0  0  0  0 ;
                0  0  0  0 ];
            
            coefExpctd(:,:,1,2) = [
                0  0  0  0 ;
                0  0  0  0 ;
                0  0  0  0 ;
                0  0  0  0 ];
            
            coefExpctd(:,:,1,3) = 1/2 * [
                1  1  1  1 ;
                1 -1 -1  1 ;
                -1  1 -1  1 ;
                -1 -1  1  1 ];
            
            coefExpctd(:,:,1,4) = [
                0  0  0  0 ;
                0  0  0  0 ;
                0  0  0  0 ;
                0  0  0  0 ];
            
            coefExpctd(:,:,1,5) = [
                0  0  0  0 ;
                0  0  0  0 ;
                0  0  0  0 ;
                0  0  0  0 ];
            
            % Instantiation of target class
            import saivdr.dictionary.nsolt.*            
            testCase.lppufb = OvsdLpPuFb2dTypeIVm1System(...
                'DecimationFactor',dec,...
                'PolyPhaseOrder',ord);
                            
            % Actual values
            coefActual = step(testCase.lppufb,ang,[]);
            
            % Evaluation
            coefDist = max(abs(coefExpctd(:)-coefActual(:))...
                ./(abs(coefExpctd(:))));
            testCase.verifyEqual(coefActual,coefExpctd,'RelTol',1e-15,...
                sprintf('%g',coefDist));
            
        end
        
        % Test for construction with order 0 4
        function testConstructorWithDec22Ord04Ang(testCase)
            
            % Parameters
            dec = [ 2 2 ];
            ord = [ 0 4 ];
            ang = 2*pi*rand(1,6);
            
            % Expected values
            nDecs = prod(dec);
            dimExpctd = [nDecs nDecs ord(1)+1 ord(2)+1];
            
            % Instantiation of target class
            import saivdr.dictionary.nsolt.*            
            testCase.lppufb = OvsdLpPuFb2dTypeIVm1System(...
                'DecimationFactor',dec,...
                'PolyPhaseOrder',ord);
                            
            % Actual values
            coefActual = step(testCase.lppufb,ang,[]);
            
            % Evaluation
            testCase.verifySize(coefActual,dimExpctd);
            
            % Check symmetry
            import matlab.unittest.constraints.IsLessThan
            coefEvn = coefActual(1:ceil(end/2),:);
            coefDiff = coefEvn-fliplr(coefEvn);
            coefDist = norm(coefDiff(:))/sqrt(numel(coefDiff));
            testCase.verifyThat(coefDist,IsLessThan(1e-15),...
                sprintf('%g',coefDist));
            coefOdd = coefActual(ceil(end/2)+1:end,:);
            coefDiff = coefOdd+fliplr(coefOdd);
            coefDist = norm(coefDiff(:))/sqrt(numel(coefDiff));
            testCase.verifyThat(coefDist,IsLessThan(1e-15),...
                sprintf('%g',coefDist));
            
            % Check orthogonality
            coefE = step(testCase.lppufb,[],[]); 
            E = saivdr.dictionary.utility.PolyPhaseMatrix2d(coefE);
            coefActual = double(E.'*E);
            coefActual(1:nDecs,1:nDecs,ord(1)+1,ord(2)+1) = ...
                coefActual(1:nDecs,1:nDecs,ord(1)+1,ord(2)+1) - eye(nDecs);
            coefDist = norm(coefActual(:))/sqrt(numel(coefActual));
            testCase.verifyTrue(coefDist<1e-15,sprintf('%g',coefDist));
            
        end
        
        % Test dec 2 2 order 0 4
        function testConstructorWithDec22Ord40(testCase)
            
            % Parameters
            dec = [ 2 2 ];
            ord = [ 4 0 ];
            ang = 0;
            
            % Expected values
            coefExpctd(:,:,1) = [
                0  0  0  0 ;
                0  0  0  0 ;
                0  0  0  0 ;
                0  0  0  0 ];
            
            coefExpctd(:,:,2) = [
                0  0  0  0 ;
                0  0  0  0 ;
                0  0  0  0 ;
                0  0  0  0 ];
            
            coefExpctd(:,:,3) = 1/2 * [
                1  1  1  1 ;
                1 -1 -1  1 ;
                -1  1 -1  1 ;
                -1 -1  1  1 ];
            
            coefExpctd(:,:,4) = [
                0  0  0  0 ;
                0  0  0  0 ;
                0  0  0  0 ;
                0  0  0  0 ];
            
            coefExpctd(:,:,5) = [
                0  0  0  0 ;
                0  0  0  0 ;
                0  0  0  0 ;
                0  0  0  0 ];
            
            % Instantiation of target class
            import saivdr.dictionary.nsolt.*            
            testCase.lppufb = OvsdLpPuFb2dTypeIVm1System(...
                'DecimationFactor',dec,...
                'PolyPhaseOrder',ord);
            
            % Actual values
            coefActual = step(testCase.lppufb,ang,[]);
            
            % Evaluation
            coefDist = max(abs(coefExpctd(:)-coefActual(:))...
                ./(abs(coefExpctd(:))));
            testCase.verifyEqual(coefActual,coefExpctd,'RelTol',1e-15,...
                sprintf('%g',coefDist));
            
        end
        
        % Test for construction with order 4 0
        function testConstructorWithDec22Ord40Ang(testCase)
            
            % Parameters
            dec = [ 2 2 ];
            ord = [ 4 0 ];
            ang = 2*pi*rand(1,6);
            
            % Expected values
            nDecs = prod(dec);
            dimExpctd = [nDecs nDecs ord(1)+1];
            
            % Instantiation of target class
            import saivdr.dictionary.nsolt.*            
            testCase.lppufb = OvsdLpPuFb2dTypeIVm1System(...
                'DecimationFactor',dec,...
                'PolyPhaseOrder',ord);
                            
            % Actual values
            coefActual = step(testCase.lppufb,ang,[]);
            
            % Evaluation
            testCase.verifySize(coefActual,dimExpctd);
            
            % Check symmetry
            import matlab.unittest.constraints.IsLessThan
            coefEvn = coefActual(1:ceil(end/2),:);
            coefDiff = coefEvn-fliplr(coefEvn);
            coefDist = norm(coefDiff(:))/sqrt(numel(coefDiff));
            testCase.verifyThat(coefDist,IsLessThan(1e-15),...
                sprintf('%g',coefDist));
            coefOdd = coefActual(ceil(end/2)+1:end,:);
            coefDiff = coefOdd+fliplr(coefOdd);
            coefDist = norm(coefDiff(:))/sqrt(numel(coefDiff));
            testCase.verifyThat(coefDist,IsLessThan(1e-15),...
                sprintf('%g',coefDist));
            
            % Check orthogonality
            coefE = step(testCase.lppufb,[],[]); 
            E = saivdr.dictionary.utility.PolyPhaseMatrix2d(coefE);
            coefActual = double(E.'*E);
            coefActual(1:nDecs,1:nDecs,ord(1)+1,ord(2)+1) = ...
                coefActual(1:nDecs,1:nDecs,ord(1)+1,ord(2)+1) - eye(nDecs);
            coefDist = norm(coefActual(:))/sqrt(numel(coefActual));
            testCase.verifyTrue(coefDist<1e-15,sprintf('%g',coefDist));
            
        end
        
        % Test dec 2 2 order 2 2
        function testConstructorWithDec22Ord44(testCase)
            
            % Parameters
            dec = [ 2 2 ];
            ord = [ 4 4 ];
            ang = 0;
            
            % Expected values
            coefExpctd(:,:,1,1) = [
                0  0  0  0 ;
                0  0  0  0 ;
                0  0  0  0 ;
                0  0  0  0 ];
            
            coefExpctd(:,:,2,1) = [
                0  0  0  0 ;
                0  0  0  0 ;
                0  0  0  0 ;
                0  0  0  0 ];
            
            coefExpctd(:,:,3,1) = [
                0  0  0  0 ;
                0  0  0  0 ;
                0  0  0  0 ;
                0  0  0  0 ];
            
            coefExpctd(:,:,4,1) = [
                0  0  0  0 ;
                0  0  0  0 ;
                0  0  0  0 ;
                0  0  0  0 ];
            
            coefExpctd(:,:,5,1) = [
                0  0  0  0 ;
                0  0  0  0 ;
                0  0  0  0 ;
                0  0  0  0 ];
            
            coefExpctd(:,:,1,2) = [
                0  0  0  0 ;
                0  0  0  0 ;
                0  0  0  0 ;
                0  0  0  0 ];
            
            coefExpctd(:,:,2,2) = [
                0  0  0  0 ;
                0  0  0  0 ;
                0  0  0  0 ;
                0  0  0  0 ];
            
            coefExpctd(:,:,3,2) = [
                0  0  0  0 ;
                0  0  0  0 ;
                0  0  0  0 ;
                0  0  0  0 ];
            
            coefExpctd(:,:,4,2) = [
                0  0  0  0 ;
                0  0  0  0 ;
                0  0  0  0 ;
                0  0  0  0 ];
            
            coefExpctd(:,:,5,2) = [
                0  0  0  0 ;
                0  0  0  0 ;
                0  0  0  0 ;
                0  0  0  0 ];
            
            coefExpctd(:,:,1,3) = [
                0  0  0  0 ;
                0  0  0  0 ;
                0  0  0  0 ;
                0  0  0  0 ];
            
            coefExpctd(:,:,2,3) = [
                0  0  0  0 ;
                0  0  0  0 ;
                0  0  0  0 ;
                0  0  0  0 ];
            
            coefExpctd(:,:,3,3) = 1/2 * [
                1  1  1  1 ;
                1 -1 -1  1 ;
                -1  1 -1  1 ;
                -1 -1  1  1 ];
            
            coefExpctd(:,:,4,3) = [
                0  0  0  0 ;
                0  0  0  0 ;
                0  0  0  0 ;
                0  0  0  0 ];
            
            coefExpctd(:,:,5,3) = [
                0  0  0  0 ;
                0  0  0  0 ;
                0  0  0  0 ;
                0  0  0  0 ];
            
            coefExpctd(:,:,1,1) = [
                0  0  0  0 ;
                0  0  0  0 ;
                0  0  0  0 ;
                0  0  0  0 ];
            
            coefExpctd(:,:,2,4) = [
                0  0  0  0 ;
                0  0  0  0 ;
                0  0  0  0 ;
                0  0  0  0 ];
            
            coefExpctd(:,:,3,4) = [
                0  0  0  0 ;
                0  0  0  0 ;
                0  0  0  0 ;
                0  0  0  0 ];
            
            coefExpctd(:,:,4,4) = [
                0  0  0  0 ;
                0  0  0  0 ;
                0  0  0  0 ;
                0  0  0  0 ];
            
            coefExpctd(:,:,5,4) = [
                0  0  0  0 ;
                0  0  0  0 ;
                0  0  0  0 ;
                0  0  0  0 ];
            
            coefExpctd(:,:,1,5) = [
                0  0  0  0 ;
                0  0  0  0 ;
                0  0  0  0 ;
                0  0  0  0 ];
            
            coefExpctd(:,:,2,5) = [
                0  0  0  0 ;
                0  0  0  0 ;
                0  0  0  0 ;
                0  0  0  0 ];
            
            coefExpctd(:,:,3,5) = [
                0  0  0  0 ;
                0  0  0  0 ;
                0  0  0  0 ;
                0  0  0  0 ];
            
            coefExpctd(:,:,4,5) = [
                0  0  0  0 ;
                0  0  0  0 ;
                0  0  0  0 ;
                0  0  0  0 ];
            
            coefExpctd(:,:,5,5) = [
                0  0  0  0 ;
                0  0  0  0 ;
                0  0  0  0 ;
                0  0  0  0 ];
            
            % Instantiation of target class
            import saivdr.dictionary.nsolt.*            
            testCase.lppufb = OvsdLpPuFb2dTypeIVm1System(...
                'DecimationFactor',dec,...
                'PolyPhaseOrder',ord);
                            
            % Actual values
            coefActual = step(testCase.lppufb,ang,[]);

            % Evaluation
            coefDist = max(abs(coefExpctd(:)-coefActual(:))...
                ./(abs(coefExpctd(:))));
            testCase.verifyEqual(coefActual,coefExpctd,'RelTol',1e-15,...
                sprintf('%g',coefDist));
            
        end
        
        % Test dec 2 2 order 2 2
        function testConstructorWithDec22Ord44Ang(testCase)
            
            % Parameters
            dec = [ 2 2 ];
            ord = [ 4 4 ];
            ang = 2*pi*rand(1,10);
            
            % Expected values
            nDecs = prod(dec);
            dimExpctd = [nDecs nDecs ord(1)+1 ord(2)+1];
            
            % Instantiation of target class
            import saivdr.dictionary.nsolt.*            
            testCase.lppufb = OvsdLpPuFb2dTypeIVm1System(...
                'DecimationFactor',dec,...
                'PolyPhaseOrder',ord);
                            
            % Actual values
            coefActual = step(testCase.lppufb,ang,[]);
            
            % Evaluation
            testCase.verifySize(coefActual,dimExpctd);
            
            % Check symmetry
            import matlab.unittest.constraints.IsLessThan
            coefEvn = coefActual(1:ceil(end/2),:);
            coefDiff = coefEvn-fliplr(coefEvn);
            coefDist = norm(coefDiff(:))/sqrt(numel(coefDiff));
            testCase.verifyThat(coefDist,IsLessThan(1e-15),...
                sprintf('%g',coefDist));
            coefOdd = coefActual(ceil(end/2)+1:end,:);
            coefDiff = coefOdd+fliplr(coefOdd);
            coefDist = norm(coefDiff(:))/sqrt(numel(coefDiff));
            testCase.verifyThat(coefDist,IsLessThan(1e-15),...
                sprintf('%g',coefDist));
            
            % Check orthogonality
            coefE = step(testCase.lppufb,[],[]); 
            E = saivdr.dictionary.utility.PolyPhaseMatrix2d(coefE);
            coefActual = double(E.'*E);
            coefActual(1:nDecs,1:nDecs,ord(1)+1,ord(2)+1) = ...
                coefActual(1:nDecs,1:nDecs,ord(1)+1,ord(2)+1) - eye(nDecs);
            coefDist = norm(coefActual(:))/sqrt(numel(coefActual));
            testCase.verifyTrue(coefDist<1e-15,sprintf('%g',coefDist));
            
        end
        
        % Test dec 4 4 order 0 2
        function testConstructorWithDec44Ord02(testCase)
            
            % Parameters
            dec = [ 4 4 ];
            ord = [ 0 2 ];
            ang = 0;
            
            % Expected values
            coefExpctd(:,:,1,1) = zeros(16,16);
            
            coefExpctd(:,1:4,1,2) = [
                0.250000000000000   0.250000000000000   0.250000000000000   0.250000000000000
                0.250000000000000  -0.250000000000000  -0.250000000000000   0.250000000000000
                0.250000000000000   0.250000000000000   0.250000000000000   0.250000000000000
                0.250000000000000  -0.250000000000000  -0.250000000000000   0.250000000000000
                0.426776695296637   0.176776695296637  -0.176776695296637  -0.426776695296637
                0.176776695296637  -0.426776695296637   0.426776695296637  -0.176776695296637
                0.176776695296637   0.073223304703363  -0.073223304703363  -0.176776695296637
                0.073223304703363  -0.176776695296637   0.176776695296637  -0.073223304703363
                -0.326640741219094  -0.135299025036549   0.135299025036549   0.326640741219094
                -0.135299025036549   0.326640741219094  -0.326640741219094   0.135299025036549
                -0.326640741219094  -0.135299025036549   0.135299025036549   0.326640741219094
                -0.135299025036549   0.326640741219094  -0.326640741219094   0.135299025036549
                -0.326640741219094  -0.326640741219094  -0.326640741219094  -0.326640741219094
                -0.326640741219094   0.326640741219094   0.326640741219094  -0.326640741219094
                -0.135299025036549  -0.135299025036549  -0.135299025036549  -0.135299025036549
                -0.135299025036549   0.135299025036549   0.135299025036549  -0.135299025036549 ];
            
            coefExpctd(:,5:8,1,2) = [
                0.250000000000000   0.250000000000000   0.250000000000000   0.250000000000000
                0.250000000000000  -0.250000000000000  -0.250000000000000   0.250000000000000
                -0.250000000000000  -0.250000000000000  -0.250000000000000  -0.250000000000000
                -0.250000000000000   0.250000000000000   0.250000000000000  -0.250000000000000
                0.176776695296637   0.073223304703363  -0.073223304703363  -0.176776695296637
                0.073223304703363  -0.176776695296637   0.176776695296637  -0.073223304703363
                -0.426776695296637  -0.176776695296637   0.176776695296637   0.426776695296637
                -0.176776695296637   0.426776695296637  -0.426776695296637   0.176776695296637
                -0.326640741219094  -0.135299025036549   0.135299025036549   0.326640741219094
                -0.135299025036549   0.326640741219094  -0.326640741219094   0.135299025036549
                0.326640741219094   0.135299025036549  -0.135299025036549  -0.326640741219094
                0.135299025036549  -0.326640741219094   0.326640741219094  -0.135299025036549
                -0.135299025036549  -0.135299025036549  -0.135299025036549  -0.135299025036549
                -0.135299025036549   0.135299025036549   0.135299025036549  -0.135299025036549
                0.326640741219094   0.326640741219094   0.326640741219094   0.326640741219094
                0.326640741219094  -0.326640741219094  -0.326640741219094   0.326640741219094 ];
            
            coefExpctd(:,9:12,1,2) = [
                0.250000000000000   0.250000000000000   0.250000000000000   0.250000000000000
                0.250000000000000  -0.250000000000000  -0.250000000000000   0.250000000000000
                -0.250000000000000  -0.250000000000000  -0.250000000000000  -0.250000000000000
                -0.250000000000000   0.250000000000000   0.250000000000000  -0.250000000000000
                -0.176776695296637  -0.073223304703363   0.073223304703363   0.176776695296637
                -0.073223304703363   0.176776695296637  -0.176776695296637   0.073223304703363
                0.426776695296637   0.176776695296637  -0.176776695296637  -0.426776695296637
                0.176776695296637  -0.426776695296637   0.426776695296637  -0.176776695296637
                -0.326640741219094  -0.135299025036549   0.135299025036549   0.326640741219094
                -0.135299025036549   0.326640741219094  -0.326640741219094   0.135299025036549
                0.326640741219094   0.135299025036549  -0.135299025036549  -0.326640741219094
                0.135299025036549  -0.326640741219094   0.326640741219094  -0.135299025036549
                0.135299025036549   0.135299025036549   0.135299025036549   0.135299025036549
                0.135299025036549  -0.135299025036549  -0.135299025036549   0.135299025036549
                -0.326640741219094  -0.326640741219094  -0.326640741219094  -0.326640741219094
                -0.326640741219094   0.326640741219094   0.326640741219094  -0.326640741219094 ];
            
            coefExpctd(:,13:16,1,2) = [
                0.250000000000000   0.250000000000000   0.250000000000000   0.250000000000000
                0.250000000000000  -0.250000000000000  -0.250000000000000   0.250000000000000
                0.250000000000000   0.250000000000000   0.250000000000000   0.250000000000000
                0.250000000000000  -0.250000000000000  -0.250000000000000   0.250000000000000
                -0.426776695296637  -0.176776695296637   0.176776695296637   0.426776695296637
                -0.176776695296637   0.426776695296637  -0.426776695296637   0.176776695296637
                -0.176776695296637  -0.073223304703363   0.073223304703363   0.176776695296637
                -0.073223304703363   0.176776695296637  -0.176776695296637   0.073223304703363
                -0.326640741219094  -0.135299025036549   0.135299025036549   0.326640741219094
                -0.135299025036549   0.326640741219094  -0.326640741219094   0.135299025036549
                -0.326640741219094  -0.135299025036549   0.135299025036549   0.326640741219094
                -0.135299025036549   0.326640741219094  -0.326640741219094   0.135299025036549
                0.326640741219094   0.326640741219094   0.326640741219094   0.326640741219094
                0.326640741219094  -0.326640741219094  -0.326640741219094   0.326640741219094
                0.135299025036549   0.135299025036549   0.135299025036549   0.135299025036549
                0.135299025036549  -0.135299025036549  -0.135299025036549   0.135299025036549 ];
            
            coefExpctd(:,:,1,3) = zeros(16,16);
            
            % Instantiation of target class
            import saivdr.dictionary.nsolt.*            
            testCase.lppufb = OvsdLpPuFb2dTypeIVm1System(...
                'DecimationFactor',dec,...
                'PolyPhaseOrder',ord);
                            
            % Actual values
            coefActual = step(testCase.lppufb,ang,[]);
            
            % Evaluation
            coefDist = max(abs(coefExpctd(:)-coefActual(:))...
                ./(abs(coefExpctd(:))));
            testCase.verifyEqual(coefActual,coefExpctd,'RelTol',1e-14,...
                sprintf('%g',coefDist));
            
        end
        
        % Test dec 2 2 order 0 2
        function testConstructorWithDec44Ord02Ang(testCase)
            
            % Parameters
            dec = [ 4 4 ];
            ord = [ 0 2 ];
            ang = 2*pi*rand(28,4);
            
            % Expected values
            nDecs = prod(dec);
            dimExpctd = [nDecs nDecs ord(1)+1 ord(2)+1];
            
            % Instantiation of target class
            import saivdr.dictionary.nsolt.*            
            testCase.lppufb = OvsdLpPuFb2dTypeIVm1System(...
                'DecimationFactor',dec,...
                'PolyPhaseOrder',ord);
                            
            % Actual values
            coefActual = step(testCase.lppufb,ang,[]);
            
            % Evaluation
            testCase.verifySize(coefActual,dimExpctd);
            
            % Check symmetry
            import matlab.unittest.constraints.IsLessThan
            coefEvn = coefActual(1:ceil(end/2),:);
            coefDiff = coefEvn-fliplr(coefEvn);
            coefDist = norm(coefDiff(:))/sqrt(numel(coefDiff));
            testCase.verifyThat(coefDist,IsLessThan(1e-15),...
                sprintf('%g',coefDist));
            coefOdd = coefActual(ceil(end/2)+1:end,:);
            coefDiff = coefOdd+fliplr(coefOdd);
            coefDist = norm(coefDiff(:))/sqrt(numel(coefDiff));
            testCase.verifyThat(coefDist,IsLessThan(1e-15),...
                sprintf('%g',coefDist));
            
            % Check orthogonality
            coefE = step(testCase.lppufb,[],[]); 
            E = saivdr.dictionary.utility.PolyPhaseMatrix2d(coefE);
            coefActual = double(E.'*E);
            coefActual(1:nDecs,1:nDecs,ord(1)+1,ord(2)+1) = ...
                coefActual(1:nDecs,1:nDecs,ord(1)+1,ord(2)+1) - eye(nDecs);
            coefDist = norm(coefActual(:))/sqrt(numel(coefActual));
            testCase.verifyTrue(coefDist<1e-15,sprintf('%g',coefDist));
            
        end
        
        % Test dec 4 4 order 2 0
        function testConstructorWithDec44Ord20(testCase)
            
            % Parameters
            dec = [ 4 4 ];
            ord = [ 2 0 ];
            ang = 0;
            
            % Expected values
            coefExpctd(:,:,1) = zeros(16,16);
            
            coefExpctd(:,1:4,2) = [
                0.250000000000000   0.250000000000000   0.250000000000000   0.250000000000000
                0.250000000000000  -0.250000000000000  -0.250000000000000   0.250000000000000
                0.250000000000000   0.250000000000000   0.250000000000000   0.250000000000000
                0.250000000000000  -0.250000000000000  -0.250000000000000   0.250000000000000
                0.426776695296637   0.176776695296637  -0.176776695296637  -0.426776695296637
                0.176776695296637  -0.426776695296637   0.426776695296637  -0.176776695296637
                0.176776695296637   0.073223304703363  -0.073223304703363  -0.176776695296637
                0.073223304703363  -0.176776695296637   0.176776695296637  -0.073223304703363
                -0.326640741219094  -0.135299025036549   0.135299025036549   0.326640741219094
                -0.135299025036549   0.326640741219094  -0.326640741219094   0.135299025036549
                -0.326640741219094  -0.135299025036549   0.135299025036549   0.326640741219094
                -0.135299025036549   0.326640741219094  -0.326640741219094   0.135299025036549
                -0.326640741219094  -0.326640741219094  -0.326640741219094  -0.326640741219094
                -0.326640741219094   0.326640741219094   0.326640741219094  -0.326640741219094
                -0.135299025036549  -0.135299025036549  -0.135299025036549  -0.135299025036549
                -0.135299025036549   0.135299025036549   0.135299025036549  -0.135299025036549 ];
            
            coefExpctd(:,5:8,2) = [
                0.250000000000000   0.250000000000000   0.250000000000000   0.250000000000000
                0.250000000000000  -0.250000000000000  -0.250000000000000   0.250000000000000
                -0.250000000000000  -0.250000000000000  -0.250000000000000  -0.250000000000000
                -0.250000000000000   0.250000000000000   0.250000000000000  -0.250000000000000
                0.176776695296637   0.073223304703363  -0.073223304703363  -0.176776695296637
                0.073223304703363  -0.176776695296637   0.176776695296637  -0.073223304703363
                -0.426776695296637  -0.176776695296637   0.176776695296637   0.426776695296637
                -0.176776695296637   0.426776695296637  -0.426776695296637   0.176776695296637
                -0.326640741219094  -0.135299025036549   0.135299025036549   0.326640741219094
                -0.135299025036549   0.326640741219094  -0.326640741219094   0.135299025036549
                0.326640741219094   0.135299025036549  -0.135299025036549  -0.326640741219094
                0.135299025036549  -0.326640741219094   0.326640741219094  -0.135299025036549
                -0.135299025036549  -0.135299025036549  -0.135299025036549  -0.135299025036549
                -0.135299025036549   0.135299025036549   0.135299025036549  -0.135299025036549
                0.326640741219094   0.326640741219094   0.326640741219094   0.326640741219094
                0.326640741219094  -0.326640741219094  -0.326640741219094   0.326640741219094 ];
            
            coefExpctd(:,9:12,2) = [
                0.250000000000000   0.250000000000000   0.250000000000000   0.250000000000000
                0.250000000000000  -0.250000000000000  -0.250000000000000   0.250000000000000
                -0.250000000000000  -0.250000000000000  -0.250000000000000  -0.250000000000000
                -0.250000000000000   0.250000000000000   0.250000000000000  -0.250000000000000
                -0.176776695296637  -0.073223304703363   0.073223304703363   0.176776695296637
                -0.073223304703363   0.176776695296637  -0.176776695296637   0.073223304703363
                0.426776695296637   0.176776695296637  -0.176776695296637  -0.426776695296637
                0.176776695296637  -0.426776695296637   0.426776695296637  -0.176776695296637
                -0.326640741219094  -0.135299025036549   0.135299025036549   0.326640741219094
                -0.135299025036549   0.326640741219094  -0.326640741219094   0.135299025036549
                0.326640741219094   0.135299025036549  -0.135299025036549  -0.326640741219094
                0.135299025036549  -0.326640741219094   0.326640741219094  -0.135299025036549
                0.135299025036549   0.135299025036549   0.135299025036549   0.135299025036549
                0.135299025036549  -0.135299025036549  -0.135299025036549   0.135299025036549
                -0.326640741219094  -0.326640741219094  -0.326640741219094  -0.326640741219094
                -0.326640741219094   0.326640741219094   0.326640741219094  -0.326640741219094 ];
            
            coefExpctd(:,13:16,2) = [
                0.250000000000000   0.250000000000000   0.250000000000000   0.250000000000000
                0.250000000000000  -0.250000000000000  -0.250000000000000   0.250000000000000
                0.250000000000000   0.250000000000000   0.250000000000000   0.250000000000000
                0.250000000000000  -0.250000000000000  -0.250000000000000   0.250000000000000
                -0.426776695296637  -0.176776695296637   0.176776695296637   0.426776695296637
                -0.176776695296637   0.426776695296637  -0.426776695296637   0.176776695296637
                -0.176776695296637  -0.073223304703363   0.073223304703363   0.176776695296637
                -0.073223304703363   0.176776695296637  -0.176776695296637   0.073223304703363
                -0.326640741219094  -0.135299025036549   0.135299025036549   0.326640741219094
                -0.135299025036549   0.326640741219094  -0.326640741219094   0.135299025036549
                -0.326640741219094  -0.135299025036549   0.135299025036549   0.326640741219094
                -0.135299025036549   0.326640741219094  -0.326640741219094   0.135299025036549
                0.326640741219094   0.326640741219094   0.326640741219094   0.326640741219094
                0.326640741219094  -0.326640741219094  -0.326640741219094   0.326640741219094
                0.135299025036549   0.135299025036549   0.135299025036549   0.135299025036549
                0.135299025036549  -0.135299025036549  -0.135299025036549   0.135299025036549 ];
            
            coefExpctd(:,:,3) = zeros(16,16);
            
            % Instantiation of target class
            import saivdr.dictionary.nsolt.*            
            testCase.lppufb = OvsdLpPuFb2dTypeIVm1System(...
                'DecimationFactor',dec,...
                'PolyPhaseOrder',ord);
                            
            % Actual values
            coefActual = step(testCase.lppufb,ang,[]);
            
            % Evaluation
            coefDist = max(abs(coefExpctd(:)-coefActual(:))...
                ./(abs(coefExpctd(:))));
            testCase.verifyEqual(coefActual,coefExpctd,'RelTol',1e-14,...
                sprintf('%g',coefDist));
            
        end
        
        % Test dec 4 4 order 2 0
        function testConstructorWithDec44Ord20Ang(testCase)
            
            % Parameters
            dec = [ 4 4 ];
            ord = [ 2 0 ];
            ang = 2*pi*rand(28,4);
            
            % Expected values
            nDecs = prod(dec);
            dimExpctd = [nDecs nDecs ord(1)+1];
            
            % Instantiation of target class
            import saivdr.dictionary.nsolt.*            
            testCase.lppufb = OvsdLpPuFb2dTypeIVm1System(...
                'DecimationFactor',dec,...
                'PolyPhaseOrder',ord);
                            
            % Actual values
            coefActual = step(testCase.lppufb,ang,[]);
            
            % Evaluation
            testCase.verifySize(coefActual,dimExpctd);
            
            % Check symmetry
            import matlab.unittest.constraints.IsLessThan
            coefEvn = coefActual(1:ceil(end/2),:);
            coefDiff = coefEvn-fliplr(coefEvn);
            coefDist = norm(coefDiff(:))/sqrt(numel(coefDiff));
            testCase.verifyThat(coefDist,IsLessThan(1e-15),...
                sprintf('%g',coefDist));
            coefOdd = coefActual(ceil(end/2)+1:end,:);
            coefDiff = coefOdd+fliplr(coefOdd);
            coefDist = norm(coefDiff(:))/sqrt(numel(coefDiff));
            testCase.verifyThat(coefDist,IsLessThan(1e-15),...
                sprintf('%g',coefDist));
            
            % Check orthogonality
            coefE = step(testCase.lppufb,[],[]); 
            E = saivdr.dictionary.utility.PolyPhaseMatrix2d(coefE);
            coefActual = double(E.'*E);
            coefActual(1:nDecs,1:nDecs,ord(1)+1,ord(2)+1) = ...
                coefActual(1:nDecs,1:nDecs,ord(1)+1,ord(2)+1) - eye(nDecs);
            coefDist = norm(coefActual(:))/sqrt(numel(coefActual));
            testCase.verifyTrue(coefDist<1e-15,sprintf('%g',coefDist));
            
        end
        
        % Test dec 4 4 order 0 4
        function testConstructorWithDec44Ord04(testCase)
            
            % Parameters
            dec = [ 4 4 ];
            ord = [ 0 4 ];
            ang = 0;
            
            % Expected values
            coefExpctd(:,:,1,1) = zeros(16,16);
            
            coefExpctd(:,:,1,2) = zeros(16,16);
            
            coefExpctd(:,1:4,1,3) = [
                0.250000000000000   0.250000000000000   0.250000000000000   0.250000000000000
                0.250000000000000  -0.250000000000000  -0.250000000000000   0.250000000000000
                0.250000000000000   0.250000000000000   0.250000000000000   0.250000000000000
                0.250000000000000  -0.250000000000000  -0.250000000000000   0.250000000000000
                0.426776695296637   0.176776695296637  -0.176776695296637  -0.426776695296637
                0.176776695296637  -0.426776695296637   0.426776695296637  -0.176776695296637
                0.176776695296637   0.073223304703363  -0.073223304703363  -0.176776695296637
                0.073223304703363  -0.176776695296637   0.176776695296637  -0.073223304703363
                -0.326640741219094  -0.135299025036549   0.135299025036549   0.326640741219094
                -0.135299025036549   0.326640741219094  -0.326640741219094   0.135299025036549
                -0.326640741219094  -0.135299025036549   0.135299025036549   0.326640741219094
                -0.135299025036549   0.326640741219094  -0.326640741219094   0.135299025036549
                -0.326640741219094  -0.326640741219094  -0.326640741219094  -0.326640741219094
                -0.326640741219094   0.326640741219094   0.326640741219094  -0.326640741219094
                -0.135299025036549  -0.135299025036549  -0.135299025036549  -0.135299025036549
                -0.135299025036549   0.135299025036549   0.135299025036549  -0.135299025036549 ];
            
            coefExpctd(:,5:8,1,3) = [
                0.250000000000000   0.250000000000000   0.250000000000000   0.250000000000000
                0.250000000000000  -0.250000000000000  -0.250000000000000   0.250000000000000
                -0.250000000000000  -0.250000000000000  -0.250000000000000  -0.250000000000000
                -0.250000000000000   0.250000000000000   0.250000000000000  -0.250000000000000
                0.176776695296637   0.073223304703363  -0.073223304703363  -0.176776695296637
                0.073223304703363  -0.176776695296637   0.176776695296637  -0.073223304703363
                -0.426776695296637  -0.176776695296637   0.176776695296637   0.426776695296637
                -0.176776695296637   0.426776695296637  -0.426776695296637   0.176776695296637
                -0.326640741219094  -0.135299025036549   0.135299025036549   0.326640741219094
                -0.135299025036549   0.326640741219094  -0.326640741219094   0.135299025036549
                0.326640741219094   0.135299025036549  -0.135299025036549  -0.326640741219094
                0.135299025036549  -0.326640741219094   0.326640741219094  -0.135299025036549
                -0.135299025036549  -0.135299025036549  -0.135299025036549  -0.135299025036549
                -0.135299025036549   0.135299025036549   0.135299025036549  -0.135299025036549
                0.326640741219094   0.326640741219094   0.326640741219094   0.326640741219094
                0.326640741219094  -0.326640741219094  -0.326640741219094   0.326640741219094 ];
            
            coefExpctd(:,9:12,1,3) = [
                0.250000000000000   0.250000000000000   0.250000000000000   0.250000000000000
                0.250000000000000  -0.250000000000000  -0.250000000000000   0.250000000000000
                -0.250000000000000  -0.250000000000000  -0.250000000000000  -0.250000000000000
                -0.250000000000000   0.250000000000000   0.250000000000000  -0.250000000000000
                -0.176776695296637  -0.073223304703363   0.073223304703363   0.176776695296637
                -0.073223304703363   0.176776695296637  -0.176776695296637   0.073223304703363
                0.426776695296637   0.176776695296637  -0.176776695296637  -0.426776695296637
                0.176776695296637  -0.426776695296637   0.426776695296637  -0.176776695296637
                -0.326640741219094  -0.135299025036549   0.135299025036549   0.326640741219094
                -0.135299025036549   0.326640741219094  -0.326640741219094   0.135299025036549
                0.326640741219094   0.135299025036549  -0.135299025036549  -0.326640741219094
                0.135299025036549  -0.326640741219094   0.326640741219094  -0.135299025036549
                0.135299025036549   0.135299025036549   0.135299025036549   0.135299025036549
                0.135299025036549  -0.135299025036549  -0.135299025036549   0.135299025036549
                -0.326640741219094  -0.326640741219094  -0.326640741219094  -0.326640741219094
                -0.326640741219094   0.326640741219094   0.326640741219094  -0.326640741219094 ];
            
            coefExpctd(:,13:16,1,3) = [
                0.250000000000000   0.250000000000000   0.250000000000000   0.250000000000000
                0.250000000000000  -0.250000000000000  -0.250000000000000   0.250000000000000
                0.250000000000000   0.250000000000000   0.250000000000000   0.250000000000000
                0.250000000000000  -0.250000000000000  -0.250000000000000   0.250000000000000
                -0.426776695296637  -0.176776695296637   0.176776695296637   0.426776695296637
                -0.176776695296637   0.426776695296637  -0.426776695296637   0.176776695296637
                -0.176776695296637  -0.073223304703363   0.073223304703363   0.176776695296637
                -0.073223304703363   0.176776695296637  -0.176776695296637   0.073223304703363
                -0.326640741219094  -0.135299025036549   0.135299025036549   0.326640741219094
                -0.135299025036549   0.326640741219094  -0.326640741219094   0.135299025036549
                -0.326640741219094  -0.135299025036549   0.135299025036549   0.326640741219094
                -0.135299025036549   0.326640741219094  -0.326640741219094   0.135299025036549
                0.326640741219094   0.326640741219094   0.326640741219094   0.326640741219094
                0.326640741219094  -0.326640741219094  -0.326640741219094   0.326640741219094
                0.135299025036549   0.135299025036549   0.135299025036549   0.135299025036549
                0.135299025036549  -0.135299025036549  -0.135299025036549   0.135299025036549 ];
            
            coefExpctd(:,:,1,4) = zeros(16,16);
            
            coefExpctd(:,:,1,5) = zeros(16,16);
            
            % Instantiation of target class
            import saivdr.dictionary.nsolt.*            
            testCase.lppufb = OvsdLpPuFb2dTypeIVm1System(...
                'DecimationFactor',dec,...
                'PolyPhaseOrder',ord);
                            
            % Actual values
            coefActual = step(testCase.lppufb,ang,[]);
            
            % Evaluation
            coefDist = max(abs(coefExpctd(:)-coefActual(:))...
                ./(abs(coefExpctd(:))));
            testCase.verifyEqual(coefActual,coefExpctd,'RelTol',1e-14,...
                sprintf('%g',coefDist));
            
        end
        
        % Test dec 4 4 order 0 4
        function testConstructorWithDec44Ord04Ang(testCase)
            
            % Parameters
            dec = [ 4 4 ];
            ord = [ 0 4 ];
            ang = 2*pi*rand(28,6);
            
            % Expected values
            nDecs = prod(dec);
            dimExpctd = [nDecs nDecs ord(1)+1 ord(2)+1];
            
            % Instantiation of target class
            import saivdr.dictionary.nsolt.*            
            testCase.lppufb = OvsdLpPuFb2dTypeIVm1System(...
                'DecimationFactor',dec,...
                'PolyPhaseOrder',ord);
                            
            % Actual values
            coefActual = step(testCase.lppufb,ang,[]);
            
            % Evaluation
            testCase.verifySize(coefActual,dimExpctd);
            
            % Check symmetry
            import matlab.unittest.constraints.IsLessThan
            coefEvn = coefActual(1:ceil(end/2),:);
            coefDiff = coefEvn-fliplr(coefEvn);
            coefDist = norm(coefDiff(:))/sqrt(numel(coefDiff));
            testCase.verifyThat(coefDist,IsLessThan(1e-15),...
                sprintf('%g',coefDist));
            coefOdd = coefActual(ceil(end/2)+1:end,:);
            coefDiff = coefOdd+fliplr(coefOdd);
            coefDist = norm(coefDiff(:))/sqrt(numel(coefDiff));
            testCase.verifyThat(coefDist,IsLessThan(1e-15),...
                sprintf('%g',coefDist));
            
            % Check orthogonality
            coefE = step(testCase.lppufb,[],[]); 
            E = saivdr.dictionary.utility.PolyPhaseMatrix2d(coefE);
            coefActual = double(E.'*E);
            coefActual(1:nDecs,1:nDecs,ord(1)+1,ord(2)+1) = ...
                coefActual(1:nDecs,1:nDecs,ord(1)+1,ord(2)+1) - eye(nDecs);
            coefDist = norm(coefActual(:))/sqrt(numel(coefActual));
            testCase.verifyTrue(coefDist<1e-15,sprintf('%g',coefDist));
            
        end
        
        % Test dec 4 4 order 4 0
        function testConstructorWithDec44Ord40(testCase)
            
            % Parameters
            dec = [ 4 4 ];
            ord = [ 4 0 ];
            ang = 0;
            
            % Expected values
            coefExpctd(:,:,1) = zeros(16,16);
            
            coefExpctd(:,:,2) = zeros(16,16);
            
            coefExpctd(:,1:4,3) = [
                0.250000000000000   0.250000000000000   0.250000000000000   0.250000000000000
                0.250000000000000  -0.250000000000000  -0.250000000000000   0.250000000000000
                0.250000000000000   0.250000000000000   0.250000000000000   0.250000000000000
                0.250000000000000  -0.250000000000000  -0.250000000000000   0.250000000000000
                0.426776695296637   0.176776695296637  -0.176776695296637  -0.426776695296637
                0.176776695296637  -0.426776695296637   0.426776695296637  -0.176776695296637
                0.176776695296637   0.073223304703363  -0.073223304703363  -0.176776695296637
                0.073223304703363  -0.176776695296637   0.176776695296637  -0.073223304703363
                -0.326640741219094  -0.135299025036549   0.135299025036549   0.326640741219094
                -0.135299025036549   0.326640741219094  -0.326640741219094   0.135299025036549
                -0.326640741219094  -0.135299025036549   0.135299025036549   0.326640741219094
                -0.135299025036549   0.326640741219094  -0.326640741219094   0.135299025036549
                -0.326640741219094  -0.326640741219094  -0.326640741219094  -0.326640741219094
                -0.326640741219094   0.326640741219094   0.326640741219094  -0.326640741219094
                -0.135299025036549  -0.135299025036549  -0.135299025036549  -0.135299025036549
                -0.135299025036549   0.135299025036549   0.135299025036549  -0.135299025036549 ];
            
            coefExpctd(:,5:8,3) = [
                0.250000000000000   0.250000000000000   0.250000000000000   0.250000000000000
                0.250000000000000  -0.250000000000000  -0.250000000000000   0.250000000000000
                -0.250000000000000  -0.250000000000000  -0.250000000000000  -0.250000000000000
                -0.250000000000000   0.250000000000000   0.250000000000000  -0.250000000000000
                0.176776695296637   0.073223304703363  -0.073223304703363  -0.176776695296637
                0.073223304703363  -0.176776695296637   0.176776695296637  -0.073223304703363
                -0.426776695296637  -0.176776695296637   0.176776695296637   0.426776695296637
                -0.176776695296637   0.426776695296637  -0.426776695296637   0.176776695296637
                -0.326640741219094  -0.135299025036549   0.135299025036549   0.326640741219094
                -0.135299025036549   0.326640741219094  -0.326640741219094   0.135299025036549
                0.326640741219094   0.135299025036549  -0.135299025036549  -0.326640741219094
                0.135299025036549  -0.326640741219094   0.326640741219094  -0.135299025036549
                -0.135299025036549  -0.135299025036549  -0.135299025036549  -0.135299025036549
                -0.135299025036549   0.135299025036549   0.135299025036549  -0.135299025036549
                0.326640741219094   0.326640741219094   0.326640741219094   0.326640741219094
                0.326640741219094  -0.326640741219094  -0.326640741219094   0.326640741219094 ];
            
            coefExpctd(:,9:12,3) = [
                0.250000000000000   0.250000000000000   0.250000000000000   0.250000000000000
                0.250000000000000  -0.250000000000000  -0.250000000000000   0.250000000000000
                -0.250000000000000  -0.250000000000000  -0.250000000000000  -0.250000000000000
                -0.250000000000000   0.250000000000000   0.250000000000000  -0.250000000000000
                -0.176776695296637  -0.073223304703363   0.073223304703363   0.176776695296637
                -0.073223304703363   0.176776695296637  -0.176776695296637   0.073223304703363
                0.426776695296637   0.176776695296637  -0.176776695296637  -0.426776695296637
                0.176776695296637  -0.426776695296637   0.426776695296637  -0.176776695296637
                -0.326640741219094  -0.135299025036549   0.135299025036549   0.326640741219094
                -0.135299025036549   0.326640741219094  -0.326640741219094   0.135299025036549
                0.326640741219094   0.135299025036549  -0.135299025036549  -0.326640741219094
                0.135299025036549  -0.326640741219094   0.326640741219094  -0.135299025036549
                0.135299025036549   0.135299025036549   0.135299025036549   0.135299025036549
                0.135299025036549  -0.135299025036549  -0.135299025036549   0.135299025036549
                -0.326640741219094  -0.326640741219094  -0.326640741219094  -0.326640741219094
                -0.326640741219094   0.326640741219094   0.326640741219094  -0.326640741219094 ];
            
            coefExpctd(:,13:16,3) = [
                0.250000000000000   0.250000000000000   0.250000000000000   0.250000000000000
                0.250000000000000  -0.250000000000000  -0.250000000000000   0.250000000000000
                0.250000000000000   0.250000000000000   0.250000000000000   0.250000000000000
                0.250000000000000  -0.250000000000000  -0.250000000000000   0.250000000000000
                -0.426776695296637  -0.176776695296637   0.176776695296637   0.426776695296637
                -0.176776695296637   0.426776695296637  -0.426776695296637   0.176776695296637
                -0.176776695296637  -0.073223304703363   0.073223304703363   0.176776695296637
                -0.073223304703363   0.176776695296637  -0.176776695296637   0.073223304703363
                -0.326640741219094  -0.135299025036549   0.135299025036549   0.326640741219094
                -0.135299025036549   0.326640741219094  -0.326640741219094   0.135299025036549
                -0.326640741219094  -0.135299025036549   0.135299025036549   0.326640741219094
                -0.135299025036549   0.326640741219094  -0.326640741219094   0.135299025036549
                0.326640741219094   0.326640741219094   0.326640741219094   0.326640741219094
                0.326640741219094  -0.326640741219094  -0.326640741219094   0.326640741219094
                0.135299025036549   0.135299025036549   0.135299025036549   0.135299025036549
                0.135299025036549  -0.135299025036549  -0.135299025036549   0.135299025036549 ];
            
            coefExpctd(:,:,4) = zeros(16,16);
            
            coefExpctd(:,:,5) = zeros(16,16);
            
            % Instantiation of target class
            import saivdr.dictionary.nsolt.*            
            testCase.lppufb = OvsdLpPuFb2dTypeIVm1System(...
                'DecimationFactor',dec,...
                'PolyPhaseOrder',ord);
                            
            % Actual values
            coefActual = step(testCase.lppufb,ang,[]);
            
            % Evaluation
            coefDist = max(abs(coefExpctd(:)-coefActual(:))...
                ./(abs(coefExpctd(:))));
            testCase.verifyEqual(coefActual,coefExpctd,'RelTol',1e-14,...
                sprintf('%g',coefDist));
            
        end
        
        % Test dec 4 4 order 4 0
        function testConstructorWithDec44Ord40Ang(testCase)
            
            % Parameters
            dec = [ 4 4 ];
            ord = [ 4 0 ];
            ang = 2*pi*rand(28,6);
            
            % Expected values
            nDecs = prod(dec);
            dimExpctd = [nDecs nDecs ord(1)+1];
            
            % Instantiation of target class
            import saivdr.dictionary.nsolt.*            
            testCase.lppufb = OvsdLpPuFb2dTypeIVm1System(...
                'DecimationFactor',dec,...
                'PolyPhaseOrder',ord);
                            
            % Actual values
            coefActual = step(testCase.lppufb,ang,[]);
            
            % Evaluation
            testCase.verifySize(coefActual,dimExpctd);
            
            % Check symmetry
            import matlab.unittest.constraints.IsLessThan
            coefEvn = coefActual(1:ceil(end/2),:);
            coefDiff = coefEvn-fliplr(coefEvn);
            coefDist = norm(coefDiff(:))/sqrt(numel(coefDiff));
            testCase.verifyThat(coefDist,IsLessThan(1e-15),...
                sprintf('%g',coefDist));
            coefOdd = coefActual(ceil(end/2)+1:end,:);
            coefDiff = coefOdd+fliplr(coefOdd);
            coefDist = norm(coefDiff(:))/sqrt(numel(coefDiff));
            testCase.verifyThat(coefDist,IsLessThan(1e-15),...
                sprintf('%g',coefDist));
            
            % Check orthogonality
            coefE = step(testCase.lppufb,[],[]); 
            E = saivdr.dictionary.utility.PolyPhaseMatrix2d(coefE);
            coefActual = double(E.'*E);
            coefActual(1:nDecs,1:nDecs,ord(1)+1,ord(2)+1) = ...
                coefActual(1:nDecs,1:nDecs,ord(1)+1,ord(2)+1) - eye(nDecs);
            coefDist = norm(coefActual(:))/sqrt(numel(coefActual));
            testCase.verifyTrue(coefDist<1e-15,sprintf('%g',coefDist));
            
        end
        
        % Test dec 2 2 order 2 4
        function testConstructorWithDec22Ord24(testCase)
            
            % Parameters
            dec = [ 2 2 ];
            ord = [ 2 4 ];
            ang = 0;
            
            % Expected values
            coefExpctd(:,:,1,1) = zeros(4,4);
            
            coefExpctd(:,:,2,1) = zeros(4,4);
            
            coefExpctd(:,:,3,1) = zeros(4,4);
            
            coefExpctd(:,:,1,2) = zeros(4,4);
            
            coefExpctd(:,:,2,2) = zeros(4,4);
            
            coefExpctd(:,:,3,2) = zeros(4,4);
            
            coefExpctd(:,:,1,3) = zeros(4,4);
            
            coefExpctd(:,:,2,3) = 1/2 * [
                1  1  1  1 ;
                1 -1 -1  1 ;
                -1  1 -1  1 ;
                -1 -1  1  1 ];
            
            coefExpctd(:,:,3,3) = zeros(4,4);
            
            coefExpctd(:,:,1,4) = zeros(4,4);
            
            coefExpctd(:,:,2,4) = zeros(4,4);
            
            coefExpctd(:,:,3,4) = zeros(4,4);
            
            coefExpctd(:,:,1,5) = zeros(4,4);
            
            coefExpctd(:,:,2,5) = zeros(4,4);
            
            coefExpctd(:,:,3,5) = zeros(4,4);
            
            % Instantiation of target class
            import saivdr.dictionary.nsolt.*            
            testCase.lppufb = OvsdLpPuFb2dTypeIVm1System(...
                'DecimationFactor',dec,...
                'PolyPhaseOrder',ord);
                            
            % Actual values
            coefActual = step(testCase.lppufb,ang,[]);
            
            % Evaluation
            coefDist = max(abs(coefExpctd(:)-coefActual(:))...
                ./(abs(coefExpctd(:))));
            testCase.verifyEqual(coefActual,coefExpctd,'RelTol',1e-15,...
                sprintf('%g',coefDist));
            
        end
        
        % Test dec 2 2 order 2 4
        function testConstructorWithDec22Ord24Ang(testCase)
            
            % Parameters
            dec = [ 2 2 ];
            ord = [ 2 4 ];
            ang = 2*pi*rand(1,8);
            
            % Expected values
            nDecs = prod(dec);
            dimExpctd = [nDecs nDecs ord(1)+1 ord(2)+1];
            
            % Instantiation of target class
            import saivdr.dictionary.nsolt.*            
            testCase.lppufb = OvsdLpPuFb2dTypeIVm1System(...
                'DecimationFactor',dec,...
                'PolyPhaseOrder',ord);
                            
            % Actual values
            coefActual = step(testCase.lppufb,ang,[]);
            
            % Evaluation
            testCase.verifySize(coefActual,dimExpctd);
            
            % Check symmetry
            import matlab.unittest.constraints.IsLessThan
            coefEvn = coefActual(1:ceil(end/2),:);
            coefDiff = coefEvn-fliplr(coefEvn);
            coefDist = norm(coefDiff(:))/sqrt(numel(coefDiff));
            testCase.verifyThat(coefDist,IsLessThan(1e-15),...
                sprintf('%g',coefDist));
            coefOdd = coefActual(ceil(end/2)+1:end,:);
            coefDiff = coefOdd+fliplr(coefOdd);
            coefDist = norm(coefDiff(:))/sqrt(numel(coefDiff));
            testCase.verifyThat(coefDist,IsLessThan(1e-15),...
                sprintf('%g',coefDist));
            
            % Check orthogonality
            coefE = step(testCase.lppufb,[],[]); 
            E = saivdr.dictionary.utility.PolyPhaseMatrix2d(coefE);
            coefActual = double(E.'*E);
            coefActual(1:nDecs,1:nDecs,ord(1)+1,ord(2)+1) = ...
                coefActual(1:nDecs,1:nDecs,ord(1)+1,ord(2)+1) - eye(nDecs);
            coefDist = norm(coefActual(:))/sqrt(numel(coefActual));
            testCase.verifyTrue(coefDist<1e-15,sprintf('%g',coefDist));
            
        end
        
        % Test dec 4 4 order 2 4
        function testConstructorWithDec44Ord24(testCase)
            
            % Parameters
            dec = [ 4 4 ];
            ord = [ 2 4 ];
            ang = 0;
            
            % Expected values
            coefExpctd(:,:,1,1) = zeros(16,16);
            
            coefExpctd(:,:,2,1) = zeros(16,16);
            
            coefExpctd(:,:,3,1) = zeros(16,16);
            
            coefExpctd(:,:,1,2) = zeros(16,16);
            
            coefExpctd(:,:,2,2) = zeros(16,16);
            
            coefExpctd(:,:,3,2) = zeros(16,16);
            
            coefExpctd(:,:,1,3) = zeros(16,16);
            
            coefExpctd(:,1:4,2,3) = [
                0.250000000000000   0.250000000000000   0.250000000000000   0.250000000000000
                0.250000000000000  -0.250000000000000  -0.250000000000000   0.250000000000000
                0.250000000000000   0.250000000000000   0.250000000000000   0.250000000000000
                0.250000000000000  -0.250000000000000  -0.250000000000000   0.250000000000000
                0.426776695296637   0.176776695296637  -0.176776695296637  -0.426776695296637
                0.176776695296637  -0.426776695296637   0.426776695296637  -0.176776695296637
                0.176776695296637   0.073223304703363  -0.073223304703363  -0.176776695296637
                0.073223304703363  -0.176776695296637   0.176776695296637  -0.073223304703363
                -0.326640741219094  -0.135299025036549   0.135299025036549   0.326640741219094
                -0.135299025036549   0.326640741219094  -0.326640741219094   0.135299025036549
                -0.326640741219094  -0.135299025036549   0.135299025036549   0.326640741219094
                -0.135299025036549   0.326640741219094  -0.326640741219094   0.135299025036549
                -0.326640741219094  -0.326640741219094  -0.326640741219094  -0.326640741219094
                -0.326640741219094   0.326640741219094   0.326640741219094  -0.326640741219094
                -0.135299025036549  -0.135299025036549  -0.135299025036549  -0.135299025036549
                -0.135299025036549   0.135299025036549   0.135299025036549  -0.135299025036549 ];
            
            coefExpctd(:,5:8,2,3) = [
                0.250000000000000   0.250000000000000   0.250000000000000   0.250000000000000
                0.250000000000000  -0.250000000000000  -0.250000000000000   0.250000000000000
                -0.250000000000000  -0.250000000000000  -0.250000000000000  -0.250000000000000
                -0.250000000000000   0.250000000000000   0.250000000000000  -0.250000000000000
                0.176776695296637   0.073223304703363  -0.073223304703363  -0.176776695296637
                0.073223304703363  -0.176776695296637   0.176776695296637  -0.073223304703363
                -0.426776695296637  -0.176776695296637   0.176776695296637   0.426776695296637
                -0.176776695296637   0.426776695296637  -0.426776695296637   0.176776695296637
                -0.326640741219094  -0.135299025036549   0.135299025036549   0.326640741219094
                -0.135299025036549   0.326640741219094  -0.326640741219094   0.135299025036549
                0.326640741219094   0.135299025036549  -0.135299025036549  -0.326640741219094
                0.135299025036549  -0.326640741219094   0.326640741219094  -0.135299025036549
                -0.135299025036549  -0.135299025036549  -0.135299025036549  -0.135299025036549
                -0.135299025036549   0.135299025036549   0.135299025036549  -0.135299025036549
                0.326640741219094   0.326640741219094   0.326640741219094   0.326640741219094
                0.326640741219094  -0.326640741219094  -0.326640741219094   0.326640741219094 ];
            
            coefExpctd(:,9:12,2,3) = [
                0.250000000000000   0.250000000000000   0.250000000000000   0.250000000000000
                0.250000000000000  -0.250000000000000  -0.250000000000000   0.250000000000000
                -0.250000000000000  -0.250000000000000  -0.250000000000000  -0.250000000000000
                -0.250000000000000   0.250000000000000   0.250000000000000  -0.250000000000000
                -0.176776695296637  -0.073223304703363   0.073223304703363   0.176776695296637
                -0.073223304703363   0.176776695296637  -0.176776695296637   0.073223304703363
                0.426776695296637   0.176776695296637  -0.176776695296637  -0.426776695296637
                0.176776695296637  -0.426776695296637   0.426776695296637  -0.176776695296637
                -0.326640741219094  -0.135299025036549   0.135299025036549   0.326640741219094
                -0.135299025036549   0.326640741219094  -0.326640741219094   0.135299025036549
                0.326640741219094   0.135299025036549  -0.135299025036549  -0.326640741219094
                0.135299025036549  -0.326640741219094   0.326640741219094  -0.135299025036549
                0.135299025036549   0.135299025036549   0.135299025036549   0.135299025036549
                0.135299025036549  -0.135299025036549  -0.135299025036549   0.135299025036549
                -0.326640741219094  -0.326640741219094  -0.326640741219094  -0.326640741219094
                -0.326640741219094   0.326640741219094   0.326640741219094  -0.326640741219094 ];
            
            coefExpctd(:,13:16,2,3) = [
                0.250000000000000   0.250000000000000   0.250000000000000   0.250000000000000
                0.250000000000000  -0.250000000000000  -0.250000000000000   0.250000000000000
                0.250000000000000   0.250000000000000   0.250000000000000   0.250000000000000
                0.250000000000000  -0.250000000000000  -0.250000000000000   0.250000000000000
                -0.426776695296637  -0.176776695296637   0.176776695296637   0.426776695296637
                -0.176776695296637   0.426776695296637  -0.426776695296637   0.176776695296637
                -0.176776695296637  -0.073223304703363   0.073223304703363   0.176776695296637
                -0.073223304703363   0.176776695296637  -0.176776695296637   0.073223304703363
                -0.326640741219094  -0.135299025036549   0.135299025036549   0.326640741219094
                -0.135299025036549   0.326640741219094  -0.326640741219094   0.135299025036549
                -0.326640741219094  -0.135299025036549   0.135299025036549   0.326640741219094
                -0.135299025036549   0.326640741219094  -0.326640741219094   0.135299025036549
                0.326640741219094   0.326640741219094   0.326640741219094   0.326640741219094
                0.326640741219094  -0.326640741219094  -0.326640741219094   0.326640741219094
                0.135299025036549   0.135299025036549   0.135299025036549   0.135299025036549
                0.135299025036549  -0.135299025036549  -0.135299025036549   0.135299025036549 ];
            
            coefExpctd(:,:,3,3) = zeros(16,16);
            
            coefExpctd(:,:,1,4) = zeros(16,16);
            
            coefExpctd(:,:,2,4) = zeros(16,16);
            
            coefExpctd(:,:,3,4) = zeros(16,16);
            
            coefExpctd(:,:,1,5) = zeros(16,16);
            
            coefExpctd(:,:,2,5) = zeros(16,16);
            
            coefExpctd(:,:,3,5) = zeros(16,16);
            
            % Instantiation of target class
            import saivdr.dictionary.nsolt.*            
            testCase.lppufb = OvsdLpPuFb2dTypeIVm1System(...
                'DecimationFactor',dec,...
                'PolyPhaseOrder',ord);
                            
            % Actual values
            coefActual = step(testCase.lppufb,ang,[]);
            
            % Evaluation
            coefDist = max(abs(coefExpctd(:)-coefActual(:))...
                ./(abs(coefExpctd(:))));
            testCase.verifyEqual(coefActual,coefExpctd,'RelTol',1e-14,...
                sprintf('%g',coefDist));
            
        end
        
        % Test dec 4 4 order 2 4
        function testConstructorWithDec44Ord24Ang(testCase)
            
            % Parameters
            dec = [ 4 4 ];
            ord = [ 2 4 ];
            ang = 2*pi*rand(28,8);
            
            % Expected values
            nDecs = prod(dec);
            dimExpctd = [nDecs nDecs ord(1)+1 ord(2)+1];
            
            % Instantiation of target class
            import saivdr.dictionary.nsolt.*            
            testCase.lppufb = OvsdLpPuFb2dTypeIVm1System(...
                'DecimationFactor',dec,...
                'PolyPhaseOrder',ord);
                
            
            % Actual values
            coefActual = step(testCase.lppufb,ang,[]);            
            
            % Evaluation
            testCase.verifySize(coefActual,dimExpctd);
            
            % Check symmetry
            import matlab.unittest.constraints.IsLessThan
            coefEvn = coefActual(1:ceil(end/2),:);
            coefDiff = coefEvn-fliplr(coefEvn);
            coefDist = norm(coefDiff(:))/sqrt(numel(coefDiff));
            testCase.verifyThat(coefDist,IsLessThan(1e-15),...
                sprintf('%g',coefDist));
            coefOdd = coefActual(ceil(end/2)+1:end,:);
            coefDiff = coefOdd+fliplr(coefOdd);
            coefDist = norm(coefDiff(:))/sqrt(numel(coefDiff));
            testCase.verifyThat(coefDist,IsLessThan(1e-15),...
                sprintf('%g',coefDist));
            
            % Check orthogonality
            coefE = step(testCase.lppufb,[],[]); 
            E = saivdr.dictionary.utility.PolyPhaseMatrix2d(coefE);
            coefActual = double(E.'*E);
            coefActual(1:nDecs,1:nDecs,ord(1)+1,ord(2)+1) = ...
                coefActual(1:nDecs,1:nDecs,ord(1)+1,ord(2)+1) - eye(nDecs);
            coefDist = norm(coefActual(:))/sqrt(numel(coefActual));
            testCase.verifyTrue(coefDist<1e-15,sprintf('%g',coefDist));
            
        end
        
        % Test dec 2 2 order 4 2
        function testConstructorWithDec22Ord42(testCase)
            
            % Parameters
            dec = [ 2 2 ];
            ord = [ 4 2 ];
            ang = 0;
            
            % Expected values
            coefExpctd(:,:,1,1) = zeros(4,4);
            
            coefExpctd(:,:,2,1) = zeros(4,4);
            
            coefExpctd(:,:,3,1) = zeros(4,4);
            
            coefExpctd(:,:,4,1) = zeros(4,4);
            
            coefExpctd(:,:,5,1) = zeros(4,4);
            
            coefExpctd(:,:,1,2) = zeros(4,4);
            
            coefExpctd(:,:,2,2) = zeros(4,4);
            
            coefExpctd(:,:,3,2) = 1/2 * [
                1  1  1  1 ;
                1 -1 -1  1 ;
                -1  1 -1  1 ;
                -1 -1  1  1 ];
            
            coefExpctd(:,:,4,2) = zeros(4,4);
            
            coefExpctd(:,:,5,2) = zeros(4,4);
            
            coefExpctd(:,:,1,3) = zeros(4,4);
            
            coefExpctd(:,:,2,3) = zeros(4,4);
            
            coefExpctd(:,:,3,3) = zeros(4,4);
            
            coefExpctd(:,:,4,3) = zeros(4,4);
            
            coefExpctd(:,:,5,3) = zeros(4,4);
            
            % Instantiation of target class
            import saivdr.dictionary.nsolt.*            
            testCase.lppufb = OvsdLpPuFb2dTypeIVm1System(...
                'DecimationFactor',dec,...
                'PolyPhaseOrder',ord);
                            
            % Actual values
            coefActual = step(testCase.lppufb,ang,[]);
            
            % Evaluation
            coefDist = max(abs(coefExpctd(:)-coefActual(:))...
                ./(abs(coefActual(:))));
            testCase.verifyEqual(coefActual,coefExpctd,'RelTol',1e-15,...
                sprintf('%g',coefDist));
            
        end
        
        % Test dec 2 2 order 4 2
        function testConstructorWithDec22Ord42Ang(testCase)
            
            % Parameters
            dec = [ 2 2 ];
            ord = [ 4 2 ];
            ang = 2*pi*rand(1,8);
            
            % Expected values
            nDecs = prod(dec);
            dimExpctd = [nDecs nDecs ord(1)+1 ord(2)+1];
            
            % Instantiation of target class
            import saivdr.dictionary.nsolt.*            
            testCase.lppufb = OvsdLpPuFb2dTypeIVm1System(...
                'DecimationFactor',dec,...
                'PolyPhaseOrder',ord);
                
            % Actual values
            coefActual = step(testCase.lppufb,ang,[]);
            
            % Evaluation
            testCase.verifySize(coefActual,dimExpctd);
            
            % Check symmetry
            import matlab.unittest.constraints.IsLessThan
            coefEvn = coefActual(1:ceil(end/2),:);
            coefDiff = coefEvn-fliplr(coefEvn);
            coefDist = norm(coefDiff(:))/sqrt(numel(coefDiff));
            testCase.verifyThat(coefDist,IsLessThan(1e-15),...
                sprintf('%g',coefDist));
            coefOdd = coefActual(ceil(end/2)+1:end,:);
            coefDiff = coefOdd+fliplr(coefOdd);
            coefDist = norm(coefDiff(:))/sqrt(numel(coefDiff));
            testCase.verifyThat(coefDist,IsLessThan(1e-15),...
                sprintf('%g',coefDist));
            
            % Check orthogonality
            coefE = step(testCase.lppufb,[],[]); 
            E = saivdr.dictionary.utility.PolyPhaseMatrix2d(coefE);
            coefActual = double(E.'*E);
            coefActual(1:nDecs,1:nDecs,ord(1)+1,ord(2)+1) = ...
                coefActual(1:nDecs,1:nDecs,ord(1)+1,ord(2)+1) - eye(nDecs);
            coefDist = norm(coefActual(:))/sqrt(numel(coefActual));
            testCase.verifyTrue(coefDist<1e-15,sprintf('%g',coefDist));
            
        end
        
        % Test dec 4 4 order 4 2
        function testConstructorWithDec44Ord42(testCase)
            
            % Parameters
            dec = [ 4 4 ];
            ord = [ 4 2 ];
            ang = 0;
            
            % Expected values
            coefExpctd(:,:,1,1) = zeros(16,16);
            
            coefExpctd(:,:,2,1) = zeros(16,16);
            
            coefExpctd(:,:,3,1) = zeros(16,16);
            
            coefExpctd(:,:,4,1) = zeros(16,16);
            
            coefExpctd(:,:,5,1) = zeros(16,16);
            
            coefExpctd(:,:,1,2) = zeros(16,16);
            
            coefExpctd(:,:,2,2) = zeros(16,16);
            
            coefExpctd(:,1:4,3,2) = [
                0.250000000000000   0.250000000000000   0.250000000000000   0.250000000000000
                0.250000000000000  -0.250000000000000  -0.250000000000000   0.250000000000000
                0.250000000000000   0.250000000000000   0.250000000000000   0.250000000000000
                0.250000000000000  -0.250000000000000  -0.250000000000000   0.250000000000000
                0.426776695296637   0.176776695296637  -0.176776695296637  -0.426776695296637
                0.176776695296637  -0.426776695296637   0.426776695296637  -0.176776695296637
                0.176776695296637   0.073223304703363  -0.073223304703363  -0.176776695296637
                0.073223304703363  -0.176776695296637   0.176776695296637  -0.073223304703363
                -0.326640741219094  -0.135299025036549   0.135299025036549   0.326640741219094
                -0.135299025036549   0.326640741219094  -0.326640741219094   0.135299025036549
                -0.326640741219094  -0.135299025036549   0.135299025036549   0.326640741219094
                -0.135299025036549   0.326640741219094  -0.326640741219094   0.135299025036549
                -0.326640741219094  -0.326640741219094  -0.326640741219094  -0.326640741219094
                -0.326640741219094   0.326640741219094   0.326640741219094  -0.326640741219094
                -0.135299025036549  -0.135299025036549  -0.135299025036549  -0.135299025036549
                -0.135299025036549   0.135299025036549   0.135299025036549  -0.135299025036549 ];
            
            coefExpctd(:,5:8,3,2) = [
                0.250000000000000   0.250000000000000   0.250000000000000   0.250000000000000
                0.250000000000000  -0.250000000000000  -0.250000000000000   0.250000000000000
                -0.250000000000000  -0.250000000000000  -0.250000000000000  -0.250000000000000
                -0.250000000000000   0.250000000000000   0.250000000000000  -0.250000000000000
                0.176776695296637   0.073223304703363  -0.073223304703363  -0.176776695296637
                0.073223304703363  -0.176776695296637   0.176776695296637  -0.073223304703363
                -0.426776695296637  -0.176776695296637   0.176776695296637   0.426776695296637
                -0.176776695296637   0.426776695296637  -0.426776695296637   0.176776695296637
                -0.326640741219094  -0.135299025036549   0.135299025036549   0.326640741219094
                -0.135299025036549   0.326640741219094  -0.326640741219094   0.135299025036549
                0.326640741219094   0.135299025036549  -0.135299025036549  -0.326640741219094
                0.135299025036549  -0.326640741219094   0.326640741219094  -0.135299025036549
                -0.135299025036549  -0.135299025036549  -0.135299025036549  -0.135299025036549
                -0.135299025036549   0.135299025036549   0.135299025036549  -0.135299025036549
                0.326640741219094   0.326640741219094   0.326640741219094   0.326640741219094
                0.326640741219094  -0.326640741219094  -0.326640741219094   0.326640741219094 ];
            
            coefExpctd(:,9:12,3,2) = [
                0.250000000000000   0.250000000000000   0.250000000000000   0.250000000000000
                0.250000000000000  -0.250000000000000  -0.250000000000000   0.250000000000000
                -0.250000000000000  -0.250000000000000  -0.250000000000000  -0.250000000000000
                -0.250000000000000   0.250000000000000   0.250000000000000  -0.250000000000000
                -0.176776695296637  -0.073223304703363   0.073223304703363   0.176776695296637
                -0.073223304703363   0.176776695296637  -0.176776695296637   0.073223304703363
                0.426776695296637   0.176776695296637  -0.176776695296637  -0.426776695296637
                0.176776695296637  -0.426776695296637   0.426776695296637  -0.176776695296637
                -0.326640741219094  -0.135299025036549   0.135299025036549   0.326640741219094
                -0.135299025036549   0.326640741219094  -0.326640741219094   0.135299025036549
                0.326640741219094   0.135299025036549  -0.135299025036549  -0.326640741219094
                0.135299025036549  -0.326640741219094   0.326640741219094  -0.135299025036549
                0.135299025036549   0.135299025036549   0.135299025036549   0.135299025036549
                0.135299025036549  -0.135299025036549  -0.135299025036549   0.135299025036549
                -0.326640741219094  -0.326640741219094  -0.326640741219094  -0.326640741219094
                -0.326640741219094   0.326640741219094   0.326640741219094  -0.326640741219094 ];
            
            coefExpctd(:,13:16,3,2) = [
                0.250000000000000   0.250000000000000   0.250000000000000   0.250000000000000
                0.250000000000000  -0.250000000000000  -0.250000000000000   0.250000000000000
                0.250000000000000   0.250000000000000   0.250000000000000   0.250000000000000
                0.250000000000000  -0.250000000000000  -0.250000000000000   0.250000000000000
                -0.426776695296637  -0.176776695296637   0.176776695296637   0.426776695296637
                -0.176776695296637   0.426776695296637  -0.426776695296637   0.176776695296637
                -0.176776695296637  -0.073223304703363   0.073223304703363   0.176776695296637
                -0.073223304703363   0.176776695296637  -0.176776695296637   0.073223304703363
                -0.326640741219094  -0.135299025036549   0.135299025036549   0.326640741219094
                -0.135299025036549   0.326640741219094  -0.326640741219094   0.135299025036549
                -0.326640741219094  -0.135299025036549   0.135299025036549   0.326640741219094
                -0.135299025036549   0.326640741219094  -0.326640741219094   0.135299025036549
                0.326640741219094   0.326640741219094   0.326640741219094   0.326640741219094
                0.326640741219094  -0.326640741219094  -0.326640741219094   0.326640741219094
                0.135299025036549   0.135299025036549   0.135299025036549   0.135299025036549
                0.135299025036549  -0.135299025036549  -0.135299025036549   0.135299025036549 ];
            
            coefExpctd(:,:,4,2) = zeros(16,16);
            
            coefExpctd(:,:,5,2) = zeros(16,16);
            
            coefExpctd(:,:,1,3) = zeros(16,16);
            
            coefExpctd(:,:,2,3) = zeros(16,16);
            
            coefExpctd(:,:,3,3) = zeros(16,16);
            
            coefExpctd(:,:,4,3) = zeros(16,16);
            
            coefExpctd(:,:,5,3) = zeros(16,16);
            
            % Instantiation of target class
            import saivdr.dictionary.nsolt.*            
            testCase.lppufb = OvsdLpPuFb2dTypeIVm1System(...
                'DecimationFactor',dec,...
                'PolyPhaseOrder',ord);
                            
            % Actual values
            coefActual = step(testCase.lppufb,ang,[]);
            
            % Evaluation
            coefDist = max(abs(coefExpctd(:)-coefActual(:))...
                ./(abs(coefExpctd(:))));
            testCase.verifyEqual(coefActual,coefExpctd,'RelTol',1e-14,...
                sprintf('%g',coefDist));
            
        end
        
        % Test dec 4 4 order 4 2
        function testConstructorWithDec44Ord42Ang(testCase)
            
            % Parameters
            dec = [ 4 4 ];
            ord = [ 4 2 ];
            ang = 2*pi*rand(28,8);
            
            % Expected values
            nDecs = prod(dec);
            dimExpctd = [nDecs nDecs ord(1)+1 ord(2)+1];
            
            % Instantiation of target class
            import saivdr.dictionary.nsolt.*            
            testCase.lppufb = OvsdLpPuFb2dTypeIVm1System(...
                'DecimationFactor',dec,...
                'PolyPhaseOrder',ord);
                            
            % Actual values
            coefActual = step(testCase.lppufb,ang,[]);
            
            % Evaluation
            testCase.verifySize(coefActual,dimExpctd);
            
            % Check symmetry
            import matlab.unittest.constraints.IsLessThan
            coefEvn = coefActual(1:ceil(end/2),:);
            coefDiff = coefEvn-fliplr(coefEvn);
            coefDist = norm(coefDiff(:))/sqrt(numel(coefDiff));
            testCase.verifyThat(coefDist,IsLessThan(1e-15),...
                sprintf('%g',coefDist));
            coefOdd = coefActual(ceil(end/2)+1:end,:);
            coefDiff = coefOdd+fliplr(coefOdd);
            coefDist = norm(coefDiff(:))/sqrt(numel(coefDiff));
            testCase.verifyThat(coefDist,IsLessThan(1e-15),...
                sprintf('%g',coefDist));
            
            % Check orthogonality
            coefE = step(testCase.lppufb,[],[]); 
            E = saivdr.dictionary.utility.PolyPhaseMatrix2d(coefE);
            coefActual = double(E.'*E);
            coefActual(1:nDecs,1:nDecs,ord(1)+1,ord(2)+1) = ...
                coefActual(1:nDecs,1:nDecs,ord(1)+1,ord(2)+1) - eye(nDecs);
            coefDist = norm(coefActual(:))/sqrt(numel(coefActual));
            testCase.verifyTrue(coefDist<1e-15,sprintf('%g',coefDist));
            
        end
        
        % Test dec 2 2 ch 4 order 3 3
        function testConstructorWithDec22Ch4Ord33Ang(testCase)
            
            % Parameters
            decch = [ 2 2 4 ];
            ord = [ 3 3 ];
            ang = 2*pi*rand(1,8);
            
            % Expected values
            nChs = decch(3);
            nDec = decch(1)*decch(2);
            dimExpctd = [nChs nDec ord(1)+1 ord(2)+1];
            
            % Instantiation of target class
            import saivdr.dictionary.nsolt.*            
            testCase.lppufb = OvsdLpPuFb2dTypeIVm1System(...
                'DecimationFactor',decch(1:2),...
                'NumberOfChannels',decch(3:end),...
                'PolyPhaseOrder',ord);
                            
            % Actual values
            coefActual = step(testCase.lppufb,ang,[]);
            
            % Evaluation
            testCase.verifySize(coefActual,dimExpctd);
            
            % Check symmetry
            import matlab.unittest.constraints.IsLessThan
            coefEvn = coefActual(1:ceil(end/2),:);
            coefDiff = coefEvn-fliplr(coefEvn);
            coefDist = norm(coefDiff(:))/sqrt(numel(coefDiff));
            testCase.verifyThat(coefDist,IsLessThan(1e-15),...
                sprintf('%g',coefDist));
            coefOdd = coefActual(ceil(end/2)+1:end,:);
            coefDiff = coefOdd+fliplr(coefOdd);
            coefDist = norm(coefDiff(:))/sqrt(numel(coefDiff));
            testCase.verifyThat(coefDist,IsLessThan(1e-15),...
                sprintf('%g',coefDist));
            
            % Check tightness
            coefE = step(testCase.lppufb,[],[]);
            E = saivdr.dictionary.utility.PolyPhaseMatrix2d(coefE);
            coefActual = double(E.'*E);
            coefActual(1:nDec,1:nDec,ord(1)+1,ord(2)+1) = ...
                coefActual(1:nDec,1:nDec,ord(1)+1,ord(2)+1) - eye(nDec);
            coefDist = norm(coefActual(:))/sqrt(numel(coefActual));
            testCase.verifyTrue(coefDist<1e-15,sprintf('%g',coefDist));
            
        end
        
        % Test dec 2 2 ch 4 order 4 4
        function testConstructorWithDec22Ch4Ord44Ang(testCase)
            
            % Parameters
            decch = [ 2 2 4 ];
            ord = [ 4 4 ];
            ang = 2*pi*rand(1,10);
            
            % Expected values
            nChs = decch(3);
            nDec = decch(1)*decch(2);
            dimExpctd = [nChs nDec ord(1)+1 ord(2)+1];
            
            % Instantiation of target class
            import saivdr.dictionary.nsolt.*            
            testCase.lppufb = OvsdLpPuFb2dTypeIVm1System(...
                'DecimationFactor',decch(1:2),...
                'NumberOfChannels',decch(3:end),...
                'PolyPhaseOrder',ord);
                            
            % Actual values
            coefActual = step(testCase.lppufb,ang,[]);
            
            % Evaluation
            testCase.verifySize(coefActual,dimExpctd);
            
            % Check symmetry
            import matlab.unittest.constraints.IsLessThan
            coefEvn = coefActual(1:ceil(end/2),:);
            coefDiff = coefEvn-fliplr(coefEvn);
            coefDist = norm(coefDiff(:))/sqrt(numel(coefDiff));
            testCase.verifyThat(coefDist,IsLessThan(1e-15),...
                sprintf('%g',coefDist));
            coefOdd = coefActual(ceil(end/2)+1:end,:);
            coefDiff = coefOdd+fliplr(coefOdd);
            coefDist = norm(coefDiff(:))/sqrt(numel(coefDiff));
            testCase.verifyThat(coefDist,IsLessThan(1e-15),...
                sprintf('%g',coefDist));
            
            % Check tightness
            coefE = step(testCase.lppufb,[],[]);
            E = saivdr.dictionary.utility.PolyPhaseMatrix2d(coefE);
            coefActual = double(E.'*E);
            coefActual(1:nDec,1:nDec,ord(1)+1,ord(2)+1) = ...
                coefActual(1:nDec,1:nDec,ord(1)+1,ord(2)+1) - eye(nDec);
            coefDist = norm(coefActual(:))/sqrt(numel(coefActual));
            testCase.verifyTrue(coefDist<1e-15,sprintf('%g',coefDist));
            
        end
        
        % Test dec 2 2 ch 6 order 1 1
        function testConstructorWithDec22Ch6Ord11Ang(testCase)
            
            % Parameters
            decch = [ 2 2 6 ];
            ord = [ 1 1 ];
            ang = 2*pi*rand(3,4);
            
            % Expected values
            nChs = decch(3);
            nDec = decch(1)*decch(2);
            dimExpctd = [nChs nDec ord(1)+1 ord(2)+1];
            
            % Instantiation of target class
            import saivdr.dictionary.nsolt.*            
            testCase.lppufb = OvsdLpPuFb2dTypeIVm1System(...
                'DecimationFactor',decch(1:2),...
                'NumberOfChannels',decch(3:end),...
                'PolyPhaseOrder',ord);
                            
            % Actual values
            coefActual = step(testCase.lppufb,ang,[]);
            
            % Evaluation
            testCase.verifySize(coefActual,dimExpctd);
            
            % Check symmetry
            import matlab.unittest.constraints.IsLessThan
            coefEvn = coefActual(1:ceil(end/2),:);
            coefDiff = coefEvn-fliplr(coefEvn);
            coefDist = norm(coefDiff(:))/sqrt(numel(coefDiff));
            testCase.verifyThat(coefDist,IsLessThan(1e-15),...
                sprintf('%g',coefDist));
            coefOdd = coefActual(ceil(end/2)+1:end,:);
            coefDiff = coefOdd+fliplr(coefOdd);
            coefDist = norm(coefDiff(:))/sqrt(numel(coefDiff));
            testCase.verifyThat(coefDist,IsLessThan(1e-15),...
                sprintf('%g',coefDist));
            
            % Check tightness
            coefE = step(testCase.lppufb,[],[]);
            E = saivdr.dictionary.utility.PolyPhaseMatrix2d(coefE);
            coefActual = double(E.'*E);
            coefActual(1:nDec,1:nDec,ord(1)+1,ord(2)+1) = ...
                coefActual(1:nDec,1:nDec,ord(1)+1,ord(2)+1) - eye(nDec);
            coefDist = norm(coefActual(:))/sqrt(numel(coefActual));
            testCase.verifyTrue(coefDist<1e-15,sprintf('%g',coefDist));
            
        end
        
        % Test dec 2 2 ch 6 order 2 2
        function testConstructorWithDec22Ch6Ord22Ang(testCase)
            
            % Parameters
            decch = [ 2 2 6 ];
            ord = [ 2 2 ];
            ang = 2*pi*rand(3,6);
            
            % Expected values
            nChs = decch(3);
            nDec = decch(1)*decch(2);
            dimExpctd = [nChs nDec ord(1)+1 ord(2)+1];
            
            % Instantiation of target class
            import saivdr.dictionary.nsolt.*            
            testCase.lppufb = OvsdLpPuFb2dTypeIVm1System(...
                'DecimationFactor',decch(1:2),...
                'NumberOfChannels',decch(3:end),...
                'PolyPhaseOrder',ord);
                            
            % Actual values
            coefActual = step(testCase.lppufb,ang,[]);
            
            % Evaluation
            testCase.verifySize(coefActual,dimExpctd);
            
            % Check symmetry
            import matlab.unittest.constraints.IsLessThan
            coefEvn = coefActual(1:ceil(end/2),:);
            coefDiff = coefEvn-fliplr(coefEvn);
            coefDist = norm(coefDiff(:))/sqrt(numel(coefDiff));
            testCase.verifyThat(coefDist,IsLessThan(1e-15),...
                sprintf('%g',coefDist));
            coefOdd = coefActual(ceil(end/2)+1:end,:);
            coefDiff = coefOdd+fliplr(coefOdd);
            coefDist = norm(coefDiff(:))/sqrt(numel(coefDiff));
            testCase.verifyThat(coefDist,IsLessThan(1e-15),...
                sprintf('%g',coefDist));
            
            % Check tightness
            coefE = step(testCase.lppufb,[],[]);
            E = saivdr.dictionary.utility.PolyPhaseMatrix2d(coefE);
            coefActual = double(E.'*E);
            coefActual(1:nDec,1:nDec,ord(1)+1,ord(2)+1) = ...
                coefActual(1:nDec,1:nDec,ord(1)+1,ord(2)+1) - eye(nDec);
            coefDist = norm(coefActual(:))/sqrt(numel(coefActual));
            testCase.verifyTrue(coefDist<1e-15,sprintf('%g',coefDist));
            
        end
               
        % Test dec 2 2 ch 6 order 3 3
        function testConstructorWithDec22Ch6Ord33Ang(testCase)
            
            % Parameters
            decch = [ 2 2 6 ];
            ord = [ 3 3 ];
            ang = 2*pi*rand(3,8);
            
            % Expected values
            nChs = decch(3);
            nDec = decch(1)*decch(2);
            dimExpctd = [nChs nDec ord(1)+1 ord(2)+1];
            
            % Instantiation of target class
            import saivdr.dictionary.nsolt.*            
            testCase.lppufb = OvsdLpPuFb2dTypeIVm1System(...
                'DecimationFactor',decch(1:2),...
                'NumberOfChannels',decch(3:end),...
                'PolyPhaseOrder',ord);
                            
            % Actual values
            coefActual = step(testCase.lppufb,ang,[]);
            
            % Evaluation
            testCase.verifySize(coefActual,dimExpctd);
            
            % Check symmetry
            import matlab.unittest.constraints.IsLessThan
            coefEvn = coefActual(1:ceil(end/2),:);
            coefDiff = coefEvn-fliplr(coefEvn);
            coefDist = norm(coefDiff(:))/sqrt(numel(coefDiff));
            testCase.verifyThat(coefDist,IsLessThan(1e-15),...
                sprintf('%g',coefDist));
            coefOdd = coefActual(ceil(end/2)+1:end,:);
            coefDiff = coefOdd+fliplr(coefOdd);
            coefDist = norm(coefDiff(:))/sqrt(numel(coefDiff));
            testCase.verifyThat(coefDist,IsLessThan(1e-15),...
                sprintf('%g',coefDist));
            
            % Check tightness
            coefE = step(testCase.lppufb,[],[]);
            E = saivdr.dictionary.utility.PolyPhaseMatrix2d(coefE);
            coefActual = double(E.'*E);
            coefActual(1:nDec,1:nDec,ord(1)+1,ord(2)+1) = ...
                coefActual(1:nDec,1:nDec,ord(1)+1,ord(2)+1) - eye(nDec);
            coefDist = norm(coefActual(:))/sqrt(numel(coefActual));
            testCase.verifyTrue(coefDist<1e-15,sprintf('%g',coefDist));
            
        end
        
        % Test dec 2 2 ch 6 order 4 4
        function testConstructorWithDec22Ch6Ord44Ang(testCase)
            
            % Parameters
            decch = [ 2 2 6 ];
            ord = [ 4 4 ];
            ang = 2*pi*rand(3,10);
            
            % Expected values
            nChs = decch(3);
            nDec = decch(1)*decch(2);
            dimExpctd = [nChs nDec ord(1)+1 ord(2)+1];
            
            % Instantiation of target class
            import saivdr.dictionary.nsolt.*            
            testCase.lppufb = OvsdLpPuFb2dTypeIVm1System(...
                'DecimationFactor',decch(1:2),...
                'NumberOfChannels',decch(3:end),...
                'PolyPhaseOrder',ord);
                            
            % Actual values
            coefActual = step(testCase.lppufb,ang,[]);
            
            % Evaluation
            testCase.verifySize(coefActual,dimExpctd);
            
            % Check symmetry
            import matlab.unittest.constraints.IsLessThan
            coefEvn = coefActual(1:ceil(end/2),:);
            coefDiff = coefEvn-fliplr(coefEvn);
            coefDist = norm(coefDiff(:))/sqrt(numel(coefDiff));
            testCase.verifyThat(coefDist,IsLessThan(1e-15),...
                sprintf('%g',coefDist));
            coefOdd = coefActual(ceil(end/2)+1:end,:);
            coefDiff = coefOdd+fliplr(coefOdd);
            coefDist = norm(coefDiff(:))/sqrt(numel(coefDiff));
            testCase.verifyThat(coefDist,IsLessThan(1e-15),...
                sprintf('%g',coefDist));
            
            % Check tightness
            coefE = step(testCase.lppufb,[],[]);
            E = saivdr.dictionary.utility.PolyPhaseMatrix2d(coefE);
            coefActual = double(E.'*E);
            coefActual(1:nDec,1:nDec,ord(1)+1,ord(2)+1) = ...
                coefActual(1:nDec,1:nDec,ord(1)+1,ord(2)+1) - eye(nDec);
            coefDist = norm(coefActual(:))/sqrt(numel(coefActual));
            testCase.verifyTrue(coefDist<1e-15,sprintf('%g',coefDist));
            
        end
        
        % Test dec 2 2 ch 8 order 1 1
        function testConstructorWithDec22Ch8Ord11Ang(testCase)
            
            % Parameters
            decch = [ 2 2 8 ];
            ord = [ 1 1 ];
            ang = 2*pi*rand(6,4);
            
            % Expected values
            nChs = decch(3);
            nDec = decch(1)*decch(2);
            dimExpctd = [nChs nDec ord(1)+1 ord(2)+1];
            
            % Instantiation of target class
            import saivdr.dictionary.nsolt.*            
            testCase.lppufb = OvsdLpPuFb2dTypeIVm1System(...
                'DecimationFactor',decch(1:2),...
                'NumberOfChannels',decch(3:end),...
                'PolyPhaseOrder',ord);
                            
            % Actual values
            coefActual = step(testCase.lppufb,ang,[]);
            
            % Evaluation
            testCase.verifySize(coefActual,dimExpctd);
            
            % Check symmetry
            import matlab.unittest.constraints.IsLessThan
            coefEvn = coefActual(1:ceil(end/2),:);
            coefDiff = coefEvn-fliplr(coefEvn);
            coefDist = norm(coefDiff(:))/sqrt(numel(coefDiff));
            testCase.verifyThat(coefDist,IsLessThan(1e-15),...
                sprintf('%g',coefDist));
            coefOdd = coefActual(ceil(end/2)+1:end,:);
            coefDiff = coefOdd+fliplr(coefOdd);
            coefDist = norm(coefDiff(:))/sqrt(numel(coefDiff));
            testCase.verifyThat(coefDist,IsLessThan(1e-15),...
                sprintf('%g',coefDist));
            
            % Check tightness
            coefE = step(testCase.lppufb,[],[]);
            E = saivdr.dictionary.utility.PolyPhaseMatrix2d(coefE);
            coefActual = double(E.'*E);
            coefActual(1:nDec,1:nDec,ord(1)+1,ord(2)+1) = ...
                coefActual(1:nDec,1:nDec,ord(1)+1,ord(2)+1) - eye(nDec);
            coefDist = norm(coefActual(:))/sqrt(numel(coefActual));
            testCase.verifyTrue(coefDist<1e-15,sprintf('%g',coefDist));
            
        end
        
        % Test dec 2 2 ch 8 order 2 2
        function testConstructorWithDec22Ch8Ord22Ang(testCase)
            
            % Parameters
            decch = [ 2 2 8 ];
            ord = [ 2 2 ];
            ang = 2*pi*rand(6,6);
            
            % Expected values
            nChs = decch(3);
            nDec = decch(1)*decch(2);
            dimExpctd = [nChs nDec ord(1)+1 ord(2)+1];
            
            % Instantiation of target class
            import saivdr.dictionary.nsolt.*            
            testCase.lppufb = OvsdLpPuFb2dTypeIVm1System(...
                'DecimationFactor',decch(1:2),...
                'NumberOfChannels',decch(3:end),...
                'PolyPhaseOrder',ord);
                            
            % Actual values
            coefActual = step(testCase.lppufb,ang,[]);
            
            % Evaluation
            testCase.verifySize(coefActual,dimExpctd);
            
            % Check symmetry
            import matlab.unittest.constraints.IsLessThan
            coefEvn = coefActual(1:ceil(end/2),:);
            coefDiff = coefEvn-fliplr(coefEvn);
            coefDist = norm(coefDiff(:))/sqrt(numel(coefDiff));
            testCase.verifyThat(coefDist,IsLessThan(1e-15),...
                sprintf('%g',coefDist));
            coefOdd = coefActual(ceil(end/2)+1:end,:);
            coefDiff = coefOdd+fliplr(coefOdd);
            coefDist = norm(coefDiff(:))/sqrt(numel(coefDiff));
            testCase.verifyThat(coefDist,IsLessThan(1e-15),...
                sprintf('%g',coefDist));
            
            % Check tightness
            coefE = step(testCase.lppufb,[],[]); 
            E = saivdr.dictionary.utility.PolyPhaseMatrix2d(coefE);
            coefActual = double(E.'*E);
            coefActual(1:nDec,1:nDec,ord(1)+1,ord(2)+1) = ...
                coefActual(1:nDec,1:nDec,ord(1)+1,ord(2)+1) - eye(nDec);
            coefDist = norm(coefActual(:))/sqrt(numel(coefActual));
            testCase.verifyTrue(coefDist<1e-15,sprintf('%g',coefDist));
            
        end
        
        % Test dec 2 2 ch 8 order 3 3
        function testConstructorWithDec22Ch8Ord33Ang(testCase)
            
            % Parameters
            decch = [ 2 2 8 ];
            ord = [ 3 3 ];
            ang = 2*pi*rand(6,8);
            
            % Expected values
            nChs = decch(3);
            nDec = decch(1)*decch(2);
            dimExpctd = [nChs nDec ord(1)+1 ord(2)+1];
            
            % Instantiation of target class
            import saivdr.dictionary.nsolt.*            
            testCase.lppufb = OvsdLpPuFb2dTypeIVm1System(...
                'DecimationFactor',decch(1:2),...
                'NumberOfChannels',decch(3:end),...
                'PolyPhaseOrder',ord);
                            
            % Actual values
            coefActual = step(testCase.lppufb,ang,[]);
            
            % Evaluation
            testCase.verifySize(coefActual,dimExpctd);
            
            % Check symmetry
            import matlab.unittest.constraints.IsLessThan
            coefEvn = coefActual(1:ceil(end/2),:);
            coefDiff = coefEvn-fliplr(coefEvn);
            coefDist = norm(coefDiff(:))/sqrt(numel(coefDiff));
            testCase.verifyThat(coefDist,IsLessThan(1e-15),...
                sprintf('%g',coefDist));
            coefOdd = coefActual(ceil(end/2)+1:end,:);
            coefDiff = coefOdd+fliplr(coefOdd);
            coefDist = norm(coefDiff(:))/sqrt(numel(coefDiff));
            testCase.verifyThat(coefDist,IsLessThan(1e-15),...
                sprintf('%g',coefDist));
            
            % Check tightness
            coefE = step(testCase.lppufb,[],[]); 
            E = saivdr.dictionary.utility.PolyPhaseMatrix2d(coefE);
            coefActual = double(E.'*E);
            coefActual(1:nDec,1:nDec,ord(1)+1,ord(2)+1) = ...
                coefActual(1:nDec,1:nDec,ord(1)+1,ord(2)+1) - eye(nDec);
            coefDist = norm(coefActual(:))/sqrt(numel(coefActual));
            testCase.verifyTrue(coefDist<1e-15,sprintf('%g',coefDist));
            
        end
        
        % Test dec 2 2 ch 8 order 4 4
        function testConstructorWithDec22Ch8Ord44Ang(testCase)
            
            % Parameters
            decch = [ 2 2 8 ];
            ord = [ 4 4 ];
            ang = 2*pi*rand(6,10);
            
            % Expected values
            nChs = decch(3);
            nDec = decch(1)*decch(2);
            dimExpctd = [nChs nDec ord(1)+1 ord(2)+1];
            
            % Instantiation of target class
            import saivdr.dictionary.nsolt.*            
            testCase.lppufb = OvsdLpPuFb2dTypeIVm1System(...
                'DecimationFactor',decch(1:2),...
                'NumberOfChannels',decch(3:end),...
                'PolyPhaseOrder',ord);
                            
            % Actual values
            coefActual = step(testCase.lppufb,ang,[]);
            
            % Evaluation
            testCase.verifySize(coefActual,dimExpctd);
            
            % Check symmetry
            import matlab.unittest.constraints.IsLessThan
            coefEvn = coefActual(1:ceil(end/2),:);
            coefDiff = coefEvn-fliplr(coefEvn);
            coefDist = norm(coefDiff(:))/sqrt(numel(coefDiff));
            testCase.verifyThat(coefDist,IsLessThan(1e-15),...
                sprintf('%g',coefDist));
            coefOdd = coefActual(ceil(end/2)+1:end,:);
            coefDiff = coefOdd+fliplr(coefOdd);
            coefDist = norm(coefDiff(:))/sqrt(numel(coefDiff));
            testCase.verifyThat(coefDist,IsLessThan(1e-15),...
                sprintf('%g',coefDist));
            
            % Check tightness
            coefE = step(testCase.lppufb,[],[]); 
            E = saivdr.dictionary.utility.PolyPhaseMatrix2d(coefE);
            coefActual = double(E.'*E);
            coefActual(1:nDec,1:nDec,ord(1)+1,ord(2)+1) = ...
                coefActual(1:nDec,1:nDec,ord(1)+1,ord(2)+1) - eye(nDec);
            coefDist = norm(coefActual(:))/sqrt(numel(coefActual));
            testCase.verifyTrue(coefDist<1e-15,sprintf('%g',coefDist));
            
        end
        
        % Test dec 2 2 ch 6 order 2 2
        function testConstructorWithDec22Ch6Ord22AngNoDcLeakage(testCase)
            
            % Parameters
            decch = [ 2 2 6 ];
            ord = [ 2 2 ];
            ang = 2*pi*rand(3,6);
            
            % Expected values
            nChs = decch(3);
            nDec = decch(1)*decch(2);
            dimExpctd = [nChs nDec ord(1)+1 ord(2)+1];
            
            % Instantiation of target class
            import saivdr.dictionary.nsolt.*            
            testCase.lppufb = OvsdLpPuFb2dTypeIVm1System(...
                'DecimationFactor',decch(1:2),...
                'NumberOfChannels',decch(3:end),...
                'PolyPhaseOrder',ord);
                            
            % Actual values
            coefActual = step(testCase.lppufb,ang,[]);
            
            % Evaluation
            testCase.verifySize(coefActual,dimExpctd);
            
            % Check DC-E
            release(testCase.lppufb)
            import matlab.unittest.constraints.IsLessThan
            set(testCase.lppufb,'OutputMode','AnalysisFilterAt');
            for iSubband = 2:nChs
                H = step(testCase.lppufb,[],[],iSubband);
                dc = abs(sum(H(:)));
                testCase.verifyThat(dc,IsLessThan(1e-14),sprintf('%g',dc));
            end
            
        end
        
        % Test dec 2 2 ch 6 order 2 2
        function testConstructorWithDec22Ch6Ord44AngNoDcLeakage(testCase)
            
            % Parameters
            decch = [ 2 2 6 ];
            ord = [ 4 4 ];
            ang = 2*pi*rand(3,10);
            
            % Expected values
            nChs = decch(3);
            nDec = decch(1)*decch(2);
            dimExpctd = [nChs nDec ord(1)+1 ord(2)+1];
            
            % Instantiation of target class
            import saivdr.dictionary.nsolt.*            
            testCase.lppufb = OvsdLpPuFb2dTypeIVm1System(...
                'DecimationFactor',decch(1:2),...
                'NumberOfChannels',decch(3:end),...
                'PolyPhaseOrder',ord);
                            
            % Actual values
            coefActual = step(testCase.lppufb,ang,[]);
            
            % Evaluation
            testCase.verifySize(coefActual,dimExpctd);
            
            % Check DC-leakage
            release(testCase.lppufb)
            import matlab.unittest.constraints.IsLessThan
            set(testCase.lppufb,'OutputMode','AnalysisFilterAt');
            for iSubband = 2:nChs
                H = step(testCase.lppufb,[],[],iSubband);
                dc = abs(sum(H(:)));
                testCase.verifyThat(dc,IsLessThan(1e-14),sprintf('%g',dc));
            end
            
        end
        
         % Test dec 2 2 ch 6 order 2 2
        function testConstructorWithDec22Ch44Ord44AngNoDcLeakage(testCase)
            
            % Parameters
            decch = [ 2 2 4 4 ];
            ord = [ 4 4 ];
            ang = 2*pi*rand(6,10);
            
            % Expected values
            nChs = sum(decch(3:4));
            nDec = prod(decch(1:2));
            dimExpctd = [nChs nDec ord(1)+1 ord(2)+1];
            
            % Instantiation of target class
            import saivdr.dictionary.nsolt.*            
            testCase.lppufb = OvsdLpPuFb2dTypeIVm1System(...
                'DecimationFactor',decch(1:2),...
                'NumberOfChannels',decch(3:end),...
                'PolyPhaseOrder',ord);
                            
            % Actual values
            coefActual = step(testCase.lppufb,ang,[]);
            
            % Evaluation
            testCase.verifySize(coefActual,dimExpctd);
            
            % Check DC-leakage
            release(testCase.lppufb)
            import matlab.unittest.constraints.IsLessThan
            set(testCase.lppufb,'OutputMode','AnalysisFilterAt');
            for iSubband = 2:nChs
                H = step(testCase.lppufb,[],[],iSubband);
                dc = abs(sum(H(:)));
                testCase.verifyThat(dc,IsLessThan(1e-14),sprintf('%g',dc));
            end
            
        end
        
        % Test for ParameterMatrixSet
        function testParameterMatrixSet(testCase)
            
            % Preparation
            mstab = [ 2 2 ; 2 2 ];
            
            % Expected value
            import saivdr.dictionary.utility.ParameterMatrixSet
            paramExpctd = ParameterMatrixSet(...
                'MatrixSizeTable',mstab);
            step(paramExpctd,eye(2),1);
            step(paramExpctd,eye(2),2);
            
            % Instantiation of target class
            import saivdr.dictionary.nsolt.*
            testCase.lppufb = OvsdLpPuFb2dTypeIVm0System(...
                'OutputMode','ParameterMatrixSet');
            
            % Actual values
            paramActual = step(testCase.lppufb,[],[]);
            
            % Evaluation
            testCase.verifyEqual(paramExpctd, paramActual);
            
        end
        
        % Test for construction with order 2 2
        function testParameterMatrixSetRandAngMuWithDec22Ch22Ord22(testCase)
            
            % Parameters
            decch = [ 2 2 2 2 ];
            ord = [ 2 2 ];
            mstab = [ 2 2 ; 2 2 ; 2 2 ; 2 2 ; 2 2 ; 2 2 ];
            
            % Expected values
            import saivdr.dictionary.utility.*
            paramMtxExpctd = ParameterMatrixSet(...
                'MatrixSizeTable',mstab);
            step(paramMtxExpctd, eye(mstab(1,:)),uint32(1)); % W0
            step(paramMtxExpctd, eye(mstab(2,:)),uint32(2)); % U0
            step(paramMtxExpctd,-eye(mstab(3,:)),uint32(3)); % Ux1
            step(paramMtxExpctd,-eye(mstab(4,:)),uint32(4)); % Ux2
            step(paramMtxExpctd,-eye(mstab(5,:)),uint32(5)); % Uy1
            step(paramMtxExpctd,-eye(mstab(6,:)),uint32(6)); % Uy2
            coefExpctd = get(paramMtxExpctd,'Coefficients');
            
            % Instantiation of target class
            import saivdr.dictionary.nsolt.*
            testCase.lppufb = OvsdLpPuFb2dTypeIVm1System(...
                'DecimationFactor',decch(1:2),...
                'NumberOfChannels',decch(3:end),...
                'PolyPhaseOrder',ord,...
                'OutputMode','ParameterMatrixSet');
            
            % Actual values
            paramMtxActual = step(testCase.lppufb,[],[]);
            coefActual = get(paramMtxActual,'Coefficients');
            
            % Evaluation
            diff = max(abs(coefExpctd-coefActual)./abs(coefExpctd));
            testCase.verifyEqual(coefActual,coefExpctd,'RelTol',1e-14,sprintf('%g',diff));
            
            %
            ang = get(testCase.lppufb,'Angles');
            ang = randn(size(ang));
            mus = get(testCase.lppufb,'Mus');
            mus = 2*(rand(size(mus))>0.5)-1;
            %
            import saivdr.dictionary.utility.*
            omgs = OrthonormalMatrixGenerationSystem();
            W0  = step(omgs,0     , [1; mus(2,1)]);
            U0  = step(omgs,ang(2), mus(:,2));
            Ux1 = step(omgs,ang(3), mus(:,3));
            Ux2 = step(omgs,ang(4), mus(:,4));
            Uy1 = step(omgs,ang(5), mus(:,5));
            Uy2 = step(omgs,ang(6), mus(:,6));
            step(paramMtxExpctd,W0 ,uint32(1)); % W0
            step(paramMtxExpctd,U0 ,uint32(2)); % U0
            step(paramMtxExpctd,Ux1,uint32(3)); % Ux1
            step(paramMtxExpctd,Ux2,uint32(4)); % Ux2
            step(paramMtxExpctd,Uy1,uint32(5)); % Uy1            
            step(paramMtxExpctd,Uy2,uint32(6)); % Uy2
            %
            coefExpctd = get(paramMtxExpctd,'Coefficients');            
            
            %
            set(testCase.lppufb,'Angles',ang,'Mus',mus);

            % Actual values
            paramMtxActual = step(testCase.lppufb,ang,mus);
            coefActual = get(paramMtxActual,'Coefficients');
            
            % Evaluation
            diff = max(abs(coefExpctd-coefActual)./abs(coefExpctd));
            testCase.verifyEqual(coefActual,coefExpctd,'RelTol',1e-14,sprintf('%g',diff));
            
            % Check DC-E
            release(testCase.lppufb)
            import matlab.unittest.constraints.IsLessThan
            set(testCase.lppufb,'OutputMode','AnalysisFilterAt');
            for iSubband = 2:sum(decch(3:4))
                H = step(testCase.lppufb,[],[],iSubband);
                dc = abs(sum(H(:)));
                testCase.verifyThat(dc,IsLessThan(1e-14),sprintf('%g',dc));
            end
            
        end
        
        
        % Test for construction with order 2 2
        function testParameterMatrixSetRandAngWithDec22Ch22Ord22(testCase)
            
            % Parameters
            decch = [ 2 2 2 2 ];
            ord = [ 2 2 ];
            mstab = [ 2 2 ; 2 2 ; 2 2 ; 2 2 ; 2 2 ; 2 2 ];
            
            % Expected values
            import saivdr.dictionary.utility.*
            paramMtxExpctd = ParameterMatrixSet(...
                'MatrixSizeTable',mstab);
            step(paramMtxExpctd, eye(mstab(1,:)),uint32(1)); % W0
            step(paramMtxExpctd, eye(mstab(2,:)),uint32(2)); % U0
            step(paramMtxExpctd,-eye(mstab(3,:)),uint32(3)); % Ux1
            step(paramMtxExpctd,-eye(mstab(4,:)),uint32(4)); % Ux2
            step(paramMtxExpctd,-eye(mstab(5,:)),uint32(5)); % Uy1
            step(paramMtxExpctd,-eye(mstab(6,:)),uint32(6)); % Uy2
            coefExpctd = get(paramMtxExpctd,'Coefficients');
            
            % Instantiation of target class
            import saivdr.dictionary.nsolt.*
            testCase.lppufb = OvsdLpPuFb2dTypeIVm1System(...
                'DecimationFactor',decch(1:2),...
                'NumberOfChannels',decch(3:end),...
                'PolyPhaseOrder',ord,...
                'OutputMode','ParameterMatrixSet');
            
            % Actual values
            paramMtxActual = step(testCase.lppufb,[],[]);
            coefActual = get(paramMtxActual,'Coefficients');
            
            % Evaluation
            diff = max(abs(coefExpctd-coefActual)./abs(coefExpctd));
            testCase.verifyEqual(coefActual,coefExpctd,'RelTol',1e-14,sprintf('%g',diff));
            
            %
            ang = get(testCase.lppufb,'Angles');
            ang = randn(size(ang));
            mus = get(testCase.lppufb,'Mus');
            %
            import saivdr.dictionary.utility.*
            omgs = OrthonormalMatrixGenerationSystem();
            W0  = step(omgs,0     , [1; mus(2,1)]);
            U0  = step(omgs,ang(2), mus(:,2));
            Ux1 = step(omgs,ang(3), mus(:,3));
            Ux2 = step(omgs,ang(4), mus(:,4));
            Uy1 = step(omgs,ang(5), mus(:,5));
            Uy2 = step(omgs,ang(6), mus(:,6));
            step(paramMtxExpctd,W0 ,uint32(1)); % W0
            step(paramMtxExpctd,U0 ,uint32(2)); % U0
            step(paramMtxExpctd,Ux1,uint32(3)); % Ux1
            step(paramMtxExpctd,Ux2,uint32(4)); % Ux2
            step(paramMtxExpctd,Uy1,uint32(5)); % Uy1            
            step(paramMtxExpctd,Uy2,uint32(6)); % Uy2
            %
            coefExpctd = get(paramMtxExpctd,'Coefficients');            
            
            %
            set(testCase.lppufb,'Angles',ang);

            % Actual values
            paramMtxActual = step(testCase.lppufb,ang,mus);
            coefActual = get(paramMtxActual,'Coefficients');
            
            % Evaluation
            diff = max(abs(coefExpctd-coefActual)./abs(coefExpctd));
            testCase.verifyEqual(coefActual,coefExpctd,'RelTol',1e-14,sprintf('%g',diff));
            
            % Check DC-E
            release(testCase.lppufb)
            import matlab.unittest.constraints.IsLessThan
            set(testCase.lppufb,'OutputMode','AnalysisFilterAt');
            for iSubband = 2:sum(decch(3:4))
                H = step(testCase.lppufb,[],[],iSubband);
                dc = abs(sum(H(:)));
                testCase.verifyThat(dc,IsLessThan(1e-14),sprintf('%g',dc));
            end            
        end  
        
        % Test for construction with order 2 2
        function testParameterMatrixSetRandMuWithDec22Ch22Ord22(testCase)
            
            % Parameters
            decch = [ 2 2 2 2 ];
            ord = [ 2 2 ];
            mstab = [ 2 2 ; 2 2 ; 2 2 ; 2 2 ; 2 2 ; 2 2 ];
            
            % Expected values
            import saivdr.dictionary.utility.*
            paramMtxExpctd = ParameterMatrixSet(...
                'MatrixSizeTable',mstab);
            step(paramMtxExpctd, eye(mstab(1,:)),uint32(1)); % W0
            step(paramMtxExpctd, eye(mstab(2,:)),uint32(2)); % U0
            step(paramMtxExpctd,-eye(mstab(3,:)),uint32(3)); % Ux1
            step(paramMtxExpctd,-eye(mstab(4,:)),uint32(4)); % Ux2
            step(paramMtxExpctd,-eye(mstab(5,:)),uint32(5)); % Uy1
            step(paramMtxExpctd,-eye(mstab(6,:)),uint32(6)); % Uy2
            coefExpctd = get(paramMtxExpctd,'Coefficients');
            
            % Instantiation of target class
            import saivdr.dictionary.nsolt.*
            testCase.lppufb = OvsdLpPuFb2dTypeIVm1System(...
                'DecimationFactor',decch(1:2),...
                'NumberOfChannels',decch(3:end),...
                'PolyPhaseOrder',ord,...
                'OutputMode','ParameterMatrixSet');
            
            % Actual values
            paramMtxActual = step(testCase.lppufb,[],[]);
            coefActual = get(paramMtxActual,'Coefficients');
            
            % Evaluation
            diff = max(abs(coefExpctd-coefActual)./abs(coefExpctd));
            testCase.verifyEqual(coefActual,coefExpctd,'RelTol',1e-14,sprintf('%g',diff));
            
            %
            ang = get(testCase.lppufb,'Angles');
            mus = get(testCase.lppufb,'Mus');
            mus = 2*(rand(size(mus))>0.5)-1;
            %
            import saivdr.dictionary.utility.*
            omgs = OrthonormalMatrixGenerationSystem();
            W0  = step(omgs,0     , [1; mus(2,1)]);
            U0  = step(omgs,ang(2), mus(:,2));
            Ux1 = step(omgs,ang(3), mus(:,3));
            Ux2 = step(omgs,ang(4), mus(:,4));
            Uy1 = step(omgs,ang(5), mus(:,5));
            Uy2 = step(omgs,ang(6), mus(:,6));
            step(paramMtxExpctd,W0 ,uint32(1)); % W0
            step(paramMtxExpctd,U0 ,uint32(2)); % U0
            step(paramMtxExpctd,Ux1,uint32(3)); % Ux1
            step(paramMtxExpctd,Ux2,uint32(4)); % Ux2
            step(paramMtxExpctd,Uy1,uint32(5)); % Uy1            
            step(paramMtxExpctd,Uy2,uint32(6)); % Uy2
            %
            coefExpctd = get(paramMtxExpctd,'Coefficients');            
            
            %
            set(testCase.lppufb,'Mus',mus);

            % Actual values
            paramMtxActual = step(testCase.lppufb,ang,mus);
            coefActual = get(paramMtxActual,'Coefficients');
            
            % Evaluation
            diff = max(abs(coefExpctd-coefActual)./abs(coefExpctd));
            testCase.verifyEqual(coefActual,coefExpctd,'RelTol',1e-14,sprintf('%g',diff));
            
            % Check DC-E
            release(testCase.lppufb)
            import matlab.unittest.constraints.IsLessThan
            set(testCase.lppufb,'OutputMode','AnalysisFilterAt');
            for iSubband = 2:sum(decch(3:4))
                H = step(testCase.lppufb,[],[],iSubband);
                dc = abs(sum(H(:)));
                testCase.verifyThat(dc,IsLessThan(1e-14),sprintf('%g',dc));
            end
        end  
    end
    
end
