function res = Function_DoG2D(v, x)
% Purpose: 		2D Difference of Gaussians (DoG) function.
%
% Input:
% v 			A vector of DoG function parameters, as in:
% 				y[v1, v2, v3, v4, v5, v6](x) = v1 + v4*exp(-v2*(x - v6).^2) - v5*exp(-v3*(x - v6).^2)
% x 			The x-values to be evaluated over.
%
% Output:
% res 			The evaluated function values.

lv = [ v(1); 10.^v(2:5); v(6) ];

bell1 = lv(4)*exp(-lv(2)*(x - lv(6)).^2);
bell2 = lv(5)*exp(-lv(3)*(x - lv(6)).^2);

res = lv(1) + bell1 - bell2;