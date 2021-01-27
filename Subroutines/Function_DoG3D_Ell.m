function z = Function_DoG3D_Ell(v, xy, dispout)
% Purpose: 		Elliptical 3D DoG function.
%
% Input:
% v 			A vector of elliptical DoG function parameters (see below).
% xy 			A grid of points in the complex plane.
% dispout 		Boolean whether to output an optimization progress timer.
%
% Output:
% z 			The evaluated function values over the grid.

global citer
global miter
global titer

% Difference of Bell curves / Gaussians function:
% h + b1*exp(-a1*(x-c).^2) - b2*exp(-a2*(x-c).^2)
%
% Model parameters along the primary axis (axis a):
% v(1) = h
% v(2) = log10(a1)
% v(3) = log10(a2)
% v(4) = log10(b1)
% v(5) = log10(b2)
%
% Ellipse parameters:
% v(6) = ecx
% v(7) = ecy
% v(8) = log10(abrat), where abrat = eb/ea
% v(9) = eang

% Iteration progress:
citer = citer + 1;

if ((citer > 2) && (citer < 0.95*miter) && dispout) % 1

titer0 = floor(100*(1 - (citer/miter))*titer)/100;

bs = repmat('\b', 1, 7);
fprintf([ bs, MyMins(titer0), '.\n' ]);

end % 1

% Model parameters:
h = v(1);
a1 = 10^v(2);
a2 = 10^v(3);
b1 = 10^v(4);
b2 = 10^v(5);
ecx = v(6);
ecy = v(7);
abrat = 10^v(8);
eang = v(9);
clear i
c = ecx + i*ecy;

% Primitive ellipse radius function at angle t:
erad = @(t) abs(exp(eang*i)*(cos(t) + abrat*sin(t)*i));

% Difference of Gaussians function:
DoG = @(r) h + b1*exp(-a1*(r.^2)) - b2*exp(-a2*(r.^2));

r = abs(xy - c);
t = angle(xy);
eradxy = erad(t);
r2 = r./eradxy; % Correcting for the pr. ellipse radius.
z = DoG(r2);