% generate_chapter3_figures.m
% Lightweight, Targeted Figure Generation for Chapter 3
% Generates exactly 17 publication-quality PDF figures.

function generate_chapter3_figures()
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
    out_dir = fullfile(project_root, '1_Thesis_Report', 'images');

    subdirs = {'1_LQR_Step', '3_NMPC_Basic', '4_NMPC_Trajectory', 'Comparative'};

    for i = 1:length(subdirs)

        if ~isfolder(fullfile(out_dir, subdirs{i}))
            mkdir(fullfile(out_dir, subdirs{i}));
        end

    end

    fprintf('--- Starting Targeted Figure Generation ---\n');

    % =========================================================
    % 2. Extract Data Robustly (Only what we need)
    % =========================================================
    data = struct();

    % Maps folder name -> struct field
    scenarios = {'1_LQR_Step', '2_LQR_Trajectory', '3_NMPC_Basic', '4_NMPC_Trajectory'};

    % Signals per scenario
    sigs.s_1_LQR_Step = {'fw1', 'fw2', 'F', 'theta', 'x'};
    sigs.s_2_LQR_Trajectory = {'x', 'theta', 'ref'};
    sigs.s_3_NMPC_Basic = {'fw1', 'fw2', 'F', 'l', 'l_ddot', 'theta', 'x'};
    sigs.s_4_NMPC_Trajectory = {'F', 'l', 'l_ddot', 'theta', 'x'};

    dists = {'05', '5'};

    success = 0; fail = 0; miss = 0;

    for s = 1:length(scenarios)
        scen_raw = scenarios{s};
        scen_fld = ['s_' scen_raw];

        for d = 1:2
            dst_raw = dists{d};
            dst_fld = ['d_' dst_raw];

            for i = 1:length(sigs.(scen_fld))
                sig = sigs.(scen_fld){i};
                path = fullfile(src_dir, scen_raw, sprintf('%s_%s.fig', sig, dst_raw));

                [extr, stat, msg] = extract_fig_data(path);

                if stat == 1

                    if strcmp(sig, 'ref')
                        data.(scen_fld).(dst_fld).(sig) = parse_references(extr);
                    else
                        data.(scen_fld).(dst_fld).(sig) = extr{1};
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

    end

    fprintf('Data Extracted: %d OK | %d MISSING | %d FAILED\n\n', success, miss, fail);

    % =========================================================
    % 3. Generate The 17 Figures
    % =========================================================
    try
        gen_lqr_step(data, out_dir); % Figs 1, 2, 3, 4
        gen_nmpc_basic(data, out_dir); % Figs 7, 8
        gen_nmpc_traj(data, out_dir); % Figs 9, 10, 11, 12
        gen_comparative(data, out_dir); % Figs 5, 6, 13, 14, 15, 16
        gen_metrics(data, out_dir); % Fig 17 (Table + CSV + MAT)
        fprintf('\n--- Pipeline Finished Successfully ---\n');
    catch ME
        fprintf('\nERROR during generation:\n%s\n', ME.message);
    end

end

%% ========================================================================
%  FIGURE GENERATORS (TARGETED)
%  ========================================================================

function gen_lqr_step(data, out)
    % FIG 1 & 2: 0.5m
    if isfield(data.s_1_LQR_Step, 'd_05')
        D = data.s_1_LQR_Step.d_05;
        % Fig 1: LQR_x_theta.pdf
        f1 = setup_fig('2x1'); tl = tiledlayout(f1, 2, 1, 'TileSpacing', 'compact');
        ax1 = nexttile(tl); plot(D.x.x, D.x.y, 'Color', hex2rgb('0072BD'), 'LineWidth', 1.8); add_zero(ax1); format_ax(ax1, '', 'Position $x$ (m)');
        ax2 = nexttile(tl); plot(D.theta.x, D.theta.y, 'Color', hex2rgb('0072BD'), 'LineWidth', 1.8); add_zero(ax2); add_lims(ax2, [-15 15] * pi / 180); format_ax(ax2, 'Time (s)', 'Angle $\theta$ (rad)');
        save_pdf(f1, fullfile(out, '1_LQR_Step', 'LQR_x_theta.pdf'));

        % Fig 2: LQR_F.pdf
        f2 = setup_fig('single'); ax = axes(f2);
        plot(D.F.x, D.F.y, 'Color', hex2rgb('0072BD'), 'LineWidth', 1.8); add_lims(ax, [-5 5]); format_ax(ax, 'Time (s)', 'Force $F$ (N)');
        save_pdf(f2, fullfile(out, '1_LQR_Step', 'LQR_F.pdf'));
    end

    % FIG 3 & 4: 5m
    if isfield(data.s_1_LQR_Step, 'd_5')
        D = data.s_1_LQR_Step.d_5;
        % Fig 3: LQR_x_theta_5.pdf
        f3 = setup_fig('2x1'); tl = tiledlayout(f3, 2, 1, 'TileSpacing', 'compact');
        ax1 = nexttile(tl); plot(D.x.x, D.x.y, 'Color', hex2rgb('0072BD'), 'LineWidth', 1.8); add_zero(ax1); format_ax(ax1, '', 'Position $x$ (m)');
        ax2 = nexttile(tl); plot(D.theta.x, D.theta.y, 'Color', hex2rgb('0072BD'), 'LineWidth', 1.8); add_zero(ax2); add_lims(ax2, [-15 15] * pi / 180); format_ax(ax2, 'Time (s)', 'Angle $\theta$ (rad)');
        save_pdf(f3, fullfile(out, '1_LQR_Step', 'LQR_x_theta_5.pdf'));

        % Fig 4: LQR_F_5.pdf
        f4 = setup_fig('single'); ax = axes(f4);
        plot(D.F.x, D.F.y, 'Color', hex2rgb('0072BD'), 'LineWidth', 1.8); add_lims(ax, [-5 5]); format_ax(ax, 'Time (s)', 'Force $F$ (N)');
        save_pdf(f4, fullfile(out, '1_LQR_Step', 'LQR_F_5.pdf'));
    end

end

function gen_nmpc_basic(data, out)
    % FIG 7: 0.5m
    if isfield(data.s_3_NMPC_Basic, 'd_05')
        D = data.s_3_NMPC_Basic.d_05;
        f1 = setup_fig('2x2'); tl = tiledlayout(f1, 2, 2, 'TileSpacing', 'compact');
        ax1 = nexttile(tl); plot(D.x.x, D.x.y, 'Color', hex2rgb('D95319'), 'LineWidth', 1.8); format_ax(ax1, '', 'Position $x$ (m)');
        ax2 = nexttile(tl); plot(D.theta.x, D.theta.y, 'Color', hex2rgb('D95319'), 'LineWidth', 1.8); add_lims(ax2, [-15 15] * pi / 180); format_ax(ax2, '', 'Angle $\theta$ (rad)');
        ax3 = nexttile(tl); plot(D.F.x, D.F.y, 'Color', hex2rgb('D95319'), 'LineWidth', 1.8); add_lims(ax3, [-5 5]); format_ax(ax3, 'Time (s)', 'Force $F$ (N)');
        ax4 = nexttile(tl); plot(D.l_ddot.x, D.l_ddot.y, 'Color', hex2rgb('D95319'), 'LineWidth', 1.8); add_lims(ax4, [-5 5]); format_ax(ax4, 'Time (s)', 'Winch $\ddot{l}$ (m/s$^2$)');
        save_pdf(f1, fullfile(out, '3_NMPC_Basic', 'NMPC_Basic_Analytical_05.pdf'));
    end

    % FIG 8: 5m
    if isfield(data.s_3_NMPC_Basic, 'd_5')
        D = data.s_3_NMPC_Basic.d_5;
        f2 = setup_fig('2x2'); tl = tiledlayout(f2, 2, 2, 'TileSpacing', 'compact');
        ax1 = nexttile(tl); plot(D.x.x, D.x.y, 'Color', hex2rgb('D95319'), 'LineWidth', 1.8); format_ax(ax1, '', 'Position $x$ (m)');
        ax2 = nexttile(tl); plot(D.theta.x, D.theta.y, 'Color', hex2rgb('D95319'), 'LineWidth', 1.8); add_lims(ax2, [-15 15] * pi / 180); format_ax(ax2, '', 'Angle $\theta$ (rad)');
        ax3 = nexttile(tl); plot(D.F.x, D.F.y, 'Color', hex2rgb('D95319'), 'LineWidth', 1.8); add_lims(ax3, [-5 5]); format_ax(ax3, 'Time (s)', 'Force $F$ (N)');
        ax4 = nexttile(tl); plot(D.l_ddot.x, D.l_ddot.y, 'Color', hex2rgb('D95319'), 'LineWidth', 1.8); add_lims(ax4, [-5 5]); format_ax(ax4, 'Time (s)', 'Winch $\ddot{l}$ (m/s$^2$)');
        save_pdf(f2, fullfile(out, '3_NMPC_Basic', 'NMPC_Basic_Analytical_5.pdf'));
    end

end

function gen_nmpc_traj(data, out)
    if ~isfield(data.s_4_NMPC_Trajectory, 'd_5'), return; end
    D = data.s_4_NMPC_Trajectory.d_5;
    Ref = data.s_2_LQR_Trajectory.d_5.ref; % Common Ref

    % FIG 9: x_theta_l 5m
    f9 = setup_fig('3x1'); tl = tiledlayout(f9, 3, 1, 'TileSpacing', 'compact');
    ax1 = nexttile(tl); hold on;
    h1 = plot(Ref.x.x, Ref.x.y, 'k--', 'LineWidth', 1.8, 'DisplayName', '$x_{ref}$');
    h2 = plot(D.x.x, D.x.y, 'Color', hex2rgb('D95319'), 'LineWidth', 1.8, 'DisplayName', '$x_{NMPC}$');
    format_ax(ax1, '', 'Position $x$ (m)'); create_leg([h1, h2]);
    ax2 = nexttile(tl); plot(D.theta.x, D.theta.y, 'Color', hex2rgb('D95319'), 'LineWidth', 1.8); add_zero(ax2); add_lims(ax2, [-15 15] * pi / 180); format_ax(ax2, '', 'Angle $\theta$ (rad)');
    ax3 = nexttile(tl); plot(D.l.x, D.l.y, 'Color', hex2rgb('D95319'), 'LineWidth', 1.8); add_lims(ax3, [0.1 1.5]); format_ax(ax3, 'Time (s)', 'Cable $l$ (m)');
    save_pdf(f9, fullfile(out, '4_NMPC_Trajectory', 'MPC_TRAJ_x_theta_l_5.pdf'));

    % FIG 10: f_l_ddot 5m
    f10 = setup_fig('2x1'); tl = tiledlayout(f10, 2, 1, 'TileSpacing', 'compact');
    ax1 = nexttile(tl); plot(D.F.x, D.F.y, 'Color', hex2rgb('D95319'), 'LineWidth', 1.8); add_lims(ax1, [-5 5]); format_ax(ax1, '', 'Force $F$ (N)');
    ax2 = nexttile(tl); plot(D.l_ddot.x, D.l_ddot.y, 'Color', hex2rgb('D95319'), 'LineWidth', 1.8); add_lims(ax2, [-5 5]); format_ax(ax2, 'Time (s)', 'Winch $\ddot{l}$ (m/s$^2$)');
    save_pdf(f10, fullfile(out, '4_NMPC_Trajectory', 'MPC_TRAJ_f_l_ddot_5.pdf'));

    % FIG 11: State Tracking 5m
    f11 = setup_fig('4x1'); tl = tiledlayout(f11, 4, 1, 'TileSpacing', 'compact');
    ax1 = nexttile(tl); hold on; h1 = plot(Ref.x.x, Ref.x.y, 'k--', 'LineWidth', 1.6, 'DisplayName', 'Ref'); h2 = plot(D.x.x, D.x.y, 'Color', hex2rgb('D95319'), 'LineWidth', 1.6, 'DisplayName', 'NMPC'); format_ax(ax1, '', '$x$ (m)'); create_leg([h1, h2]);
    ax2 = nexttile(tl); hold on; xdot = gradient(D.x.y, D.x.x); h3 = plot(Ref.xdot.x, Ref.xdot.y, 'k--', 'LineWidth', 1.6); plot(D.x.x, xdot, 'Color', hex2rgb('D95319'), 'LineWidth', 1.6); format_ax(ax2, '', '$\dot{x}$ (m/s)');
    ax3 = nexttile(tl); hold on; h5 = plot(Ref.theta.x, Ref.theta.y, 'k--', 'LineWidth', 1.6); plot(D.theta.x, D.theta.y, 'Color', hex2rgb('D95319'), 'LineWidth', 1.6); format_ax(ax3, '', '$\theta$ (rad)');
    ax4 = nexttile(tl); hold on; thdot = gradient(D.theta.y, D.theta.x); h7 = plot(Ref.thetadot.x, Ref.thetadot.y, 'k--', 'LineWidth', 1.6); plot(D.theta.x, thdot, 'Color', hex2rgb('D95319'), 'LineWidth', 1.6); format_ax(ax4, 'Time (s)', '$\dot{\theta}$ (rad/s)');
    save_pdf(f11, fullfile(out, '4_NMPC_Trajectory', 'NMPC_TRAJ_StateTracking_5.pdf'));

    % FIG 12: Constraint Utilization 5m
    f12 = setup_fig('2x2'); tl = tiledlayout(f12, 2, 2, 'TileSpacing', 'compact');
    ax1 = nexttile(tl); plot(D.theta.x, abs(D.theta.y) / (15 * pi / 180), 'Color', hex2rgb('D95319'), 'LineWidth', 1.8); add_lims(ax1, 1); format_ax(ax1, '', '$|\theta| / 15^\circ$');
    ax2 = nexttile(tl); plot(D.l.x, abs(D.l.y - 0.8) / 0.7, 'Color', hex2rgb('D95319'), 'LineWidth', 1.8); add_lims(ax2, 1); format_ax(ax2, '', 'Norm. Cable $|l-0.8|/0.7$');
    ax3 = nexttile(tl); plot(D.F.x, abs(D.F.y) / 5, 'Color', hex2rgb('D95319'), 'LineWidth', 1.8); add_lims(ax3, 1); format_ax(ax3, 'Time (s)', '$|F| / 5$');
    ax4 = nexttile(tl); plot(D.l_ddot.x, abs(D.l_ddot.y) / 5, 'Color', hex2rgb('D95319'), 'LineWidth', 1.8); add_lims(ax4, 1); format_ax(ax4, 'Time (s)', '$|\ddot{l}| / 5$');
    save_pdf(f12, fullfile(out, '4_NMPC_Trajectory', 'NMPC_TRAJ_ConstraintUtilization_5.pdf'));
end

function gen_comparative(data, out)
    if ~isfield(data.s_1_LQR_Step, 'd_5') || ~isfield(data.s_3_NMPC_Basic, 'd_5'), return; end
    LQR_S = data.s_1_LQR_Step.d_5; NMPC_B = data.s_3_NMPC_Basic.d_5;

    % FIG 5: Step States 5m
    f5 = setup_fig('2x1'); tl = tiledlayout(f5, 2, 1, 'TileSpacing', 'compact');
    ax1 = nexttile(tl); hold on; h1 = plot(LQR_S.x.x, LQR_S.x.y, 'Color', hex2rgb('0072BD'), 'LineWidth', 1.8, 'DisplayName', '$x_{LQR}$'); h2 = plot(NMPC_B.x.x, NMPC_B.x.y, 'Color', hex2rgb('D95319'), 'LineWidth', 1.8, 'DisplayName', '$x_{NMPC}$'); format_ax(ax1, '', 'Position $x$ (m)'); create_leg([h1, h2]);
    ax2 = nexttile(tl); hold on; h3 = plot(LQR_S.theta.x, LQR_S.theta.y, 'Color', hex2rgb('0072BD'), 'LineWidth', 1.8, 'DisplayName', '$\theta_{LQR}$'); h4 = plot(NMPC_B.theta.x, NMPC_B.theta.y, 'Color', hex2rgb('D95319'), 'LineWidth', 1.8, 'DisplayName', '$\theta_{NMPC}$'); add_lims(ax2, [-15 15] * pi / 180); format_ax(ax2, 'Time (s)', 'Angle $\theta$ (rad)'); create_leg([h3, h4]);
    save_pdf(f5, fullfile(out, 'Comparative', 'Step_Comparison_States_5.pdf'));

    % FIG 6: Step Force 5m
    f6 = setup_fig('single'); ax = axes(f6); hold on;
    h1 = plot(LQR_S.F.x, LQR_S.F.y, 'Color', hex2rgb('0072BD'), 'LineWidth', 1.8, 'DisplayName', '$F_{LQR}$');
    h2 = plot(NMPC_B.F.x, NMPC_B.F.y, 'Color', hex2rgb('D95319'), 'LineWidth', 1.8, 'DisplayName', '$F_{NMPC}$');
    add_lims(ax, [-5 5]); format_ax(ax, 'Time (s)', 'Force $F$ (N)'); create_leg([h1, h2]);
    save_pdf(f6, fullfile(out, 'Comparative', 'Step_Comparison_Force_5.pdf'));

    % FIG 14: Step Wheels 5m
    f14 = setup_fig('2x1'); tl = tiledlayout(f14, 2, 1, 'TileSpacing', 'compact');
    ax1 = nexttile(tl); hold on; h1 = plot(LQR_S.fw1.x, LQR_S.fw1.y, 'Color', hex2rgb('0072BD'), 'LineWidth', 1.6, 'DisplayName', '$F_{w1,LQR}$'); h2 = plot(NMPC_B.fw1.x, NMPC_B.fw1.y, 'Color', hex2rgb('D95319'), 'LineWidth', 1.6, 'DisplayName', '$F_{w1,NMPC}$'); format_ax(ax1, '', 'Front Wheel (N)'); create_leg([h1, h2]);
    ax2 = nexttile(tl); hold on; h3 = plot(LQR_S.fw2.x, LQR_S.fw2.y, 'Color', hex2rgb('0072BD'), 'LineWidth', 1.6, 'DisplayName', '$F_{w2,LQR}$'); h4 = plot(NMPC_B.fw2.x, NMPC_B.fw2.y, 'Color', hex2rgb('D95319'), 'LineWidth', 1.6, 'DisplayName', '$F_{w2,NMPC}$'); format_ax(ax2, 'Time (s)', 'Rear Wheel (N)'); create_leg([h3, h4]);
    save_pdf(f14, fullfile(out, 'Comparative', 'Step_Comparison_Wheels_5.pdf'));

    % Trajectory Comparisons
    if isfield(data.s_2_LQR_Trajectory, 'd_5') && isfield(data.s_4_NMPC_Trajectory, 'd_5')
        LQRT = data.s_2_LQR_Trajectory.d_5; NMPCT = data.s_4_NMPC_Trajectory.d_5; Ref = LQRT.ref;

        % FIG 13: Trajectory Tracking 5m
        f13 = setup_fig('2x1'); tl = tiledlayout(f13, 2, 1, 'TileSpacing', 'compact');
        ax1 = nexttile(tl); hold on; h1 = plot(Ref.x.x, Ref.x.y, 'k--', 'LineWidth', 1.8, 'DisplayName', '$x_{ref}$'); h2 = plot(LQRT.x.x, LQRT.x.y, 'Color', hex2rgb('0072BD'), 'LineWidth', 1.8, 'DisplayName', '$x_{LQR}$'); h3 = plot(NMPCT.x.x, NMPCT.x.y, 'Color', hex2rgb('D95319'), 'LineWidth', 1.8, 'DisplayName', '$x_{NMPC}$'); format_ax(ax1, '', 'Position $x$ (m)'); create_leg([h1, h2, h3]);
        ax2 = nexttile(tl); hold on; h4 = plot(LQRT.theta.x, LQRT.theta.y, 'Color', hex2rgb('0072BD'), 'LineWidth', 1.8, 'DisplayName', '$\theta_{LQR}$'); h5 = plot(NMPCT.theta.x, NMPCT.theta.y, 'Color', hex2rgb('D95319'), 'LineWidth', 1.8, 'DisplayName', '$\theta_{NMPC}$'); add_zero(ax2); format_ax(ax2, 'Time (s)', 'Angle $\theta$ (rad)'); create_leg([h4, h5]);
        save_pdf(f13, fullfile(out, 'Comparative', 'Trajectory_Comparison_Tracking_5.pdf'));

        % FIG 15: Trajectory Errors 5m
        f15 = setup_fig('2x1'); tl = tiledlayout(f15, 2, 1, 'TileSpacing', 'compact');
        [tc_lqr, xr_lqr, xa_lqr] = align_sigs(Ref.x, LQRT.x); [tc_nmpc, xr_nmpc, xa_nmpc] = align_sigs(Ref.x, NMPCT.x);
        ax1 = nexttile(tl); hold on; h1 = plot(tc_lqr, xa_lqr - xr_lqr, 'Color', hex2rgb('0072BD'), 'LineWidth', 1.6, 'DisplayName', '$e_{x,LQR}$'); h2 = plot(tc_nmpc, xa_nmpc - xr_nmpc, 'Color', hex2rgb('D95319'), 'LineWidth', 1.6, 'DisplayName', '$e_{x,NMPC}$'); add_zero(ax1); format_ax(ax1, '', 'Pos. Error $e_x$ (m)'); create_leg([h1, h2]);
        ax2 = nexttile(tl); hold on; h3 = plot(LQRT.theta.x, LQRT.theta.y, 'Color', hex2rgb('0072BD'), 'LineWidth', 1.6, 'DisplayName', '$e_{\theta,LQR}$'); h4 = plot(NMPCT.theta.x, NMPCT.theta.y, 'Color', hex2rgb('D95319'), 'LineWidth', 1.6, 'DisplayName', '$e_{\theta,NMPC}$'); add_zero(ax2); format_ax(ax2, 'Time (s)', 'Angle Error $e_\theta$ (rad)'); create_leg([h3, h4]);
        save_pdf(f15, fullfile(out, 'Comparative', 'Trajectory_Comparison_Errors_5.pdf'));

        % FIG 16: Residual Sway 5m
        f16 = setup_fig('single'); ax = axes(f16); hold on;
        tf_l = LQRT.theta.x(end); tf_n = NMPCT.theta.x(end);
        idx_l = LQRT.theta.x >= (tf_l - 2); idx_n = NMPCT.theta.x >= (tf_n - 2);
        h1 = plot(LQRT.theta.x(idx_l) - tf_l, LQRT.theta.y(idx_l), 'Color', hex2rgb('0072BD'), 'LineWidth', 1.8, 'DisplayName', '$\theta_{LQR}$');
        h2 = plot(NMPCT.theta.x(idx_n) - tf_n, NMPCT.theta.y(idx_n), 'Color', hex2rgb('D95319'), 'LineWidth', 1.8, 'DisplayName', '$\theta_{NMPC}$');
        add_zero(ax); format_ax(ax, '$\tau = t - t_f$ (s)', 'Terminal Sway $\theta$ (rad)'); create_leg([h1, h2]);
        save_pdf(f16, fullfile(out, 'Comparative', 'Residual_Sway_Comparison_5.pdf'));
    end

end

function gen_metrics(data, out)
    scens = {'s_1_LQR_Step', 's_3_NMPC_Basic', 's_2_LQR_Trajectory', 's_4_NMPC_Trajectory'};
    names = {'LQR Step', 'NMPC Basic', 'LQR Traj', 'NMPC Traj'};
    dists = {'d_05', 'd_5'};
    dsts_val = [0.5, 5];

    res = {};

    for s = 1:4

        for d = 1:2
            if ~isfield(data, scens{s}) || ~isfield(data.(scens{s}), dists{d}), continue; end
            D = data.(scens{s}).(dists{d});

            row = struct();
            row.Architecture = names{s};
            row.Dist_m = dsts_val(d);
            row.Peak_Theta_rad = max(abs(D.theta.y));
            row.Peak_Theta_deg = row.Peak_Theta_rad * 180 / pi;

            if isfield(D, 'F'), row.Peak_F_N = max(abs(D.F.y)); else, row.Peak_F_N = NaN; end
            if isfield(D, 'l_ddot'), row.Peak_lddot = max(abs(D.l_ddot.y)); else, row.Peak_lddot = NaN; end
            if isfield(D, 'l'), row.Min_l = min(D.l.y); row.Max_l = max(D.l.y); else, row.Min_l = NaN; row.Max_l = NaN; end

            row.Final_ex_m = abs(D.x.y(end) - dsts_val(d));

            idx1s = D.theta.x >= (D.theta.x(end) - 1.0);
            row.RMS_Res_Theta = rms(D.theta.y(idx1s));

            if s > 2 % Trajectories
                % Reference is always taken from LQR Trajectory
                Ref = data.s_2_LQR_Trajectory.(dists{d}).ref;
                [~, xr, xa] = align_sigs(Ref.x, D.x);
                row.Peak_ex_m = max(abs(xa - xr));
                row.Peak_etheta_rad = max(abs(D.theta.y)); % theta_ref is 0
            else
                row.Peak_ex_m = NaN; row.Peak_etheta_rad = NaN;
            end

            res{end + 1} = row;
        end

    end

    if isempty(res), return; end
    T = struct2table([res{:}]);

    % FIG 17: Table PDF
    f17 = figure('Visible', 'off', 'Color', 'w', 'Position', [100 100 1100 300]);
    uitable(f17, 'Data', table2cell(T), 'ColumnName', T.Properties.VariableNames, ...
        'RowName', [], 'Units', 'normalized', 'Position', [0.05 0.05 0.9 0.9], 'FontSize', 9);
    save_pdf(f17, fullfile(out, 'Comparative', 'Performance_Metrics.pdf'));

    writetable(T, fullfile(out, 'Comparative', 'Performance_Metrics.csv'));
    save(fullfile(out, 'Comparative', 'Performance_Metrics.mat'), 'T');
    fprintf('Metrics generated: CSV, MAT, PDF.\n');
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

            switch type
                case 'single', pos = [100 100 800 450];
                case '2x1', pos = [100 100 800 650];
                case '3x1', pos = [100 100 800 850];
                case '4x1', pos = [100 100 800 1000];
                case '2x2', pos = [100 100 1000 800];
            end

            fig.Position = pos;
        end

        function format_ax(ax, xl, yl)
            set(ax, 'Color', 'w', 'XColor', 'k', 'YColor', 'k', 'FontSize', 11, 'TickLabelInterpreter', 'latex', 'Box', 'on'); grid(ax, 'on');
            if ~isempty(xl), xlabel(ax, xl, 'Interpreter', 'latex', 'FontSize', 13, 'Color', 'k'); end
            if ~isempty(yl), ylabel(ax, yl, 'Interpreter', 'latex', 'FontSize', 13, 'Color', 'k'); end
        end

        function add_zero(ax), hold(ax, 'on'); plot(ax, xlim(ax), [0 0], ':', 'Color', [0.7 0.7 0.7], 'LineWidth', 1, 'HandleVisibility', 'off'); end

            function add_lims(ax, lims), hold(ax, 'on'); xl = xlim(ax); for i = 1:length(lims), plot(ax, xl, [lims(i) lims(i)], '--', 'Color', [0.6 0.6 0.6], 'LineWidth', 1.2, 'HandleVisibility', 'off'); end; end

                function create_leg(hdls)

                    if numel(hdls) > 1
                        lgd = legend(hdls, 'Location', 'best', 'Interpreter', 'latex', 'FontSize', 11);
                        lgd.Color = 'w'; lgd.EdgeColor = 'k'; lgd.TextColor = 'k'; % Fix for dark mode OS
                    end

                end

                function save_pdf(fig, path)
                    exportgraphics(fig, path, 'ContentType', 'vector', 'BackgroundColor', 'white');
                    fprintf('  -> Generated: %s\n', path);
                    close(fig);
                end

                function c = hex2rgb(hex), if startsWith(hex, '#'), hex = hex(2:end); end; c = sscanf(hex, '%2x%2x%2x', [1 3]) / 255; end
