function layersm = DataMissingValues(layers, Anum, Bnum, Ainc, Binc)
% Purpose: 		Fills in missing values in the raw data via interpolation.
%
% Input:
% layers 		A cell vector of matrices containing each layer of the imported scan.
% Anum 			The number of A-scan values in the grid.
% Bnum 			The number of B-scan values in the grid.
% Ainc 			The increment between the A-scan grid points.
% Binc 			The increment between the B-scan grid points.
%
% Output:
% layersm 		The layers of the imported scan corrected for missing values.

% Initialization:
layersm = {};

minx = 0;
maxx = (Anum-1)*Ainc;
miny = 0;
maxy = (Bnum-1)*Binc;
x = linspace(minx, maxx, Anum)';
y = linspace(miny, maxy, Bnum)';
[ ym, xm ] = meshgrid(y, x);
xmv = xm(1:end);
ymv = ym(1:end);
lg = length(xmv);

% Interpolating problematic values (0 and n/a) with griddata:
for i = 1:11 % 1

layi = layers{i}';
layi2 = layi;
layiv = layi(1:end);

binds = find((layiv == 0) | isnan(layiv));
ginds = setdiff(1:lg, binds);
if (length(binds) > 0) % 2
	layiv(binds) = griddata(xmv(ginds), ymv(ginds), layiv(ginds), xmv(binds), ymv(binds), 'cubic');
	layi2(1:end) = layiv;
end % 2

layersm{end+1} = layi2';

end % 1

% Checking again if all missing values were handled:
layersm2 = {};
rlims = [ 1, Bnum ];
clims = [ 1, Anum ];

for i = 1:11 % 1

layeri = layersm{i};
layeri2 = layeri;
[ r, c ] = find((layeri == 0) | isnan(layeri));
n = length(r); % Number of missing values.

for j = 1:n % 2

rj1 = r(j);
rj2 = r(j);
cj1 = max(c(j)-1, 1);
cj2 = min(c(j)+1, Anum);

sm = 0;
cnt = 0; 
for rj = rj1:rj2 % 3
for cj = cj1:cj2 % 4
	if (~(rj == r(j) && cj == c(j)) && (layeri(rj, cj) ~= 0)) % 5
		sm = sm + layeri(rj, cj);
		cnt = cnt + 1;
	end % 5
end % 4
end % 3

if (cnt ~= 0) % 6
	layeri2(r(j), c(j)) = round(sm/cnt);
else % 6
	[ mval, mind ] = min(abs(find(layeri(r(j), :)) - c(j)));
	if ~isempty(mind) % 7
		layeri2(r(j), c(j)) = layeri(r(j), mind);
	end % 7
end % 6

end % 2

layersm2{end+1} = layeri2;

end % 1

layersm = layersm2;