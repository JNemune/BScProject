function [F_w1, F_w2] = wheel_force(X, U)
    % Extract mechanical states for LQR architecture
    x_dot = X(2);
    theta = X(3);
    theta_dot = X(4);

    % Define constant cable parameters
    l = 0.5;
    l_dot = 0;

    % Extract inputs
    F = U(1);
    l_ddot = U(2);

    % System physical parameters
    m = 0.2;
    M = 1.0;
    g = 9.81;
    bc = 0.1;
    bp = 0.05;
    D1 = 0.2;
    D2 = 0.1;

    % Precompute trigonometric terms
    s = sin(theta);
    c = cos(theta);

    % Calculate theta_ddot using analytical inversion
    RHS1 = F - bc * x_dot - m * l_ddot * s ...
        - 2 * m * l_dot * theta_dot * c ...
        + m * l * theta_dot ^ 2 * s;

    RHS2 = -2 * m * l * l_dot * theta_dot ...
        - m * g * l * s ...
        - bp * theta_dot;

    theta_ddot = ((M + m) * RHS2 - m * l * c * RHS1) / (m * l ^ 2 * (M + m * s ^ 2));

    % Payload vertical acceleration via local polar coordinates
    a_radial = l_ddot - l * theta_dot ^ 2;
    a_tang = l * theta_ddot + 2 * l_dot * theta_dot;
    y_p_ddot = -a_radial * c + a_tang * s;

    % Wheel load calculations
    F_sum = (M + m) * g + m * y_p_ddot;
    F_diff = (D2 * bc * x_dot - bp * theta_dot) / D1;

    % Final vertical loads on left and right wheel sets
    F_w1 = (F_sum - F_diff) / 2;
    F_w2 = (F_sum + F_diff) / 2;
end
