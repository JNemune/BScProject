clear; clc; close all;

% --- 1. System Parameters ---
m = 0.2;
M = 1;
g = 9.81;
bc = 0.1;
bp = 0.05;
l0 = 0.5;
theta0 = 0;
x0 = -0.5; % or -5

% --- 2. State-Space Matrices ---
A = [0, 1, 0, 0;
     0, -bc / M, (m * g) / M, bp / (M * l0);
     0, 0, 0, 1;
     0, bc / (M * l0), -g * (M + m) / (M * l0), -bp * (M + m) / (M * m * l0 ^ 2)];

% Only the 1st column of B is used (Input: Force F)
B_LQR = [0; 1 / M; 0; -1 / (M * l0)];

% --- 3. LQR Design ---
Q = diag([1000, 10, 500, 10]);
R = 1;

% Calculate LQR Gain 'K' silently
K = lqr(A, B_LQR, Q, R); % 31.6228   14.0488  -17.7264    0.3611
