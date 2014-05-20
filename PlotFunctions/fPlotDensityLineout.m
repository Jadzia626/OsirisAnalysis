%
%  Function: fPlotDensityLineout
% *******************************
%  Plots the density for a given t and r
%
%  Inputs:
% =========
%  oData    :: OsirisData object
%  iTime    :: Dump number
%  sSpecies :: Which species
%  iR       :: R-value
%
%  Outputs:
% ==========
%  None
%

function fPlotDensityLineout(oData, iTime, sSpecies, iR)


    %
    %  Function Init
    % ***************
    %

    if nargin == 0
       fprintf('\n');
       fprintf('  Function: fPlotDensityLineout\n');
       fprintf(' *******************************\n');
       fprintf('  Plots the density for a given t and r\n');
       fprintf('\n');
       fprintf('  Inputs:\n');
       fprintf(' =========\n');
       fprintf('  oData    :: OsirisData object\n');
       fprintf('  iTime    :: Dump number\n');
       fprintf('  sSpecies :: Which species\n');
       fprintf('  iR       :: R-value\n');
       fprintf('\n');
       return;
    end % if
    
    sSpecies = fTranslateSpecies(sSpecies);

    % Plasma
    dPStart     = oData.Config.Variables.Plasma.PlasmaStart;
    dPEnd       = oData.Config.Variables.Plasma.PlasmaEnd;
    dE0         = oData.Config.Variables.Convert.SI.E0;

    % Simulation
    dBoxLength  = oData.Config.Variables.Simulation.BoxX1Max;
    iBoxNZ      = oData.Config.Variables.Simulation.BoxNX1;
    dBoxRadius  = oData.Config.Variables.Simulation.BoxX2Max;
    iBoxNR      = oData.Config.Variables.Simulation.BoxNX2;

    % Factors
    dTFactor    = oData.Config.Variables.Convert.SI.TimeFac;
    dLFactor    = oData.Config.Variables.Convert.SI.LengthFac;
    
    % Prepare axes
    aXAxis      = 1e3*linspace(0,dBoxLength*dLFactor,iBoxNZ);

    h5Data = oData.Data(iTime, 'DENSITY', 'charge', sSpecies);
    aCharge = h5Data(:,iR);
    clear h5Data;

    fig1 = figure(1);
    clf;
    
    hold on
    plot(aXAxis, aCharge);

    sSpecies = strrep(sSpecies, '_', ' ');
    sSpecies = regexprep(sSpecies,'(\<[a-z])','${upper($1)}');
    
    sTitle = sprintf('%s Density at R = %d cells and S = %0.2f m', sSpecies, iR, iTime*dTFactor*dLFactor);
    title(sTitle,'FontSize',18);
    xlabel('$z \;\mbox{[mm]}$','interpreter','LaTex','FontSize',16);
    ylabel('Density','FontSize',16);
    
    %axis([92.1, 95.6, 0.0, 0.18]);
    
    pbaspect([1.0,0.4,1.0]);
    hold off;

    saveas(fig1, 'Plots/PlotDensityLineoutFigure1.eps','epsc');

end

