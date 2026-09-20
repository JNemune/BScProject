clear; clc; close all;

% System parameters
m = 0.2;
M = 1;
g = 9.81;
bc = 0.1;
bp = 0.05;
l0 = 0.5;
theta0 = 0;
x0 = -0.5; % or -5

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

% Set HARD state constraints
nlobj.States(3).Min = theta_min; nlobj.States(3).Max = theta_max;
nlobj.States(5).Min = l_min; nlobj.States(5).Max = l_max;

% Set MV hard constraints
nlobj.MV(1).Min = f_min; nlobj.MV(1).Max = f_max;
nlobj.MV(2).Min = l_ddot_min; nlobj.MV(2).Max = l_ddot_max;

% Distance-Invariant Tuning Weights
% OutputVariables: [x, x_dot, theta, theta_dot, l, l_dot]
% x weight reduced to allow tracking flexibility without constraint violation
nlobj.Weights.OutputVariables = [150, 20, 300, 20, 50, 10];

% ManipulatedVariables: [F, l_ddot]
nlobj.Weights.ManipulatedVariables = [1, 1];

% ManipulatedVariablesRate: [F_rate, l_ddot_rate]
% Heavily penalized to enforce smooth control actions, preventing hard constraint hits
nlobj.Weights.ManipulatedVariablesRate = [150, 150];

% Optimization solver settings
nlobj.Optimization.SolverOptions.Algorithm = 'sqp';
nlobj.Optimization.SolverOptions.MaxIterations = 200;
% Increase tolerance slightly to help the solver in tight constraint scenarios
nlobj.Optimization.SolverOptions.StepTolerance = 1e-4;

% Trajectory and feedforward parameters
v_max = 1.0;
a_max = 2.0;
traj_params = [x0, v_max, a_max, M, m, bc, l0];
