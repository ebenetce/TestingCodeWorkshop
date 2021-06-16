classdef myAppTest < matlab.uitest.TestCase

    properties
        app
    end
    
    properties (TestParameter)
        symbols = {[1 3 4 5 8],  1,   [10 5 3 2 1]};
        result  = {[0 1 0], [0.80,0.80,0.80], [0 1 0]}
    end

    methods (TestMethodSetup)

        function openApp(tc)
            tc.app = CVaRopt;
            tc.addTeardown(@delete, tc.app)
        end

    end

    methods (Test)

        function tBasicOptim(tc)
            tc.press(tc.app.OptimizeButton)
            tc.verifyEqual(tc.app.Lamp.Color, [0.80,0.80,0.80])
        end
        
        function tBasicOptimWithOne(tc)
            tc.choose(tc.app.SelectAssetsListBox, [1])
            tc.type(tc.app.NumberofscenariosEditField, 1000)
            tc.press(tc.app.OptimizeButton)
            tc.verifyEqual(tc.app.Lamp.Color, [0.80,0.80,0.80])
        end

        function tBasicWorkflow(tc)
            tc.choose(tc.app.SelectAssetsListBox, [1 3 4 5 8])
            tc.type(tc.app.NumberofscenariosEditField, 1000)
            tc.press(tc.app.OptimizeButton)
            tc.verifyEqual(tc.app.Lamp.Color, [0 1 0])            
            
            tc.choose(tc.app.TabGroup, 2)
            tc.choose(tc.app.PlotTypeDropDown, 2)
            tc.choose(tc.app.PlotTypeDropDown, 3)
            tc.choose(tc.app.PlotTypeDropDown, 1)
        end

    end
    
    
     methods (Test,ParameterCombination = "sequential")
        
        function tAdd(tc, symbols, result)
            tc.choose(tc.app.SelectAssetsListBox, symbols)
            tc.type(tc.app.NumberofscenariosEditField, 1000)
            tc.press(tc.app.OptimizeButton)
            tc.verifyEqual(tc.app.Lamp.Color, result)
        end
        
    end
end