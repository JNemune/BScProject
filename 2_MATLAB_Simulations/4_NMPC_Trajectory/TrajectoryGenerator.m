function [ref_out, ref_current] = TrajectoryGenerator(t, params)
    % Extract parameters
    x0 = params(1); v_max = params(2); a_max = params(3);
    l0 = params(7);

    x_target = 0.0;
    L = x_target - x0;
    D = abs(L);

    % NMPC settings
    Np = 25;
    Ts = 0.05;

    % Initialize reference matrix (Np x 6)
    ref_out = zeros(Np, 6);

    % Handle zero displacement
    if D < 1e-4
        ref_out = repmat([x_target, 0, 0, 0, l0, 0], Np, 1);
        ref_current = ref_out(1, :);
        return;
    end

    % Calculate minimum travel time constraints
    T_v = (15/8) * (D / v_max);
    T_a = sqrt((5.77 * D) / a_max);
    T_p = 2 * pi * sqrt(l0 / 9.81);

    % Select maximum required time for safety and sway suppression
    T = max([T_v, T_a, 1.5 * T_p]);

    % Generate future references over the prediction horizon
    for k = 1:Np
        t_future = t + (k - 1) * Ts;
        tau = max(0.0, min(t_future / T, 1.0));

        % 5th-order S-curve polynomial
        s = 10 * tau ^ 3 - 15 * tau ^ 4 + 6 * tau ^ 5;
        s_dot = (30 * tau ^ 2 - 60 * tau ^ 3 + 30 * tau ^ 4) / T;

        % Set reference state: [x, x_dot, theta, theta_dot, l, l_dot]
        % Target sway angle is strictly zero
        ref_out(k, :) = [x0 + L * s, L * s_dot, 0, 0, l0, 0];
    end

    % Extract current reference for feedback calculations
    ref_current = ref_out(1, :);
end
