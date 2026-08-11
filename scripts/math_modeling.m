clear; clc; close all;

syms x(t) l(t) theta(t)
syms M m g F1 F2 bp bc

xp = x + l * sin(theta);
yp = -l * cos(theta);

xp_ = diff(xp);
yp_ = diff(yp);

vp2 = xp_ ^ 2 + yp_ ^ 2;
simplify(expand(vp2));

T = 1/2 * M * diff(x) ^ 2 +1/2 * m * vp2;
simplify(expand(T));

V = -m * g * l * cos(theta);

L = T - V;
simplify(expand(L));

Qx = F1 + F2 -bc * diff(x);
Qt = -bp * diff(theta);

eq1 = diff(diff(L, diff(x, t)), t) - diff(L, x) == Qx;
simplify(expand(eq1));
eq2 = diff(diff(L, diff(theta, t)), t) - diff(L, theta) == Qt;
simplify(expand(eq2));

clear; clc; close all;

syms x__ x_ theta__ theta_ x theta M m g F1 F2 bp bc l0 D

eqns = [
        (M + m) * x__ + m * l0 * theta__ + bc * x_ == F1 + F2;
        m * l0 ^ 2 * theta__ + m * l0 * x__ + bp * theta_ + m * g * l0 * theta == 0;
        ];
slv = solve(eqns, [x__, theta__]);
slv.x__;
expand(slv.theta__);

A = [
     [0, 1, 0, 0];
     [0, -bc / M, m * g / M, bp / M / l0];
     [0, 0, 0, 1];
     [0, bc / M / l0, - (M + m) * g / M / l0, - (bp / M / l0 ^ 2 + bp / m / l0 ^ 2)];
     ];
B = [
     [0, 0];
     [1 / M, 1 / M];
     [0, 0];
     [-1 / M / l0, -1 / M / l0];
     ];
C = [
     [1, 0, 0, 0];
     [0, 0, 1, 0];
     [0, -bc, 0, 0];
     [- (M + m) * g / D, 0, 0, 0];
     [(M + m) * g / D, 0, 0, 0]
     ];
Dm = [
      [0, 0];
      [0, 0];
      [1, 1];
      [0, 0];
      [0, 0];
      ];

X = [x; x_; theta, theta_];
U = [F1, F2];
