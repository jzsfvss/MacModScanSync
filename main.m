%_________________________________________________________________________________________
% Initialization
%‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾
global citer
global miter
global titer
global lnw

warning('off', 'all')
% clear all
clc
diary off
format long

% Set constants manually:
dataloc = [ pwd, '\Data' ]; % Location of the input data.
scansloc = [ pwd, '\Data\scans.xlsx' ]; % Location of the raw scan increment data.
scanslocp = [ pwd, '\Data\scans_p.xlsx' ]; % Location of the raw scan increment data.
imglocraw = [ pwd, '\Imgs' ]; % Location of the input data.
fnmlog = 'log'; % Runtime record (diary) filename.
glev = 0.35; % Greyness level.
lnw = 2.25; % Wide line width.
ccspfac = Inf; % Cross-section modelling span factor (use 1 for the fovea, and Inf for full modelling).
titer = 0.5; % Time allowed for 3D model fitting (default: 0.5 mins).
frat = 2; % Fovea factor for modelling (default: 2; all: Inf).
fratexp = 2; % Fovea factor for exporting.

datalocxls = [ dataloc, '\xls' ];
dataloccsv = [ dataloc, '\csv' ];
datalocxlsp = [ dataloc, '\xls_p' ];
dataloccsvp = [ dataloc, '\csv_p' ];

% Set paths:
rehash path
addpath('.\Subroutines');
addpath('.\Open_Source');
addpath('.\Open_Source\export_fig');
addpath('.\Open_Source\cprintf');
addpath('.\Open_Source\hline_vline');
addpath('.\Open_Source\fit_ellipse');
addpath(dataloc);
addpath(imglocraw);

% Set colors:
clrs = cell(8, 1);
clrs{1} = [1 1 1]; % white
clrs{2} = [0 0 0]; % black
clrs{3} = [0 0 1]; % blue
clrs{4} = [0 1 0]; % green
clrs{5} = [1 0 0]; % red
clrs{6} = [1 1 0]; % yellow
clrs{7} = [1 0 1]; % magenta
clrs{8} = [0 1 1]; % cyan

% Set layers:
if ~exist('lns')
	lns = {'ILM', 'NFL', 'GCL', 'IPL', 'INL', 'OPL', 'ELM', 'PR1', 'PR2', 'RPE', 'BM', 'SNFL'};
end

if ~exist('lnl')

lnl = {'Internal Limiting Membrane',
'Nerve Fibre Layer',
'Ganglion Cell Layer',
'Inner Plexiform Layer',
'Inner Nuclear Layer',
'Outer Plexiform layer',
'External Limiting Membrane',
'Photoreceptor Layer 1',
'Photoreceptor Layer 2',
'Retinal Pigment Epithelium',
'Basement Membrane',
'Symmetrized Nerve Fibre Layer'};

end
%_________________________________________________________________________________________
% Menu
%‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾
diary([ fnmlog, '.txt' ]);

% Display software name:
[ c8, ct8 ] = MyHexaColor('B87C3D');
[ c9, ct9 ] = MyHexaColor('3D57B8');
[ c10, ct10 ] = MyHexaColor('5D5D5D');

disp(' ');
% cprintf('black', [ repmat(num2str(char(95)), 1, 63), '\n' ]);
cprintf([ '*', ct9 ], 'Macula Modeller and Scan Synchronizer ');
cprintf('black', '| ');
cprintf([ '*', ct8 ], 'Version 8 ');
cprintf('black', '| ');
cprintf([ '*', ct10 ], [ 'J', num2str(char(243)), 'zsef Vass\n' ]);
% cprintf('black', [ repmat('‾', 1, 63), '\n' ]);
disp(' ');

% Menu:
opts = {'Menu'};
opts{end+1} = 'Load: raw data'; % 1
opts{end+1} = 'Plot: raw / processed data'; % 2
opts{end+1} = 'Analyze: raw / processed data'; % 3
opts{end+1} = 'Model: cross-section from image'; % 4
opts{end+1} = 'Model: cross-section'; % 5
opts{end+1} = 'Model: fovea axis'; % 6
opts{end+1} = 'Model: fovea ellipse'; % 7
opts{end+1} = 'Model: complete fit in 3D (elliptical)'; % 8
opts{end+1} = 'Model: complete fit in 3D (circular)'; % 9: circular
opts{end+1} = 'Process: data to standard center and scale'; % 10
opts{end+1} = 'Load: processed data'; % 11

optn = [ 1, 11, 2, 3, 5, 4, 9, 8, 10 ];
opti = OptSel(opts([ 1, 1 + optn ]), 1);
opt = optn(opti);

if ~exist('optp')
	optp = 0;
end
%_________________________________________________________________________________________
% 1./11. Load: raw / processed data
%‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾
if ((opt == 1) || (opt == 11)) % 0

if (opt == 1) % 6
	scansloc0 = scansloc;
	datalocxls0 = datalocxls;
else
	scansloc0 = scanslocp;
	datalocxls0 = datalocxlsp;
end % 6

% Import raw data:
if exist(scansloc0) % 1
	if (~exist('inctable') || (opt ~= optp) || (opt == 11)) % 2
		disp(' ');
		if (opt == 1) % 3
			disp([ 'Importing <scans.xlsx>...' ]);
			optp = 1;
		else % 3
			disp([ 'Importing <scans_p.xlsx>...' ]);
			optp = 11;
		end % 3
		tic;
		inctable = readtable(scansloc0);
		rt = toc;
		fprintf([ '\bdone in ', num2str(rt, '%.2f'), ' secs.\n' ]);
	end % 2
else % 1
	inctable = [];
end % 1

disp(' ');
[ layers, fnm, fnmind, inctable, impsucc ] = DataImport(datalocxls0, 2, inctable);
if (impsucc == 0)
	disp(' ');
	diary off
	return
end
lyrsymboo = 0;
Ainc = inctable{fnmind, 5};
Binc = inctable{fnmind, 6};
if (Ainc ==  0) % 5
	Anum = 512;
	Bnum = 25;
	Ainc = 1;
	Binc = 1;
else % 5
	Anum = inctable{fnmind, 7};
	Bnum = inctable{fnmind, 8};
end % 5

% Handle missing values by averaging neighbors:
layersm = DataMissingValues(layers, Anum, Bnum, Ainc, Binc);

% Find the height of each layer relative to the basement membrane:
layersh = {};
layersh2 = {};
layersh3 = {};

layersb = (layersm{9} + layersm{10} + layersm{11})/3; % Ave. bottom three membranes.

for i = 1:11 % 3
	layersh{end+1} = layersm{11} - layersm{i};
	layersh2{end+1} = layersb - layersm{i};
end % 3

for i = 1:2 % 4
	layersh3{end+1} = layersm{3} - layersm{i};
end % 4

layersh4 = layersm{2} - layersm{1};

maxz = max(max(layersh{1}));

clear optoe
clear optoc

beep on
beep
beep off

end % 0
%_________________________________________________________________________________________
% 2. Plot: raw / processed data
%‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾
if (opt == 2)

disp(' ');
optmenu0 = {'Values', 'Absolute', 'Relative to BM', 'Relative to AveL9-11', 'Relative to GCL', 'Relative to NFL'};
optra = OptSel(optmenu0, 1);

switch optra
case 1
	mlen = 11;
	ra = 'A';
case 2
	mlen = 10;
	ra = 'R';
case 3
	mlen = 8;
	ra = 'M';
case 4
	mlen = 2;
	ra = 'G';
otherwise
	mlen = 1;
	ra = 'N';
end

switch optra
case 1 % Absolute.
	maxz = max(max(layersm{1}));
case 2 % Relative to BM.
	maxz = max(max(layersh{1}));
case 3 % Relative to AveL9-11.
	maxz = max(max(layersh2{1}));
case 4 % Relative to GCL.
	maxz = max(max(layersh3{1}));
otherwise % Relative to NFL.
	maxz = max(max(layersh4));
end

% mlen = 10 + (optra == 1);
if (optra < 5)
	disp(' ');
	optmenu = [ {'Plot'}, reshape(lns(1:mlen), [ 1, mlen ]) ];
	ilay = OptSel(optmenu, 2, 10);
else
	ilay = 1;
end

if (ilay == 2) % 1

disp(' ');
optsym = input('Symmetrize? y/n = 1/0 ');

if optsym % 2
	if ~lyrsymboo % 3
		lyrsym = SurfSym(layersh, Anum, Bnum);
		layersh{end+1} = lyrsym;
		lyrsymboo = 1;
	end % 3
	ilay = 12;
end % 2

end % 1

% Plotting:
h = PlotLayer(fnm, lnl, optra, ilay, layersm, layersh, layersh2, layersh3, layersh4, Anum, Bnum, Ainc, Binc);

beep on
beep
beep off

disp(' ');
opt0 = input('Save plot? y/n=1/0 ');
if (opt0) % 4
	export_fig tmp -png -transparent -m3;
	if (ilay < 10)
		zer = '0';
	else
		zer = '';
	end
	fnmp = [ 'Fig_', replace(fnm(1:(end-4)), '_', '-'), '_', ra, zer, num2str(ilay), '.', lns{ilay} ];
	movefile('tmp.png', [ '.\Plots\', fnmp, '.png' ]);		
	disp('Figure saved to file:');
	disp([ pwd, '\Plots\', fnmp, '.png' ]);
end % 4

end
%_________________________________________________________________________________________
% 3. Analyze: raw data
%‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾
if (opt == 3)

statst = DataStats(layersh, lnl, Anum, Bnum);

disp(' ');
disp('Raw data height statistics relative to ave. ILM height from BM (%):');
disp(' ');
disp(statst);

beep on
beep
beep off

end
%_________________________________________________________________________________________
% 4. Model: cross-section from image
%‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾
if (opt == 4) % 0

% Imports a cross-section image file from the Imgs directory:
[ img, fnmimg ] = ImgImport(imglocraw, 2, 'png');
rs = size(img, 1);
cs = size(img, 2);
imgm = ~(img == 0);
imgm = imgm(:, :, 1);

% Extracting the cross-section model data:
csmod = zeros(cs, 1);
for j = 1:cs % 1
	hs = sort(rs - find(imgm(:, j)));
	csmod(j) = hs(3) - (hs(1) + hs(2))/2;
end % 1

% Smoothing options:
disp(' ');
opt2 = OptSel({'Smoothing', 'Mean', 'Median', 'Gaussian', 'Linear regression', 'Quadratic regression', 'Savitzky-Golay filter'}, 2);
meths = {'movmean', 'movmedian', 'gaussian', 'lowess', 'loess', 'sgolay'};
methsn = {'mean', 'median', 'gaussian', 'linreg', 'quadreg', 'savgol'};
meth2 = meths{opt2};
methn2 = methsn{opt2};
disp(' ');
maper = input('Smoothing span (recommended: 35) = ');

% Smoothing:
y0 = csmod;
y = smoothdata(csmod, meth2, maper);
[ mv, mi ] = min(y);
x = (0:(cs-1))';
lx = length(x);
ra = 'R'; % Relative to BM.
miny = min(y);
maxy = max(y);

% Rescaling:
x = (6000/lx)*x;
y0 = (10^5)*(2.25 + 1.5*(y0 - miny)/(maxy - miny));
y = (10^5)*(2.25 + 1.5*(y - miny)/(maxy - miny));
miny = min(y);
maxy = max(y);

% Find the axis:
[ aind, lind, rind, avals ] = ModelAxis2D(y);
c = x(aind);

% Set up modelling points:
if (ccspfac ~= Inf)
	ccsp = round(ccspfac*min(aind - lind, rind - aind));
	lind2 = max(aind - ccsp, 1);
	rind2 = min(aind + ccsp, length(x));
else
	ccsp = min(aind - 1, length(x) - aind);
	lind2 = aind - ccsp;
	rind2 = aind + ccsp;
end

% Symmetrizing the modelling:
xm = x(lind2:rind2, 1);
ym1 = (y(lind2:(aind-1), 1) + y(rind2:(-1):(aind+1), 1))/2;
ym2 = ym1(end:(-1):1);
ym = [ ym1; y(aind); ym2 ];

% Modelling:
[ vopt, zm ] = Model_DoG2D(xm, ym, miny, c, 1);
fnmmod = 'DoG';
fnmmod2 = 'Difference of Gaussians Model';

% Plotting:
cla;
clf;
hold on

plot(x, y0, '-', 'Color', (1-glev)*clrs{1} + glev*clrs{2}, 'LineWidth', 3*lnw);
h = plot(xm, ym, '-', 'Color', clrs{5}, 'LineWidth', 2*lnw);
% h.Color(4) = 0.5; % Change opacity.
plot(xm, zm, '-', 'Color', clrs{2}, 'LineWidth', lnw);

plot([ x(lind), x(rind) ], [ y(lind), y(rind) ], 'b.', 'MarkerSize', 20);
axis([ 0, 6000, miny - 0.05*(maxy-miny), maxy + 0.05*(maxy-miny) ]);

vlout = vline(c, 'k:', [ 'x = ', num2str(c, '%.2f') ]);
vlout = vline(x(lind2), 'r:', [ 'x(', num2str(lind2), ') = ', num2str(x(lind2)) ]);
vlout = vline(x(rind2), 'r:', [ 'x(', num2str(rind2), ') = ', num2str(x(rind2)) ]);

xlabel([ 'A scans' ]);
ylabel('Height from BM  (nm)');
title([ fnmmod, ' Model  <', fnmimg, '>' ], 'Interpreter', 'none');

legend({ 'Cross-section', 'Smoothed and symmetrized c.s.', 'Model', 'Cross-section maxima' });
glg = findobj(gcf,'Type','axes','Tag','legend');
set(glg, 'Color', 'None', 'Interpreter', 'none');
glg2 = findall(gcf, 'tag', 'legend');
set(glg2, 'location', 'northeast');

set(gcf, 'units', 'normalized', 'outerposition', [0 0 1 1]);

hold off

beep on
beep
beep off

disp(' ');
opt0 = input('Save plot? y/n=1/0 ');
if (opt0) % 1
	export_fig tmp -png -transparent -m3;
	fnmp = [ 'Fig_', fnmmod, '_', fnmimg ];
	movefile('tmp.png', [ '.\Plots\', fnmp, '.png' ]);		
	disp('Figure saved to file:');
	disp([ pwd, '\Plots\', fnmp, '.png' ]);
end % 1

end % 0
%_________________________________________________________________________________________
% 5. Model: cross-section
%‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾
if (opt == 5)

% Set the x-values:
if (Ainc == 0)
	x = linspace(0, 100, Anum)';
else
	x = linspace(0, (Anum-1)*Ainc, Anum)';
end
lx = length(x);

% Set the y-values:
disp(' ');
sel = OptSel2('B scans', 1:Bnum, 0, 20);
ilay = 2; % NFL
layi = layersh{ilay}';
y = layi(:, sel);
miny = min(y);
maxy = max(max(layersh{1}));
ra = 'R';

% Find the axis:
[ aind, lind, rind, avals ] = ModelAxis2D(y);
c = x(aind);

% Set up modelling points:
if (ccspfac ~= Inf)
	ccsp = round(ccspfac*min(aind - lind, rind - aind));
	lind2 = max(aind - ccsp, 1);
	rind2 = min(aind + ccsp, length(x));
else
	ccsp = min(aind - 1, length(x) - aind);
	lind2 = aind - ccsp;
	rind2 = aind + ccsp;
end

% Symmetrization:
disp(' ');
opt0 = input('Symmetrize the cross-section for modelling? y/n = 1/0 ');

xm = x(lind2:rind2);
if ~opt0
	ym = y(lind2:rind2);
else
	ym1 = (y(lind2:(aind-1)) + y(rind2:(-1):(aind+1)))/2;
	ym2 = ym1(end:(-1):1);
	ym = [ ym1; y(aind); ym2 ];
end

% Modelling:
[ vopt, zm ] = Model_DoG2D(xm, ym, miny, c, 1);
fnmmod = 'DoG';
fnmmod2 = 'Difference of Gaussians Model';

% Plotting:
cla;
clf;
hold on

plot(x, y, '-', 'Color', (1-glev)*clrs{1} + glev*clrs{2}, 'LineWidth', 3*lnw);
h = plot(xm, ym, '-', 'Color', clrs{5}, 'LineWidth', 2*lnw);
plot(xm, zm, '-', 'Color', clrs{2}, 'LineWidth', lnw);

plot([ x(lind), x(rind) ], [ y(lind), y(rind) ], 'b.', 'MarkerSize', 22);
axis([ 0, max(x), 0, maxy ]);

vlout = vline(c, 'k:', [ 'x = ', num2str(c, '%.2f') ]);
vlout = vline(x(lind2), 'r:', [ 'x(', num2str(lind2), ') = ', num2str(x(lind2)) ]);
vlout = vline(x(rind2), 'r:', [ 'x(', num2str(rind2), ') = ', num2str(x(rind2)) ]);

xlabel([ 'A scans  (', num2str(Anum), ' pts at ', num2str(Ainc), ' \mum)' ]);
ylabel('Height from BM  (nm)');
title([ num2str(ilay), '. ', lnl{ilay}, ', B scan ', num2str(sel), '  <', fnm, '>  |  relative view to BM  |  ', fnmmod2 ], 'Interpreter', 'none');

legend({ 'Cross-section', 'Symmetrized cross-section', 'Model', 'Cross-section maxima' });
glg = findobj(gcf,'Type','axes','Tag','legend');
set(glg, 'Color', 'None', 'Interpreter', 'none');
glg2 = findall(gcf, 'tag', 'legend');
set(glg2, 'location', 'northeast');
set(gcf, 'units', 'normalized', 'outerposition', [0 0 1 1]);

hold off

beep on
beep
beep off

disp(' ');
opt0 = input('Save plot? y/n=1/0 ');
if (opt0) % 1
	export_fig tmp -png -transparent -m3;
	if (sel < 10) % 2
		zer = '0';
	else % 2
		zer = '';
	end % 2
	fnmp = [ 'Fig_', replace(fnm(1:(end-4)), '_', '-'), '_', ra, '0', num2str(ilay), '.', lns{ilay}, '.', zer, num2str(sel), '.', num2str(ccspfac), '_', fnmmod ];
	movefile('tmp.png', [ '.\Plots\', fnmp, '.png' ]);		
	disp('Figure saved to file:');
	disp([ pwd, '\Plots\', fnmp, '.png' ]);
end % 1

end
%_________________________________________________________________________________________
% 6. Model: fovea axis
%‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾
if (opt == 6)

if (Ainc == 0)
	disp(' ');
	disp('The fovea axis cannot be determined due to unknown scan increments.');
	disp(' ');
	diary off
	return
end

% Find the fovea center:
lyr = layersh{2}';
disp(' ');
disp([ 'Estimating the axis of rotation...' ]);
tic;
[ c, inds, fovmins, fovmaxsl, fovmaxsr ] = ModelAxis3D(lyr, Anum, Ainc, Bnum, Binc);
rt = toc;
fprintf([ '\bdone in ', num2str(rt, '%.2f'), ' secs.\n' ]);

% Plotting the surface:
h = PlotLayer(fnm, lnl, 2, 2, layersm, layersh, [], [], [], Anum, Bnum, Ainc, Binc);

hold on

% Plotting the symmetry axis:
plot3([ c(1), c(1) ], [ c(2), c(2) ], zlim, 'k-', 'LineWidth', lnw);
plot3(c(1), c(2), c(3), 'k.', 'MarkerSize', 22);

% Plotting the special points:
plot3(fovmins(:, 1), fovmins(:, 2), fovmins(:, 3), 'r.', 'MarkerSize', 22);
plot3(fovmaxsl(:, 1), fovmaxsl(:, 2), fovmaxsl(:, 3), 'b.', 'MarkerSize', 22);
plot3(fovmaxsr(:, 1), fovmaxsr(:, 2), fovmaxsr(:, 3), 'b.', 'MarkerSize', 22);

hold off

beep on
beep
beep off

disp(' ');
opt0 = input('Save plot? y/n=1/0 ');
if (opt0) % 4
	export_fig tmp -png -transparent -m3;
	fnmp = [ 'Fig_', replace(fnm(1:(end-4)), '_', '-'), '_R02.NFL_axis' ];
	movefile('tmp.png', [ '.\Plots\', fnmp, '.png' ]);
	disp('Figure saved to file:');
	disp([ pwd, '\Plots\', fnmp, '.png' ]);
end % 4

end
%_________________________________________________________________________________________
% 7. Model: fovea ellipse
%‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾
if (opt == 7)

if (Ainc == 0)
	disp(' ');
	disp('The fovea ellipse cannot be determined due to unknown scan increments.');
	disp(' ');
	diary off
	return
end

% Find the fovea center:
lyr = layersh{2}';
[ c, inds, fovmins, fovmaxsl, fovmaxsr ] = ModelAxis3D(lyr, Anum, Ainc, Bnum, Binc);

% Find the best fit ellipse for the local maxima:
ex = [ fovmaxsl(:, 1); fovmaxsr(:, 1) ];
ey = [ fovmaxsl(:, 2); fovmaxsr(:, 2) ];
ez = [ fovmaxsl(:, 3); fovmaxsr(:, 3) ];
enum = size(ex, 1);

epars = fit_ellipse(ex, ey);
ecx = epars.X0_in;
ecy = epars.Y0_in;
ea = epars.a;
eb = epars.b;

if (ea >= eb) % The longer axis should always be primary.
	eang = epars.phi;
else
	eang = epars.phi + pi/2;
	tmp = ea;
	ea = eb;
	eb = tmp;
end

% Plotting the surface:
h = PlotLayer(fnm, lnl, 2, 2, layersm, layersh, [], [], [], Anum, Bnum, Ainc, Binc);

hold on

% Plotting the symmetry axis:
plot3([ c(1), c(1) ], [ c(2), c(2) ], zlim, 'k-', 'LineWidth', lnw);
plot3(c(1), c(2), c(3), 'k.', 'MarkerSize', 22);
plot(c(1), c(2), 'k.', 'MarkerSize', 22);

% Plotting the local min.:
plot3(fovmins(:, 1), fovmins(:, 2), fovmins(:, 3), 'r.', 'MarkerSize', 22);

% Plotting the local max.:
plot3(ex, ey, ez, 'b.', 'MarkerSize', 22);
for k = 1:enum
	plot3([ ex(k), ex(k) ], [ ey(k), ey(k) ], [ 0, ez(k) ], 'b-', 'LineWidth', round(lnw/2));
end

% Plotting the ellipse max. points:
plot(ex, ey, 'b.', 'MarkerSize', 22);

% Plotting the ellipse:
t = 0:0.01:2*pi;
clear i
ee = (ecx + ecy*i) + exp(eang*i)*(ea*cos(t) + eb*sin(t)*i);
lindir = (ecx + ecy*i) + exp(eang*i)*ea;

plot(real(ee), imag(ee), 'm-', 'LineWidth', lnw);
plot([ ecx, real(lindir) ], [ ecy, imag(lindir) ], 'm-');
plot(ecx, ecy, 'm.', 'MarkerSize', 22);

hold off

beep on
beep
beep off

disp(' ');
opt0 = input('Save plot? y/n=1/0 ');
if (opt0) % 4
	export_fig tmp -png -transparent -m3;
	fnmp = [ 'Fig_', replace(fnm(1:(end-4)), '_', '-'), '_R02.NFL_ellipse' ];
	movefile('tmp.png', [ '.\Plots\', fnmp, '.png' ]);
	disp('Figure saved to file:');
	disp([ pwd, '\Plots\', fnmp, '.png' ]);
end % 4

end
%_________________________________________________________________________________________
% 8. Model: complete fit in 3D (elliptical)
%‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾
if (opt == 8)

if (Ainc == 0)
	disp(' ');
	disp('The macula cannot be modelled due to unknown scan increments.');
	disp(' ');
	diary off
	return
end

if exist('optoe')
	disp(' ');
	optoe = input('Redo the optimization? y/n = 1/0 ');
else
	optoe = 1;
end

% Optimization:
if (optoe) % 1

% Estimating the initial parameters:
disp(' ');
fprintf([ 'Estimating model parameters...\n' ]);
tic;

% Find the local max:
lyr = layersh{2}';
[ c, inds, fovmins, fovmaxsl, fovmaxsr ] = ModelAxis3D(lyr, Anum, Ainc, Bnum, Binc);

ex = [ fovmaxsl(:, 1); fovmaxsr(:, 1) ];
ey = [ fovmaxsl(:, 2); fovmaxsr(:, 2) ];
ez = [ fovmaxsl(:, 3); fovmaxsr(:, 3) ];
enum = size(ex, 1);

% Fit a circle to the local max:
[ ccx, ccy, cr ] = FitCircle([ ex, ey ]);
cpars = [ ccx, ccy, cr ];

% Fit an ellipse to the local max:
epars = fit_ellipse(ex, ey);
ecx = epars.X0_in;
ecy = epars.Y0_in;
ea = epars.a;
eb = epars.b;

if (ea >= eb) % 2: The longer axis should always be primary.
	eang = epars.phi;
else % 2
	eang = epars.phi + pi/2;
	tmp = ea;
	ea = eb;
	eb = tmp;
end % 2

eang = ModInt(eang, -pi/2, pi/2); % The angle of orientation between [ -pi/2, pi/2 ].

epars = [ ecx, ecy, ea, eb, eang ];

rt = toc;
fprintf([ '\bdone in ', num2str(rt, '%.2f'), ' secs.\n' ]);

% Fitting the model:
x = linspace(0, (Anum-1)*Ainc, Anum)';
y = linspace(0, (Bnum-1)*Binc, Bnum)';
z = lyr; % z(i, j) = Surf(x(i), y(j))

disp(' ');
titer = input('Time limit for optimization (default: 1 min) = ');

[ vopt, zopt ] = Model_DoG3D_Ell(x, y, z, epars, 1);

end % 1

% Plotting:
cla;
clf;
hold on

% Plotting the raw data lines:
for l = 1:Bnum
	plot3(x, (l-1)*Binc*ones(Anum, 1), z(:, l), 'k-', 'LineWidth', lnw);
end

% Plotting the model surface:
[ yp, xp ] = meshgrid(y, x);
Mnum = max(Anum, Bnum);
x0 = linspace(0, (Anum-1)*Ainc, Mnum);
y0 = linspace(0, (Bnum-1)*Binc, Mnum);
[ yp, xp ] = meshgrid(y0, x0);
clear i
zp = Function_DoG3D_Ell(vopt, xp + i*yp, 0);

s = surf(xp, yp, zp, 'FaceAlpha', 0.5, 'EdgeColor', 'none');

% Plotting the axis of revolution:
mcx = vopt(6);
mcy = vopt(7);
plot3([ mcx, mcx ], [ mcy, mcy ], [ 0, maxz ], 'b-', 'LineWidth', lnw);

% Plotting the local min.:
plot3(fovmins(:, 1), fovmins(:, 2), fovmins(:, 3), 'r.', 'MarkerSize', 22);

% Plotting the local max.:
plot3(ex, ey, ez, 'b.', 'MarkerSize', 22);

% Axis settings:
ylabel([ 'B scans  (', num2str(Bnum), ' pts at ', num2str(Binc), ' \mum)' ]);
xlabel([ 'A scans  (', num2str(Anum), ' pts at ', num2str(Ainc), ' \mum)' ]);
zlabel('Height from BM  (nm)');
title([ num2str(2), '. ', lnl{2}, '  <', fnm, '>  |  relative view to BM' ], 'Interpreter', 'none');

axis tight
zlim([ 0, maxz ]);
set(gcf, 'units', 'normalized', 'outerposition', [0 0 1 1]);
view(10, 20)

hold off

beep on
beep
beep off

disp(' ');
opt0 = input('Save plot? y/n=1/0 ');
if (opt0) % 4
	export_fig tmp -png -transparent -m3;
	fnmp = [ 'Fig_', replace(fnm(1:(end-4)), '_', '-'), '_R02.NFL_ellmodel' ];
	movefile('tmp.png', [ '.\Plots\', fnmp, '.png' ]);
	disp('Figure saved to file:');
	disp([ pwd, '\Plots\', fnmp, '.png' ]);
end % 4

end
%_________________________________________________________________________________________
% 9. Model: complete fit in 3D (circular)
%‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾
if (opt == 9)

if (Ainc == 0)
	disp(' ');
	disp('The macula cannot be modelled due to unknown scan increments.');
	disp(' ');
	diary off
	return
end

if exist('optoc')
	disp(' ');
	optoc = input('Redo the optimization? y/n = 1/0 ');
else
	optoc = 1;
end

% Optimization:
if (optoc) % 1

ilay = 2;

% Symmetrization:
disp(' ');
optsym = input('Symmetrize? y/n = 1/0 ');
if optsym % 2
	if ~lyrsymboo % 3
		lyrsym = SurfSym(layersh, Anum, Bnum);
		layersh{end+1} = lyrsym;
		lyrsymboo = 1;
	end % 3
	ilay = 12;
end % 2

% Estimating the initial parameters:
disp(' ');
fprintf([ 'Estimating model parameters...\n' ]);
tic;

% Find the local max:
lyr = layersh{ilay}';
[ c, inds, fovmins, fovmaxsl, fovmaxsr ] = ModelAxis3D(lyr, Anum, Ainc, Bnum, Binc);

ex = [ fovmaxsl(:, 1); fovmaxsr(:, 1) ];
ey = [ fovmaxsl(:, 2); fovmaxsr(:, 2) ];
ez = [ fovmaxsl(:, 3); fovmaxsr(:, 3) ];
enum = size(ex, 1);

% Fit a circle to the local max:
[ ccx, ccy, cr ] = FitCircle([ ex, ey ]);
cpars = [ ccx, ccy, cr ];

rt = toc;
fprintf([ '\bdone in ', num2str(rt, '%.2f'), ' secs.\n' ]);

% Fitting the model:
x = linspace(0, (Anum-1)*Ainc, Anum)';
y = linspace(0, (Bnum-1)*Binc, Bnum)';
z = lyr; % z(i, j) = Surf(x(i), y(j))

disp(' ');
frat = input('Fovea factor for modelling (default: 2; all: Inf) = ');
Acen = round(ccx/Ainc) + 1;
Bcen = round(ccy/Binc) + 1;
Aspan = round(frat*cr/Ainc);
Bspan = round(frat*cr/Binc);
Ainds = max(1, Acen - Aspan):min(Acen + Aspan, Anum);
Binds = max(1, Bcen - Bspan):min(Bcen + Bspan, Bnum);

x2 = x(Ainds);
y2 = y(Binds);
z2 = z(Ainds, Binds);

disp(' ');
titer = input('Time limit for optimization (default: 0.5 min) = ');

[ vopt, zopt, R2 ] = Model_DoG3D_Cir(x2, y2, z2, cpars, 1);

end % 1

% Plotting:
cla;
clf;
hold on

% Plotting the raw data lines:
for l = 1:Bnum
	plot3(x, (l-1)*Binc*ones(Anum, 1), z(:, l), 'k-', 'LineWidth', lnw/2);
end

% Plotting the model surface:
Mnum = max(Anum, Bnum);
xmax0 = (Anum-1)*Ainc;
ymax0 = (Bnum-1)*Binc;
x0 = linspace(0, xmax0, Mnum);
y0 = linspace(0, ymax0, Mnum);
Ainc0 = xmax0/Mnum;
Binc0 = ymax0/Mnum;

Acen0 = round(ccx/Ainc0) + 1;
Bcen0 = round(ccy/Binc0) + 1;
Aspan0 = round(frat*cr/Ainc0);
Bspan0 = round(frat*cr/Binc0);
Ainds0 = max(1, Acen0 - Aspan0):min(Acen0 + Aspan0, Mnum);
Binds0 = max(1, Bcen0 - Bspan0):min(Bcen0 + Bspan0, Mnum);

x02 = x0(Ainds0);
y02 = y0(Binds0);

[ yp, xp ] = meshgrid(y02, x02);
clear i
zp = Function_DoG3D_Cir(vopt, xp + i*yp, 0);

s = surf(xp, yp, zp, 'FaceAlpha', 0.5, 'EdgeColor', 'none');

% Plotting the local min.:
plot3(fovmins(:, 1), fovmins(:, 2), fovmins(:, 3), 'r.', 'MarkerSize', 22);

% Plotting the local max.:
plot3(ex, ey, ez, 'b.', 'MarkerSize', 22);

% Determining the fovea max. circle:
ccxo = vopt(6);
ccyo = vopt(7);
clear i
cco = ccxo + ccyo*i; % Fovea center.

t1 = min(x2):0.01:max(x2);
linray1 = t1 + ccyo*i;
t2 = min(y2):0.01:max(y2);
linray2 = t2*i + ccxo;

h = vopt(1);
a1 = 10^vopt(2);
a2 = 10^vopt(3);
b1 = 10^vopt(4);
b2 = 10^vopt(5);
DoG = @(xy) h + b1*exp(-a1*(abs(xy - cco).^2)) - b2*exp(-a2*(abs(xy - cco).^2));

zray1 = DoG(linray1);
zray2 = DoG(linray2);

% Check if the model is degenerate:
[ lm, lmi, lcl ] = MyFindPeaks(zray1);
lmd = lmi(end) - lmi(1);
moddeg = (lmd < 10);

% Fovea radius:
if ~moddeg
	cro = sqrt((1/(a2-a1))*log((a2*b2)/(a1*b1)));
	croz = DoG(cco + cro);
else
	cco = ccx + ccy*i;
	cro = cr;
	croz = sum(ez)/length(ez);
end

% Plotting the axis of revolution:
if ~moddeg
	mcx = vopt(6);
	mcy = vopt(7);
else
	mcx = ccx;
	mcy = ccy;
end
plot3([ mcx, mcx ], [ mcy, mcy ], [ 0, maxz ], 'm-', 'LineWidth', lnw);

% Plotting the fovea max. circle:
t = 0:0.01:2*pi;
clear i
cpts = cco + cro*exp(t*i);

plot3(real(cpts), imag(cpts), croz + 0*real(cpts), 'm-', 'LineWidth', lnw);

% Plotting the cross-sections:
if ~moddeg
	plot3(real(linray1), imag(linray1), zray1, 'm-', 'LineWidth', lnw);
	plot3(real(linray2), imag(linray2), zray2, 'm-', 'LineWidth', lnw);
end

% Plotting the model min.:
if ~moddeg
	ccoz = DoG(cco);
	plot3(real(cco), imag(cco), ccoz, 'm.', 'MarkerSize', 22);
end

% Plotting the model max:
if ~moddeg
	cptsm = [ cco + cro, cco - cro, cco + cro*i, cco - cro*i ];
	plot3(real(cptsm), imag(cptsm), croz + 0*real(cptsm), 'm.', 'MarkerSize', 22);
end

% Axes settings:
ylabel([ 'B scans  (', num2str(Bnum), ' pts at ', num2str(Binc), ' \mum)' ]);
xlabel([ 'A scans  (', num2str(Anum), ' pts at ', num2str(Ainc), ' \mum)' ]);
zlabel('Height from BM  (nm)');
title([ num2str(2), '. ', lnl{2}, '  <', fnm, '>  |  relative view to BM' ], 'Interpreter', 'none');

axis tight
zlim([ 0, maxz ]);
set(gcf, 'units', 'normalized', 'outerposition', [0 0 1 1]);
view(10, 20)

hold off

beep on
beep
beep off

disp(' ');
opt0 = input('Save plot? y/n=1/0 ');
if (opt0) % 4
	export_fig tmp -png -transparent -m3;
	fnmp = [ 'Fig_', replace(fnm(1:(end-4)), '_', '-'), '_R', num2str(ilay), '.', lns{ilay}, '_cirmodel' ];
	movefile('tmp.png', [ '.\Plots\', fnmp, '.png' ]);
	disp('Figure saved to file:');
	disp([ pwd, '\Plots\', fnmp, '.png' ]);
end % 4

end
%_________________________________________________________________________________________
% 10. Transform / export: data to standard center and scale
%‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾
if (opt == 10) % 0

% Import raw data:
if exist(scansloc) % 1

if ~exist('inctable1') % 2

disp(' ');
disp([ 'Importing <scans.xlsx>...' ]);
tic;

inctable1 = readtable(scansloc);

% Extract the relevant rows with increments, i.e. can be modelled:
rinds = find(prod(inctable1{:, 5:8}, 2) ~= 0);

if (length(rinds) == 0) % 3

rt = toc;
fprintf([ '\bdone in ', num2str(rt, '%.2f'), ' secs.\n' ]);

disp(' ');
disp('No file can be modelled due to unknown scan increments.');
diary off
return

else % 3

rinctable = inctable1(rinds, :);
nf = size(rinctable, 1);

rt = toc;
fprintf([ '\bdone in ', num2str(rt, '%.2f'), ' secs.\n' ]);

end % 3

end % 2

else % 1

disp(' ');
disp('The file <scans.xlsx> must first be generated (option 1).');
diary off
return

end % 1

disp(' ');
optmenu0 = {'Process', 'All', 'Patient', 'Scan'};
optt = OptSel(optmenu0, 2);

% Determining the file indices to import from rinctable:
switch optt
case 1
	% iinds = 1:nf;
	iinds = rinds;
case 2
	disp(' ');
	idsel = OptSel2('Patient IDs-scans', rinctable{:, 2}, 1, 10, 'ID');
	iinds = find(inctable1{:, 2} == idsel);
otherwise
	disp(' ');
	idsel = OptSel2('Patient IDs-scans', rinctable{:, 2}, 1, 10, 'ID');
	idrows = find(inctable1{:, 2} == idsel);

	files2 = inctable1{idrows, 1};
	nf2 = size(files2, 1);
	filemenu = [ {'Scans'}, reshape(files2, [ 1, nf2 ]) ];
	disp(' ');
	ssel = OptSel(filemenu, 2, 6);

	iinds = (idrows(1)-1) + ssel;
end

% Transforming / exporting data to standard center and scale:
fnms = inctable1{:, 1};
iil = length(iinds);

if ~exist(scanslocp)
	inctable2 = inctable1;
	binds = setdiff(1:size(inctable1, 1), iinds);
	inctable2{binds, 5:8} = 0;
else
	disp(' ');
	disp('Importing <scans_p.xlsx>...');
	tic;

	rinctable2 = readtable(scanslocp);

	binds = setdiff(1:size(inctable1, 1), iinds);

	inctable2 = inctable1;
	inctable2{:, 5:8} = 0;
	inctable2{rinds, 5:8} = rinctable2{:, 5:8};
	inctable2{iinds, 5:8} = inctable1{iinds, 5:8};

	rt = toc;
	fprintf([ '\bdone in ', num2str(rt, '%.2f'), ' secs.\n' ]);
end

disp(' ');
for k = 1:iil % 1

fnmind = iinds(k);
disp([ 'Processing <', fnms{fnmind}, '.xls>: ' ]);
tic;

fprintf([ '\bmodelling...\n' ]);
titer = 0.2;
[ cco, cro, DoG, layersm, T ] = DataModel(inctable1, fnmind, dataloc, frat);

fprintf([ '\b\b\b\b, transforming...\n' ]);
[ layersm2, Ainc2, Binc2 ] = DataTransform(inctable1, fnmind, cco, cro, DoG, layersm, fratexp);
inctable2{fnmind, 5} = round(Ainc2, 4);
inctable2{fnmind, 6} = round(Binc2, 4);

fprintf([ '\b\b\b\b, exporting...\n' ]);
res = DataExport(inctable1, fnmind, dataloc, T, layersm2);

rt = toc;
fprintf([ '\bdone in ', num2str(rt/60, '%.2f'), ' mins.\n' ]);

end % 1

% Export scans parameters:
rinctable2 = inctable2(rinds, :);
writetable(rinctable2, scanslocp);

beep on
beep
beep off

end % 0
%_________________________________________________________________________________________
% Termination
%‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾
disp(' ');
diary off