function lyrsym = SurfSym(layersh, Anum, Bnum)
% Purpose: 		Symmetrizes the NFL layer in the x-direction (A scans).
%
% Input:
% layersh 		The distance of the imported layers from the basement membrane.
% Anum 			The number of A-scan values in the grid.
% Bnum 			The number of B-scan values in the grid.
%
% Output:
% lyrsym 		The NFL layer symmetrized.

layi = layersh{2}';
lyrsym = 0*layi;
cind = round(Anum/2);

for Bind = 1:Bnum % 1

% Determining the center:
y = layi(:, Bind);
[ aind, lind, rind, avals ] = ModelAxis2D_2(y);

% Correcting degenerate cases:
if ((abs(aind - cind) > 0.2*Anum) || (rind < cind) || (lind > cind)) % 2
	aind = cind;
end % 2

% Finding the fullest index interval:
ccsp = min(aind - 1, Anum - aind);
lind = aind - ccsp;
rind = aind + ccsp;

% Symmetrizing:
ym2 = (y(lind:(aind-1)) + y(rind:(-1):(aind+1)))/2;
ym3 = ym2(end:(-1):1);

if (lind > 1) % 3
	ym1 = zeros(lind-1, 1) + ym2(1);
else % 3
	ym1 = [];
end % 3

if (rind < Anum) % 4
	ym4 = zeros(Anum - (rind+1) + 1, 1) + ym3(end);
else % 4
	ym4 = [];
end % 4

ym = [ ym1; ym2; y(aind); ym3; ym4 ];

% Shifting all B layers to the center:
if (aind > cind) % 5
	yma = ym(end)*ones(aind-cind, 1);
	yms = [ ym((1 + (aind-cind)):end); yma ];
elseif (aind < cind) % 5
	yma = ym(1)*ones(cind-aind, 1);
	yms = [ yma; ym(1:(Anum - (cind-aind))) ];
else % 5
	yms = ym;
end % 5

lyrsym(:, Bind) = yms;

end % 1

lyrsym = lyrsym';