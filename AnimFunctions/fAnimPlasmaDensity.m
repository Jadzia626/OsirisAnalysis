
%
%  Function: fAnimBeamDensity
% ****************************
%  Plots density plot as animation
%
%  Inputs:
% =========
%  oData    :: OsirisData object
%  sDrive   :: Drive beam
%  sWitness :: Witness beam (optional)
%
%  Options:
% ==========
%  FigureSize  :: Default [1100 600]
%  DriveCut    :: Drive beam limits
%  WitnessCut  :: Witness beam limits
%  Start       :: First dump (default = 0)
%  End         :: Last dump (default = end)
%

function stReturn = fAnimPlasmaDensity(oData, sDrive, sWitness, varargin)

    % Input/Output

    if nargin == 0
       fprintf('\n');
       fprintf('  Function: fAnimBeamDensity\n');
       fprintf(' ****************************\n');
       fprintf('  Plots density plot as animation\n');
       fprintf('\n');
       fprintf('  Inputs:\n');
       fprintf(' =========\n');
       fprintf('  oData    :: OsirisData object\n');
       fprintf('  sDrive   :: Drive beam\n');
       fprintf('  sWitness :: Witness beam (optional)\n');
       fprintf('\n');
       fprintf('  Options:\n');
       fprintf(' ==========\n');
       fprintf('  FigureSize  :: Default [1100 600]\n');
       fprintf('  Limits      :: Limits\n');
       fprintf('  Start       :: First dump (default = 0)\n');
       fprintf('  End         :: Last dump (default = end)\n');
       fprintf('\n');
       return;
    end % if
    
    stReturn   = {};
    sMovieFile = sprintf('AnimPlasmaDensity-%s', oData.Config.Name);

    oOpt = inputParser;
    addParameter(oOpt, 'FigureSize',  [1100 600]);
    addParameter(oOpt, 'Limits',      []);
    addParameter(oOpt, 'Start',       'Start');
    addParameter(oOpt, 'End',         'End');
    parse(oOpt, varargin{:});
    stOpt = oOpt.Results;

    iStart  = oData.StringToDump(stOpt.Start);
    iEnd    = oData.StringToDump(stOpt.End);
    aDim    = stOpt.FigureSize;
    aLimits = stOpt.Limits;


    % Animation Loop

    figMain = figure;
    set(figMain, 'Position', [1800-aDim(1), 1000-aDim(2), aDim(1), aDim(2)]);

    for k=iStart:iEnd

        clf;
        i = k-iStart+1;

        % Call plot
        stInfo = fPlotPlasmaDensity(oData, k, 'PE', 'Absolute', 'Yes', 'Limits', aLimits, 'CAxis', [0 5], ...
                                      'Overlay1', sDrive, 'Overlay2', sWitness, ...
                                      'Scatter1', sDrive, 'Sample1', 3000, 'Filter1', 'W2Random', ...
                                      'Scatter2', sWitness, 'Sample2', 1000, 'Filter2', 'W2Random', ...
                                      'E1',[3,3],'E2',[3,3], ...
                                      'FigureSize', stOpt.FigureSize);

        drawnow;

        set(figMain, 'PaperUnits', 'Inches', 'PaperPosition', [1 1 aDim(1)/96 aDim(2)/96]);
        set(figMain, 'InvertHardCopy', 'Off');
        print(figMain, '-dtiffnocompression', '-r96', '/tmp/osiris-print.tif');
        M(i).cdata    = imread('/tmp/osiris-print.tif');
        M(i).colormap = [];

    end % for

    LocalConfig;
    movie2avi(M, '/tmp/osiris-temp.avi', 'fps', 6, 'Compression', 'None');
    [~,~] = system(sprintf('avconv -i /tmp/osiris-temp.avi -c:v libx264 -crf 1 -s %dx%d -b:v 50000k %s/%s-%s.mp4', aDim(1), aDim(2), sAnimPath, sMovieFile, fTimeStamp));
    [~,~] = system('rm /tmp/osiris-temp.avi');
    
    
    % Return values
    stReturn.Movie      = M;
    stReturn.PlotInfo   = stInfo;

end % function
