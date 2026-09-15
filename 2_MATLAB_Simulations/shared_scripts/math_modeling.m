%% lagrange
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

%% linear state space
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

X = [x; x_; theta; theta_];
U = [F1; F2];

X_ = A * X + B * U;
Y = C * X + Dm * U;

%% non-linear state space
clear; clc; close all;

syms x x_ x__ theta theta_ theta__ l l_
syms F1 F2 l__
syms M m g bc bp
assume(M > 0);
assume(m > 0);
assume(g > 0);
assume(bc > 0);
assume(bp > 0);
assume(theta > -pi / 2);
assume(theta < pi / 2);
assume(l > 0);

x1 = x;
x2 = x_;
x3 = theta;
x4 = theta_;
x5 = l;
x6 = l_;

eqns = [
        (M + m) * x__ + m * l * theta__ * cos(theta) + m * l__ * sin(theta) + 2 * m * l_ * theta_ * cos(theta) - m * l * theta_ ^ 2 * sin(theta) + bc * x_ == F1 + F2;
        m * l ^ 2 * theta__ + m * l * x__ * cos(theta) + 2 * m * l * l_ * theta_ + m * g * l * sin(theta) + bp * theta_ == 0;
        ];
slv = solve(eqns, [x__, theta__]);
simplify(slv.x__);
simplify(slv.theta__);

X = [x; x_; theta; theta_; l; l_];
U = [F1; F2; l__];
RHS1 = m * x5 * x4 ^ 2 * sin(x3) - 2 * m * x6 * x4 * cos(x3) - bc * x2;
RHS2 = -2 * m * x5 * x6 * x4 - m * g * x5 * sin(x3) - bp * x4;
gamma = M + m * sin(x3) ^ 2;
F = [
     x2;
     (x5 * RHS1 - cos(x3) * RHS2) / x5 / (M + m * sin(x3) ^ 2);
     x4;
     (-m * x5 * cos(x3) * RHS1 + (M + m) * RHS2) / m / x5 ^ 2 / (M + m * sin(x3) ^ 2);
     x6;
     0;
     ];
G = [
     [0, 0, 0];
     [1 / gamma, 1 / gamma, -m * sin(x3) / gamma];
     [0, 0, 0];
     [-cos(x3) / x5 / gamma, -cos(x3) / x5 / gamma, m * sin(x3) * cos(x3) / x5 / gamma];
     [0, 0, 0];
     [0, 0, 1];
     ];

X_ = F + G * U;
simplify(X_);

simplify(X_(2) - slv.x__);
simplify(X_(4) - slv.theta__);
