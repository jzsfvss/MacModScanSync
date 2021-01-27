function [ cx, cy, r ] = FitCircle(xy)
% Purpose: 		Fits a circle to a set of points in the 2D plane.
%
% Input:
% xy 			A 2-column matrix of (x,y) coordinates.
%
% Output:
% cx 			The x-coordinate of the fitted circle center.
% cy 			The y-coordinate of the fitted circle center.
% r 			The radius of the fitted circle.

% Initialization:
x = xy(:, 1);
y = xy(:, 2);
o = ones(size(x, 1), 1);

% Least squares regression based on the equation of a circle:
a = [ x, y, o ]\[ -(x.^2 + y.^2) ];

% Deducing the circle parameters:
cx = -a(1)/2;
cy = -a(2)/2;
r = sqrt(cx^2 + cy^2 - a(3));