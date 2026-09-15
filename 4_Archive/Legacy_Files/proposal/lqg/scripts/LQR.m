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

B = [0; 1 / M; 0; 1 / L / M];

C = [
     [1, 0, 0, 0];
     [0, 0, 1, 0];
     ];

D = [0; 0];

Q = [
     [100, 0, 0, 0];
     [0, 50, 0, 0];
     [0, 0, 500, 0];
     [0, 0, 0, 50];
     ];
R = 1;
[K, S, CLP] = lqr(A, B, Q, R);
K;
%    10.0000    9.2843   26.5142    4.1460

% 1. Define the closed-loop system matrix (Ac = A - B*K)
Ac = A - B * K;
Bc = B;
Cc = C;
Dc = D;

% Create the continuous-time state-space model
sys_cl = ss(Ac, Bc, Cc, Dc);

% 2. Define simulation time and initial conditions
t = 0:0.01:10; % Simulate for 10 seconds
% Initial state: [cart pos; cart vel; pend angle; pend vel]
x0 = [0.5; 0; 0.2; 0];

% 3. Run the initial condition response
[y, t, x] = initial(sys_cl, x0, t);

% 4. Plot the results
figure('Name', 'LQR Initial Condition Response');

subplot(2, 1, 1);
plot(t, x(:, 1), 'b', 'LineWidth', 1.5);
yline(0, 'k--'); % Target equilibrium
ylabel('Cart Position (m)');
title('Cart Position over Time');
grid on;

subplot(2, 1, 2);
plot(t, x(:, 3), 'r', 'LineWidth', 1.5);
yline(0, 'k--'); % Target equilibrium
ylabel('Pendulum Angle (rad)');
xlabel('Time (s)');
title('Pendulum Angle over Time');
grid on;

F_initial = -x * K';

figure('Name', 'Control Effort (Initial Condition)');
plot(t, F_initial, 'g', 'LineWidth', 1.5);
yline(0, 'k--'); % خط صفر
ylabel('Force (N)');
xlabel('Time (s)');
title('Controller Output (F) - Initial Condition');
grid on;
