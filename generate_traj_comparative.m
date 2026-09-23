% generate_traj_comparative.m
% Comparative Figure Generation for LQR Trajectory vs NMPC Trajectory
% Generates 6 specific publication-quality PDF figures with signal extension.

function generate_traj_comparative()
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
    out_dir = fullfile(project_root, '1_Thesis_Report', 'images', 'Comparative');

    if ~isfolder(out_dir), mkdir(out_dir); end

    fprintf('--- Starting Trajectory Comparative Generation ---\n');

    % =========================================================
    % 2. Extract Data Robustly
    % =========================================================
    data = struct();
    dists = {'05', '5'};

    % Signals for LQR Trajectory
    sigs_lqr = {'x', 'theta', 'ref', 'F_ff', 'F_fb', 'fw1', 'fw2'};
    % Signals for NMPC Trajectory
    sigs_nmpc = {'x', 'theta', 'F', 'fw1', 'fw2'};

    success = 0; fail = 0; miss = 0;

    for d = 1:2
        dst_raw = dists{d};
        dst_fld = ['d_' dst_raw];

        % Extract LQR Trajectory
        for i = 1:length(sigs_lqr)
            sig = sigs_lqr{i};
            path = fullfile(src_dir, '2_LQR_Trajectory', sprintf('%s_%s.fig', sig, dst_raw));
            [extr, stat, msg] = extract_fig_data(path);

            if stat == 1

                if strcmp(sig, 'ref'), data.lqr.(dst_fld).(sig) = parse_references(extr);
                else , data.lqr.(dst_fld).(sig) = extr{1}; end
                    success = success + 1;
                elseif stat == 0
                    miss = miss + 1; fprintf('MISSING: %s\n', path);
                else
                    fail = fail + 1; fprintf('FAILED: %s | %s\n', path, msg);
                end

            end

            % Extract NMPC Trajectory
            for i = 1:length(sigs_nmpc)
                sig = sigs_nmpc{i};
                path = fullfile(src_dir, '4_NMPC_Trajectory', sprintf('%s_%s.fig', sig, dst_raw));
                [extr, stat, msg] = extract_fig_data(path);

                if stat == 1
                    data.nmpc.(dst_fld).(sig) = extr{1};
                    success = success + 1;
                elseif stat == 0
                    miss = miss + 1; fprintf('MISSING: %s\n', path);
                else
                    fail = fail + 1; fprintf('FAILED: %s | %s\n', path, msg);
                end

            end

        end

        fprintf('Data Extracted: %d OK | %d MISSING | %d FAILED\n\n', success, miss, fail);

        % =========================================================
        % 3. Generate The 6 Comparative Figures
        % =========================================================
        try
            gen_comparative_plots(data, out_dir);
            fprintf('\n--- Pipeline Finished Successfully ---\n');
        catch ME
            fprintf('\nERROR during generation:\n%s\n', ME.message);
        end

    end

    %% ========================================================================
    %  FIGURE GENERATOR
    %  ========================================================================

    function gen_comparative_plots(data, out)
        dists = {'05', '5'};
        suffixes = {'05', '5'};

        % Consistent controller colors
        c_lqr = hex2rgb('0072BD'); % Blue
        c_nmpc = hex2rgb('D95319'); % Orange

        for i = 1:2
            d_fld = ['d_' dists{i}];
            sfx = suffixes{i};

            if ~isfield(data.lqr, d_fld) || ~isfield(data.nmpc, d_fld)
                continue;
            end

            LQR = data.lqr.(d_fld);
            NMPC = data.nmpc.(d_fld);
            Ref = LQR.ref; % Reference is common

            % --- EXTEND NMPC SIGNALS TO MATCH LQR TIME (e.g., up to 12s) ---
            t_end_lqr = max(LQR.x.x);
            NMPC.x = extend_signal(NMPC.x, t_end_lqr);
            NMPC.theta = extend_signal(NMPC.theta, t_end_lqr);
            NMPC.F = extend_signal(NMPC.F, t_end_lqr);
            NMPC.fw1 = extend_signal(NMPC.fw1, t_end_lqr);
            NMPC.fw2 = extend_signal(NMPC.fw2, t_end_lqr);

            % ---------------------------------------------------------
            % 1. States (x and theta tracking comparison)
            % ---------------------------------------------------------
            fig1 = setup_fig('2x1');
            tl1 = tiledlayout(fig1, 2, 1, 'TileSpacing', 'compact');

            ax1 = nexttile(tl1); hold on;
            h1 = plot(Ref.x.x, Ref.x.y, 'k--', 'LineWidth', 1.8, 'DisplayName', '$x_{ref}$');
            h2 = plot(LQR.x.x, LQR.x.y, 'Color', c_lqr, 'LineWidth', 1.8, 'DisplayName', '$x_{LQR}$');
            h3 = plot(NMPC.x.x, NMPC.x.y, 'Color', c_nmpc, 'LineWidth', 1.8, 'DisplayName', '$x_{NMPC}$');
            format_ax(ax1, '', 'Position $x$ (m)');
            create_leg([h1, h2, h3]);

            ax2 = nexttile(tl1); hold on;
            h4 = plot(LQR.theta.x, LQR.theta.y, 'Color', c_lqr, 'LineWidth', 1.8, 'DisplayName', '$\theta_{LQR}$');
            h5 = plot(NMPC.theta.x, NMPC.theta.y, 'Color', c_nmpc, 'LineWidth', 1.8, 'DisplayName', '$\theta_{NMPC}$');
            add_zero(ax2); add_lims(ax2, [-15 15] * pi / 180);
            format_ax(ax2, 'Time (s)', 'Angle $\theta$ (rad)');
            create_leg([h4, h5]);

            save_pdf(fig1, fullfile(out, sprintf('Traj_Comparison_States_%s_xtrack.pdf', sfx)));

            % ---------------------------------------------------------
            % 2. Force Comparison (F_LQR_total vs F_NMPC)
            % ---------------------------------------------------------
            fig2 = setup_fig('single'); ax3 = axes(fig2); hold on;

            % Calculate Total LQR Force (F_ff + F_fb)
            [tc, ff, fb] = align_sigs(LQR.F_ff, LQR.F_fb);
            F_total_LQR = ff + fb;

            h6 = plot(tc, F_total_LQR, 'Color', c_lqr, 'LineWidth', 1.8, 'DisplayName', '$F_{LQR}$');
            h7 = plot(NMPC.F.x, NMPC.F.y, 'Color', c_nmpc, 'LineWidth', 1.8, 'DisplayName', '$F_{NMPC}$');

            add_lims(ax3, [-5 5]);
            format_ax(ax3, 'Time (s)', 'Control force $F$ (N)');
            create_leg([h6, h7]);

            save_pdf(fig2, fullfile(out, sprintf('Traj_Comparison_Force_%s.pdf', sfx)));

            % ---------------------------------------------------------
            % 3. Wheel Load Comparison (fw1 and fw2)
            % ---------------------------------------------------------
            fig3 = setup_fig('2x1');
            tl2 = tiledlayout(fig3, 2, 1, 'TileSpacing', 'compact');

            % Front Wheel (fw1)
            ax4 = nexttile(tl2); hold on;
            h8 = plot(LQR.fw1.x, LQR.fw1.y, 'Color', c_lqr, 'LineWidth', 1.6, 'DisplayName', '$F_{w1,LQR}$');
            h9 = plot(NMPC.fw1.x, NMPC.fw1.y, 'Color', c_nmpc, 'LineWidth', 1.6, 'DisplayName', '$F_{w1,NMPC}$');
            format_ax(ax4, '', 'Front Wheel $F_{w1}$ (N)');
            create_leg([h8, h9]);

            % Rear Wheel (fw2)
            ax5 = nexttile(tl2); hold on;
            h10 = plot(LQR.fw2.x, LQR.fw2.y, 'Color', c_lqr, 'LineWidth', 1.6, 'DisplayName', '$F_{w2,LQR}$');
            h11 = plot(NMPC.fw2.x, NMPC.fw2.y, 'Color', c_nmpc, 'LineWidth', 1.6, 'DisplayName', '$F_{w2,NMPC}$');
            format_ax(ax5, 'Time (s)', 'Rear Wheel $F_{w2}$ (N)');
            create_leg([h10, h11]);

            save_pdf(fig3, fullfile(out, sprintf('Traj_Comparison_Wheels_%s.pdf', sfx)));
        end

    end

    %% ========================================================================
    %  CORE HELPER FUNCTIONS
    %  ========================================================================

    function sig_out = extend_signal(sig, t_end)
        % Extends the signal by holding its final value up to t_end
        sig_out = sig;

        if ~isempty(sig) && ~isempty(sig.x)

            if max(sig.x) < t_end
                sig_out.x = [sig.x(:); t_end];
                sig_out.y = [sig.y(:); sig.y(end)];
            end

        end

    end

    function [extr, stat, msg] = extract_fig_data(path)
        extr = {}; stat = 0; msg = '';
        if ~isfile(path), return; end

        try
            fig = openfig(path, 'invisible');
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

                if strcmp(type, '2x1')
                    pos = [100 100 800 650];
                else
                    pos = [100 100 800 450]; % single
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
                    lgd.TextColor = 'k';
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
