function [ aind, lind, rind, avals ] = ModelAxis2D(y)
% Purpose: 		Estimates the axis of a cross-section giving the best symmetry.
%
% Input:
% y 			A vector of y-values.
%
% Output:
% aind 			Index of the estimated axis location among the input vector indices.
% lind 			Index of the local max. to the left of aind.
% rind 			Index of the local min. to the right of aind.
% avals 		The total error (L1) for different axis locations.

% Initialization:
n = length(y);

% Determining the two local max indices around the fovea:
cind = round(n/2);
ly = y(1:cind);
ry = y((cind+1):n);
[ lmax, lind ] = max(ly);
[ rmax, rind ] = max(ry);
rind = cind + rind;

if ((lind == cind) || (rind == cind+1))
	rind = cind;
	lind = cind;
end

% Finding the index that gives the best symmetry:
ind1 = lind;
ind2 = rind;
ainds = ind1:ind2;
avals = [];

% Finding the L1 norm difference between each "half" with axis a:
for a = ainds % 1

sp = min(a - ind1, ind2 - a); % Biggest radius in the index interval.
aval = 0;
for i = 0:(sp - 1) % 2
	if ((a - sp + i)*(a + sp - i) ~= 0) % 3
		aval = aval + abs(y(a - sp + i) - y(a + sp - i));
	end % 3
end % 2
aval = aval/sp;

avals = [ avals, aval ];

end % 1

% Finding the optimal axis location:
[ lm, lmi, lcl ] = MyFindPeaks(-avals);
[ mval, ind ] = min(abs(lmi - length(avals)/2));
aind = ainds(lmi(ind));

if (lind == rind)
	aind = lind;
end