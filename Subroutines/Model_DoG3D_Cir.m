function [ vopt, zopt, R2 ] = Model_DoG3D_Cir(x, y, z, cpars, dispsol)
% Purpose: 		3D modelling of a layer with circular DoG.
%
% Input:
% x 			The grid x-values.
% y 			The grid y-values.
% z 			The layer values to be modelled (typically NFL).
% cpars 		Initial estimates for the circle parameters.
% dispsol 		Boolean whether to output the fitted model parameters to the command line.
%
% Output:
% vopt 			The near-optimal model parameters.
% zopt 			The z-values of the fitted model over the modelling grid.
% R2 			The coefficient of determination for the fitted model.

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

% Initialization:
clear i
nx = length(x);
ny = length(y);
xy = zeros(nx, ny);
for i1 = 1:nx % 1
for i2 = 1:ny % 2
	xy(i1, i2) = x(i1) + i*y(i2);
end % 2
end % 1

% Objective function:
F = @(v) MyNorm2(z - Function_DoG3D_Cir(v, xy, dispsol));

% Optimization starting point:
v0 = zeros(9, 1); % Starting point for the optimization (based on images).

v0(1) = -5.50E+05;
v0(2) = log10(3.00E-08);
v0(3) = log10(5.61E-06);
v0(4) = log10(9.45E+05);
v0(5) = log10(1.75E+05);

v0(6) = cpars(1);
v0(7) = cpars(2);

% Optimization bounds:
A = [];
b = [];
Aeq = [];
beq = [];
lb = 0*v0;
ub = lb;

lb(1) = -Inf;
ub(1) = Inf;

lb(2:5) = v0(2:5) - 5;
ub(2:5) = v0(2:5) + 5;

lb(6:7) = v0(6:7) - 1000;
ub(6:7) = v0(6:7) + 1000;

nonlcon = [];

% Estimate the total time (mins) for the optimization and set total iterations:
ntsts = 200;
citer = 0;
tic;
for k = 1:ntsts
	f = F(v0);
	citer = 0;
end
rt = toc/ntsts;
miter = round(titer*60/rt);

% Optimization options:
hsnm = 'bfgs';
yeps = 0;
nz = 1E-500; % Very tiny near-zero value, to prevent premature termination.
mi = Inf;
% demopt = 'final-detailed';
demopt = 'off';

options = optimoptions('fmincon', 'Algorithm', 'interior-point', 'HessianApproximation', hsnm, 'ObjectiveLimit', yeps, 'MaxFunctionEvaluations', miter, 'MaxIterations', mi, 'StepTolerance', nz, 'FunctionTolerance', nz, 'ConstraintTolerance', nz, 'OptimalityTolerance', nz, 'Display', demopt);

if dispsol
	disp(' ');
	fprintf([ 'Optimizing model parameters in ', num2str(miter, '%.2E'), ' iterations. Minutes left: ~00:00.\n' ]);
	tic;
end

% Optimization:
[ vopt, Fopt ] = fmincon(F, v0, A, b, Aeq, beq, lb, ub, nonlcon, options);
zopt = Function_DoG3D_Cir(vopt, xy, 0);
R2 = MyR2(z(1:end), zopt(1:end));

if dispsol

rt = toc;
fprintf([ '\b Done in ', num2str(rt/60, '%.2f'), ' mins.\n' ]);

disp(' ');
disp('Difference of Gaussians Model in 3D (circular)');
disp('y(x) = h + b1*exp(-a1*(x-c).^2) - b2*exp(-a2*(x-c).^2)');

lvopt = 10.^vopt;
lv0 = 10.^v0;
degsgn = char(0176);

disp('[ c_x, c_y, h, a1, a2, b1, b2 ] = ');
disp([ 'Ini: [ ', num2str(v0(6), '%.2f'), ', ', num2str(v0(7), '%.2f'), ', ', num2str(v0(1), '%.2E'), ', ', num2str(lv0(2), '%.2E'), ', ', num2str(lv0(3), '%.2E'), ', ', num2str(lv0(4), '%.2E'), ', ', num2str(lv0(5), '%.2E'), ' ]' ]);
disp([ 'Opt: [ ', num2str(vopt(6), '%.2f'), ', ', num2str(vopt(7), '%.2f'), ', ', num2str(vopt(1), '%.2E'), ', ', num2str(lvopt(2), '%.2E'), ', ', num2str(lvopt(3), '%.2E'), ', ', num2str(lvopt(4), '%.2E'), ', ', num2str(lvopt(5), '%.2E'), ' ]' ]);
disp([ 'R^2 = ', num2str(R2, '%.2f'), '%' ]);

end