
# Osiris Analysis Toolbox
MATLAB package for analysing Osiris data
Current version: Dev2.0

**Developed by:**<br>
Veronica K. Berglyd Olsen<br>
Department of Physics<br>
University of Oslo

## Development History

### Version 2.0

**Bug Fixes**
* Numerous minor bug fixed to unexpected content in datasets
* Fixed bugs in plot control updates in AnalyseGUI

**New Functionality**
* Added row of buttons in AnalyseGUi for a set of new GUI tools to analyse datasets in more detail. These are:
    * DN (Track Density): A tool to track changes in beam profile based on density data
    * EM (Track Fields):  A tool to track changes in the em-fields as time progresses.
    * 3D (3D Tools):      Some extra tools specifically suited for 3D simulations that aren't covered bu the main GUI.
    * SP (Track Species): A tool to track macroparticles of a specific species.
    * TM (Track Time):    A tool to plot time evolution of a number of key parameters. Replaces the "Time Tools" tab.
    * LN (Lineout Tools): A tool to look at lineouts of various density type plots.
    * PS (Phase Space):   A tool to analyse emittance of a given beam.
* Field class now also calculates wakefields using the simulation moving frame velocities in units of beta. The class OsirisConfig will evaluate the emf reports to determine which wakefields can be calculated, and the GUI will offer a list based on this for the field density plot.
* Momentum.PhaseSpace now accepts Slice and SliceDim as input parameter. The calculation is only made in the region defined by these slice parameters.
* Species names can now have a one digit number appended to them, so ElectronBeam1 and EB1 are valid names.
* Some grid diagnostics options are now supported. 2D slices of 3D data is supported throughout, line data is supported in core objects, and so is time and space averages.

### Version 1.4.2
* Fixed bug in AnalyseGUI where opening a new dataset when another one is loaded caused the maximum zoom limits from the previous dataset to not get updated to the new.
* Added code to disable time step controls when the plots are bing refreshed. Clicking multiple times can cause Matlab to crash if a lot of plots are open at the same time.
* Added a reset button to each plot to reset the limits to maximum simulation box size.

### Version 1.4.1
* Fixed bug in Analyse2D where a refresh following moving to another time step would break before all plots have been updated.
* Fixed bug in calculating Species.EnergyChange with limits set.
* Added current to OsirisData.BeamInfo().

### Version 1.4
* Classes and tools now support 3D simulations in 2D plots by making slices. A flexible Grid2D and Lineout function has been added to OsirisType.
* Added option to select slices in Analyse2D for the relevant plots.
* All classes have better error checking functionality and will report errors rather than fail.
* Added a listbox to browse/load datasets rather than drobdown menu. The dropdown menu does not handle lists longer than the screen height.
* New class and plot for handling UDIST diagnostics.
* First lines of comments in input deck are now read into a string array in OsirisData.Config.Details.
* New class to handle particle tracking. The class is named Species.
* Rewritten reading of RAW data in OsirisData.Data.

### Version 1.3
* Bug fixes.
* OsirisConfig input deck parser has been completely rewritten to parse all types of input decks, in principle, and now stores the raw input deck as a struct. The relevant variables are then extracted and stored in appropriate places. This makes it much easier to implement analysis that needs settings not used before.
* OsirisConfig now has the option to set a simulation N0 and a physics N0 that overrides whatever is extracted from the input deck. They are called SimN0 and PhysN0 respectively.
* Merged BField and EField into single class Field.
* Renamed Charge class to Density, as it now handles all types of densities. This involved renaming the Density method to Density2D. The corresponding method in Phase class was also renamed for consistency.
* Added RawHist1D method to Phase class to analyse the various columns in raw data (macro particles). This involved adding the function fAccu1D to generate histograms of weighted data.
* Various updates to the Variables class. Added fields for standard unit and the number of the dimension the variable belongs to. E.g.: x1 -> Dim = 1, p2 -> Dim = 2, etc.
* OsirisConfig now calculates total charge for all species, and this is used in OsirisData.BeamInfo().
* OsirisData.BeamInfo() now calculates mean and sigma for gaussian beams again.
* Added AddPaths.m script that adds the relevant folders to Matlab path.

### Version 1.2.1
* Bug fixes.
* More code cleanup. Including removing fExtractEQ that has been replaced by class MathFunc.
* Added CAxis as an option to all five standard plots.
* Fixed reloading of vriables when switching datasets for all plots.

### Version 1.2
* Introduced OsirisType as superclass for Charge, BField, EField, Momentum and Phase.
* Introduced Variables as a class to handle Osiris variable checks and conversions to readable and internal formats. This class replaces all the fTranslate... functions from previous version. It also replaces the isBeam, isPlasma, isField and isAxis functions.
* The Variables class can be run independently, but is also accessbile from OsirisData.Translate
* Removed fStringToDump and merged it into OsirisData. This function needs an OsirisData object anyway, so no point having an independant function.
* Merged function fPlasmaPosition into OsirisType. It too needs an OsirisData object, but fits better with OsirisType because ut also depends on the current time dump.
* OsirisData now accepts data files with non-standard species names. In theory. Not tested.

### Version 1.1
* Significant updates to GUI
* Added plot functions and new classes including a MathFunc interpreter.
* Updates and bug fixes for OsirisData and OsirisConfig

### Version 1.0
* Classes now handle units as normalised by default. Changing units is done when the object is created by using standard matlab input pairs. For instance: CH = Charge(<Data object>, 'EB', 'Units', 'SI', 'X1Scale', 'mm'); This sets class units to SI and the x1-axis (xi-axis) to millimetres.
* Added plasma density anim and plot.
* Added Charge class function to return particle selection for scatter plot.
* Added GUI and updated all plot functions accordingly

### Version 0.7
* Added charge conversion calculations to OsirisConfig
* Changed how Osiris datasets are opened
* Bug fixes

### Version 0.6
* Added wavelet functionality

### Version 0.5
* Initial code with classes for reading OsirisData, OsirisConfig and process Charge, EField and Momentum data.
* A set of plot functions
