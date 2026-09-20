clear; clc; close all;

% --- 1. System Parameters ---
m = 0.2;
M = 1;
g = 9.81;
bc = 0.1;
bp = 0.05;
l0 = 0.5;
theta0 = 0;
x0 = -0.5;

% NMPC horizons and constraints
Ts = 0.05;
prediction_horizon = 25;
control_horizon = 5;

theta_max = deg2rad(15);
theta_min = -theta_max;
l_max = 1.5; l_min = 0.1;
f_max = 50; f_min = -f_max;
l_ddot_max = 5; l_ddot_min = -l_ddot_max;

% NMPC object configuration
nx = 6; % States: [x, x_dot, theta, theta_dot, l, l_dot]
ny = 6; % Outputs
nu = 2; % Inputs: [F, l_ddot]

nlobj = nlmpc(nx, ny, nu);
nlobj.Model.StateFcn = "CraneStateFcn";
nlobj.Ts = Ts;
nlobj.PredictionHorizon = prediction_horizon;
nlobj.ControlHorizon = control_horizon;

% Set state constraints
nlobj.States(3).Min = theta_min; nlobj.States(3).Max = theta_max;
nlobj.States(5).Min = l_min; nlobj.States(5).Max = l_max;

% Set MV constraints
nlobj.MV(1).Min = f_min; nlobj.MV(1).Max = f_max;
nlobj.MV(2).Min = l_ddot_min; nlobj.MV(2).Max = l_ddot_max;

% Tuning weights (Aligned with LQR: Q = diag([1000, 10, 500, 10]), R = 1)
% OutputVariables: [x, x_dot, theta, theta_dot, l, l_dot]
nlobj.Weights.OutputVariables = [1000, 10, 500, 10, 50, 10];

% ManipulatedVariables: [F, l_ddot]
nlobj.Weights.ManipulatedVariables = [1, 1];

% ManipulatedVariablesRate: [F_rate, l_ddot_rate]
nlobj.Weights.ManipulatedVariablesRate = [50, 50];
