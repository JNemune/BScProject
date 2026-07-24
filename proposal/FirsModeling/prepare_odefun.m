clear; clc; close all;

syms M m L g F x theta x_ theta_ x__ theta__

eqns = [
        L * theta__ + g * sin(theta) == cos(theta) * x__;
        L * m * cos(theta) * theta__ + F == m * x__ + M * x__ + L * m * sin(theta) * theta_ ^ 2
        ];

slv = solve(eqns, [x__, theta__]);
simplify(expand(slv.x__))
simplify(expand(slv.theta__))
