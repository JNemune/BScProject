function dxdt = CraneStateFcn(x, u)
    % CraneStateFcn: Continuous-time nonlinear state equations for NMPC
    % States: x = [x; x_dot; theta; theta_dot; l; l_dot]
    % Inputs: u = [F; l_ddot]

    % L_initial = 0.5;
    M = 1.0; % [kg]
    bc = 0.1; % [N.s/m]
    bp = 0.05; % [N.m.s/rad]
    g = 9.81; % [m/s^2]
    m = 0.2; % [kg]

    % x1 = x(1); % x
    x2 = x(2); % x_dot
    x3 = x(3); % theta
    x4 = x(4); % theta_dot
    x5 = x(5); % l
    x6 = x(6); % l_dot

    F = u(1);
    l_ddot = u(2);

    if x5 < 0.01
        x5 = 0.01;
    end

    RHS1 = m * x5 * x4 ^ 2 * sin(x3) - 2 * m * x6 * x4 * cos(x3) - bc * x2;
    RHS2 = -2 * m * x5 * x6 * x4 - m * g * x5 * sin(x3) - bp * x4;
    gamma = M + m * sin(x3) ^ 2;

    dxdt = zeros(6, 1);

    dxdt(1) = x2;

    dxdt(2) = (x5 * RHS1 - cos(x3) * RHS2) / (x5 * gamma) ...
        + (F) / gamma ...
        - (m * sin(x3) / gamma) * l_ddot;

    dxdt(3) = x4;

    dxdt(4) = (-m * x5 * cos(x3) * RHS1 + (M + m) * RHS2) / (m * x5 ^ 2 * gamma) ...
        - (cos(x3) / (x5 * gamma)) * (F) ...
        + (m * sin(x3) * cos(x3) / (x5 * gamma)) * l_ddot;

    dxdt(5) = x6;

    dxdt(6) = l_ddot;
end
