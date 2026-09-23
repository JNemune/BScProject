% generate_nmpc_traj_figures.m
% Targeted Figure Generation for NMPC Trajectory (Chapter 3)
% Generates exactly 5 publication-quality PDF figures with signal extension.

function generate_nmpc_traj_figures()
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
    out_dir = fullfile(project_root, '1_Thesis_Report', 'images', '4_NMPC_Trajectory');

    if ~isfolder(out_dir), mkdir(out_dir); end

    fprintf('--- Starting NMPC Trajectory Figure Generation ---\n');

    % =========================================================
    % 2. Extract Data Robustly
    % =========================================================
    data = struct();
    dists = {'05', '5'};

    % Signals to extract for NMPC
    nmpc_sigs = {'x', 'theta', 'l', 'F', 'l_ddot'};

    success = 0; fail = 0; miss = 0;

    for d = 1:2
        dst_raw = dists{d};
        dst_fld = ['d_' dst_raw];

        % A. Extract Reference from LQR folder (Common Ref)
        ref_path = fullfile(src_dir, '2_LQR_Trajectory', sprintf('ref_%s.fig', dst_raw));
        [extr_ref, stat_ref, msg_ref] = extract_fig_data(ref_path);

        if stat_ref == 1
            data.ref.(dst_fld) = parse_references(extr_ref);
            success = success + 1;
        else
            miss = miss + (stat_ref == 0); fail = fail + (stat_ref == -1);
            fprintf('REF ERROR: %s | %s\n', ref_path, msg_ref);
        end

        % B. Extract NMPC Signals
        for i = 1:length(nmpc_sigs)
            sig = nmpc_sigs{i};
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
    % 3. Generate The 5 Figures
    % =========================================================
    try
        gen_nmpc_traj_plots(data, out_dir);
        fprintf('\n--- Pipeline Finished Successfully ---\n');
    catch ME
        fprintf('\nERROR during generation:\n%s\n', ME.message);
    end

end

%% ========================================================================
%  FIGURE GENERATOR
%  ========================================================================

function gen_nmpc_traj_plots(data, out)
    dists = {'05', '5'};
    suffixes = {'', '_5'}; % For 0.5m use no suffix, for 5m use '_5'

    % Colors based on thesis style
    c_nmpc = hex2rgb('D95319'); % Orange
    c_theta = hex2rgb('7E2F8E'); % Purple
    c_l = hex2rgb('77AC30'); % Green

    for i = 1:2
        d_fld = ['d_' dists{i}];

        if ~isfield(data.nmpc, d_fld) || ~isfield(data.ref, d_fld)
            continue;
        end

        D = data.nmpc.(d_fld);
        Ref = data.ref.(d_fld);
        sfx = suffixes{i};

        % --- EXTEND NMPC SIGNALS TO MATCH REFERENCE TIME (e.g., up to 12s) ---
        t_end_ref = max(Ref.x.x);
        D.x = extend_signal(D.x, t_end_ref);
        D.theta = extend_signal(D.theta, t_end_ref);
        D.l = extend_signal(D.l, t_end_ref);
        D.F = extend_signal(D.F, t_end_ref);
        D.l_ddot = extend_signal(D.l_ddot, t_end_ref);

        % ---------------------------------------------------------
        % FIGURE 1 & 3: MPC_TRAJ_x_theta_l.pdf / MPC_TRAJ_x_theta_l_5.pdf
        % ---------------------------------------------------------
        fig1 = setup_fig('3x1');
        tl1 = tiledlayout(fig1, 3, 1, 'TileSpacing', 'compact');

        % Subplot 1: Position (x)
        ax1 = nexttile(tl1); hold on;
        h1 = plot(Ref.x.x, Ref.x.y, 'k--', 'LineWidth', 1.8, 'DisplayName', '$x_{ref}$');
        h2 = plot(D.x.x, D.x.y, 'Color', c_nmpc, 'LineWidth', 1.8, 'DisplayName', '$x_{NMPC}$');
        format_ax(ax1, '', 'Position $x$ (m)');
        create_leg([h1, h2]);

        % Subplot 2: Angle (theta)
        ax2 = nexttile(tl1); hold on;
        plot(D.theta.x, D.theta.y, 'Color', c_theta, 'LineWidth', 1.8);
        add_zero(ax2); add_lims(ax2, [-15 15] * pi / 180);
        format_ax(ax2, '', 'Angle $\theta$ (rad)');

        % Subplot 3: Cable length (l)
        ax3 = nexttile(tl1); hold on;
        plot(D.l.x, D.l.y, 'Color', c_l, 'LineWidth', 1.8);
        add_lims(ax3, [0.1 1.5]);
        format_ax(ax3, 'Time (s)', 'Cable $l$ (m)');

        save_pdf(fig1, fullfile(out, sprintf('MPC_TRAJ_x_theta_l%s.pdf', sfx)));

        % ---------------------------------------------------------
        % FIGURE 2 & 4: MPC_TRAJ_f_l_ddot.pdf / MPC_TRAJ_f_l_ddot_5.pdf
        % ---------------------------------------------------------
        fig2 = setup_fig('2x1');
        tl2 = tiledlayout(fig2, 2, 1, 'TileSpacing', 'compact');

        % Subplot 1: Force (F)
        ax4 = nexttile(tl2); hold on;
        plot(D.F.x, D.F.y, 'Color', c_nmpc, 'LineWidth', 1.8);
        add_lims(ax4, [-50 50]); % Corrected force limit to +/- 50 N
        format_ax(ax4, '', 'Force $F$ (N)');

        % Subplot 2: Winch Acceleration (l_ddot)
        ax5 = nexttile(tl2); hold on;
        plot(D.l_ddot.x, D.l_ddot.y, 'Color', c_l, 'LineWidth', 1.8);
        add_lims(ax5, [-5 5]);
        format_ax(ax5, 'Time (s)', 'Winch $\ddot{l}$ (m/s$^2$)');

        save_pdf(fig2, fullfile(out, sprintf('MPC_TRAJ_f_l_ddot%s.pdf', sfx)));

        % ---------------------------------------------------------
        % FIGURE 5: NMPC_TRAJ_StateTracking_5.pdf (Only for 5m)
        % ---------------------------------------------------------
        if strcmp(dists{i}, '5')
            fig3 = setup_fig('4x1');
            tl3 = tiledlayout(fig3, 4, 1, 'TileSpacing', 'compact');

            % 1. x tracking
            ax6 = nexttile(tl3); hold on;
            hx1 = plot(Ref.x.x, Ref.x.y, 'k--', 'LineWidth', 1.6, 'DisplayName', '$x_{ref}$');
            hx2 = plot(D.x.x, D.x.y, 'Color', c_nmpc, 'LineWidth', 1.6, 'DisplayName', '$x_{NMPC}$');
            format_ax(ax6, '', '$x$ (m)'); create_leg([hx1, hx2]);

            % 2. xdot tracking (numerical derivative)
            ax7 = nexttile(tl3); hold on;
            xdot = gradient(D.x.y, D.x.x);
            hxd1 = plot(Ref.xdot.x, Ref.xdot.y, 'k--', 'LineWidth', 1.6, 'DisplayName', '$\dot{x}_{ref}$');
            hxd2 = plot(D.x.x, xdot, 'Color', c_nmpc, 'LineWidth', 1.6, 'DisplayName', '$\dot{x}_{NMPC}$');
            format_ax(ax7, '', '$\dot{x}$ (m/s)'); create_leg([hxd1, hxd2]);

            % 3. theta tracking
            ax8 = nexttile(tl3); hold on;
            hth1 = plot(Ref.theta.x, Ref.theta.y, 'k--', 'LineWidth', 1.6, 'DisplayName', '$\theta_{ref}$');
            hth2 = plot(D.theta.x, D.theta.y, 'Color', c_nmpc, 'LineWidth', 1.6, 'DisplayName', '$\theta_{NMPC}$');
            format_ax(ax8, '', '$\theta$ (rad)'); create_leg([hth1, hth2]);

            % 4. thetadot tracking (numerical derivative)
            ax9 = nexttile(tl3); hold on;
            thdot = gradient(D.theta.y, D.theta.x);
            hthd1 = plot(Ref.thetadot.x, Ref.thetadot.y, 'k--', 'LineWidth', 1.6, 'DisplayName', '$\dot{\theta}_{ref}$');
            hthd2 = plot(D.theta.x, thdot, 'Color', c_nmpc, 'LineWidth', 1.6, 'DisplayName', '$\dot{\theta}_{NMPC}$');
            format_ax(ax9, 'Time (s)', '$\dot{\theta}$ (rad/s)'); create_leg([hthd1, hthd2]);

            save_pdf(fig3, fullfile(out, 'NMPC_TRAJ_StateTracking_5.pdf'));
        end

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

        function fig = setup_fig(type)
            fig = figure('Visible', 'off', 'Color', 'w');

            if strcmp(type, '4x1')
                pos = [100 100 800 1000];
            elseif strcmp(type, '3x1')
                pos = [100 100 800 850];
            else
                pos = [100 100 800 650]; % 2x1
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
