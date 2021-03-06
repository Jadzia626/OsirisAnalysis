
%
%  Function: fPlotPhase1D
% ************************
%  Plots 1D Phase Data
%
%  Inputs:
% =========
%  oData    :: OsirisData object
%  sTime    :: Which dump to look at
%  sSpecies :: Which species to look at
%  sAxis    :: Which axis to plot
%
%  Options:
% ==========
%  Lim         :: Horizontal axis limits
%  FigureSize  :: Default [900 500]
%  HideDump    :: Default No
%  IsSubplot   :: Default No
%  AutoResize  :: Default On
%

function stReturn = fPlotPhase1D(oData, sTime, sSpecies, sAxis, varargin)

    % Input/Output

    stReturn = {};

    if nargin == 0
        fprintf('\n');
        fprintf('  Function: fPlotPhase1D\n');
        fprintf(' ************************\n');
        fprintf('  Plots 1D Phase Data\n');
        fprintf('\n');
        fprintf('  Inputs:\n');
        fprintf(' =========\n');
        fprintf('  oData    :: OsirisData object\n');
        fprintf('  sTime    :: Which dump to look at\n');
        fprintf('  sSpecies :: Which species to look at\n');
        fprintf('  sAxis    :: Which axis to plot\n');
        fprintf('\n');
        fprintf('  Options:\n');
        fprintf(' ==========\n');
        fprintf('  Lim         :: Horizontal axis limits\n');
        fprintf('  FigureSize  :: Default [900 500]\n');
        fprintf('  HideDump    :: Default No\n');
        fprintf('  IsSubplot   :: Default No\n');
        fprintf('  AutoResize  :: Default On\n');
        fprintf('\n');
        return;
    end % if
    
    vSpecies = oData.Translate.Lookup(sSpecies,'Species');
    iTime    = oData.StringToDump(num2str(sTime));

    oOpt = inputParser;
    addParameter(oOpt, 'Lim',        []);
    addParameter(oOpt, 'FigureSize', [900 500]);
    addParameter(oOpt, 'HideDump',   'No');
    addParameter(oOpt, 'IsSubPlot',  'No');
    addParameter(oOpt, 'AutoResize', 'On');
    parse(oOpt, varargin{:});
    stOpt = oOpt.Results;

    if ~isempty(stOpt.Lim) && length(stOpt.Lim) ~= 2
        fprintf(2, 'Error: Lim specified, but must be of dimension 2.\n');
        return;
    end % if

    % Data
    oPha      = Phase(oData,vSpecies.Name,'Units','SI');
    oPha.Time = iTime;
    stData    = oPha.Phase1D(sAxis,'Lim',stOpt.Lim);
    
    if isempty(stData)
        fprintf(2, 'Error: No data.\n');
        stReturn.Error = 'No data';
        return;
    end % if

    aData    = stData.Data*100;
    aAxis    = stData.Axis;
    vAxis    = oData.Translate.Lookup(strrep(stData.AxisName,'x1','xi'));
    vDeposit = oData.Translate.Lookup(stData.Deposit);

    % Scale Data
    dAMax = max(abs(aAxis));
    [dAVal,sAUnit] = fAutoScale(dAMax,stData.AxisUnit);
    aAxis = aAxis*dAVal/dAMax;

    stReturn.DataSet   = stData.DataSet;
    stReturn.AxisRange = stData.AxisRange;
    stReturn.AxisScale = dAVal/dAMax;

    % Plot
    
    if strcmpi(stOpt.IsSubPlot, 'No')
        clf;
        if strcmpi(stOpt.AutoResize, 'On')
            fFigureSize(gcf, stOpt.FigureSize);
        end % if
        set(gcf,'Name',sprintf('PhaseSpace 1D (%s #%d)',oData.Config.Name,iTime))
    else
        cla;
    end % if

    plot(aAxis,aData);

    if strcmpi(stOpt.HideDump, 'No')
        sTitle = sprintf('%s on %s %s (%s #%d)',vSpecies.Full,vAxis.Full,oPha.PlasmaPosition,oData.Config.Name,iTime);
    else
        sTitle = sprintf('%s on %s %s',vSpecies.Full,vAxis.Full,oPha.PlasmaPosition);
    end % if

    title(sTitle);
    xlabel(sprintf('%s [%s]',vAxis.Tex,sAUnit));
    ylabel(sprintf('%s/\\Sigma%s [%%]',vDeposit.Tex,vDeposit.Tex));
    
    if ~isempty(stOpt.Lim)
        xlim(stOpt.Lim*stReturn.AxisScale);
    end % if
    
    % Return

    stReturn.Species = vSpecies.Name;
    stReturn.HAxis   = vAxis.Name;
    stReturn.XLim    = xlim;
    stReturn.YLim    = ylim;

end % function
