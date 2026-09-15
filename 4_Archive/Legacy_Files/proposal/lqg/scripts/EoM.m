clear; clc; close all;

syms M m L g F b_c b_p x(t) theta(t)
assume(L > 0);
assume(m > 0);
assume(b_c >= 0);
assume(b_p >= 0);

x_     = diff(x, t);
theta_ = diff(theta, t);

% Velocity of the pendulum mass (cart + pendulum)
vp2 = (x_ - L * theta_ * cos(theta)) ^ 2 + (L * theta_ * sin(theta)) ^ 2;

% Kinetic and potential energy
T = 1/2 * M * x_ ^ 2 + 1/2 * m * vp2;
V = -m * g * L * cos(theta);

% Lagrangian
Lag = T - V;

% Generalized non-conservative forces:
%   Q_x     = F - b_c * x_dot
%   Q_theta = -b_p * theta_dot
Qx     = F - b_c * x_;
Qtheta = -b_p * theta_;

% Lagrange equations with non-conservative forces:
% d/dt(∂L/∂theta_dot) - ∂L/∂theta = Q_theta
% d/dt(∂L/∂x_dot)      - ∂L/∂x     = Q_x

eqns = [
    diff(diff(Lag, theta_), t) - diff(Lag, theta) == Qtheta;
    diff(diff(Lag, x_), t)      - diff(Lag, x)     == Qx;
    ];

% Get LaTeX of the equations
latex(simplify(expand(eqns)))
