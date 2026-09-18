function [X_ref, F_ff] = TrajectoryGenerator_LQR(t, params)
    % Extract parameters
    x0 = params(1); v_max = params(2); a_max = params(3);
    M = params(4); m = params(5); bc = params(6); l0 = params(7);

    x_target = 0.0;
    L = x_target - x0;
    D = abs(L);

    % Handle zero displacement
    if D < 1e-4
        X_ref = [x_target; 0; 0; 0];
        F_ff = 0;
        return;
    end

    % Calculate minimum travel time constraints
    T_v = (15/8) * (D / v_max);
    T_a = sqrt((5.77 * D) / a_max);
    T_p = 2 * pi * sqrt(l0 / 9.81);

    % Select maximum required time for safety and sway suppression
    T = max([T_v, T_a, 1.5 * T_p]);

    % Generate reference profiles
    if t >= T
        X_ref = [x_target; 0; 0; 0];
        F_ff = 0;
    else
        tau = t / T;

        % 5th-order S-curve polynomial
        s = 10 * tau ^ 3 - 15 * tau ^ 4 + 6 * tau ^ 5;
        s_dot = (30 * tau ^ 2 - 60 * tau ^ 3 + 30 * tau ^ 4) / T;
        s_ddot = (60 * tau - 180 * tau ^ 2 + 120 * tau ^ 3) / T ^ 2;

        x_ref = x0 + L * s;
        v_ref = L * s_dot;
        a_ref = L * s_ddot;

        % 4x1 state reference vector
        X_ref = [x_ref; v_ref; 0; 0];

        % Analytical feedforward to overcome inertia and friction
        F_ff = (M + m) * a_ref + bc * v_ref;
    end

end
