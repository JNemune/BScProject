clear; clc; close all;

% Define symbolic variables for states and inputs
syms x1 x2 x3 x4
syms u1 u2 u3 u4
syms M m g bc bp l0

X = [x1; x2; x3; x4];
U = [u1; u2; u3; u4];

% Inertia matrix M(x,u)
M_mat = [M + m, m * u4 * cos(x3);
         m * u4 * cos(x3), m * u4 ^ 2];

disp('--- Inertia Matrix M(x,u) ---');
disp(M_mat);

% Right hand side vector RHS(x,u)
RHS1 = u1 - bc * x2 - m * u2 * sin(x3) - 2 * m * u3 * x4 * cos(x3) + m * u4 * x4 ^ 2 * sin(x3);
RHS2 = -2 * m * u4 * u3 * x4 - m * g * u4 * sin(x3) - bp * x4;
RHS = [RHS1; RHS2];

disp('--- RHS Vector ---');
disp(RHS);

% Determinant of M_mat
det_M = simplify(det(M_mat));
disp('--- Determinant of M(x,u) ---');
disp(det_M);

% Non-linear state-space (X_dot = f)
acc = M_mat \ RHS;
f = [x2;
     acc(1);
     x4;
     acc(2)];
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
X_eq = [0; 0; 0; 0];
U_eq = [0; 0; 0; l0];

% Linearized matrices at equilibrium point
A_lin = subs(A_jac, [X; U], [X_eq; U_eq]);
B_lin = subs(B_jac, [X; U], [X_eq; U_eq]);

disp('--- Linearized Matrix A at Equilibrium ---');
disp(A_lin);

disp('--- Linearized Matrix B at Equilibrium ---');
disp(B_lin);

% --- Inertia Matrix M(x, u) ---
% [M + m, m * u4 * cos(x3)]
% [m * u4 * cos(x3), m * u4 ^ 2]

% --- RHS Vector ---
% m * u4 * sin(x3) * x4 ^ 2 - 2 * m * u3 * cos(x3) * x4 + u1 - bc * x2 - m * u2 * sin(x3)
% - bp * x4 - 2 * m * u3 * u4 * x4 - g * m * u4 * sin(x3)

% --- Determinant of M(x, u) ---
% m * u4 ^ 2 * (- m * cos(x3) ^ 2 + M + m)

% --- Non - linear State - Space Equations (f) ---
% x2
% (u1 * u4 + bp * x4 * cos(x3) - bc * u4 * x2 + m * u4 ^ 2 * x4 ^ 2 * sin(x3) - m * u2 * u4 * sin(x3) + g * m * u4 * cos(x3) * sin(x3)) / (u4 * (- m * cos(x3) ^ 2 + M + m))
% x4
% - (2 * (M * bp * x4 + bp * m * x4 + (m ^ 2 * u4 ^ 2 * x4 ^ 2 * sin(2 * x3)) / 2 - (m ^ 2 * u2 * u4 * sin(2 * x3)) / 2 + m ^ 2 * u3 * u4 * x4 + m * u1 * u4 * cos(x3) + g * m ^ 2 * u4 * sin(x3) + 2 * M * m * u3 * u4 * x4 - m ^ 2 * u3 * u4 * x4 * cos(2 * x3) + M * g * m * u4 * sin(x3) - bc * m * u4 * x2 * cos(x3))) / (m * u4 ^ 2 * (2 * M + m - m * cos(2 * x3)))

% --- Jacobian Matrix A(x, u) ---
% [0, 1, 0, 0]
% [0, -bc / (- m * cos(x3) ^ 2 + M + m), - (2 * (bp * x4 * sin(x3) - m * u4 ^ 2 * x4 ^ 2 * cos(x3) + m * u2 * u4 * cos(x3) - g * m * u4 * (2 * cos(x3) ^ 2 - 1))) / (u4 * (2 * M + m - m * (2 * cos(x3) ^ 2 - 1))) - (2 * m * cos(x3) * sin(x3) * (u1 * u4 + bp * x4 * cos(x3) - bc * u4 * x2 + m * u4 ^ 2 * x4 ^ 2 * sin(x3) - m * u2 * u4 * sin(x3) + g * m * u4 * cos(x3) * sin(x3))) / (u4 * (- m * cos(x3) ^ 2 + M + m) ^ 2), (2 * m * x4 * sin(x3) * u4 ^ 2 + bp * cos(x3)) / (u4 * (- m * cos(x3) ^ 2 + M + m))]
% [0, 0, 0, 1]
% [0, (bc * cos(x3)) / (u4 * (- m * cos(x3) ^ 2 + M + m)), (4 * sin(2 * x3) * (M * bp * x4 + bp * m * x4 + (m ^ 2 * u4 ^ 2 * x4 ^ 2 * sin(2 * x3)) / 2 - (m ^ 2 * u2 * u4 * sin(2 * x3)) / 2 + m ^ 2 * u3 * u4 * x4 + m * u1 * u4 * cos(x3) + g * m ^ 2 * u4 * sin(x3) + 2 * M * m * u3 * u4 * x4 - m ^ 2 * u3 * u4 * x4 * cos(2 * x3) + M * g * m * u4 * sin(x3) - bc * m * u4 * x2 * cos(x3))) / (u4 ^ 2 * (2 * M + m - m * cos(2 * x3)) ^ 2) - (2 * (m * u4 * (2 * cos(x3) ^ 2 - 1) * x4 ^ 2 + 4 * m * u3 * cos(x3) * sin(x3) * x4 - u1 * sin(x3) + g * m * cos(x3) + bc * x2 * sin(x3) - m * u2 * (2 * cos(x3) ^ 2 - 1) + M * g * cos(x3))) / (u4 * (2 * M + m - m * (2 * cos(x3) ^ 2 - 1))), - (2 * (M * bp + bp * m + m ^ 2 * u3 * u4 + 2 * M * m * u3 * u4 - m ^ 2 * u3 * u4 * cos(2 * x3) + m ^ 2 * u4 ^ 2 * x4 * sin(2 * x3))) / (m * u4 ^ 2 * (2 * M + m - m * cos(2 * x3)))]

% --- Jacobian Matrix B(x, u) ---
% [0, 0, 0, 0]
% [1 / (- m * cos(x3) ^ 2 + M + m), - (m * sin(x3)) / (m * sin(x3) ^ 2 + M), 0, - (x4 * (- m * x4 * sin(x3) * u4 ^ 2 + bp * cos(x3))) / (u4 ^ 2 * (- m * cos(x3) ^ 2 + M + m))]
% [0, 0, 0, 0]
% [-cos(x3) / (u4 * (- m * cos(x3) ^ 2 + M + m)), (m * sin(2 * x3)) / (u4 * (2 * M + m - m * cos(2 * x3))), - (2 * x4) / u4, (2 * M * bp * x4 + 2 * bp * m * x4 - (m ^ 2 * u2 * u4 * sin(2 * x3)) / 2 + 2 * m ^ 2 * u3 * u4 * x4 + m * u1 * u4 * cos(x3) + g * m ^ 2 * u4 * sin(x3) + 2 * M * m * u3 * u4 * x4 - 2 * m ^ 2 * u3 * u4 * x4 * cos(x3) ^ 2 + M * g * m * u4 * sin(x3) - bc * m * u4 * x2 * cos(x3)) / (m * u4 ^ 3 * (- m * cos(x3) ^ 2 + M + m))]

% --- Linearized Matrix A at Equilibrium ---
% [0, 1, 0, 0]
% [0, -bc / M, (g * m) / M, bp / (M * l0)]
% [0, 0, 0, 1]
% [0, bc / (M * l0), - (M * g + g * m) / (M * l0), - (M * bp + bp * m) / (M * l0 ^ 2 * m)]

% --- Linearized Matrix B at Equilibrium ---
% [0, 0, 0, 0]
% [1 / M, 0, 0, 0]
% [0, 0, 0, 0]
% [-1 / (M * l0), 0, 0, 0]
