clear; clc; close all;

syms M m L g F b_c b_p x1 x2 x3 x4 y1 y2
assume(L > 0);
assume(m > 0);
assume(b_c >= 0);
assume(b_p >= 0);

% x1 = x
% x2 = x_
% x3 = theta
% x4 = theta_
% y1 = x__
% y2 = theta__
eqns = [
    (M + m) * y1 - m * L * y2 + b_c * x2 == F;
    m * L^2 * y2 - m * L* y1 + b_p * x4 + m * g * L * x3 == 0;
    ];

slv = solve(eqns, [y1, y2]);

expand(slv.y1)
expand(slv.y2)
