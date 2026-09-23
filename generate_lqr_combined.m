% generate_lqr_combined.m
% Combines x, theta, and Fs plots into a single 3x1 figure for LQR Trajectory
% Generates exactly 2 publication-quality PDF figures.

function generate_lqr_combined()
    clc; close all; warning('off', 'MATLAB:hg:AutoSoftwareOpenGL');

    % =========================================================
    % 1. Setup Directories
    % =========================================================
    project_root = 'C:\Users\JNemune\Documents\Uni\BScProject';

    if ~isfolder(project_root)
        warning('Project root not found exactly as requested. Using pwd.');
        project_root = pwd;
    end

    src_dir = fullfile(project_root, '2_MATLAB_Simulations');
    out_dir = fullfile(project_root, '1_Thesis_Report', 'images', '2_LQR_Trajectory');

    if ~isfolder(out_dir), mkdir(out_dir); end

    fprintf('--- Starting LQR Combined Figure Generation ---\n');

    % =========================================================
    % 2. Extract Data Robustly (Only LQR Trajectory)
    % =========================================================
    data = struct();
    signals = {'x', 'theta', 'ref', 'F_ff', 'F_fb'};
    dists = {'05', '5'};

    success = 0; fail = 0; miss = 0;

    for d = 1:2
        dst_raw = dists{d};
        dst_fld = ['d_' dst_raw];

        for i = 1:length(signals)
            sig = signals{i};
            path = fullfile(src_dir, '2_LQR_Trajectory', sprintf('%s_%s.fig', sig, dst_raw));

            [extr, stat, msg] = extract_fig_data(path);

            if stat == 1

                if strcmp(sig, 'ref')
                    data.s_2_LQR_Trajectory.(dst_fld).(sig) = parse_references(extr);
                else
                    data.s_2_LQR_Trajectory.(dst_fld).(sig) = extr{1};
                end

                success = success + 1;
            elseif stat == 0
                miss = miss + 1;
                fprintf('MISSING: %s\n', path);
            else
                fail = fail + 1;
                fprintf('FAILED: %s | %s\n', path, msg);
            end

        end

    end

    fprintf('Data Extracted: %d OK | %d MISSING | %d FAILED\n\n', success, miss, fail);

    % =========================================================
    % 3. Generate The 2 Combined Figures
    % =========================================================
    try
        gen_lqr_combined_plots(data, out_dir);
        fprintf('\n--- Pipeline Finished Successfully ---\n');
    catch ME
        fprintf('\nERROR during generation:\n%s\n', ME.message);
    end

end

%% ========================================================================
%  FIGURE GENERATOR
%  ========================================================================

function gen_lqr_combined_plots(data, out)
    dists = {'05', '5'};
    suffixes = {'05', '5'};

    for i = 1:2
        d_fld = ['d_' dists{i}];

        if ~isfield(data, 's_2_LQR_Trajectory') || ~isfield(data.s_2_LQR_Trajectory, d_fld)
            continue;
        end

        D = data.s_2_LQR_Trajectory.(d_fld);
        Ref = D.ref;

        % Setup 3x1 Figure
        fig = setup_fig('3x1');
        tl = tiledlayout(fig, 3, 1, 'TileSpacing', 'compact');

        % --- Subplot 1: Position (x) ---
        ax1 = nexttile(tl); hold on;
        h1 = plot(Ref.x.x, Ref.x.y, 'k--', 'LineWidth', 1.8, 'DisplayName', '$x_{ref}$');
        h2 = plot(D.x.x, D.x.y, 'Color', hex2rgb('0072BD'), 'LineWidth', 1.8, 'DisplayName', '$x_{LQR}$');
        format_ax(ax1, '', 'Position $x$ (m)');
        create_leg([h1, h2]);

        % --- Subplot 2: Pendulum Angle (theta) ---
        ax2 = nexttile(tl); hold on;
        plot(D.theta.x, D.theta.y, 'Color', hex2rgb('0072BD'), 'LineWidth', 1.8);
        add_zero(ax2);
        add_lims(ax2, [-15 15] * pi / 180); % +/- 15 degree limits
        format_ax(ax2, '', 'Angle $\theta$ (rad)');
        % No legend needed for a single curve

        % --- Subplot 3: Forces (F_ff, F_fb, F_total) ---
        ax3 = nexttile(tl); hold on;
        [tc, ff, fb] = align_sigs(D.F_ff, D.F_fb);

        h3 = plot(D.F_ff.x, D.F_ff.y, 'Color', hex2rgb('0072BD'), 'LineWidth', 1.6, 'DisplayName', '$F_{ff}$');
        h4 = plot(D.F_fb.x, D.F_fb.y, 'Color', hex2rgb('A2142F'), 'LineWidth', 1.6, 'DisplayName', '$F_{fb}$');
        h5 = plot(tc, ff + fb, 'k', 'LineWidth', 2.0, 'DisplayName', '$F_{total}$');

        add_lims(ax3, [-2 2]); % +/- 2 N limits
        format_ax(ax3, 'Time (s)', 'Control force $F$ (N)');
        create_leg([h3, h4, h5]);

        % Save Output
        filename = sprintf('LQR_TRAJ_Combined_%s.pdf', suffixes{i});
        save_pdf(fig, fullfile(out, filename));
    end

end

%% ========================================================================
%  CORE HELPER FUNCTIONS
%  ========================================================================

function [extr, stat, msg] = extract_fig_data(path)
    extr = {}; stat = 0; msg = '';
    if ~isfile(path), return; end

    try
        fig = openfig(path, 'invisible');
        % Robust search avoiding 'Type', 'line' bugs
        objs = findall(fig, '-property', 'XData', '-and', '-property', 'YData');
        valid = {};

        for i = 1:length(objs)
            x = objs(i).XData; y = objs(i).YData;

            if isnumeric(x) && isnumeric(y) && length(x) > 1 && length(x) == length(y) && all(isfinite(x)) && all(isfinite(y))
                valid{end + 1} = struct('x', x(:), 'y', y(:));
            end

        end

        close(fig);

        if isempty(valid), stat = -1; msg = 'No numerical arrays found.';
        else , extr = valid; stat = 1; end
        catch ME
            stat = -1; msg = ME.message;
            if exist('fig', 'var') && isvalid(fig), close(fig); end
        end

    end

    function ref = parse_references(extr)
        % Robust identifier (avoiding trailing zeros bug)
        ref = struct(); nz = {}; zs = {};

        for i = 1:length(extr)
            if max(abs(extr{i}.y)) < 1e-4, zs{end + 1} = extr{i}; else, nz{end + 1} = extr{i}; end
        end

        if length(nz) >= 2

            if mean(abs(nz{1}.y)) > mean(abs(nz{2}.y)), ref.x = nz{1}; ref.xdot = nz{2};
            else , ref.x = nz{2}; ref.xdot = nz{1}; end
            else
                ref.x = extr{1}; ref.xdot = extr{1};
            end

            if length(zs) >= 2
                ref.theta = zs{1}; ref.thetadot = zs{2};
            else
                ref.theta = struct('x', ref.x.x, 'y', zeros(size(ref.x.x)));
                ref.thetadot = struct('x', ref.x.x, 'y', zeros(size(ref.x.x)));
            end

        end

        function [tc, y1, y2] = align_sigs(s1, s2)
            tmin = max(min(s1.x), min(s2.x)); tmax = min(max(s1.x), max(s2.x));
            idx = s1.x >= tmin & s1.x <= tmax; tc = s1.x(idx);
            [u2, i2] = unique(s2.x); y2_u = s2.y(i2);
            y1 = s1.y(idx); y2 = interp1(u2, y2_u, tc, 'linear');
        end

        function fig = setup_fig(type)
            fig = figure('Visible', 'off', 'Color', 'w');

            if strcmp(type, '3x1')
                pos = [100 100 800 850]; % Proportional for 3 stacked plots
            else
                pos = [100 100 800 450];
            end

            fig.Position = pos;
        end

        function format_ax(ax, xl, yl)
            set(ax, 'Color', 'w', 'XColor', 'k', 'YColor', 'k', 'FontSize', 11, 'TickLabelInterpreter', 'latex', 'Box', 'on'); grid(ax, 'on');
            if ~isempty(xl), xlabel(ax, xl, 'Interpreter', 'latex', 'FontSize', 13, 'Color', 'k'); end
            if ~isempty(yl), ylabel(ax, yl, 'Interpreter', 'latex', 'FontSize', 13, 'Color', 'k'); end
        end

        function add_zero(ax)
            hold(ax, 'on');
            plot(ax, xlim(ax), [0 0], ':', 'Color', [0.7 0.7 0.7], 'LineWidth', 1, 'HandleVisibility', 'off');
        end

        function add_lims(ax, lims)
            hold(ax, 'on'); xl = xlim(ax);

            for i = 1:length(lims)
                plot(ax, xl, [lims(i) lims(i)], '--', 'Color', [0.6 0.6 0.6], 'LineWidth', 1.2, 'HandleVisibility', 'off');
            end

        end

        function create_leg(hdls)

            if numel(hdls) > 1
                lgd = legend(hdls, 'Location', 'best', 'Interpreter', 'latex', 'FontSize', 11);
                lgd.Color = 'w';
                lgd.EdgeColor = 'k';
                lgd.TextColor = 'k'; % Fix for dark mode OS
            end

        end

        function save_pdf(fig, path)
            exportgraphics(fig, path, 'ContentType', 'vector', 'BackgroundColor', 'white');
            fprintf('  -> Generated: %s\n', path);
            close(fig);
        end

        function c = hex2rgb(hex)
            if startsWith(hex, '#'), hex = hex(2:end); end
            c = sscanf(hex, '%2x%2x%2x', [1 3]) / 255;
        end
