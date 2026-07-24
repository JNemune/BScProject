clear; clc; close all;

%% 1. System Parameters and Matrices
M = 1.0; % cart mass (kg)
m = 0.2; % pendulum mass (kg)
L = 0.5; % pendulum length (m)
g = 9.81; % gravity
b_c = 0.1; % cart friction
b_p = 0.05; % pendulum friction

A = [
     0, 1, 0, 0;
     0, -b_c / M, -g * m / M, -b_p / L / M;
     0, 0, 0, 1;
     0, -b_c / L / M, - (g / L + g * m / L / M), - (b_p / L ^ 2 / M + b_p / L ^ 2 / m)
     ];

B = [0; 1 / M; 0; 1 / L / M];

% CRITICAL CHANGE: We only measure the first state (cart position, x)
C = [1, 0, 0, 0];
D = 0;

%% 2. LQR Controller Design (Same as before)
Q = diag([100, 50, 500, 50]);
R = 1;
K = lqr(A, B, Q, R);

%% 3. Kalman Filter (Observer) Design

% Aggressive Tuning: Now that the initial condition is fixed,
% we force the observer to track the pendulum dynamics extremely fast!
Qk = diag([0.1, 0.01, 0.1, 1]); 

% تنظیم Rk متناسب با قدرت نویز جدید شما
Rk = 0.001; 

G = eye(4); 
L = lqe(A, G, C, Qk, Rk);
A_obs = A - L * C;
B_obs = [B, L]; % Observer takes TWO inputs: [u; y]
C_obs = eye(4); % Observer outputs all 4 estimated states
D_obs = zeros(4, 2); % Zero feedthrough

%% 4. Closed-Loop Simulation (Plant + Observer) using ode45
tspan = 0:0.01:5; % Simulate for 5 seconds

% Initial Conditions
% x0_true: The actual physical states of the system (cart displaced, pendulum tilted)
x0_true = [0.5; 0; 0.2; 0];

% x0_est: The observer's initial guess.
% We start it at [0; 0; 0; 0] to show how it "learns" the true states over time.
x0_est = [0.5; 0; 0; 0];

% Augmented state vector for simulation: z = [True States; Estimated States]
z0 = [x0_true; x0_est];

% Run the ODE solver
[t, Z] = ode45(@(t, z) lqg_dynamics(z, A, B, C, K, L), tspan, z0);

% Extract true and estimated states from the results
x_true = Z(:, 1:4);
x_est = Z(:, 5:8);

%% 5. Plotting the Results
figure('Name', 'Kalman Filter Estimation vs True States', 'Position', [100, 100, 800, 600]);

% Plot 1: Cart Position (Measured)
subplot(2, 2, 1);
plot(t, x_true(:, 1), 'b', 'LineWidth', 2); hold on;
plot(t, x_est(:, 1), 'r--', 'LineWidth', 1.5);
title('Cart Position (x)'); ylabel('Meters'); xlabel('Time (s)');
legend('True', 'Estimated'); grid on;

% Plot 2: Cart Velocity (Unmeasured - Estimated)
subplot(2, 2, 2);
plot(t, x_true(:, 2), 'b', 'LineWidth', 2); hold on;
plot(t, x_est(:, 2), 'r--', 'LineWidth', 1.5);
title('Cart Velocity (dx/dt)'); ylabel('m/s'); xlabel('Time (s)');
legend('True', 'Estimated'); grid on;

% Plot 3: Pendulum Angle (Unmeasured - Estimated)
subplot(2, 2, 3);
plot(t, x_true(:, 3), 'b', 'LineWidth', 2); hold on;
plot(t, x_est(:, 3), 'r--', 'LineWidth', 1.5);
title('Pendulum Angle (\theta)'); ylabel('Radians'); xlabel('Time (s)');
legend('True', 'Estimated'); grid on;

% Plot 4: Pendulum Angular Velocity (Unmeasured - Estimated)
subplot(2, 2, 4);
plot(t, x_true(:, 4), 'b', 'LineWidth', 2); hold on;
plot(t, x_est(:, 4), 'r--', 'LineWidth', 1.5);
title('Angular Velocity (d\theta/dt)'); ylabel('rad/s'); xlabel('Time (s)');
legend('True', 'Estimated'); grid on;

%% ODE Function definition for the coupled system
function dz = lqg_dynamics(z, A, B, C, K, L)
    % Extract states
    x_true = z(1:4); % Real physics
    x_hat = z(5:8); % Microcontroller's brain (Observer)

    % 1. Control Law: The controller only has access to the ESTIMATED states
    u = -K * x_hat;

    % 2. True Plant Dynamics
    dx_true = A * x_true + B * u;

    % 3. Sensor Measurement: Only cart position is sent back to the observer
    y = C * x_true;

    % 4. Observer Dynamics (Kalman Filter equation)
    % The observer predicts the next state using the model, and corrects it using the sensor error (y - C*x_hat)
    dx_hat = A * x_hat + B * u + L * (y - C * x_hat);

    % Return derivatives
    dz = [dx_true; dx_hat];
end
