classdef tPortfolio < matlab.unittest.TestCase
    
    methods (Test)
        
        function tNormal(tc)
            expectedMethod = "Normal";
            expectedAssets = timetable((datetime('now')-days(9):days(1):datetime('now'))', rand(10,1), rand(10,1));
            
            t = myCVARPortfolio(expectedAssets);
            
            tc.verifyEqual(t.SimulationMethod, expectedMethod);
            tc.verifyEqual(t.assetsTable, expectedAssets);
            tc.verifyEqual(t.alpha, 0.95);
            tc.verifyEqual(t.nPort, 40);
            tc.verifyEqual(t.nScenario, 5000);
        end
        
        function tEmpirical(tc)
            
            expectedMethod = "Empirical";
            expectedAssets = timetable((datetime('now')-days(9):days(1):datetime('now'))', rand(10,1), rand(10,1));
            
            t = myCVARPortfolio(expectedAssets, expectedMethod);
            
            tc.verifyEqual(t.SimulationMethod, expectedMethod);
            tc.verifyEqual(t.assetsTable, expectedAssets);
            tc.verifyEqual(t.alpha, 0.95);
            tc.verifyEqual(t.nPort, 40);
            tc.verifyEqual(t.nScenario, 5000);
            
        end
        
        function tMethod(testCase)
                        
            rng(0, 'twister')
            assets = timetable((datetime('now')-days(9):days(1):datetime('now'))', rand(10,1), rand(10,1));
            t = myCVARPortfolio(assets);
            t.nScenario = 2;
            scenarios = t.AScenarios;
            testCase.verifyEqual(scenarios(1,1), 2.337132864818915, 'AbsTol', 1e-12)
            
            t.SimulationMethod = "Empirical";
            t.nScenario = 4;
            rng(0, 'twister')
            scenarios = t.AScenarios;  
            
            rng(0, 'twister')
            expValue = t.simEmpirical(tick2ret(assets{:,:}), 4);
            testCase.verifyEqual(scenarios, expValue, 'AbsTol', 1e-12)
            
        end
        
        function tOptimization(tc)
            
            expectedAssets = timetable((datetime('now')-days(9):days(1):datetime('now'))', (1:10)', (10:-1:1)');
            t = myCVARPortfolio(expectedAssets, 'Normal');
            frontWgts = t.optimizePortfolio();
            
            tc.verifyEqual(frontWgts(1,:), ones(1, t.nPort));
            
        end
        
        function tBadMethod(testCase)
            
            fcn = @() myCVARPortfolio(timetable(),"Foobah");
            verifyError(testCase,fcn,'MATLAB:unrecognizedStringChoice')
            
        end
        
        function tPlot(tc)
            
            f = figure();
            addTeardown(tc, @close, f)
                        
            expectedAssets = timetable((datetime('now')-days(9):days(1):datetime('now'))', (1:10)', (10:-1:1)');
            t = myCVARPortfolio(expectedAssets, 'Normal');
            [frontWgts] =  t.optimizePortfolio();
            t.plotWeight(axes('Parent', f), frontWgts)            
            
        end
        
    end
    
end