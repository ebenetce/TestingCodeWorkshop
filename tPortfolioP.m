classdef tPortfolioP < matlab.unittest.TestCase
           
    properties (TestParameter)
        
        Methods = {"Empirical" "Normal"};
        nPort = {10, 20, 30}
        
    end
    
    methods (Test, ParameterCombination = 'exhaustive')
        
        function tSupportedMethods(tc, Methods, nPort)
            
            expectedAssets = timetable((datetime('now')-days(9):days(1):datetime('now'))', (1:10)', (10:-1:1)');
            t = myCVARPortfolio(expectedAssets,  Methods);
            t.nPort = nPort;
            frontWgts = t.optimizePortfolio();
            
            tc.verifyEqual(size(frontWgts,2), t.nPort);
            
        end
        
    end
    
end