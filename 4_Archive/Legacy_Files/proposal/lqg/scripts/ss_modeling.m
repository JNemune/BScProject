clear; clc; close all;

M = 1.0; % cart mass (kg)
m = 0.2; % pendulum mass (kg)
L = 0.5; % pendulum length (m)
g = 9.81; % gravity
b_c = 0.1; % cart friction
b_p = 0.05; % pendulum friction

A = [
     [0, 1, 0, 0];
     [0, -b_c / M, -g * m / M, -b_p / L / M];
     [0, 0, 0, 1];
     [0, -b_c / L / M, -g / L - g * m / L / M, -b_p / L ^ 2 / M - b_p / L ^ 2 / m];
     ];
%  0    1.0000         0         0
%  0   -0.1000   -1.9620   -0.1000
%  0         0         0    1.0000
%  0   -0.2000  -23.5440   -1.2000

B = [0; 1 / M; 0; 1 / L / M];
%  0
%  1
%  0
%  2

C = [
     [1, 0, 0, 0];
     [0, 0, 1, 0];
     ];

D = [0; 0];

eig(A);
%   0.0000 + 0.0000i
%  -0.0833 + 0.0000i
%  -0.6083 + 4.8138i
%  -0.6083 - 4.8138i

rank(ctrb(A, B));
% 4

rank(obsv(A, C));
% 4
