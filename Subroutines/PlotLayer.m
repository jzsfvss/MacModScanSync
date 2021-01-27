function [ h, s1 ] = PlotLayer(fnm, lnl, optra, ilay, layersm, layersh, layersh2, layersh3, layersh4, Anum, Bnum, Ainc, Binc)
% Purpose: 		Plots a layer in 3D relative to another.
%
% Input:
% fnm 			Name of the file imported.
% lnl 			A cell vector containing the names of the layers.
% optra 		Option selected for the base layer.
% ilay 			Layer to be plotted.
% layersm 		The layers of the imported scan corrected for missing values.
% layersh 		The distance of the imported layers from the basement membrane (BM).
% layersh2 		The distance of the imported layers from the ave. of the bottom three layers.
% layersh3 		The distance of the imported layers from the GCL.
% layersh4 		The distance of ILM and NFL.
% Anum 			The number of A-scan values in the grid.
% Bnum 			The number of B-scan values in the grid.
% Ainc 			The increment between the A-scan grid points.
% Binc 			The increment between the B-scan grid points.
%
% Output:
% h 			Figure handle.
% s1 			Surface handle.

global lnw

switch optra
case 1 % Absolute.
	layi = layersm{ilay}';
	maxz = max(max(layersm{1}));
	layi = max(max(layersm{11})) - layi;
	ra = 'A';
case 2 % Relative to BM.
	layi = layersh{ilay}';
	maxz = max(max(layersh{1}));
	ra = 'R';
case 3 % Relative to AveL9-11.
	layi = layersh2{ilay}';
	maxz = max(max(layersh2{1}));
	ra = 'M';
case 4 % Relative to GCL.
	layi = layersh3{ilay}';
	maxz = max(max(layersh3{1}));
	ra = 'G';
otherwise % Relative to NFL.
	layi = layersh4';
	maxz = max(max(layersh4));
	ra = 'N';
end

if (Ainc == 0)
	[ y, x ] = meshgrid(linspace(0, 100, Bnum), linspace(0, 100, Anum));
	x0 = linspace(0, 100, Anum);
else
	[ y, x ] = meshgrid(linspace(0, (Bnum-1)*Binc, Bnum), linspace(0, (Anum-1)*Ainc, Anum));
	x0 = linspace(0, (Anum-1)*Ainc, Anum);
end

cla;
clf;
hold on

% Plotting the surface:
s1 = surf(x, y, layi, 'FaceAlpha', 0.5, 'EdgeColor', 'none');

% Plotting the raw data lines:
% s2 = scatter3(x(1:end), y(1:end), layi(1:end), 'k', '.');
y0 = Binc*ones(Anum, 1);
for l = 1:Bnum
	plot3(x0, (l-1)*y0, layi(:, l), 'k-', 'LineWidth', lnw/2);
end

hold off

if (Ainc == 0)
	ylabel('B scans  (', num2str(Bnum), ' pts)');
	xlabel('A scans  (', num2str(Anum), ' pts)');
else
	ylabel([ 'B scans  (', num2str(Bnum), ' pts at ', num2str(Binc), ' \mum)' ]);
	xlabel([ 'A scans  (', num2str(Anum), ' pts at ', num2str(Ainc), ' \mum)' ]);
end

switch optra
case 1
	zlabel('Height  (nm)');
	title([ num2str(ilay), '. ', lnl{ilay}, '  <', fnm, '>  |  absolute view' ], 'Interpreter', 'none');
case 2
	zlabel('Height from BM  (nm)');
	title([ num2str(ilay), '. ', lnl{ilay}, '  <', fnm, '>  |  relative view to BM' ], 'Interpreter', 'none');
case 3
	zlabel('Height from AveL9-11  (nm)');
	title([ num2str(ilay), '. ', lnl{ilay}, '  <', fnm, '>  |  relative view to AveL9-11' ], 'Interpreter', 'none');
case 4
	zlabel('Height from GCL  (nm)');
	title([ num2str(ilay), '. ', lnl{ilay}, '  <', fnm, '>  |  relative view to GCL' ], 'Interpreter', 'none');
otherwise
	zlabel('Height from NFL  (nm)');
	title([ num2str(ilay), '. ', lnl{ilay}, '  <', fnm, '>  |  relative view to NFL' ], 'Interpreter', 'none');
end

% axis equal
axis tight
zlim([ 0, maxz ]);

set(gcf, 'units', 'normalized', 'outerposition', [0 0 1 1]);
% set(gca, 'Color', 'None'); % Make plot background transparent.

view(10, 20)

h = gcf;