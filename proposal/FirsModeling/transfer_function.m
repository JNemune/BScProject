clear; clc; close all;

syms M m L g F x theta s

eqns = [
        L * theta * s ^ 2 + g * theta == x * s ^ 2;
        L * m * theta * s ^ 2 + F == m * x * s ^ 2 + M * x * s ^ 2
        ];

slv = solve(eqns, [x, theta]);
% simplify(expand(slv.x / F))
% latex(simplify(expand(slv.theta / F)))

g = 9.80665;
L = 0.3;
s = tf("s");
G = s ^ 2 / (L * s ^ 2 + g);
C = 12.693 * (s + 32.315) / (s + 229.43);
step(C * G)
