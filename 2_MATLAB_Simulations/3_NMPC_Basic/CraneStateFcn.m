function dxdt = CraneStateFcn(x, u)
    % Continuous-time augmented nonlinear model for NMPC
    % States: x = [x; x_dot; theta; theta_dot; l; l_dot]
    % Inputs: u = [F; l_ddot]

    % System parameters
    M = 1.0;
    bc = 0.1;
    bp = 0.05;
    g = 9.81;
    m = 0.2;

    % Extract states and inputs
    x2 = x(2);
    x3 = x(3);
    x4 = x(4);
    x5 = x(5);
    x6 = x(6);

    u1 = u(1);
    u2 = u(2);

    % Prevent singularity at l = 0
    if x5 < 0.01
        x5 = 0.01;
    end

    % Exact RHS terms from symbolic derivation
    RHS1 = u1 - bc * x2 - m * u2 * sin(x3) - 2 * m * x6 * x4 * cos(x3) + m * x5 * x4 ^ 2 * sin(x3);
    RHS2 = -2 * m * x5 * x6 * x4 - m * g * x5 * sin(x3) - bp * x4;
    RHS = [RHS1; RHS2];

    % Exact inertia matrix M(x,u)
    M_mat = [M + m, m * x5 * cos(x3);
             m * x5 * cos(x3), m * x5 ^ 2];

    % Compute accelerations
    acc = M_mat \ RHS;

    % Augmented state derivatives
    dxdt = zeros(6, 1);
    dxdt(1) = x2;
    dxdt(2) = acc(1);
    dxdt(3) = x4;
    dxdt(4) = acc(2);
    dxdt(5) = x6;
    dxdt(6) = u2;
end
