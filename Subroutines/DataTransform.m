function [ layersm2, Ainc2, Binc2 ] = DataTransform(inctable, fnmind, cco, cro, DoG, layersm, fratexp)
% Purpose: 		Transforms all the layers to a common grid.
%
% Input:
% inctable 		A table containing the filenames and grid dimensions.
% fnmind 		The index of the file imported in inctable.
% cco 			The model center.
% cro 			The model radius.
% DoG 			The model function.
% layersm 		The layers of the imported scan corrected for missing values.
% fratexp 		The factor which the fovea radius is to be multiplied by to get the new grid.
%
% Output:
% layersm2 		The transformed layers over the standard grid.
% Ainc2 		The increment between the transformed A-scan grid points.
% Binc2 		The increment between the transformed B-scan grid points.

% Initializing:
clear i

% Initializing the meshes:
Ainc = inctable{fnmind, 5};
Binc = inctable{fnmind, 6};
Anum = inctable{fnmind, 7};
Bnum = inctable{fnmind, 8};

minx = 0;
maxx = (Anum-1)*Ainc;
miny = 0;
maxy = (Bnum-1)*Binc;

x = linspace(minx, maxx, Anum)';
y = linspace(miny, maxy, Bnum)';
[ ym, xm ] = meshgrid(y, x);
xmv = xm(1:end);
ymv = ym(1:end);

span = fratexp*cro;
minx2 = real(cco) - span;
maxx2 = real(cco) + span;
miny2 = imag(cco) - span;
maxy2 = imag(cco) + span;

x2 = linspace(minx2, maxx2, Anum)';
y2 = linspace(miny2, maxy2, Bnum)';
Ainc2 = (maxx2 - minx2)/(Anum - 1);
Binc2 = (maxy2 - miny2)/(Bnum - 1);
[ y2m, x2m ] = meshgrid(y2, x2);
x2mv = x2m(1:end);
y2mv = y2m(1:end);

rinds = find((x2mv >= minx) & (x2mv <= maxx) & (y2mv >= miny) & (y2mv <= maxy));
binds = find((x2mv < minx) | (x2mv > maxx) | (y2mv < miny) | (y2mv > maxy));

% Initializing layers:
layersh = {};
for ind = 1:11
	layersh{end+1} = layersm{11} - layersm{ind};
end

% Transforming the reference layer:
zr = layersm{11}';
zrv = zr(1:end);
zr2 = 0*zr;
zr2v = 0*zrv;

zr2v(rinds) = griddata(xm, ym, zr, x2mv(rinds), y2mv(rinds), 'cubic');
ninds = find(isnan(zr2v));
zr2v(ninds) = 0;
zr2(1:end) = zr2v;

% Transforming all the other layers:
layersm2 = {};

for ilay = 1:11 % 1

z = layersh{ilay}';
zv = z(1:end);
z2 = 0*z;
z2v = 0*zv;

z2v(rinds) = griddata(xm, ym, z, x2mv(rinds), y2mv(rinds), 'cubic');
ninds = find(isnan(z2v));
z2v(ninds) = 0;

if (ilay == 2) % 2
	z2v(binds) = DoG(x2mv(binds) + i*y2mv(binds));
end % 2
z2(1:end) = z2v;

z22v = 0*z2v;
z22v(rinds) = zr2v(rinds) - z2v(rinds);
z22 = 0*z2;
z22(1:end) = z22v;
layersm2{end+1} = z22';

end % 1