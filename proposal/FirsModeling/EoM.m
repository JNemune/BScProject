clear; clc; close all;

syms M m L g F x(t) theta(t)
assume(L > 0);
assume(m > 0);
theta_ = diff(theta);
x_ = diff(x);
vp2 = (x_ - L * theta_ * cos(theta)) ^ 2 + (L * theta_ * sin(theta)) ^ 2;
T = 1/2 * M * x_ ^ 2 +1/2 * m * vp2;
V = -m * g * L * cos(theta);
L = T - V;

eqns = [
        diff(diff(L, theta_), t) - diff(L, theta) == 0;
        diff(diff(L, x_), t) - diff(L, x) == F;
        ];
latex(simplify(expand(eqns)))
