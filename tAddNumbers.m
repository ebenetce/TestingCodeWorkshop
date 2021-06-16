classdef tAddNumbers < matlab.unittest.TestCase
    
    properties (TestParameter)
%         a = struct("Small",1,"Medium",2,"Large",3)
%         b = struct("Small",10,"Medium",11,"Large",12)
%         c = struct("Small",21,"Medium",22,"Large",23)

        a = {1,  2,   3};
        b = {10, 11, 12};
        c = {21, 22, 23};
    end
    
    methods (Test,ParameterCombination = "exhaustive")
        function tAdd(testCase,a,b,c)
            res = sum([a b c]);
            verifyEqual(testCase,res,a+b+c);
        end
    end
end