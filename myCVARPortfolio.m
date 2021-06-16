classdef myCVARPortfolio %< matlab.mixin.SetGet
    
    properties (Constant, Access = private)
        ValidSimMethod = ["Normal" "Empirical"]
    end
    
    properties
        alpha (1,1) double = 0.95
        nPort (1,1) double = 40
        SimulationMethod (1,1) string = "Normal"
        nScenario (1,1) double = 5000
        symbol (1,:) string
    end
    
    properties
        assetsTable (:,:) timetable
    end
    
    properties (Dependent, SetAccess = private)
        ret
        AScenarios
    end
    
    methods
        
        function obj = myCVARPortfolio(T, method)
            % Constructor method
            %
            % Inputs (method optional):
            % T - table with the ticker values
            % method - simulation method
            %
            % Output:
            % OBJ - An instance of the class
            %
            % Examples:
            % >> myCustomPortfolio(readtable('dowPortfolio.xlsx'), 'Normal')
            
            % Initialize object
            if nargin == 0
                error('myCVARPortfolio:assetListNeeded', 'This class needs a portfolio in timetable format')
            end
            
            obj.assetsTable = T;
            
            if (nargin > 1)
                obj.SimulationMethod = method;
            end
            
        end
        
        function obj = set.alpha(obj, value)
            obj.alpha = value;
        end
        
        function obj = set.nPort(obj, value)
            obj.nPort = value;
        end
        
        function sy = get.symbol(obj)
            if isempty(obj.symbol)
                sy = string(obj.assetsTable.Properties.VariableNames);
            else
                sy = obj.symbol;
            end
        end
        
        function obj = set.SimulationMethod(obj, method)
            method = obj.validateMethod(method);
            obj.SimulationMethod = method;
        end
        
        function returns = get.ret(obj)
            % If the user did not set the symbols, use all of them.
            if isempty(obj.symbol)
                returns = tick2ret(obj.assetsTable{:,:});
            else
                returns = tick2ret(obj.assetsTable{:,obj.symbol});
            end
        end
        
        function obj = set.symbol(obj, symbols)
            
            obj.symbol = symbols;
            
        end
        
        function AScenarios = get.AScenarios(obj)
            
            switch obj.SimulationMethod
                case "Normal" % Based on normal distribution
                    AScenarios = mvnrnd(mean(obj.ret),cov(obj.ret), obj.nScenario);
                case "Empirical" % Based on empirical distribution using t-copula
                    AScenarios = obj.simEmpirical(obj.ret, obj.nScenario);
            end
            
        end
        
        function [frontWgts, frontRisk , frontReturn, frontStd, frontVaR] = optimizePortfolio(obj)
            
            p1 = PortfolioCVaR('Scenarios', obj.AScenarios);
            p1 = setAssetList(p1, obj.symbol);
            p1 = setDefaultConstraints(p1);
            
            p1 = setProbabilityLevel(p1, obj.alpha);
            
            % Estimate Frontier, calculate and store risk/return
            frontWgts   = estimateFrontier(p1, obj.nPort);
            frontRisk   = estimatePortRisk(p1, frontWgts);
            frontReturn = estimatePortReturn(p1, frontWgts);
            frontStd    = estimatePortStd(p1, frontWgts);
            frontVaR    = estimatePortVaR(p1, frontWgts);
            
        end
        
         function plotWeight(obj, ax, frontWgts)
            w = frontWgts'*100;
            assetsKeep = ~all(w < 0.01);
            w = w(:,assetsKeep);
            obj.nPort = size(w,1);
            nAssets = size(w,2);
            ylabel(ax,'Portfolio weight (%)')
            xlabel(ax,'Portfolio number')
            title(ax,"");
            ylim(ax,[0 100]);
            xlim(ax,[0,obj.nPort+1])
            assetNamesKeep = obj.symbol(assetsKeep);
            b = bar(ax,1:obj.nPort, w,'stacked');
            cmap = jet(nAssets);
            for i=1:nAssets
                b(i).FaceColor = cmap(i,:);
            end
            
            legend(ax,assetNamesKeep,'NumColumns',ceil(nAssets/6));
        end
        
        function plotFrontier(obj, ax, frontRisk, frontReturn) %#ok<INUSL>
            ax.Toolbar.Visible = 'off';
            if ~isempty(ax.Legend)
                ax.Legend.Visible = 'off';
            end
            ax.XGrid = 'on';
            ax.YGrid = 'on';
            plot(ax, 100*frontRisk,100*frontReturn, 'Color','r','LineStyle',"-",'Marker',"o",'LineWidth',1.5)
            title(ax, 'Efficient frontier')
            xlabel(ax,'CVaR of portfolio (%)')
            ylabel(ax,'Mean of portfolio returns (%)')
            % set x limit and y limit
            minRet = min(100*frontReturn);
            maxRet = max(100*frontReturn);
            margin = 0.04;
            ylim(ax,[minRet-margin*(maxRet-minRet),maxRet+margin*(maxRet-minRet)])
            minRisk = min(100*frontRisk);
            maxRisk = max(100*frontRisk);
            xlim(ax,[minRisk-margin*(maxRisk-minRisk),maxRisk+margin*(maxRisk-minRisk)])
        end
        
        function plotPortfolioHistogram(obj, ax, frontWgts, frontRisk, frontVaR)
            portNum = obj.nPort;
            VaR = -100*frontVaR(portNum);
            CVaR = -100*frontRisk(portNum);
            portRet = 100*obj.ret * frontWgts(:,portNum);
            nBin = 40;
            ax.Toolbar.Visible = 'off';
            if ~isempty(ax.Legend)
                ax.Legend.Visible = 'off';
            end
            ax.XGrid = 'off';
            ax.YGrid = 'off';
            h1 = histogram(ax, portRet,nBin);
            hold(ax,'on')
            title(ax, 'Histogram of returns');
            xlabel(ax, 'Returns (%)')
            ylabel(ax, 'Frequency')
            % Highlight bins with lower edges < VaR level in red
            edges = h1.BinEdges;
            ax.XLim = [min(edges)-0.05*(max(edges)-min(edges)), max(edges)+0.05*(max(edges)-min(edges))];
            ax.YLim = [0 max(h1.Values)+2];
            counts = h1.Values.*(edges(1:end-1) < VaR);
            
            h2 = histogram(ax, 'BinEdges',edges,'BinCounts',counts);
            h2.FaceColor = 'r';
            % Add CVaR line
            plot(ax, [CVaR;CVaR],[0;max(h1.BinCounts)*0.80],'--r')
            % Add CVaR text
            text(ax, edges(3), max(h1.BinCounts)*0.85,['CVaR = ' num2str(round(-CVaR,3)) '%'])
            hold(ax,'off')
        end
        
    end
    
    methods(Static)
        
        function AScenarios = simEmpirical(ret, nScenario)
            
            % Simulate empirical scenarios given historical returns
            [nSample,nAsset] = size(ret);
            u = zeros(nSample,nAsset);
            % Estimate the cumulative distribution function for each
            % variable
            for i = 1:nAsset
                u(:,i) = ksdensity(ret(:,i),ret(:,i),'Function','cdf');
            end
            % Fit a t copula to data
            [rho, dof] = copulafit('t',u);
            % Generate copula random numbers
            r = copularnd('t',rho,dof,nScenario);
            AScenarios = zeros(nScenario,nAsset);
            for i = 1:nAsset
                AScenarios(:,i) = ksdensity(ret(:,i),r(:,i),'function','icdf');
            end
            
        end
        
    end
    
    methods (Access = private)
        
        function method = validateMethod(obj, method)
            method = validatestring(method, obj.ValidSimMethod);
        end
        
    end
    
    
    
end