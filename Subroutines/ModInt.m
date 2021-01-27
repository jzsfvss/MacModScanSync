function b = ModInt(a, x1, x2)
% Purpose: 		Computes the residue of a real number w.r.t. an interval: b = a mod [x1, x2).
%
% Input:
% a 			A real number.
% x1 			Left interval endpoint (included).
% x2			Right interval endpoint (not included).
%
% Output:
% b 			The residue.

m = abs(x2 - x1);
x0 = mod(x1, m);
b0 = mod(a, m);

b1 = b0;
while (b1 < x0)
	b1 = b1 + m;
end
b2 = b1 - x0;

b = x1 + b2;