function R2 = MyR2(u, v)
% Purpose: 		Finds the coefficient of determination.
%
% Input:
% u 			The original (raw) data vector.
% v 			The model data vector.
%
% Output:
% R2 			The calculated coefficient of determination.

% Computing the auxiliary vectors:
uave = sum(u)/length(u);
SStot = norm(u - uave, 2)^2;
SSres = norm(u - v, 2)^2;

% Giving model fit as a percentage:
R2 = 100*(1 - (SSres/SStot));