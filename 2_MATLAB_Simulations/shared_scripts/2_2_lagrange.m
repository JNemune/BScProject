%% Lagrange Method Verification
clear; clc; close all;

% Define symbolic variables
syms t
syms x(t) l(t) theta(t)
syms M m g F bc bp

% 1. Kinematics
xp = x + l * sin(theta);
yp = -l * cos(theta);

% Time derivatives of coordinates
xp_dot = diff(xp, t);
yp_dot = diff(yp, t);

% Square of velocity (vp^2)
vp2 = xp_dot ^ 2 + yp_dot ^ 2;
vp2 = simplify(expand(vp2));

disp('--- Square of Pendulum Velocity (vp^2) ---');
disp(vp2);

% 2. Kinetic and Potential Energy
T = (1/2) * M * diff(x, t) ^ 2 + (1/2) * m * vp2;
T = simplify(expand(T));

disp('--- Total Kinetic Energy (T) ---');
disp(T);

V = -m * g * l * cos(theta);

% 3. Lagrangian
L = T - V;
L = simplify(expand(L));

% 4. Generalized non-conservative forces
Qx = F - bc * diff(x, t);
Qtheta = -bp * diff(theta, t);

% 5. Euler-Lagrange Equations
% Equation of motion for cart (x)
eq_x = diff(diff(L, diff(x, t)), t) - diff(L, x) == Qx;
eq_x = simplify(expand(eq_x));

disp('--- Equation of Motion for Cart (x) ---');
disp(eq_x);

% Equation of motion for pendulum (theta)
eq_theta = diff(diff(L, diff(theta, t)), t) - diff(L, theta) == Qtheta;
eq_theta = simplify(expand(eq_theta));

disp('--- Equation of Motion for Pendulum (theta) ---');
disp(eq_theta);

% --- Square of Pendulum Velocity (vp^2) ---
% diff(l(t), t)^2 + diff(x(t), t)^2 + l(t)^2*diff(theta(t), t)^2 + 2*sin(theta(t))*diff(l(t), t)*diff(x(t), t) + 2*cos(theta(t))*l(t)*diff(theta(t), t)*diff(x(t), t)
% symbolic function inputs: t

% --- Total Kinetic Energy (T) ---
% (M*diff(x(t), t)^2)/2 + (m*diff(l(t), t)^2)/2 + (m*diff(x(t), t)^2)/2 + (m*l(t)^2*diff(theta(t), t)^2)/2 + m*sin(theta(t))*diff(l(t), t)*diff(x(t), t) + m*cos(theta(t))*l(t)*diff(theta(t), t)*diff(x(t), t)
% symbolic function inputs: t

% --- Equation of Motion for Cart (x) ---
% m*sin(theta(t))*l(t)*diff(theta(t), t)^2 + F == m*diff(x(t), t, t) + bc*diff(x(t), t) + M*diff(x(t), t, t) + m*sin(theta(t))*diff(l(t), t, t) + m*cos(theta(t))*l(t)*diff(theta(t), t, t) + 2*m*cos(theta(t))*diff(l(t), t)*diff(theta(t), t)
% symbolic function inputs: t

% --- Equation of Motion for Pendulum (theta) ---
% m*l(t)^2*diff(theta(t), t, t) + 2*m*l(t)*diff(l(t), t)*diff(theta(t), t) + m*cos(theta(t))*l(t)*diff(x(t), t, t) + g*m*sin(theta(t))*l(t) == -bp*diff(theta(t), t)
% symbolic function inputs: t
