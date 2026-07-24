clear; clc; close all;

adams_theta = table2array(readtable("adams_theta"));

tspan = 0:0.005:50;
y0 = [0, 0];
[t, y] = ode89(@odefun, tspan, y0);

figure;
plot(t, y(:, 1) .* 180 ./ pi);
hold on;
plot(t, adams_theta);
legend("matlab", "adams")
hold off;
title("$\theta$(t)", "Interpreter", "latex")
xlabel("Time (s)")
ylabel("$\theta$ (deg)", "Interpreter", "latex")

figure;
plot(t, y(:, 2) .* 180 ./ pi);
title("$\dot{\theta}$(t)", "Interpreter", "latex")
xlabel("Time (s)")
ylabel("$\dot{\theta}$(deg/s)", "Interpreter", "latex")

function y_ = odefun(t, y)
    L = 0.3;
    g = 9.80665;

    theta = y(1);
    theta_ = y(2);

    if (t < 1.099)
        x__ = 0.62831853071795868653667946085502 * sin(6.283185307179586476925286766559 * t);
    else
        x__ = 0;
    end

    theta__ = 1 / L * (cos(theta) * x__ - g * sin(theta));
    % theta__ = 1 / L * (x__ - g * theta);

    y_ = [theta_; theta__];
end
