function [ cco, cro, DoG, layersm, T ] = DataModel(inctable, fnmind, dataloc, frat)
% Purpose: 		Finds the center and radius of the raw data.
%
% Input:
% inctable 		A table containing the filenames and grid dimensions.
% fnmind 		The index of the file imported in inctable.
% dataloc 		Directory path containing the xls folder with the raw scan files.
% frat 			Fovea factor for modelling (default: 2).
%
% Output:
% cco 			The model center.
% cro 			The model radius.
% DoG 			The model function.
% layersm 		The layers of the imported scan corrected for missing values.
% T 			The imported raw data table (for later format reference).

% Initialization:
datalocxls = [ dataloc, '/xls' ];
dataloccsv = [ dataloc, '/csv' ];
sc = inctable{fnmind, 1};
fnm = [ sc{1}, '.xls' ];

% Creating a csv version:
fnm2 = [ sc{1}, '.csv' ];
if ~exist([ dataloccsv, '/', fnm2 ]) % 2
	pwd0 = pwd;
	cd(datalocxls);
	copyfile(fnm, [ '../csv/', fnm2 ]);
	cd(pwd0);
end % 2

% Setting the increments:
Ainc = inctable{fnmind, 5};
Binc = inctable{fnmind, 6};
Anum = inctable{fnmind, 7};
Bnum = inctable{fnmind, 8};

% Importing the data file:
T = readtable([ dataloccsv, '\', fnm2 ]);
Tc = table2cell(T);
mfun = @(s) MyStr2Num(s);

layers = {};
for u = 1:2:21 % 3: layers
	su = Tc((2 + u):23:(2 + u + (Bnum-1)*23), :);
	layers{end+1} = cell2mat(cellfun(mfun, su, 'UniformOutput', false));
end % 3

% Handle missing values by averaging neighbors:
layersm = DataMissingValues(layers, Anum, Bnum, Ainc, Binc);

% Modelling:
% lyr = layersh{2}';
lyr = (layersm{11} - layersm{2})';
[ c, inds, fovmins, fovmaxsl, fovmaxsr ] = ModelAxis3D(lyr, Anum, Ainc, Bnum, Binc);

ex = [ fovmaxsl(:, 1); fovmaxsr(:, 1) ];
ey = [ fovmaxsl(:, 2); fovmaxsr(:, 2) ];
ez = [ fovmaxsl(:, 3); fovmaxsr(:, 3) ];
enum = size(ex, 1);

[ ccx, ccy, cr ] = FitCircle([ ex, ey ]);
cpars = [ ccx, ccy, cr ];

x = linspace(0, (Anum-1)*Ainc, Anum)';
y = linspace(0, (Bnum-1)*Binc, Bnum)';
z = lyr; % z(i, j) = Surf(x(i), y(j))
% disp(' ');
% frat = input('Fovea factor for modelling (default: 2; all: Inf) = ');
Acen = round(ccx/Ainc) + 1;
Bcen = round(ccy/Binc) + 1;
Aspan = round(frat*cr/Ainc);
Bspan = round(frat*cr/Binc);
Ainds = max(1, Acen - Aspan):min(Acen + Aspan, Anum);
Binds = max(1, Bcen - Bspan):min(Bcen + Bspan, Bnum);
x2 = x(Ainds);
y2 = y(Binds);
z2 = z(Ainds, Binds);
% disp(' ');
% titer = input('Time limit for optimization (default: 0.5 min) = ');

[ vopt, zopt, R2 ] = Model_DoG3D_Cir(x2, y2, z2, cpars, 0);

% Determining the fovea rim circle center and radius:
ccxo = vopt(6);
ccyo = vopt(7);
h = vopt(1);
a1 = 10^vopt(2);
a2 = 10^vopt(3);
b1 = 10^vopt(4);
b2 = 10^vopt(5);

cco = ccxo + ccyo*i; % center
cro = sqrt((1/(a2-a1))*log((a2*b2)/(a1*b1))); % radius

% The model over the complex plane:
DoG = @(xy) h + b1*exp(-a1*(abs(xy - cco).^2)) - b2*exp(-a2*(abs(xy - cco).^2));

% Check if model is degenerate:
t = min(x2):0.01:max(x2);
linray = t + ccyo*i;
zray = DoG(linray);
[ lm, lmi, lcl ] = MyFindPeaks(zray);
lmd = lmi(end) - lmi(1);
moddeg = (lmd < 10);

if moddeg
	cco = ccx + ccy*i;
	cro = cr;
end