clear; clc; close all;

L = 0.3;
g = 9.80665;
% syms L g
% assume(L, "real")
% assume(g, "real")
% assume(L > 0)
% assume(g > 0)

L = @(s) s ^ 2 / (L * s ^ 2 + g);
syms J
assume(J, "real")
% syms R
% assume(R, "real")
% assume(R < 0)
R = -5;
s0 = R + J * 1i;

theta_d = pi - angle(L(s0));

theta_z = (angle(s0) + theta_d) / 2;
theta_p = (angle(s0) - theta_d) / 2;

z = real(s0) - imag(s0) / tan(theta_z);
p = real(s0) - imag(s0) / tan(theta_p);
z = double(limit(z, J, 0));
p = double(limit(p, J, 0));
s0 = R;
% vpa(z)
% vpa(p)

C = @(s) (s - z) / (s - p);
K = real(-1 / (L(s0) * C(s0)));
% vpa(K)
Go = @(s) K * C(s) * L(s);
Gc = @(s) Go(s) / (1 + Go(s));
X = @(s) simplify(Gc(s) / L(s));
syms s_sym
s_tf = tf("s");

figure;
hold on;
% adams_x = table2array(readtable("adams_x"));
% plot(0:0.005:50, adams_x, "Color", "red");
adams_theta = table2array(readtable("adams_theta"));
plot(0:0.005:50, adams_theta, "Color", "red")
step(0.01 * X(s_tf) * L(s_tf) * 180 / pi)
% legend("adams", "step matlab")

syms t
xt = ilaplace(0.01 * X(s_sym) / s_sym);
xt__ = diff(xt, t, t);
vpa(xt)
