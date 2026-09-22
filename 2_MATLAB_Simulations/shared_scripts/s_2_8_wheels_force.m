clear; clc; close all;

% Define symbolic variables

syms x x_dot theta theta_dot l l_dot
syms F l_ddot
syms M m g bc bp D1 D2 l0

X = [x; x_dot; theta; theta_dot; l; l_dot];
U = [F; l_ddot];

% Inertia matrix

M_mat = [M + m, m * l * cos(theta);
         m * l * cos(theta), m * l ^ 2];

% Right hand side vector

RHS1 = F - bc * x_dot - m * l_ddot * sin(theta) ...
    - 2 * m * l_dot * theta_dot * cos(theta) ...
    + m * l * theta_dot ^ 2 * sin(theta);

RHS2 = -2 * m * l * l_dot * theta_dot ...
    - m * g * l * sin(theta) ...
    - bp * theta_dot;

RHS = [RHS1; RHS2];

% System accelerations from Lagrange model

acc = M_mat \ RHS;
acc = simplify(acc);

x_ddot = acc(1);
theta_ddot = acc(2);

% Payload kinematics

x_p = x + l * sin(theta);
y_p = -l * cos(theta);

x_p_ddot = x_ddot + l_ddot * sin(theta) ...
    + 2 * l_dot * theta_dot * cos(theta) ...
    + l * theta_ddot * cos(theta) ...
    - l * theta_dot ^ 2 * sin(theta);

y_p_ddot = -l_ddot * cos(theta) ...
    + 2 * l_dot * theta_dot * sin(theta) ...
    + l * theta_ddot * sin(theta) ...
    + l * theta_dot ^ 2 * cos(theta);

x_p_ddot = simplify(x_p_ddot);
y_p_ddot = simplify(y_p_ddot);

% Wheel load equations

F_bc = bc * x_dot;

F_w_sum = (M + m) * g + m * y_p_ddot;

M_acc = m * (x_p * y_p_ddot - y_p * x_p_ddot);

F_w_diff = simplify((D2 * F_bc + m * g * x_p + M_acc) / D1);

F_w1 = simplify((F_w_sum - F_w_diff) / 2);
F_w2 = simplify((F_w_sum + F_w_diff) / 2);

% Display results

disp('--- Cart and Payload Accelerations ---');
disp('x_ddot =');
disp(x_ddot);
disp('theta_ddot =');
disp(theta_ddot);
disp('x_p_ddot =');
disp(x_p_ddot);
disp('y_p_ddot =');
disp(y_p_ddot);

disp('--- Wheel Load Components ---');
disp('F_w1 + F_w2 =');
disp(simplify(F_w_sum));
disp('F_w2 - F_w1 =');
disp(simplify(F_w_diff));

disp('--- Wheel Loads ---');
disp('F_w1 =');
disp(F_w1);
disp('F_w2 =');
disp(F_w2);

% --- Cart and Payload Accelerations ---
% x_ddot =
% (F * l + bp * theta_dot * cos(theta) - bc * l * x_dot + l ^ 2 * m * theta_dot ^ 2 * sin(theta) - l * l_ddot * m * sin(theta) + g * l * m * cos(theta) * sin(theta)) / (l * (- m * cos(theta) ^ 2 + M + m))

% theta_ddot =
% - (2 * (M * bp * theta_dot + bp * m * theta_dot + (l ^ 2 * m ^ 2 * theta_dot ^ 2 * sin(2 * theta)) / 2 - (l * l_ddot * m ^ 2 * sin(2 * theta)) / 2 + F * l * m * cos(theta) + l * l_dot * m ^ 2 * theta_dot + g * l * m ^ 2 * sin(theta) + 2 * M * l * l_dot * m * theta_dot - l * l_dot * m ^ 2 * theta_dot * cos(2 * theta) + M * g * l * m * sin(theta) - bc * l * m * x_dot * cos(theta))) / (l ^ 2 * m * (2 * M + m - m * cos(2 * theta)))

% x_p_ddot =
% - (bc * l * m * x_dot - F * l * m + M * bp * theta_dot * cos(theta) + F * l * m * cos(theta) ^ 2 - bc * l * m * x_dot * cos(theta) ^ 2 + M * l ^ 2 * m * theta_dot ^ 2 * sin(theta) - M * l * l_ddot * m * sin(theta) + M * g * l * m * cos(theta) * sin(theta)) / (l * m * (- m * cos(theta) ^ 2 + M + m))

% y_p_ddot =
% - (g * l * m ^ 2 - g * l * m ^ 2 * cos(theta) ^ 2 + M * bp * theta_dot * sin(theta) + bp * m * theta_dot * sin(theta) + (F * l * m * sin(2 * theta)) / 2 + M * g * l * m - M * g * l * m * cos(theta) ^ 2 - (bc * l * m * x_dot * sin(2 * theta)) / 2 - M * l ^ 2 * m * theta_dot ^ 2 * cos(theta) + M * l * l_ddot * m * cos(theta)) / (l * m * (- m * cos(theta) ^ 2 + M + m))

% --- Wheel Load Components ---
% F_w1 + F_w2 =
% (M ^ 2 * g * l - M * bp * theta_dot * sin(theta) - bp * m * theta_dot * sin(theta) - (F * l * m * sin(2 * theta)) / 2 + M * g * l * m + (bc * l * m * x_dot * sin(2 * theta)) / 2 + M * l ^ 2 * m * theta_dot ^ 2 * cos(theta) - M * l * l_ddot * m * cos(theta)) / (l * (- m * cos(theta) ^ 2 + M + m))

% F_w2 - F_w1 =
% - (bp * l * m * theta_dot + M * bp * l * theta_dot + bp * m * theta_dot * x * sin(theta) - D2 * M * bc * l * x_dot + (F * l * m * x * sin(2 * theta)) / 2 - bp * l * m * theta_dot * cos(theta) ^ 2 - D2 * bc * l * m * x_dot + M * bp * theta_dot * x * sin(theta) - M * l ^ 2 * m * theta_dot ^ 2 * x * cos(theta) + M * l * l_ddot * m * x * cos(theta) + D2 * bc * l * m * x_dot * cos(theta) ^ 2 - M * g * l * m * x * cos(theta) ^ 2 - (bc * l * m * x * x_dot * sin(2 * theta)) / 2) / (D1 * l * (- m * cos(theta) ^ 2 + M + m))

% --- Wheel Loads ---
% F_w1 =
% (2 * bp * l * m * theta_dot + 2 * D1 * M ^ 2 * g * l + 2 * M * bp * l * theta_dot + 2 * bp * m * theta_dot * x * sin(theta) - D1 * F * l * m * sin(2 * theta) + 2 * D1 * M * g * l * m - 2 * D2 * M * bc * l * x_dot + F * l * m * x * sin(2 * theta) - 2 * bp * l * m * theta_dot * cos(theta) ^ 2 - 2 * D2 * bc * l * m * x_dot - 2 * D1 * M * bp * theta_dot * sin(theta) - 2 * D1 * bp * m * theta_dot * sin(theta) + 2 * M * bp * theta_dot * x * sin(theta) - 2 * M * l ^ 2 * m * theta_dot ^ 2 * x * cos(theta) - 2 * D1 * M * l * l_ddot * m * cos(theta) + 2 * M * l * l_ddot * m * x * cos(theta) + 2 * D2 * bc * l * m * x_dot * cos(theta) ^ 2 - 2 * M * g * l * m * x * cos(theta) ^ 2 + D1 * bc * l * m * x_dot * sin(2 * theta) - bc * l * m * x * x_dot * sin(2 * theta) + 2 * D1 * M * l ^ 2 * m * theta_dot ^ 2 * cos(theta)) / (4 * D1 * l * (- m * cos(theta) ^ 2 + M + m))

% F_w2 =
% - (2 * bp * l * m * theta_dot - 2 * D1 * M ^ 2 * g * l + 2 * M * bp * l * theta_dot + 2 * bp * m * theta_dot * x * sin(theta) + D1 * F * l * m * sin(2 * theta) - 2 * D1 * M * g * l * m - 2 * D2 * M * bc * l * x_dot + F * l * m * x * sin(2 * theta) - 2 * bp * l * m * theta_dot * cos(theta) ^ 2 - 2 * D2 * bc * l * m * x_dot + 2 * D1 * M * bp * theta_dot * sin(theta) + 2 * D1 * bp * m * theta_dot * sin(theta) + 2 * M * bp * theta_dot * x * sin(theta) - 2 * M * l ^ 2 * m * theta_dot ^ 2 * x * cos(theta) + 2 * D1 * M * l * l_ddot * m * cos(theta) + 2 * M * l * l_ddot * m * x * cos(theta) + 2 * D2 * bc * l * m * x_dot * cos(theta) ^ 2 - 2 * M * g * l * m * x * cos(theta) ^ 2 - D1 * bc * l * m * x_dot * sin(2 * theta) - bc * l * m * x * x_dot * sin(2 * theta) - 2 * D1 * M * l ^ 2 * m * theta_dot ^ 2 * cos(theta)) / (4 * D1 * l * (- m * cos(theta) ^ 2 + M + m))
