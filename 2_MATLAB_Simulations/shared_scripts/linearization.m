%% lagrange
clear; clc; close all;

syms x(t) l(t) theta(t)
syms M m g F bp bc

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

Qx = F -bc * diff(x);
Qt = -bp * diff(theta);

eq1 = diff(diff(L, diff(x, t)), t) - diff(L, x) == Qx;
simplify(expand(eq1));
eq2 = diff(diff(L, diff(theta, t)), t) - diff(L, theta) == Qt;
simplify(expand(eq2));

syms x_ddot theta_ddot

eq1_sub = subs(eq1, [diff(x, 2), diff(theta, 2)], [x_ddot, theta_ddot]);
eq2_sub = subs(eq2, [diff(x, 2), diff(theta, 2)], [x_ddot, theta_ddot]);

[A, B] = equationsToMatrix([eq1_sub, eq2_sub], [x_ddot, theta_ddot]);
simplify(A) 
% [               M + m, m*cos(theta(t))*l(t)]
% [m*cos(theta(t))*l(t),             m*l(t)^2]
simplify(B)
% F - bc*diff(x(t), t) - m*sin(theta(t))*diff(l(t), t, t) + m*sin(theta(t))*l(t)*diff(theta(t), t)^2 - 2*m*cos(theta(t))*diff(l(t), t)*diff(theta(t), t)
%                                                             - bp*diff(theta(t), t) - 2*m*l(t)*diff(l(t), t)*diff(theta(t), t) - g*m*sin(theta(t))*l(t)

X_dot = A \ B;
f = [diff(x); X_dot(1); diff(theta); X_dot(2)];
simplify(X_dot)
%                                                                                                                                                                                                                                             (F*l(t) - bc*l(t)*diff(x(t), t) + bp*cos(theta(t))*diff(theta(t), t) - m*sin(theta(t))*l(t)*diff(l(t), t, t) + m*sin(theta(t))*l(t)^2*diff(theta(t), t)^2 + g*m*cos(theta(t))*sin(theta(t))*l(t))/(l(t)*(- m*cos(theta(t))^2 + M + m))
% -(2*M*bp*diff(theta(t), t) + 2*bp*m*diff(theta(t), t) + 2*F*m*cos(theta(t))*l(t) + m^2*sin(2*theta(t))*l(t)^2*diff(theta(t), t)^2 + 2*m^2*l(t)*diff(l(t), t)*diff(theta(t), t) + 2*g*m^2*sin(theta(t))*l(t) - m^2*sin(2*theta(t))*l(t)*diff(l(t), t, t) - 2*bc*m*cos(theta(t))*l(t)*diff(x(t), t) - 2*m^2*cos(2*theta(t))*l(t)*diff(l(t), t)*diff(theta(t), t) + 4*M*m*l(t)*diff(l(t), t)*diff(theta(t), t) + 2*M*g*m*sin(theta(t))*l(t))/(m*l(t)^2*(2*M + m - m*cos(2*theta(t))))
simplify(f)
%                                                                                                                                                                                                                                                                                                                                                                                                                                                                      diff(x(t), t)
%                                                                                                                                                                                                                                             (F*l(t) - bc*l(t)*diff(x(t), t) + bp*cos(theta(t))*diff(theta(t), t) - m*sin(theta(t))*l(t)*diff(l(t), t, t) + m*sin(theta(t))*l(t)^2*diff(theta(t), t)^2 + g*m*cos(theta(t))*sin(theta(t))*l(t))/(l(t)*(- m*cos(theta(t))^2 + M + m))
%                                                                                                                                                                                                                                                                                                                                                                                                                                                                  diff(theta(t), t)
% -(2*M*bp*diff(theta(t), t) + 2*bp*m*diff(theta(t), t) + 2*F*m*cos(theta(t))*l(t) + m^2*sin(2*theta(t))*l(t)^2*diff(theta(t), t)^2 + 2*m^2*l(t)*diff(l(t), t)*diff(theta(t), t) + 2*g*m^2*sin(theta(t))*l(t) - m^2*sin(2*theta(t))*l(t)*diff(l(t), t, t) - 2*bc*m*cos(theta(t))*l(t)*diff(x(t), t) - 2*m^2*cos(2*theta(t))*l(t)*diff(l(t), t)*diff(theta(t), t) + 4*M*m*l(t)*diff(l(t), t)*diff(theta(t), t) + 2*M*g*m*sin(theta(t))*l(t))/(m*l(t)^2*(2*M + m - m*cos(2*theta(t))))
 
syms x1 x2 x3 x4 u1 u2 u3 u4 l0
Xr = [diff(x); x; diff(theta); theta];
Ur = [F; diff(l, 2); diff(l); l];
X = [x1; x2; x3; x4];
U = [u1; u2; u3; u4];
X0 = [0; 0; 0; 0];
U0 = [0; 0; 0; l0];

f = subs(f, [Xr; Ur], [X; U]);
simplify(f)
%                                                                                                                                                                                                                                                          x1
%                                                                                                                            (u1*u4 + bp*x3*cos(x4) - bc*u4*x1 + m*u4^2*x3^2*sin(x4) - m*u2*u4*sin(x4) + g*m*u4*cos(x4)*sin(x4))/(u4*(- m*cos(x4)^2 + M + m))
%                                                                                                                                                                                                                                                          x3
% -(2*M*bp*x3 + 2*bp*m*x3 + m^2*u4^2*x3^2*sin(2*x4) - m^2*u2*u4*sin(2*x4) + 2*m^2*u3*u4*x3 + 2*m*u1*u4*cos(x4) + 2*g*m^2*u4*sin(x4) + 4*M*m*u3*u4*x3 - 2*m^2*u3*u4*x3*cos(2*x4) + 2*M*g*m*u4*sin(x4) - 2*bc*m*u4*x1*cos(x4))/(m*u4^2*(2*M + m - m*cos(2*x4)))
 

A = jacobian(f, X);
B = jacobian(f, U);
simplify(A)
% [                                        1, 0,                                                                                                                           0,                                                                                                                                                                                                                                                                                                                                                                                                                                                       0]
% [                    -bc/(m*sin(x4)^2 + M), 0,                                                             (2*m*x3*sin(x4)*u4^2 + bp*cos(x4))/(u4*(- m*cos(x4)^2 + M + m)),                                                                                          -(4*g*m^2*u4 + 8*m*u1*u4*sin(2*x4) - 2*m^2*u4^2*x3^2*cos(3*x4) - 4*g*m^2*u4*cos(2*x4) + 2*m^2*u2*u4*cos(3*x4) + 8*M*bp*x3*sin(x4) + 10*bp*m*x3*sin(x4) + 2*m^2*u4^2*x3^2*cos(x4) - 2*m^2*u2*u4*cos(x4) + 2*bp*m*x3*sin(3*x4) - 8*M*g*m*u4*cos(2*x4) - 8*bc*m*u4*x1*sin(2*x4) - 8*M*m*u4^2*x3^2*cos(x4) + 8*M*m*u2*u4*cos(x4))/(2*u4*(2*M + m - m*cos(2*x4))^2)]
% [                                        0, 0,                                                                                                                           1,                                                                                                                                                                                                                                                                                                                                                                                                                                                       0]
% [(bc*cos(x4))/(u4*(- m*cos(x4)^2 + M + m)), 0, -(2*(M*bp + bp*m + m^2*u3*u4 + 2*M*m*u3*u4 - m^2*u3*u4*cos(2*x4) + m^2*u4^2*x3*sin(2*x4)))/(m*u4^2*(2*M + m - m*cos(2*x4))), (2*cos(x4)*sin(x4)*(M*bp*x3 + bp*m*x3 + (m^2*u4^2*x3^2*sin(2*x4))/2 - (m^2*u2*u4*sin(2*x4))/2 + m^2*u3*u4*x3 + m*u1*u4*cos(x4) + g*m^2*u4*sin(x4) + 2*M*m*u3*u4*x3 - m^2*u3*u4*x3*cos(2*x4) + M*g*m*u4*sin(x4) - bc*m*u4*x1*cos(x4)))/(u4^2*(m*sin(x4)^2 + M)^2) - (2*(m*u4*(2*cos(x4)^2 - 1)*x3^2 + 4*m*u3*cos(x4)*sin(x4)*x3 - u1*sin(x4) + g*m*cos(x4) + bc*x1*sin(x4) - m*u2*(2*cos(x4)^2 - 1) + M*g*cos(x4)))/(u4*(2*M + m - m*(2*cos(x4)^2 - 1)))]
simplify(B)
% [                                    0,                                          0,          0,                                                                                                                                                                                                                            0]
% [                  1/(m*sin(x4)^2 + M),             -(m*sin(x4))/(m*sin(x4)^2 + M),          0,                                                                                                                                                      -(x3*(- m*x3*sin(x4)*u4^2 + bp*cos(x4)))/(u4^2*(- m*cos(x4)^2 + M + m))]
% [                                    0,                                          0,          0,                                                                                                                                                                                                                            0]
% [-cos(x4)/(u4*(- m*cos(x4)^2 + M + m)), (m*sin(2*x4))/(u4*(2*M + m - m*cos(2*x4))), -(2*x3)/u4, (2*M*bp*x3 + 2*bp*m*x3 - (m^2*u2*u4*sin(2*x4))/2 + 2*m^2*u3*u4*x3 + m*u1*u4*cos(x4) + g*m^2*u4*sin(x4) + 2*M*m*u3*u4*x3 - 2*m^2*u3*u4*x3*cos(x4)^2 + M*g*m*u4*sin(x4) - bc*m*u4*x1*cos(x4))/(m*u4^3*(- m*cos(x4)^2 + M + m))]

A_lin = subs(A, [X; U], [X0; U0]);
B_lin = subs(B, [X; U], [X0; U0]);
simplify(A_lin)
% [        1, 0,                        0,                   0]
% [    -bc/M, 0,                bp/(M*l0),             (g*m)/M]
% [        0, 0,                        1,                   0]
% [bc/(M*l0), 0, -(bp*(M + m))/(M*l0^2*m), -(g*(M + m))/(M*l0)]
simplify(B_lin)
% [        0, 0, 0, 0]
% [      1/M, 0, 0, 0]
% [        0, 0, 0, 0]
% [-1/(M*l0), 0, 0, 0]

simplify(A_lin * Xr + B_lin * Ur)
%                                                                                                  diff(x(t), t)
%                                  F/M - (bc*diff(x(t), t))/M + (g*m*theta(t))/M + (bp*diff(theta(t), t))/(M*l0)
%                                                                                              diff(theta(t), t)
% (bc*diff(x(t), t))/(M*l0) - F/(M*l0) - (g*theta(t)*(M + m))/(M*l0) - (bp*(M + m)*diff(theta(t), t))/(M*l0^2*m)
