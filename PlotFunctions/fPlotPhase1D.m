%
%  Function: fPlotPhase1D
% ************************
%  Plots 1D Phase Data
%
%  Inputs:
% =========
%  oData    :: OsirisData object
%  iTime    :: Which dump to look at
%  sSpecies :: Which species to look at
%  sAxis    :: Which axis to plot
% 
%  Optional Inputs:
% ==================
%  aCount   :: Array of energies to count between (in MeV)
%  dMin     :: Lower cutoff
%  dMax     :: Upper cutoff
%

function fPlotPhase1D(oData, iTime, sSpecies, sAxis, aCount, dMin, dMax)

    % Help output
    if nargin == 0
       fprintf('\n');
       fprintf('  Function: fPlotPhase1D\n');
       fprintf(' ************************\n');
       fprintf('  Plots 1D Phase Data\n');
       fprintf('\n');
       fprintf('  Inputs:\n');
       fprintf(' =========\n');
       fprintf('  oData    :: OsirisData object\n');
       fprintf('  iTime    :: Which dump to look at\n');
       fprintf('  sSpecies :: Which species to look at\n');
       fprintf('  sAxis    :: Which axis to plot\n');
       fprintf('\n');
       fprintf('  Optional Inputs:\n');
       fprintf(' ==================\n');
       fprintf('  aCount   :: Array of energies to count between (in MeV)\n');
       fprintf('  dMin     :: Lower cutoff\n');
       fprintf('  dMax     :: Upper cutoff\n');
       fprintf('\n');
       return;
    end % if
    
    % Check input
    if nargin < 5
        aCount = [0];
    end % if
    
    if nargin < 6
        dMin = -1.0e1000;
    end % if

    if nargin < 7
        dMax = 1.0e1000;
    end % if

    sSpecies = fTranslateSpecies(sSpecies);
    aAllowed = {'p1','p2','p3','x1','x2','x3'};
    if ~ismember(sAxis, aAllowed)
        fprintf('Error: Unknown axis\n');
        return;
    end % if
    
    switch(sAxis)
        case 'p1'
            sXUnit  = 'MeV';
            sXLabel = '$p_z \mbox{[MeV/c]}$';
        case 'p2'
            sXUnit  = 'keV';
            sXLabel = '$p_r \mbox{[keV/c]}$';
        case 'p3'
            sXUnit  = 'keV';
            sXLabel = '$p_{\theta} \mbox{[MeV/c]}$';
        case 'x1'
            sXUnit  = 'mm';
            sXLabel = '$z \mbox{[mm]}$';
        case 'x2'
            sXUnit  = 'mm';
            sXLabel = '$r \mbox{[mm]}$';
        case 'x3'
            sXUnit  = 'mm';
            sXLabel = '$\theta$';
        otherwise
            return;
    end % switch

    % Beam diag
    iNP1    = oData.Config.Variables.Beam.(sSpecies).DiagNP1;
    iNP2    = oData.Config.Variables.Beam.(sSpecies).DiagNP2;
    iNP3    = oData.Config.Variables.Beam.(sSpecies).DiagNP3;
    dP1Min  = oData.Config.Variables.Beam.(sSpecies).DiagP1Min;
    dP2Min  = oData.Config.Variables.Beam.(sSpecies).DiagP2Min;
    dP3Min  = oData.Config.Variables.Beam.(sSpecies).DiagP3Min;
    dP1Max  = oData.Config.Variables.Beam.(sSpecies).DiagP1Max;
    dP2Max  = oData.Config.Variables.Beam.(sSpecies).DiagP2Max;
    dP3Max  = oData.Config.Variables.Beam.(sSpecies).DiagP3Max;
    
    % Beam
    dRQM    = oData.Config.Variables.Beam.(sSpecies).RQM;
    dEMass  = oData.Config.Variables.Constants.ElectronMassMeV;
    dCharge = oData.Config.Variables.Constants.ElementaryCharge;
    dP1Init = oData.Config.Variables.Beam.(sSpecies).Momentum1*dEMass;
    dP2Init = oData.Config.Variables.Beam.(sSpecies).Momentum2*dEMass;
    dP3Init = oData.Config.Variables.Beam.(sSpecies).Momentum3*dEMass;

    % Factors
    dSign  = dRQM/abs(dRQM);
    
    % Data
    h5Data = oData.Data(iTime, oData.Elements.PHA.(sAxis).(sSpecies));
    h5Data = h5Data;
    fprintf('Sum: %.3e\n', sum(h5Data));
    iLen   = length(h5Data);

    switch(sAxis)
        case 'p1'
            dPFac  = abs(dRQM)*dEMass;
            dPMin  = sqrt(abs(dP1Min)^2 + 1)*dPFac*(dP1Min/abs(dP1Min));
            dPMax  = sqrt(abs(dP1Max)^2 + 1)*dPFac*(dP1Max/abs(dP1Max));
            dPInit = dP1Init;
            iNP    = iNP1;
        case 'p2'
            dPFac  = abs(dRQM)*dEMass*1e3;
            dPMin  = sqrt(abs(dP2Min)^2 + 1)*dPFac*(dP2Min/abs(dP2Min));
            dPMax  = sqrt(abs(dP2Max)^2 + 1)*dPFac*(dP2Max/abs(dP2Max));
            dPInit = dP2Init;
            iNP    = iNP2;
        case 'p3'
            dPFac  = abs(dRQM)*dEMass*1e3;
            dPMin  = sqrt(abs(dP3Min)^2 + 1)*dPFac*(dP3Min/abs(dP3Min));
            dPMax  = sqrt(abs(dP3Max)^2 + 1)*dPFac*(dP3Max/abs(dP3Max));
            dPInit = dP3Init;
            iNP    = iNP3;
        otherwise
            return;
    end % switch
    
    if strcmpi(sAxis, 'p1') || strcmpi(sAxis, 'p2') || strcmpi(sAxis, 'p3')
        
        % Axes
        aXAxis = linspace(dPMin,dPMax,iNP);

        % X-axis spread
        dYMin = min(abs(h5Data));
        dYMax = max(abs(h5Data));

        iXMin = 1;
        iXMax = iLen;
        
        dSum   = sum(abs(h5Data));
        dLInit = 0.0;
        dAInit = 0.0;
        dMInit = 0.0;
        
        if aCount(end) < aXAxis(iXMax)
            aCount(end+1) = aXAxis(iXMax);
        end % if
        aTCount = zeros(length(aCount)-1,1);

        % Find lower and upper limit of data between min and max
        for i=1:length(h5Data)
            if iXMin == 1 && abs(h5Data(i)) > dYMin
                iXMin = i;
            end % if
            if iXMax == iLen && abs(h5Data(iLen-i+1)) > dYMin
                iXMax = iLen-i+1;
            end % if
        end % for
        dXMin = aXAxis(iXMin)*0.95;
        dXMax = aXAxis(iXMax)*1.05;
        
        fprintf('\n');
        fprintf('Momentum spread, min:   %6.1f %s\n', aXAxis(iXMin), sXUnit);
        fprintf('Momentum spread, max:   %6.1f %s\n', aXAxis(iXMax), sXUnit);
        fprintf('Initial beam momentum:  %6.1f %s\n', dPInit, sXUnit);
        fprintf('\n');

        % Find cuttoff index
        iMin = -1;
        iMax = 1e10;
        for i=1:length(h5Data)
            if iMin == -1 && aXAxis(i) >= dMin
                iMin = i;
            end % if
            if iMax == 1e10 && aXAxis(i) >= dMax
                iMax = i;
            end % if
        end % for
        
        % Update range
        if iXMin < iMin
            iXMin = iMin;
            dXMin = aXAxis(iXMin);
            dYMin = min(dSign*h5Data(iXMin:iXMax));
        end % if
        if iXMax > iMax
            iXMax = iMax;
            dXMax = aXAxis(iXMax);
            dYMax = max(dSign*h5Data(iXMin:iXMax))*1.05;
        end % if

        % Calculate range for initial momentum
        if dPInit == 0
            dXSpan = aXAxis(iXMax)-aXAxis(iXMin);
            dXPM   = dXSpan/500.0;
        else
            dXPM   = dPInit/20.0;
        end % if

        for i=1:length(h5Data)

            if aXAxis(i) < dP1Init-dXPM
                dLInit = dLInit + abs(h5Data(i));
            end % if
            if aXAxis(i) >= dP1Init-dXPM && aXAxis(i) <= dP1Init+dXPM
                dAInit = dAInit + abs(h5Data(i));
            end % if
            if aXAxis(i) > dP1Init+dXPM
                dMInit = dMInit + abs(h5Data(i));
            end % if
            
            for j=2:length(aCount)
                if aXAxis(i) >= aCount(j-1) && aXAxis(i) < aCount(j)
                    aTCount(j-1) = aTCount(j-1) + abs(h5Data(i));
                end % if
            end % for
            
        end % for
        
        fprintf('Fraction below initial: %6.2f %%\n', 100*dLInit/dSum);
        fprintf('Fraction at initial:    %6.2f %% (±%.2f %s)\n', 100*dAInit/dSum, dXPM, sXUnit);
        fprintf('Fraction above initial: %6.2f %%\n', 100*dMInit/dSum);
        fprintf('\n');

        fprintf('    From    |     To     |  Fraction\n');
        fprintf('––––––––––––+––––––––––––+–––––––––––\n');
        for j=2:length(aCount)
            fprintf(' %6.1f %s | %6.1f %s | %7.3f %%\n', aCount(j-1), sXUnit, aCount(j), sXUnit, 100*aTCount(j-1)/dSum);
        end % for
        fprintf('\n');

    end % if
    

    % Plot
    fig1 = figure(1);
    clf;
    
    area(aXAxis,dSign*h5Data);
    
    xlim([dXMin,dXMax]);
    ylim([dYMin,dYMax]);

    title(sprintf('1D Phase Plot for %s',sAxis),'FontSize',22);
    xlabel(sXLabel,'interpreter','LaTex','FontSize',16);
    ylabel('$N$','interpreter','LaTex','FontSize',16);


end

