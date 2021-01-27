function [ vopt, zm ] = Model_DoG2D(xm, ym, miny, c, dispsol)
% Purpose: 		2D modelling (optimization) of a cross-section with Difference of Gaussians (DoG).
%
% Input:
% xm 			The grid x-values in the modelling interval.
% ym 			The grid y-values in the modelling interval.
% miny 			The minimum of layer values along the selected B-scan cross-section.
% c 			The center estimate for the model (variable).
% dispsol 		Boolean whether to output the fitted model parameters to the command line.
%
% Output:
% vopt 			The near-optimal model parameters.
% zm 			The z-values of the fitted model over the modelling grid.

% Difference of Bell curves / Gaussians function:
% y[h, a1, a2, b1, b2, c](x) = h + b1*exp(-a1*(x-c).^2) - b2*exp(-a2*(x-c).^2)
F = @(v) norm(ym - Function_DoG2D(v, xm));

v0 = zeros(6, 1); % Starting point for the optimization (based on images).
v0(1) = -5.50E+05;
v0(2) = log10(3.00E-08);
v0(3) = log10(5.61E-06);
v0(4) = log10(9.45E+05);
v0(5) = log10(1.75E+05);
v0(6) = c;

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
lb(6) = v0(6) - 1500;
ub(6) = v0(6) + 1500;
nonlcon = [];

% Optimization:
hsnm = 'bfgs';
% yeps = 100;
yeps = 0;
miter = 10^5;
nz = 1E-500; % Very tiny near-zero value, to prevent premature termination.
mi = Inf;
% demopt = 'final-detailed';
demopt = 'off';
options = optimoptions('fmincon', 'Algorithm', 'interior-point', 'HessianApproximation', hsnm, 'ObjectiveLimit', yeps, 'MaxFunctionEvaluations', miter, 'MaxIterations', mi, 'StepTolerance', nz, 'FunctionTolerance', nz, 'ConstraintTolerance', nz, 'OptimalityTolerance', nz, 'Display', demopt);

disp(' ');
disp([ 'Optimizing model parameters...' ]);
tic;

[ vopt, Fopt ] = fmincon(F, v0, A, b, Aeq, beq, lb, ub, nonlcon, options);

rt = toc;
fprintf([ '\bdone in ', num2str(rt, '%.2f'), ' secs.\n' ]);

zm = Function_DoG2D(vopt, xm);
% vopt(1)*(1 + vopt(4)*exp(-vopt(2)*(xm - c).^2)).*(1 - vopt(5)*exp(-vopt(3)*(xm - c).^2));

% Output the results:
if dispsol

disp(' ');
disp('Difference of Gaussians Model');
disp('y(x) = h + b1*exp(-a1*(x-c).^2) - b2*exp(-a2*(x-c).^2)');
lvopt = 10.^vopt(1:5);
lv0 = 10.^v0(1:5);
disp('[ c, h, a1, a2, b1, b2 ] = ');
disp([ 'Opt: [ ', num2str(vopt(6), '%.2f'), ', ', num2str(vopt(1), '%.2E'), ', ', num2str(lvopt(2), '%.2E'), ', ', num2str(lvopt(3), '%.2E'), ', ', num2str(lvopt(4), '%.2E'), ', ', num2str(lvopt(5), '%.2E'), ' ]' ]);
disp([ 'Ini: [ ', num2str(v0(6), '%.2f'), ', ', num2str(v0(1), '%.2E'), ', ', num2str(lv0(2), '%.2E'), ', ', num2str(lv0(3), '%.2E'), ', ', num2str(lv0(4), '%.2E'), ', ', num2str(lv0(5), '%.2E'), ' ]' ]);
R2 = MyR2(ym, zm);
disp([ 'R^2 = ', num2str(R2, '%.2f'), '%' ]);

end