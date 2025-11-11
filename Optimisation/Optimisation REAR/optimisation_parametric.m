%% === Environnement acoustique ===
dB = 134;
M  = 0.1;
env = handle_env(dB, M);

%% === Fréquences cibles ===
Frequences.f_min_lb = 200;
Frequences.f_max_lb = 1500;
Frequences.f_min_h1 = 220; Frequences.f_max_h1 = 240;
Frequences.f_min_h2 = 430; Frequences.f_max_h2 = 470;
Frequences.f_min_h3 = 640; Frequences.f_max_h3 = 700;
Frequences.f_min_h4 = 870; Frequences.f_max_h4 = 950;

%% === Paramètres géométriques ===
total_thickness   = 117e-3;
width             = 30e-3;
depth             = 30e-3;
cavities_width    = 28e-3; 
cavities_depth    = 28e-3; 
input_surface     = width * depth;
plates_thickness  = 2e-3;
depth_holes_number = 10;

NS = 1; N = 6; NV = 4;
cavities_total_thickness = total_thickness - N * plates_thickness;
config = @(x) permute(reshape(x, [], NS, N, NV), [2,3,4,1]);

%% === Configuration de base ===
r_base     = 0.9e-3;
dw_base    = 2.5e-3;
pw_base    = 6;
theta_base = 3;

x_fixed = horzcat( ...
    repmat(r_base,     1, N*NS), ...
    repmat(dw_base,    1, N*NS), ...
    repmat(pw_base,    1, N*NS), ...
    repmat(theta_base, 1, N*NS) );

% Indices blocs
idx_r     = 1               : (N*NS);
idx_dw    = (N*NS)+1        : 2*(N*NS);
idx_pw    = 2*(N*NS)+1      : 3*(N*NS);
idx_theta = 3*(N*NS)+1      : 4*(N*NS);

%% === Création des objets acoustiques ===
Objets = struct();

% Fonction qui crée un seul MPPSBH
Objets.MPPSBH_i = @(config, i) classMPPSBH_Rectangular( ...
    classMPPSBH_Rectangular.create_explicit_rectangular_pattern_config( ...
        input_surface, N, cavities_depth, cavities_width, ...
        {config(i,:,1)}, ...
        {config(i,:,2)}, ...
        {cavities_depth / depth_holes_number}, ...
        {depth_holes_number}, ...
        {config(i,:,3)}, ...
        {plates_thickness}, ...
        {perso_simplex_map(config(i,:,4), cavities_total_thickness)} ...
    ) ...
);

% Cellule de MPPSBHs
Objets.cell_of_MPPSBH = @(x) arrayfun(@(i) Objets.MPPSBH_i(config(x), i), 1:NS, 'UniformOutput', false);

% Assemblage complet
Objets.assembly_of_MPPSBH = @(x) classelementassembly( ...
    classelementassembly.create_config(Objets.cell_of_MPPSBH(x)) ...
);

%% === Étude paramétrique multi-paramètres (r, dw, pw, θ, N) ===
r_values     = linspace(0.2e-3, 1.2e-3, 6);
dw_values    = linspace(1e-3,   4e-3,   6);
pw_values    = round(linspace(2, 10,   6));
theta_values = linspace(1, 5, 6);
N_values     = 3:8;  % nombre de plaques

figure('Name','Étude paramétrique multi-paramètres','NumberTitle','off');
tiledlayout(3,2, 'Padding','compact', 'TileSpacing','compact');

params = { ...
    struct('idx',idx_r,     'values',r_values,     'label','r (m)',     'isN',false), ...
    struct('idx',idx_dw,    'values',dw_values,    'label','d_w (m)',   'isN',false), ...
    struct('idx',idx_pw,    'values',pw_values,    'label','p_w (–)',   'isN',false), ...
    struct('idx',idx_theta, 'values',theta_values, 'label','\theta (–)','isN',false), ...
    struct('idx',[],        'values',N_values,     'label','N (plaques)','isN',true) ...
};

for p = 1:length(params)
    nexttile; hold on; grid on; box on;
    colors = lines(numel(params{p}.values));

    % Courbe de référence
    alpha_ref = Objets.assembly_of_MPPSBH(x_fixed).absorption_coefficient(env, struct('HL_method','linear'));
    plot(env.w/(2*pi), alpha_ref, 'k', 'LineWidth', 2, ...
         'DisplayName', 'Réf (N = 6)');

    % Étude paramétrique
    for k = 1:numel(params{p}.values)
        if ~params{p}.isN
            % --- Cas standard : variation d'un paramètre ---
            x_test = x_fixed;
            x_test(params{p}.idx) = params{p}.values(k);
            alpha = Objets.assembly_of_MPPSBH(x_test).absorption_coefficient(env, struct('HL_method','linear'));
        else
            % --- Cas particulier : variation du nombre de plaques ---
            N_test = params{p}.values(k);
            cavities_total_thickness_test = total_thickness - N_test * plates_thickness;

            % Nouvelle configuration locale
            x_test = horzcat( ...
                repmat(r_base,     1, N_test*NS), ...
                repmat(dw_base,    1, N_test*NS), ...
                repmat(pw_base,    1, N_test*NS), ...
                repmat(theta_base, 1, N_test*NS) );

            config_local = @(x) permute(reshape(x, [], NS, N_test, NV), [2,3,4,1]);

            % Définir les objets locaux
            Objets_local.MPPSBH_i = @(config, i) classMPPSBH_Rectangular( ...
                classMPPSBH_Rectangular.create_explicit_rectangular_pattern_config( ...
                    input_surface, N_test, cavities_depth, cavities_width, ...
                    {config(i,:,1)}, {config(i,:,2)}, ...
                    {cavities_depth / depth_holes_number}, ...
                    {depth_holes_number}, {config(i,:,3)}, ...
                    {plates_thickness}, ...
                    {perso_simplex_map(config(i,:,4), cavities_total_thickness_test)} ...
                ) ...
            );

            Objets_local.cell_of_MPPSBH = @(x) arrayfun(@(i) Objets_local.MPPSBH_i(config_local(x), i), 1:NS, 'UniformOutput', false);
            Objets_local.assembly_of_MPPSBH = @(x) classelementassembly( ...
                classelementassembly.create_config(Objets_local.cell_of_MPPSBH(x)) ...
            );

            alpha = Objets_local.assembly_of_MPPSBH(x_test).absorption_coefficient(env, struct('HL_method','linear'));
        end

        plot(env.w/(2*pi), alpha, 'Color', colors(k,:), 'LineWidth', 1.1, ...
            'DisplayName', sprintf('%s = %.3g', params{p}.label, params{p}.values(k)));
    end

    % Bandes d'optimisation
    yl = ylim;
    perso_plot_targetted_frequencies(Frequences, yl(2));
    uistack(findobj(gca,'Type','patch'),'bottom');

    xlim([0 2000]);
    if strcmp(params{p}.label, '\theta (–)')
        ylim([0 0.3]);  % ✅ limite spécifique pour theta
    else
        ylim([0 1]);
    end

    xlabel('Fréquence (Hz)'); ylabel('\alpha');
    title(sprintf('Influence de %s', params{p}.label), 'Interpreter','tex');
    legend('Location','best');
end

sgtitle('Étude paramétrique — Influence des paramètres géométriques et du nombre de plaques');