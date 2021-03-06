classdef getFP_F5_Test < matlab.unittest.TestCase
    % getFP_F5_Test 
    %   Fixed Point Location and Stability Tests from 
    %   Kim & Large 2015 figure 5
    %   
    %   Note: The expected r_star and psi_star values are determined by 
    %   inspection from the figures and are not ground truth
    %
    %   Author: Wisam Reid
    %   Email: wisam@ccrma.stanford.edu
    
    properties
        OriginalPath
    end
       
    methods (TestMethodSetup)
        function addLibToPath(testCase)
            testCase.OriginalPath = path;
            addpath(fullfile(pwd,'../../lib'));
        end
    end
    
    methods (Test)
        
        %%%%%%%%%%%%%%%
        % Figure 5
        %%%%%%%%%%%%%%%
        
        function testFigure5A1(testCase)
            rError = 0.02; % error margin
            psiError = pi/12; % error margin
            stabilityOptions = {' stable node',' stable spiral',' unstable node', ...
                ' unstable spiral',' saddle point'};
            expStability = [1; 5; 4];
            expRstar = [0.11; 0.09; 0.02]; 
            expPsiStar = [pi/4; 3*pi/4; pi];
            [actRstar, actPsiStar, actStability] = getFP(1, 0.98, 1, -100, 0, 0, 0.02);
            testCase.verifyEqual(actStability,expStability);
            testCase.verifyEqual(actRstar,expRstar,'AbsTol',rError);
            testCase.verifyEqual(actPsiStar,expPsiStar,'AbsTol',psiError);
            
            % Display
            disp('For Fixed Point 1')
            disp(strcat('The expected stability is: a ', stabilityOptions(expStability(1))))
            disp(['The expected R_Star is: ', num2str(expRstar(1))])
            disp(['The expected Psi_Star is: ', num2str(expPsiStar(1))])
            fprintf('\n')

            disp('For Fixed Point 2')
            disp(strcat('The expected stability is: a ', stabilityOptions(expStability(2))))
            disp(['The expected R_Star is: ', num2str(expRstar(2))])
            disp(['The expected Psi_Star is: ', num2str(expPsiStar(2))])
            fprintf('\n')
            
            
            disp('For Fixed Point 3')
            disp(strcat('The expected stability is: a ', stabilityOptions(expStability(3))))
            disp(['The expected R_Star is: ', num2str(expRstar(3))])
            disp(['The expected Psi_Star is: ', num2str(expPsiStar(3))])
            fprintf('\n')
        end
        
        function testFigure5A2(testCase)
            rError = 0.02; % error margin
            psiError = pi/12; % error margin
            stabilityOptions = {' stable node',' stable spiral',' unstable node', ...
                ' unstable spiral',' saddle point'};
            expStability = 4;
            expRstar = 0.02;
            expPsiStar = 7*pi/8;
            [actRstar, actPsiStar, actStability] = getFP(1, 0.96, 1, -100, 0, 0, 0.02);
            testCase.verifyEqual(actStability,expStability);
            testCase.verifyEqual(actRstar,expRstar,'AbsTol',rError);
            testCase.verifyEqual(actPsiStar,expPsiStar,'AbsTol',psiError);
            
            % Display
            disp(strcat('The expected stability is: a ', stabilityOptions(expStability)))
            disp(['The expected R_Star is: ', num2str(expRstar)])
            disp(['The expected Psi_Star is: ', num2str(expPsiStar)])

        end
        
    end
end
