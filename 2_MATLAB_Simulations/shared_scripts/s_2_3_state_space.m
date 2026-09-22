clear; clc; close all;

% Define symbolic variables for states and inputs
syms x x_dot theta theta_dot l l_dot
syms F l_ddot
syms M m g bc bp l0

X = [x; x_dot; theta; theta_dot; l; l_dot];
U = [F; l_ddot];

% Inertia matrix M(x)
M_mat = [M + m, m * l * cos(theta);
         m * l * cos(theta), m * l ^ 2];
disp('--- Inertia Matrix M(x) ---');
disp(M_mat);

% Right hand side vector RHS(x,u)
RHS1 = F - bc * x_dot - m * l_ddot * sin(theta) ...
    - 2 * m * l_dot * theta_dot * cos(theta) ...
    + m * l * theta_dot ^ 2 * sin(theta);
RHS2 = -2 * m * l * l_dot * theta_dot ...
    - m * g * l * sin(theta) ...
    - bp * theta_dot;
RHS = [RHS1; RHS2];
disp('--- RHS Vector ---');
disp(RHS);

% Determinant of M_mat
det_M = simplify(det(M_mat));
disp('--- Determinant of M(x) ---');
disp(det_M);

% Non-linear state-space (X_dot = f)
acc = M_mat \ RHS;
f = [x_dot;
     acc(1);
     theta_dot;
     acc(2);
     l_dot;
     l_ddot];
f = simplify(f);
disp('--- Non-linear State-Space Equations (f) ---');
disp(f);

% Linearization (Jacobian matrices)
A_jac = jacobian(f, X);
A_jac = simplify(A_jac);

disp('--- Jacobian Matrix A(x,u) ---');
disp(A_jac);

B_jac = jacobian(f, U);
B_jac = simplify(B_jac);

disp('--- Jacobian Matrix B(x,u) ---');
disp(B_jac);

% Equilibrium point
X_eq = [0; 0; 0; 0; l0; 0];
U_eq = [0; 0];

% Linearized matrices at equilibrium point
A_lin = subs(A_jac, [X; U], [X_eq; U_eq]);
B_lin = subs(B_jac, [X; U], [X_eq; U_eq]);
A_lin = simplify(A_lin);
B_lin = simplify(B_lin);

disp('--- Linearized Matrix A at Equilibrium ---');
disp(A_lin);
disp('--- Linearized Matrix B at Equilibrium ---');
disp(B_lin);

% --- Inertia Matrix M(x) ---
% [M + m, l * m * cos(theta)]
% [l * m * cos(theta), l ^ 2 * m]

% --- RHS Vector ---
% l * m * sin(theta) * theta_dot ^ 2 - 2 * l_dot * m * cos(theta) * theta_dot + F - bc * x_dot - l_ddot * m * sin(theta)
% - bp * theta_dot - 2 * l * l_dot * m * theta_dot - g * l * m * sin(theta)

% --- Determinant of M(x) ---
% l ^ 2 * m * (- m * cos(theta) ^ 2 + M + m)

% --- Non - linear State - Space Equations (f) ---
% x_dot
% (F * l + bp * theta_dot * cos(theta) - bc * l * x_dot + l ^ 2 * m * theta_dot ^ 2 * sin(theta) - l * l_ddot * m * sin(theta) + g * l * m * cos(theta) * sin(theta)) / (l * (- m * cos(theta) ^ 2 + M + m))
% theta_dot
% - (2 * (M * bp * theta_dot + bp * m * theta_dot + (l ^ 2 * m ^ 2 * theta_dot ^ 2 * sin(2 * theta)) / 2 - (l * l_ddot * m ^ 2 * sin(2 * theta)) / 2 + F * l * m * cos(theta) + l * l_dot * m ^ 2 * theta_dot + g * l * m ^ 2 * sin(theta) + 2 * M * l * l_dot * m * theta_dot - l * l_dot * m ^ 2 * theta_dot * cos(2 * theta) + M * g * l * m * sin(theta) - bc * l * m * x_dot * cos(theta))) / (l ^ 2 * m * (2 * M + m - m * cos(2 * theta)))
% l_dot
% l_ddot

% --- Jacobian Matrix A(x, u) ---
% [0, 1, 0, 0, 0, 0]
% [0, -bc / (- m * cos(theta) ^ 2 + M + m), - (2 * (bp * theta_dot * sin(theta) - l ^ 2 * m * theta_dot ^ 2 * cos(theta) + l * l_ddot * m * cos(theta) - g * l * m * (2 * cos(theta) ^ 2 - 1))) / (l * (2 * M + m - m * (2 * cos(theta) ^ 2 - 1))) - (2 * m * cos(theta) * sin(theta) * (F * l + bp * theta_dot * cos(theta) - bc * l * x_dot + l ^ 2 * m * theta_dot ^ 2 * sin(theta) - l * l_ddot * m * sin(theta) + g * l * m * cos(theta) * sin(theta))) / (l * (- m * cos(theta) ^ 2 + M + m) ^ 2), (2 * m * theta_dot * sin(theta) * l ^ 2 + bp * cos(theta)) / (l * (- m * cos(theta) ^ 2 + M + m)), - (theta_dot * (- m * theta_dot * sin(theta) * l ^ 2 + bp * cos(theta))) / (l ^ 2 * (- m * cos(theta) ^ 2 + M + m)), 0]
% [0, 0, 0, 1, 0, 0]
% [0, (bc * cos(theta)) / (l * (- m * cos(theta) ^ 2 + M + m)), (4 * sin(2 * theta) * (M * bp * theta_dot + bp * m * theta_dot + (l ^ 2 * m ^ 2 * theta_dot ^ 2 * sin(2 * theta)) / 2 - (l * l_ddot * m ^ 2 * sin(2 * theta)) / 2 + F * l * m * cos(theta) + l * l_dot * m ^ 2 * theta_dot + g * l * m ^ 2 * sin(theta) + 2 * M * l * l_dot * m * theta_dot - l * l_dot * m ^ 2 * theta_dot * cos(2 * theta) + M * g * l * m * sin(theta) - bc * l * m * x_dot * cos(theta))) / (l ^ 2 * (2 * M + m - m * cos(2 * theta)) ^ 2) - (2 * (l * m * (2 * cos(theta) ^ 2 - 1) * theta_dot ^ 2 + 4 * l_dot * m * cos(theta) * sin(theta) * theta_dot - F * sin(theta) + g * m * cos(theta) + bc * x_dot * sin(theta) - l_ddot * m * (2 * cos(theta) ^ 2 - 1) + M * g * cos(theta))) / (l * (2 * M + m - m * (2 * cos(theta) ^ 2 - 1))), - (2 * (M * bp + bp * m + l * l_dot * m ^ 2 - l * l_dot * m ^ 2 * cos(2 * theta) + l ^ 2 * m ^ 2 * theta_dot * sin(2 * theta) + 2 * M * l * l_dot * m)) / (l ^ 2 * m * (2 * M + m - m * cos(2 * theta))), (2 * M * bp * theta_dot + 2 * bp * m * theta_dot - (l * l_ddot * m ^ 2 * sin(2 * theta)) / 2 + F * l * m * cos(theta) + 2 * l * l_dot * m ^ 2 * theta_dot + g * l * m ^ 2 * sin(theta) + 2 * M * l * l_dot * m * theta_dot - 2 * l * l_dot * m ^ 2 * theta_dot * cos(theta) ^ 2 + M * g * l * m * sin(theta) - bc * l * m * x_dot * cos(theta)) / (l ^ 3 * m * (- m * cos(theta) ^ 2 + M + m)), - (2 * theta_dot) / l]
% [0, 0, 0, 0, 0, 1]
% [0, 0, 0, 0, 0, 0]

% --- Jacobian Matrix B(x, u) ---
% [0, 0]
% [1 / (- m * cos(theta) ^ 2 + M + m), - (m * sin(theta)) / (m * sin(theta) ^ 2 + M)]
% [0, 0]
% [-cos(theta) / (l * (- m * cos(theta) ^ 2 + M + m)), (m * sin(2 * theta)) / (l * (2 * M + m - m * cos(2 * theta)))]
% [0, 0]
% [0, 1]

% --- Linearized Matrix A at Equilibrium ---
% [0, 1, 0, 0, 0, 0]
% [0, -bc / M, (g * m) / M, bp / (M * l0), 0, 0]
% [0, 0, 0, 1, 0, 0]
% [0, bc / (M * l0), - (g * (M + m)) / (M * l0), - (bp * (M + m)) / (M * l0 ^ 2 * m), 0, 0]
% [0, 0, 0, 0, 0, 1]
% [0, 0, 0, 0, 0, 0]

% --- Linearized Matrix B at Equilibrium ---
% [0, 0]
% [1 / M, 0]
% [0, 0]
% [-1 / (M * l0), 0]
% [0, 0]
% [0, 1]
