% generate_chapter3_figures.m
% Complete Chapter 3 Figure Generation Pipeline for Overhead Crane Control
% Target: publication-quality vector PDFs with LaTeX typography

function generate_chapter3_figures()
    clc; close all; warning('off', 'MATLAB:hg:AutoSoftwareOpenGL');

    % 1. Setup Directories
    project_root = 'C:\Users\JNemune\Documents\Uni\BScProject';

    if ~isfolder(project_root)
        warning('Project root not found exactly as requested. Using current directory.');
        project_root = pwd;
    end

    src_dir = fullfile(project_root, '2_MATLAB_Simulations');
    out_dir = fullfile(project_root, '1_Thesis_Report', 'images');

    % Ensure output directories exist
    subdirs = {'1_LQR_Step', '2_LQR_Trajectory', '3_NMPC_Basic', '4_NMPC_Trajectory', 'Comparative'};

    for i = 1:length(subdirs)
        d = fullfile(out_dir, subdirs{i});
        if ~isfolder(d), mkdir(d); end
    end

    fprintf('Starting Figure Generation Pipeline...\n');
    fprintf('Source: %s\n', src_dir);
    fprintf('Output: %s\n\n', out_dir);

    % 2. Extract Data Robustly
    data = struct();
    scenarios = {'1_LQR_Step', '2_LQR_Trajectory', '3_NMPC_Basic', '4_NMPC_Trajectory'};
    dists = {'05', '5'};

    % Define expected signals for each scenario (using valid struct field names starting with 's_')
    signals.s_1_LQR_Step = {'fw1', 'fw2', 'F', 'theta', 'x'};
    signals.s_2_LQR_Trajectory = {'fw1', 'fw2', 'F_fb', 'F_ff', 'ref', 'theta', 'x'};
    signals.s_3_NMPC_Basic = {'fw1', 'fw2', 'F', 'l', 'l_ddot', 'theta', 'x'};
    signals.s_4_NMPC_Trajectory = {'fw1', 'fw2', 'F', 'l', 'l_ddot', 'theta', 'x'};

    fail_count = 0; missing_count = 0; success_count = 0;

    for s = 1:length(scenarios)
        scen = scenarios{s};
        scen_field = ['s_' scen]; % Valid struct field name (e.g., s_1_LQR_Step)
        sigs = signals.(scen_field);

        for d = 1:length(dists)
            dst = dists{d};
            dst_field = ['d_' dst]; % Valid struct field name (e.g., d_05 or d_5)

            for i = 1:length(sigs)
                sig = sigs{i};
                % Read from actual folder name, not the struct field name
                filepath = fullfile(src_dir, scen, sprintf('%s_%s.fig', sig, dst));
                [extracted, status, msg] = extract_fig_data(filepath);

                % Store data in the valid struct field
                if strcmp(sig, 'ref') && status == 1
                    data.(scen_field).(dst_field).(sig) = parse_reference_signals(extracted);
                elseif status == 1
                    data.(scen_field).(dst_field).(sig) = extracted{1}; % Take primary series
                end

                if status == 1
                    success_count = success_count + 1;
                elseif status == 0
                    missing_count = missing_count + 1;
                    fprintf('MISSING: %s\n', filepath);
                else
                    fail_count = fail_count + 1;
                    fprintf('FAILED TO READ DATA: %s\n%s\n', filepath, msg);
                end

            end

        end

    end

    fprintf('\nData Extraction Complete: %d Success, %d Missing, %d Failed.\n\n', success_count, missing_count, fail_count);

    % 3. Generate Figures
    try generate_lqr_step(data, out_dir); catch ME, fprintf('Error in LQR Step: %s\n', ME.message); end
    try generate_lqr_traj(data, out_dir); catch ME, fprintf('Error in LQR Traj: %s\n', ME.message); end
    try generate_nmpc_basic(data, out_dir); catch ME, fprintf('Error in NMPC Basic: %s\n', ME.message); end
    try generate_nmpc_traj(data, out_dir); catch ME, fprintf('Error in NMPC Traj: %s\n', ME.message); end
    try generate_comparative(data, out_dir); catch ME, fprintf('Error in Comparative: %s\n', ME.message); end
    try generate_metrics(data, out_dir); catch ME, fprintf('Error in Metrics: %s\n', ME.message); end

    fprintf('\nPipeline Finished.\n');
end

%% ========================================================================
%  SCENARIO GENERATORS
%  ========================================================================

function generate_lqr_step(data, out)
    dir_out = fullfile(out, '1_LQR_Step');
    dists = {'05', '5'};
    sfx = {'', '_5'};

    for i = 1:2
        d = dists{i};
        d_field = ['d_' d];
        if ~isfield(data, 's_1_LQR_Step') || ~isfield(data.s_1_LQR_Step, d_field), continue; end
        D = data.s_1_LQR_Step.(d_field);

        % 10.1: x and theta
        fig = setup_figure('2x1'); tl = tiledlayout(fig, 2, 1, 'TileSpacing', 'compact');
        % x
        ax1 = nexttile(tl);
        plot(D.x.x, D.x.y, 'Color', hex2rgb('0072BD'), 'LineWidth', 1.8);
        add_zero_line(ax1); format_axes(ax1, 'Time (s)', 'Cart position $x$ (m)');
        % theta
        ax2 = nexttile(tl);
        plot(D.theta.x, D.theta.y, 'Color', hex2rgb('7E2F8E'), 'LineWidth', 1.8);
        add_zero_line(ax2); add_limits(ax2, [-15 15] * pi / 180);
        format_axes(ax2, 'Time (s)', 'Pendulum angle $\theta$ (rad)');
        save_pdf(fig, fullfile(dir_out, sprintf('LQR_x_theta%s.pdf', sfx{i})));

        % 10.2: F
        fig = setup_figure('single'); ax = axes(fig);
        plot(D.F.x, D.F.y, 'Color', hex2rgb('0072BD'), 'LineWidth', 1.8);
        add_limits(ax, [-50 50]); format_axes(ax, 'Time (s)', 'Control force $F$ (N)');
        save_pdf(fig, fullfile(dir_out, sprintf('LQR_F%s.pdf', sfx{i})));

        % 10.3: Wheels
        fig = setup_figure('2x1'); tl = tiledlayout(fig, 2, 1, 'TileSpacing', 'compact');
        ax1 = nexttile(tl); hold on;
        h1 = plot(D.fw1.x, D.fw1.y, 'Color', hex2rgb('0072BD'), 'LineWidth', 1.6, 'DisplayName', '$F_{w1}$');
        h2 = plot(D.fw2.x, D.fw2.y, 'Color', hex2rgb('EDB120'), 'LineWidth', 1.6, 'DisplayName', '$F_{w2}$');
        format_axes(ax1, 'Time (s)', 'Wheel load (N)'); create_legend([h1, h2]);

        ax2 = nexttile(tl); hold on;
        [tc, fw1_c, fw2_c] = align_signals(D.fw1, D.fw2);
        h3 = plot(tc, fw1_c + fw2_c, 'k', 'LineWidth', 1.6, 'DisplayName', '$F_{sum}$');
        h4 = plot(tc, fw1_c - fw2_c, 'Color', [0.5 0.5 0.5], 'LineWidth', 1.6, 'DisplayName', '$\Delta F$');
        add_limits(ax2, 11.772, 'static load'); format_axes(ax2, 'Time (s)', 'Load Analysis (N)'); create_legend([h3, h4]);
        save_pdf(fig, fullfile(dir_out, sprintf('LQR_Wheels%s.pdf', sfx{i})));

        % Additional: Analytical & Phase
        fig = setup_figure('single'); ax = axes(fig);
        [tc, theta_c] = align_signals(D.theta, D.theta);
        theta_dot = gradient(theta_c, tc);
        plot(theta_c, theta_dot, 'Color', hex2rgb('7E2F8E'), 'LineWidth', 1.6); hold on;
        plot(theta_c(1), theta_dot(1), 'go', 'MarkerFaceColor', 'g', 'HandleVisibility', 'off');
        plot(theta_c(end), theta_dot(end), 'ro', 'MarkerFaceColor', 'r', 'HandleVisibility', 'off');
        format_axes(ax, 'Pendulum angle $\theta$ (rad)', 'Angular velocity $\dot{\theta}$ (rad/s)');
        save_pdf(fig, fullfile(dir_out, sprintf('LQR_Step_Phase_%s.pdf', d)));
    end

end

function generate_lqr_traj(data, out)
    dir_out = fullfile(out, '2_LQR_Trajectory');
    dists = {'05', '5'}; sfx = {'', '_5'};

    for i = 1:2
        d = dists{i};
        d_field = ['d_' d];
        if ~isfield(data, 's_2_LQR_Trajectory') || ~isfield(data.s_2_LQR_Trajectory, d_field), continue; end
        D = data.s_2_LQR_Trajectory.(d_field);

        % 11.1: ref
        fig = setup_figure('4x1'); tl = tiledlayout(fig, 4, 1, 'TileSpacing', 'compact');
        ax1 = nexttile(tl); plot(D.ref.x.x, D.ref.x.y, 'k--', 'LineWidth', 1.6); format_axes(ax1, '', '$x_{ref}$ (m)');
        ax2 = nexttile(tl); plot(D.ref.xdot.x, D.ref.xdot.y, 'k--', 'LineWidth', 1.6); format_axes(ax2, '', '$\dot{x}_{ref}$ (m/s)');
        ax3 = nexttile(tl); plot(D.ref.theta.x, D.ref.theta.y, 'k--', 'LineWidth', 1.6); format_axes(ax3, '', '$\theta_{ref}$ (rad)');
        ax4 = nexttile(tl); plot(D.ref.thetadot.x, D.ref.thetadot.y, 'k--', 'LineWidth', 1.6); format_axes(ax4, 'Time (s)', '$\dot{\theta}_{ref}$ (rad/s)');
        save_pdf(fig, fullfile(dir_out, sprintf('LQR_TRAJ_ref%s.pdf', sfx{i})));

        % 11.2: x
        fig = setup_figure('single'); ax = axes(fig); hold on;
        h1 = plot(D.ref.x.x, D.ref.x.y, 'k--', 'LineWidth', 1.8, 'DisplayName', '$x_{ref}$');
        h2 = plot(D.x.x, D.x.y, 'Color', hex2rgb('0072BD'), 'LineWidth', 1.8, 'DisplayName', '$x_{LQR}$');
        format_axes(ax, 'Time (s)', 'Cart position $x$ (m)'); create_legend([h1, h2]);
        save_pdf(fig, fullfile(dir_out, sprintf('LQR_TRAJ_x%s.pdf', sfx{i})));

        % 11.3: theta
        fig = setup_figure('single'); ax = axes(fig); hold on;
        plot(D.theta.x, D.theta.y, 'Color', hex2rgb('7E2F8E'), 'LineWidth', 1.8);
        add_zero_line(ax); add_limits(ax, [-15 15] * pi / 180);
        format_axes(ax, 'Time (s)', 'Pendulum angle $\theta$ (rad)');
        save_pdf(fig, fullfile(dir_out, sprintf('LQR_TRAJ_theta%s.pdf', sfx{i})));

        % 11.4: Fs
        fig = setup_figure('single'); ax = axes(fig); hold on;
        [tc, ff, fb] = align_signals(D.F_ff, D.F_fb);
        h1 = plot(D.F_ff.x, D.F_ff.y, 'Color', hex2rgb('0072BD'), 'LineWidth', 1.6, 'DisplayName', '$F_{ff}$');
        h2 = plot(D.F_fb.x, D.F_fb.y, 'Color', hex2rgb('A2142F'), 'LineWidth', 1.6, 'DisplayName', '$F_{fb}$');
        h3 = plot(tc, ff + fb, 'k', 'LineWidth', 2.0, 'DisplayName', '$F_{total}$');
        add_limits(ax, [-50 50]); format_axes(ax, 'Time (s)', 'Control force $F$ (N)'); create_legend([h1, h2, h3]);
        save_pdf(fig, fullfile(dir_out, sprintf('LQR_TRAJ_Fs%s.pdf', sfx{i})));

        % 11.5: Wheels
        fig = setup_figure('2x1'); tl = tiledlayout(fig, 2, 1, 'TileSpacing', 'compact');
        ax1 = nexttile(tl); hold on;
        h1 = plot(D.fw1.x, D.fw1.y, 'Color', hex2rgb('0072BD'), 'LineWidth', 1.6, 'DisplayName', '$F_{w1}$');
        h2 = plot(D.fw2.x, D.fw2.y, 'Color', hex2rgb('EDB120'), 'LineWidth', 1.6, 'DisplayName', '$F_{w2}$');
        format_axes(ax1, 'Time (s)', 'Wheel load (N)'); create_legend([h1, h2]);
        ax2 = nexttile(tl); hold on;
        [tc, fw1_c, fw2_c] = align_signals(D.fw1, D.fw2);
        h3 = plot(tc, fw1_c + fw2_c, 'k', 'LineWidth', 1.6, 'DisplayName', '$F_{sum}$');
        h4 = plot(tc, fw1_c - fw2_c, 'Color', [0.5 0.5 0.5], 'LineWidth', 1.6, 'DisplayName', '$\Delta F$');
        add_limits(ax2, 11.772, 'static load'); format_axes(ax2, 'Time (s)', 'Load Analysis (N)'); create_legend([h3, h4]);
        save_pdf(fig, fullfile(dir_out, sprintf('LQR_TRAJ_Wheels%s.pdf', sfx{i})));

        % Additional: Errors
        fig = setup_figure('4x1'); tl = tiledlayout(fig, 4, 1, 'TileSpacing', 'compact');
        [tc, x_ref, x_act] = align_signals(D.ref.x, D.x); ax1 = nexttile(tl); plot(tc, x_act - x_ref, 'k', 'LineWidth', 1.6); format_axes(ax1, '', '$e_x$ (m)'); add_zero_line(ax1);
        [tc, th_ref, th_act] = align_signals(D.ref.theta, D.theta); ax3 = nexttile(tl); plot(tc, th_act - th_ref, 'k', 'LineWidth', 1.6); format_axes(ax3, 'Time (s)', '$e_\theta$ (rad)'); add_zero_line(ax3);
        save_pdf(fig, fullfile(dir_out, sprintf('LQR_TRAJ_TrackingErrors_%s.pdf', d)));
    end

end

function generate_nmpc_basic(data, out)
    dir_out = fullfile(out, '3_NMPC_Basic'); dists = {'05', '5'}; sfx = {'', '_5'};

    for i = 1:2
        d = dists{i};
        d_field = ['d_' d];
        if ~isfield(data, 's_3_NMPC_Basic') || ~isfield(data.s_3_NMPC_Basic, d_field), continue; end
        D = data.s_3_NMPC_Basic.(d_field);

        % 13.1: x, theta, l
        fig = setup_figure('3x1'); tl = tiledlayout(fig, 3, 1, 'TileSpacing', 'compact');
        ax1 = nexttile(tl); plot(D.x.x, D.x.y, 'Color', hex2rgb('D95319'), 'LineWidth', 1.8); format_axes(ax1, '', 'Position $x$ (m)'); add_zero_line(ax1);
        ax2 = nexttile(tl); plot(D.theta.x, D.theta.y, 'Color', hex2rgb('7E2F8E'), 'LineWidth', 1.8); add_limits(ax2, [-15 15] * pi / 180); add_zero_line(ax2); format_axes(ax2, '', 'Angle $\theta$ (rad)');
        ax3 = nexttile(tl); plot(D.l.x, D.l.y, 'Color', hex2rgb('77AC30'), 'LineWidth', 1.8); add_limits(ax3, [0.1 1.5]); format_axes(ax3, 'Time (s)', 'Cable $l$ (m)');
        save_pdf(fig, fullfile(dir_out, sprintf('Simulation_Results_x_theta_l%s.pdf', sfx{i})));

        % 13.2: F, l_ddot
        fig = setup_figure('2x1'); tl = tiledlayout(fig, 2, 1, 'TileSpacing', 'compact');
        ax1 = nexttile(tl); plot(D.F.x, D.F.y, 'Color', hex2rgb('D95319'), 'LineWidth', 1.8); add_limits(ax1, [-50 50]); format_axes(ax1, '', 'Force $F$ (N)');
        ax2 = nexttile(tl); plot(D.l_ddot.x, D.l_ddot.y, 'Color', hex2rgb('77AC30'), 'LineWidth', 1.8); add_limits(ax2, [-5 5]); format_axes(ax2, 'Time (s)', 'Winch $\ddot{l}$ (m/s$^2$)');
        save_pdf(fig, fullfile(dir_out, sprintf('plant_input_F_l_ddot%s.pdf', sfx{i})));

        % 13.3: Wheels
        fig = setup_figure('2x1'); tl = tiledlayout(fig, 2, 1, 'TileSpacing', 'compact');
        ax1 = nexttile(tl); hold on;
        h1 = plot(D.fw1.x, D.fw1.y, 'Color', hex2rgb('0072BD'), 'LineWidth', 1.6, 'DisplayName', '$F_{w1}$');
        h2 = plot(D.fw2.x, D.fw2.y, 'Color', hex2rgb('EDB120'), 'LineWidth', 1.6, 'DisplayName', '$F_{w2}$');
        format_axes(ax1, 'Time (s)', 'Wheel load (N)'); create_legend([h1, h2]);
        ax2 = nexttile(tl); hold on;
        [tc, fw1_c, fw2_c] = align_signals(D.fw1, D.fw2);
        h3 = plot(tc, fw1_c + fw2_c, 'k', 'LineWidth', 1.6, 'DisplayName', '$F_{sum}$');
        h4 = plot(tc, fw1_c - fw2_c, 'Color', [0.5 0.5 0.5], 'LineWidth', 1.6, 'DisplayName', '$\Delta F$');
        add_limits(ax2, 11.772, 'static load'); format_axes(ax2, 'Time (s)', 'Load Analysis (N)'); create_legend([h3, h4]);
        save_pdf(fig, fullfile(dir_out, sprintf('NMPC_Basic_Wheels%s.pdf', sfx{i})));
    end

end

function generate_nmpc_traj(data, out)
    dir_out = fullfile(out, '4_NMPC_Trajectory'); dists = {'05', '5'}; sfx = {'', '_5'};

    for i = 1:2
        d = dists{i};
        d_field = ['d_' d];
        if ~isfield(data, 's_4_NMPC_Trajectory') || ~isfield(data.s_4_NMPC_Trajectory, d_field), continue; end
        D = data.s_4_NMPC_Trajectory.(d_field);
        D_ref = data.s_2_LQR_Trajectory.(d_field).ref; % Common ref

        % 15.1: x, theta, l
        fig = setup_figure('3x1'); tl = tiledlayout(fig, 3, 1, 'TileSpacing', 'compact');
        ax1 = nexttile(tl); hold on;
        h1 = plot(D_ref.x.x, D_ref.x.y, 'k--', 'LineWidth', 1.8, 'DisplayName', '$x_{ref}$');
        h2 = plot(D.x.x, D.x.y, 'Color', hex2rgb('D95319'), 'LineWidth', 1.8, 'DisplayName', '$x_{NMPC}$');
        format_axes(ax1, '', 'Position $x$ (m)'); create_legend([h1, h2]);

        ax2 = nexttile(tl); plot(D.theta.x, D.theta.y, 'Color', hex2rgb('7E2F8E'), 'LineWidth', 1.8); add_limits(ax2, [-15 15] * pi / 180); add_zero_line(ax2); format_axes(ax2, '', 'Angle $\theta$ (rad)');
        ax3 = nexttile(tl); plot(D.l.x, D.l.y, 'Color', hex2rgb('77AC30'), 'LineWidth', 1.8); add_limits(ax3, [0.1 1.5]); format_axes(ax3, 'Time (s)', 'Cable $l$ (m)');
        save_pdf(fig, fullfile(dir_out, sprintf('MPC_TRAJ_x_theta_l%s.pdf', sfx{i})));

        % 15.2: F, l_ddot
        fig = setup_figure('2x1'); tl = tiledlayout(fig, 2, 1, 'TileSpacing', 'compact');
        ax1 = nexttile(tl); plot(D.F.x, D.F.y, 'Color', hex2rgb('D95319'), 'LineWidth', 1.8); add_limits(ax1, [-50 50]); format_axes(ax1, '', 'Force $F$ (N)');
        ax2 = nexttile(tl); plot(D.l_ddot.x, D.l_ddot.y, 'Color', hex2rgb('77AC30'), 'LineWidth', 1.8); add_limits(ax2, [-5 5]); format_axes(ax2, 'Time (s)', 'Winch $\ddot{l}$ (m/s$^2$)');
        save_pdf(fig, fullfile(dir_out, sprintf('MPC_TRAJ_f_l_ddot%s.pdf', sfx{i})));

        % 15.3: Wheels
        fig = setup_figure('2x1'); tl = tiledlayout(fig, 2, 1, 'TileSpacing', 'compact');
        ax1 = nexttile(tl); hold on;
        h1 = plot(D.fw1.x, D.fw1.y, 'Color', hex2rgb('0072BD'), 'LineWidth', 1.6, 'DisplayName', '$F_{w1}$');
        h2 = plot(D.fw2.x, D.fw2.y, 'Color', hex2rgb('EDB120'), 'LineWidth', 1.6, 'DisplayName', '$F_{w2}$');
        format_axes(ax1, 'Time (s)', 'Wheel load (N)'); create_legend([h1, h2]);
        ax2 = nexttile(tl); hold on;
        [tc, fw1_c, fw2_c] = align_signals(D.fw1, D.fw2);
        h3 = plot(tc, fw1_c + fw2_c, 'k', 'LineWidth', 1.6, 'DisplayName', '$F_{sum}$');
        h4 = plot(tc, fw1_c - fw2_c, 'Color', [0.5 0.5 0.5], 'LineWidth', 1.6, 'DisplayName', '$\Delta F$');
        add_limits(ax2, 11.772, 'static load'); format_axes(ax2, 'Time (s)', 'Load Analysis (N)'); create_legend([h3, h4]);
        save_pdf(fig, fullfile(dir_out, sprintf('NMPC_TRAJ_Wheels%s.pdf', sfx{i})));
    end

end

function generate_comparative(data, out)
    dir_out = fullfile(out, 'Comparative'); dists = {'05', '5'}; sfx = {'05', '5'};

    for i = 1:2
        d = dists{i};
        d_field = ['d_' d];
        has_lqr = isfield(data, 's_1_LQR_Step') && isfield(data.s_1_LQR_Step, d_field);
        has_nmpc = isfield(data, 's_3_NMPC_Basic') && isfield(data.s_3_NMPC_Basic, d_field);
        if ~(has_lqr && has_nmpc), continue; end
        LQR = data.s_1_LQR_Step.(d_field); NMPC = data.s_3_NMPC_Basic.(d_field);

        % 17.1 Step Comparison States
        fig = setup_figure('2x1'); tl = tiledlayout(fig, 2, 1, 'TileSpacing', 'compact');
        ax1 = nexttile(tl); hold on;
        h1 = plot(LQR.x.x, LQR.x.y, 'Color', hex2rgb('0072BD'), 'LineWidth', 1.8, 'DisplayName', '$x_{LQR}$');
        h2 = plot(NMPC.x.x, NMPC.x.y, 'Color', hex2rgb('D95319'), 'LineWidth', 1.8, 'DisplayName', '$x_{NMPC}$');
        format_axes(ax1, '', 'Position $x$ (m)'); create_legend([h1, h2]);

        ax2 = nexttile(tl); hold on;
        h3 = plot(LQR.theta.x, LQR.theta.y, 'Color', hex2rgb('0072BD'), 'LineWidth', 1.8, 'DisplayName', '$\theta_{LQR}$');
        h4 = plot(NMPC.theta.x, NMPC.theta.y, 'Color', hex2rgb('D95319'), 'LineWidth', 1.8, 'DisplayName', '$\theta_{NMPC}$');
        add_limits(ax2, [-15 15] * pi / 180); format_axes(ax2, 'Time (s)', 'Angle $\theta$ (rad)'); create_legend([h3, h4]);
        save_pdf(fig, fullfile(dir_out, sprintf('Step_Comparison_States_%s.pdf', sfx{i})));

        % 17.2 Special 5m Failure Mechanism (Only for d='5')
        if strcmp(d, '5')
            fig = setup_figure('2x2'); tl = tiledlayout(fig, 2, 2, 'TileSpacing', 'compact');
            ax1 = nexttile(tl); plot(LQR.x.x, LQR.x.y, 'Color', hex2rgb('0072BD'), 'LineWidth', 1.8); format_axes(ax1, '', 'LQR Position $x$ (m)');
            ax2 = nexttile(tl); plot(LQR.theta.x, LQR.theta.y, 'Color', hex2rgb('0072BD'), 'LineWidth', 1.8); add_limits(ax2, [-15 15] * pi / 180); format_axes(ax2, '', 'LQR Angle $\theta$ (rad)');
            ax3 = nexttile(tl); plot(NMPC.x.x, NMPC.x.y, 'Color', hex2rgb('D95319'), 'LineWidth', 1.8); format_axes(ax3, 'Time (s)', 'NMPC Position $x$ (m)');
            ax4 = nexttile(tl); plot(NMPC.theta.x, NMPC.theta.y, 'Color', hex2rgb('D95319'), 'LineWidth', 1.8); add_limits(ax4, [-15 15] * pi / 180); format_axes(ax4, 'Time (s)', 'NMPC Angle $\theta$ (rad)');
            linkaxes([ax1, ax3], 'xy'); linkaxes([ax2, ax4], 'y');
            save_pdf(fig, fullfile(dir_out, 'Step_5m_FailureMechanism.pdf'));
        end

        % Trajectory Comparisons
        has_lqr_t = isfield(data, 's_2_LQR_Trajectory') && isfield(data.s_2_LQR_Trajectory, d_field);
        has_nmpc_t = isfield(data, 's_4_NMPC_Trajectory') && isfield(data.s_4_NMPC_Trajectory, d_field);

        if has_lqr_t && has_nmpc_t
            LQRT = data.s_2_LQR_Trajectory.(d_field); NMPCT = data.s_4_NMPC_Trajectory.(d_field); Ref = LQRT.ref;

            % 18.1 Trajectory Comparison Tracking
            fig = setup_figure('2x1'); tl = tiledlayout(fig, 2, 1, 'TileSpacing', 'compact');
            ax1 = nexttile(tl); hold on;
            h1 = plot(Ref.x.x, Ref.x.y, 'k--', 'LineWidth', 1.8, 'DisplayName', '$x_{ref}$');
            h2 = plot(LQRT.x.x, LQRT.x.y, 'Color', hex2rgb('0072BD'), 'LineWidth', 1.8, 'DisplayName', '$x_{LQR}$');
            h3 = plot(NMPCT.x.x, NMPCT.x.y, 'Color', hex2rgb('D95319'), 'LineWidth', 1.8, 'DisplayName', '$x_{NMPC}$');
            format_axes(ax1, '', 'Position $x$ (m)'); create_legend([h1, h2, h3]);

            ax2 = nexttile(tl); hold on;
            h4 = plot(LQRT.theta.x, LQRT.theta.y, 'Color', hex2rgb('0072BD'), 'LineWidth', 1.8, 'DisplayName', '$\theta_{LQR}$');
            h5 = plot(NMPCT.theta.x, NMPCT.theta.y, 'Color', hex2rgb('D95319'), 'LineWidth', 1.8, 'DisplayName', '$\theta_{NMPC}$');
            add_limits(ax2, [-15 15] * pi / 180); format_axes(ax2, 'Time (s)', 'Angle $\theta$ (rad)'); create_legend([h4, h5]);
            save_pdf(fig, fullfile(dir_out, sprintf('Trajectory_Comparison_Tracking_%s.pdf', sfx{i})));

            % 18.5 Residual Sway Comparison
            fig = setup_figure('single'); ax = axes(fig); hold on;
            tf_lqr = LQRT.theta.x(end); tf_nmpc = NMPCT.theta.x(end);
            idx_lqr = LQRT.theta.x >= (tf_lqr - 2); idx_nmpc = NMPCT.theta.x >= (tf_nmpc - 2);
            h1 = plot(LQRT.theta.x(idx_lqr) - tf_lqr, LQRT.theta.y(idx_lqr), 'Color', hex2rgb('0072BD'), 'LineWidth', 1.8, 'DisplayName', '$\theta_{LQR}$');
            h2 = plot(NMPCT.theta.x(idx_nmpc) - tf_nmpc, NMPCT.theta.y(idx_nmpc), 'Color', hex2rgb('D95319'), 'LineWidth', 1.8, 'DisplayName', '$\theta_{NMPC}$');
            add_zero_line(ax); format_axes(ax, '$t - t_f$ (s)', 'Residual Sway $\theta$ (rad)'); create_legend([h1, h2]);
            save_pdf(fig, fullfile(dir_out, sprintf('Residual_Sway_Comparison_%s.pdf', sfx{i})));
        end

    end

    % 19. Reference Profile Comparison
    if isfield(data, 's_2_LQR_Trajectory') && isfield(data.s_2_LQR_Trajectory, 'd_05') && isfield(data.s_2_LQR_Trajectory, 'd_5')
        fig = setup_figure('2x1'); tl = tiledlayout(fig, 2, 1, 'TileSpacing', 'compact');
        ax1 = nexttile(tl); hold on;
        plot(data.s_2_LQR_Trajectory.d_05.ref.x.x, data.s_2_LQR_Trajectory.d_05.ref.x.y, 'k-', 'LineWidth', 1.6);
        plot(data.s_2_LQR_Trajectory.d_5.ref.x.x, data.s_2_LQR_Trajectory.d_5.ref.x.y, 'k--', 'LineWidth', 1.6);
        format_axes(ax1, '', 'Reference $x_{ref}$ (m)');

        ax2 = nexttile(tl); hold on;
        plot(data.s_2_LQR_Trajectory.d_05.ref.xdot.x, data.s_2_LQR_Trajectory.d_05.ref.xdot.y, 'k-', 'LineWidth', 1.6, 'DisplayName', '0.5 m');
        plot(data.s_2_LQR_Trajectory.d_5.ref.xdot.x, data.s_2_LQR_Trajectory.d_5.ref.xdot.y, 'k--', 'LineWidth', 1.6, 'DisplayName', '5.0 m');
        format_axes(ax2, 'Time (s)', 'Reference $\dot{x}_{ref}$ (m/s)'); legend(ax2, 'Location', 'best');
        save_pdf(fig, fullfile(dir_out, 'Reference_Profile_0p5m_vs_5m.pdf'));
    end

end

function generate_metrics(data, out)
    scenarios = {'1_LQR_Step', '2_LQR_Trajectory', '3_NMPC_Basic', '4_NMPC_Trajectory'};
    dists = {'05', '5'};

    results = {};

    for s = 1:length(scenarios)
        scen_field = ['s_' scenarios{s}];

        for d = 1:length(dists)
            d_field = ['d_' dists{d}];
            if ~isfield(data, scen_field) || ~isfield(data.(scen_field), d_field), continue; end
            D = data.(scen_field).(d_field);

            row = struct();
            row.Scenario = scenarios{s};
            row.Distance = str2double(strrep(dists{d}, '05', '0.5'));
            row.Peak_Theta_rad = max(abs(D.theta.y));
            row.Peak_Theta_deg = row.Peak_Theta_rad * 180 / pi;

            if isfield(D, 'F'), row.Peak_F = max(abs(D.F.y));
            elseif isfield(D, 'F_ff'), row.Peak_F = max(abs(D.F_ff.y + D.F_fb.y));
            else , row.Peak_F = NaN; end

                if isfield(D, 'l_ddot'), row.Peak_l_ddot = max(abs(D.l_ddot.y)); else, row.Peak_l_ddot = 0; end
                if isfield(D, 'l'), row.Min_l = min(D.l.y); row.Max_l = max(D.l.y); else, row.Min_l = 1.0; row.Max_l = 1.0; end

                [~, fw1_c, fw2_c] = align_signals(D.fw1, D.fw2);
                row.Peak_Total_Wheel_Load = max(fw1_c + fw2_c);

                row.Final_Pos_Error = abs(D.x.y(end) - row.Distance);

                idx_last_1s = D.theta.x >= (D.theta.x(end) - 1.0);
                row.RMS_Residual_Sway = rms(D.theta.y(idx_last_1s));

                results{end + 1} = row;
            end

        end

        if isempty(results), return; end
        T = struct2table([results{:}]);

        writetable(T, fullfile(out, 'Comparative', 'Performance_Metrics.csv'));
        save(fullfile(out, 'Comparative', 'Performance_Metrics.mat'), 'T');
        fprintf('Metrics successfully saved to CSV and MAT.\n');
    end

    %% ========================================================================
    %  CORE HELPER FUNCTIONS
    %  ========================================================================

    function [extracted, status, msg] = extract_fig_data(filepath)
        extracted = {}; status = 0; msg = '';

        if ~isfile(filepath)
            return; % status 0 means missing
        end

        try
            fig = openfig(filepath, 'invisible');
            objs = findall(fig, '-property', 'XData', '-and', '-property', 'YData');
            valid = {};

            for i = 1:length(objs)
                x = objs(i).XData; y = objs(i).YData;

                if isnumeric(x) && isnumeric(y) && length(x) > 1 && length(x) == length(y) && all(isfinite(x)) && all(isfinite(y))
                    valid{end + 1} = struct('x', x(:), 'y', y(:));
                end

            end

            close(fig);

            if isempty(valid)
                status = -1; msg = 'No valid numerical line data found.';
            else
                extracted = valid; status = 1;
            end

        catch ME
            status = -1; msg = ME.message;
            if exist('fig', 'var') && isvalid(fig), close(fig); end
        end

    end

    function ref = parse_reference_signals(extracted)
        % Robustly identify x, xdot, theta, thetadot regardless of trailing zeros
        ref = struct();
        non_zero_sigs = {};
        zero_sigs = {};

        % 1. Separate into zero and non-zero signals
        for i = 1:length(extracted)

            if max(abs(extracted{i}.y)) < 1e-4
                zero_sigs{end + 1} = extracted{i};
            else
                non_zero_sigs{end + 1} = extracted{i};
            end

        end

        % 2. Identify x_ref and xdot_ref
        if length(non_zero_sigs) >= 2

            if mean(abs(non_zero_sigs{1}.y)) > mean(abs(non_zero_sigs{2}.y))
                ref.x = non_zero_sigs{1};
                ref.xdot = non_zero_sigs{2};
            else
                ref.x = non_zero_sigs{2};
                ref.xdot = non_zero_sigs{1};
            end

        elseif length(non_zero_sigs) == 1
            ref.x = non_zero_sigs{1};
            ref.xdot = non_zero_sigs{1}; % Fallback
        else
            ref.x = extracted{1};
            ref.xdot = extracted{1}; % Fallback
        end

        % 3. Identify theta_ref and thetadot_ref
        if length(zero_sigs) >= 2
            ref.theta = zero_sigs{1};
            ref.thetadot = zero_sigs{2};
        elseif length(zero_sigs) == 1
            ref.theta = zero_sigs{1};
            ref.thetadot = zero_sigs{1}; % Fallback
        else
            % Safe fallback: generate strict zeros if missing
            ref.theta = struct('x', ref.x.x, 'y', zeros(size(ref.x.x)));
            ref.thetadot = struct('x', ref.x.x, 'y', zeros(size(ref.x.x)));
        end

    end

    function [tc, y1_c, y2_c] = align_signals(sig1, sig2)
        % Interpolates to common time vector without extrapolation
        t_min = max(min(sig1.x), min(sig2.x));
        t_max = min(max(sig1.x), max(sig2.x));

        % Only consider points inside the overlapping region
        idx1 = sig1.x >= t_min & sig1.x <= t_max;
        tc = sig1.x(idx1);

        % Ensure unique points for interpolation
        [u2, i2] = unique(sig2.x);
        y2_unique = sig2.y(i2);

        y1_c = sig1.y(idx1);
        y2_c = interp1(u2, y2_unique, tc, 'linear');
    end

    function fig = setup_figure(type)
        fig = figure('Visible', 'off', 'Color', 'w');

        switch type
            case 'single', pos = [100 100 1000 500];
            case '2x1', pos = [100 100 1000 700];
            case '3x1', pos = [100 100 1000 900];
            case '4x1', pos = [100 100 1000 1050];
            case '2x2', pos = [100 100 1100 900];
            otherwise , pos = [100 100 1000 500];
        end

        fig.Position = pos;
    end

    function format_axes(ax, xlbl, ylbl)
        set(ax, 'Color', 'w', 'XColor', 'k', 'YColor', 'k', 'FontSize', 12, 'TickLabelInterpreter', 'latex', 'Box', 'on', 'GridAlpha', 0.15);
        grid(ax, 'on');
        if nargin >= 2 && ~isempty(xlbl), xlabel(ax, xlbl, 'Interpreter', 'latex', 'FontSize', 14, 'Color', 'k'); end
        if nargin >= 3 && ~isempty(ylbl), ylabel(ax, ylbl, 'Interpreter', 'latex', 'FontSize', 14, 'Color', 'k'); end
    end

    function add_zero_line(ax)
        hold(ax, 'on');
        xl = xlim(ax);
        plot(ax, xl, [0 0], ':', 'Color', [0.7 0.7 0.7], 'LineWidth', 1.0, 'HandleVisibility', 'off');
    end

    function add_limits(ax, limits, lbl)
        hold(ax, 'on');
        xl = xlim(ax);

        for i = 1:length(limits)
            plot(ax, xl, [limits(i) limits(i)], '--', 'Color', [0.6 0.6 0.6], 'LineWidth', 1.2, 'HandleVisibility', 'off');
        end

    end

    function create_legend(handles)

        if numel(handles) > 1
            lgd = legend(handles, 'Location', 'best', 'Interpreter', 'latex', 'FontSize', 12);
            lgd.Color = 'w'; lgd.EdgeColor = 'k';
        end

    end

    function save_pdf(fig, path)
        exportgraphics(fig, path, 'ContentType', 'vector', 'BackgroundColor', 'white');
        close(fig);
    end

    function c = hex2rgb(hex)
        if startsWith(hex, '#'), hex = hex(2:end); end
        c = sscanf(hex, '%2x%2x%2x', [1 3]) / 255;
    end
