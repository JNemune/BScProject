function dxdt = CraneStateFcn(x, u) 
    % پارامترهای فیزیکی سیستم
    M = 1.0; bc = 0.1; bp = 0.05; g = 9.81; m = 0.2;

    % استخراج متغیرهای حالت
    x2 = x(2); x3 = x(3); x4 = x(4); x5 = x(5); x6 = x(6);

    % استخراج ورودی‌های کنترلی (صرفاً متغیرهای دستکاری‌شونده NMPC)
    F = u(1);      % MV 1: نیروی کالسکه
    l_ddot = u(2); % MV 2: شتاب تغییر طول کابل

    % جلوگیری از تکینگی (طول کابل نباید صفر شود)
    if x5 < 0.01
        x5 = 0.01;
    end

    % محاسبات عبارات غیرخطی
    RHS1 = m * x5 * x4 ^ 2 * sin(x3) - 2 * m * x6 * x4 * cos(x3) - bc * x2;
    RHS2 = -2 * m * x5 * x6 * x4 - m * g * x5 * sin(x3) - bp * x4;
    gamma = M + m * sin(x3) ^ 2;

    % تشکیل بردار مشتقات حالت
    dxdt = zeros(6, 1);
    dxdt(1) = x2;
    dxdt(2) = (x5 * RHS1 - cos(x3) * RHS2) / (x5 * gamma) + (F) / gamma - (m * sin(x3) / gamma) * l_ddot;
    dxdt(3) = x4;
    dxdt(4) = (-m * x5 * cos(x3) * RHS1 + (M + m) * RHS2) / (m * x5 ^ 2 * gamma) - (cos(x3) / (x5 * gamma)) * (F) + (m * sin(x3) * cos(x3) / (x5 * gamma)) * l_ddot;
    dxdt(5) = x6;
    dxdt(6) = l_ddot;
end