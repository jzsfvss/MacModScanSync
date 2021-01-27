function [ lm, lmi, lcl ] = MyFindPeaks(v)
% Purpose: 		The findpeaks function generalized to account for global extrema.
%
% Input:
% v 			A vector of y-values.
%
% Output:
% lm 			The vector of maximum values.
% lmi 			The vector of maximum indices.
% lcl 			The logical vector of whether a maximum is local (1) or global (0).

flp = 0;
if (size(v, 2) > size(v, 1))
	flp = 1;
	v = v';
end

if (isempty(v)) % 1

lm = [];
lmi = [];
lcl = 0;

else % 1

if (length(v) > 2) % 2

[ lm, lmi ] = findpeaks(v);
lcl = 1;

if (v(1) >= v(2)) % 4: Check left endpoint.
	lm = [ v(1); lm ];
	lmi = [ 1; lmi ];
end % 4

if (v(end) >= v(end-1)) % 5: Check the right endpoint.
	lm = [ lm; v(end) ];
	lmi = [ lmi; length(v) ];
end % 5

else % 2

lm = [];
lcl = 0;

end % 2

if (isempty(lm)) % 3: No local peaks, so find the global one.
	[ lm, lmi ] = max(v);
	lcl = 0;
end % 3

end % 1

if flp
	v = v';
end