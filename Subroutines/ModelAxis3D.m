function [ c, inds, fovmins, fovmaxsl, fovmaxsr ] = ModelAxis3D(lyr, Anum, Ainc, Bnum, Binc)
% Purpose: 		Estimates the axis of a layer.
%
% Input:
% lyr 			The NFL layer.
% Anum 			The number of A-scan values in the grid.
% Ainc 			The increment between the A-scan grid points.
% Bnum 			The number of B-scan values in the grid.
% Binc 			The increment between the B-scan grid points.
%
% Output:
% c 			The estimated center locus of NFL, to be used across all layers.
% inds 			The indices of the maxima per B-scan.
% fovmins 		The (x,y,z) triples of each B-scan minimum.
% fovmaxsl 		The (x,y,z) triples of each B-scan maximum to the left.
% fovmaxsr 		The (x,y,z) triples of each B-scan maximum to the right.

% Grid:
x = linspace(0, (Anum-1)*Ainc, Anum)';
y = linspace(0, (Bnum-1)*Binc, Bnum)';

% Find the fovea interval lengths for each B scan:
fovmins = zeros(Bnum, 3);
fovmaxsl = zeros(Bnum, 3);
fovmaxsr = zeros(Bnum, 3);
fovheis = zeros(Bnum, 1);
% fovwids = zeros(Bnum, 1);
inds = zeros(Bnum, 2);

for Bind = 1:Bnum % 1

zcur = lyr(:, Bind);
[ aind, lind, rind, avals ] = ModelAxis2D(zcur);
%disp([ 'lind = ', num2str(lind), ', rind = ', num2str(rind) ]);

inds(Bind, :) = [ lind, rind ];

fovmins(Bind, :) = [ x(aind), y(Bind), zcur(aind) ];
fovmaxsl(Bind, :) = [ x(lind), y(Bind), zcur(lind) ];
fovmaxsr(Bind, :) = [ x(rind), y(Bind), zcur(rind) ];
fovheis(Bind) = abs(zcur(aind) - (zcur(lind) + zcur(rind))/2);
% fovwids(Bind) = x(rind) - x(lind);

end % 1

% Finding the B scan index with the tallest foveal cross-section:
[ lm, lmi, lcl ] = MyFindPeaks(fovheis);
[ mval, ind ] = min(abs(lmi - Bnum/2));
mainBind = lmi(min(ind));

% Finding the leftmost B scan index intersecting the fovea:
k = 0;
% while (fovheis(mainBind - (k + 1)) <= fovheis(mainBind - k)) && (inds(mainBind - (k + 1), 1) ~= inds(mainBind - (k + 1), 2))
while (inds(mainBind - (k + 1), 1) ~= inds(mainBind - (k + 1), 2))
	k = k + 1;
end
lindB = mainBind - k;

% Finding the rightmost B scan index intersecting the fovea:
k = 0;
% while (fovheis(mainBind + (k + 1)) <= fovheis(mainBind + k)) && (inds(mainBind + (k + 1), 1) ~= inds(mainBind + (k + 1), 2))
while (inds(mainBind + (k + 1), 1) ~= inds(mainBind + (k + 1), 2))
	k = k + 1;
end
rindB = mainBind + k;

indsB = lindB:rindB;

% Finding the leftmost and rightmost A scan index intersecting the fovea:
lindA = min(inds(indsB, 1));
rindA = max(inds(indsB, 2));
indsA = lindA:rindA;

% Selecting only relevant output:
fovmins = fovmins(indsB, :);
fovmaxsl = fovmaxsl(indsB, :);
fovmaxsr = fovmaxsr(indsB, :);

% Find the center of mass, weighted according to the fovea cross-section area:
n = length(indsB);
c = [ 0, 0 ];
ws = 0;

for i = 1:n

Bi = indsB(i);
zcur = lyr(:, Bi);

% Area of the fovea cross-section:
% wi = fovheis(Bi)*abs(inds(Bi, 2) - inds(Bi, 1))*Ainc;
ymaxi = (fovmaxsl(i, 3) + fovmaxsr(i, 3))/2;
j1 = inds(Bi, 1);
j2 = inds(Bi, 2);
Ai = (ymaxi*(j2-j1+1) - sum(zcur(j1:j2)))*Ainc;

c = c + Ai*fovmins(i, 1:2);
ws = ws + Ai;

end

c = c/ws;

% Finding the z-value at the center:
[ mval, ind ] = min(abs(x - c(1)));
cxind = ind(1);
cz = interp1(y, lyr(cxind, :)', c(2), 'spline', 'extrap');

c = [ c, cz ];