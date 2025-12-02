%% ========================================================================
%%
%%  Fréquences cibles, gabarits
%%
%% =========================================================================

% % Objectif larges bande

Frequences.f_min_lb = 200;
Frequences.f_max_lb = 1500;
g_obj_lb = @(env) (env.w / (2*pi) > Frequences.f_min_lb & env.w / (2*pi) < Frequences.f_max_lb);

% Objectifs tonaux
% On définit une largeur de bande associée à la variation du régime moteur de 3000 à 3500 RPM
% On définit les bandes de variations des harmoniques tant que celles-ci ne se recoupent pas

% Première harmonique (Fondamentale) : 233 Hz (20 Hz)
Frequences.f_min_h1 = 220;
Frequences.f_max_h1 = 240;
g_obj_h1 = @(env) (env.w / (2*pi) > Frequences.f_min_h1 & env.w / (2*pi) < Frequences.f_max_h1);

% Deuxième harmonique : 467 Hz (40 Hz)
Frequences.f_min_h2 = 430;
Frequences.f_max_h2 = 470;
g_obj_h2 = @(env) (env.w / (2*pi) > Frequences.f_min_h2 & env.w / (2*pi) < Frequences.f_max_h2);

% Troisième harmonique : 700 Hz (60 Hz)
Frequences.f_min_h3 = 640;
Frequences.f_max_h3 = 700;
g_obj_h3 = @(env) (env.w / (2*pi) > Frequences.f_min_h3 & env.w / (2*pi) < Frequences.f_max_h3);

% Quatrième harmonique : 933 Hz (80 Hz)
Frequences.f_min_h4 = 870;
Frequences.f_max_h4 = 950;
g_obj_h4 = @(env) (env.w / (2*pi) > Frequences.f_min_h4 & env.w / (2*pi) < Frequences.f_max_h4);

g_obj_harm =  @(env) g_obj_h1(env) + g_obj_h2(env) + g_obj_h3(env) + g_obj_h4(env) > 0;



%% ========================================================================
%%
%%  Niveau sonore, écoulement...
%%
%% =========================================================================

data = readmatrix([env.Root, '\Optimisation\Optimisation REAR\stator_spectrum_data.txt'], ...
               'CommentStyle', '#');
f1 = data(:,1); 
f2 = data(:,2);
fmean = data(:, 3);
mf2500 = fmean < 2500;
DSP_dB = data(:,5); % (dB re p0^2/Hz)
df = f2 - f1;

% Linéarisation de la densité spectrale de puissance (Pa^2/Hz)
DSP = (env.p_ref^2) * 10.^(DSP_dB/10);
L_tiers = compute_third_octave(fmean, DSP, env.w/(2*pi));
M = 0.1;
env = handle_env(L_tiers, M);
% env0 = handle_env(dB, 0);

%% =========================================================================
%%
%%   Paramètres géométriques invariants
%%
%% =========================================================================

total_thickness  = 117e-3;
width            = 30e-3;
depth            = 30e-3;
cavities_width   = 28e-3;
cavities_depth   = 28e-3;
input_surface    = width * depth;
plate_thickness  = 2e-3;
depth_holes_number  = 18;
depth_holes_distance = ETS_cav_depth / (depth_holes_number + 1);

% Liste des diamètres de foret en pouces

diameters_mm = [ ...
    0.508, 0.521, 0.533, 0.559, 0.584, 0.589, ...
    0.711, 0.794, 0.737, 0.787, 0.812, 0.838, ...
    0.891, 0.914, 0.953, 0.965, 1.016];

drill_tag = {'#76','#75','#74','#73','#72','#71', ...
                '#70','1/32','#69','#68','#67','#66', ...
                '#65','#64','#63','#62','#61'};

radius_m = @(i) diameters_mm(i) / 2 * 1e-3;

%% =========================================================================
%%
%% Structure des variables optimisées
%%
%% =========================================================================

NS = 4; % Nombre de MPPSBH 
NV = 3; % Nombre de variables
N = 6; % Nombre de plaques 

% NP = 500; % Nombre de points de départ
% NP = 100;
NP = 50;
% NP = 10;
% NP = 5;
% NP = 2;

cavities_total_thickness = total_thickness - N * plate_thickness;

%% =========================================================================
%%
%% Valeurs limites, contraintes entières, contraintes non linéaires
%%
%% =========================================================================

% Valeurs minimales

r_min = 1;
nb_w_min = 1;
theta_min = 1;
phi_min = 0.01;
phi_max = 0.3;
lb = horzcat(repmat(r_min, 1, N * NS), repmat(nb_w_min, 1, N * NS), repmat(theta_min, 1, N)); %#ok<RPMT1> % NV * N * NS

% Valeurs maximales

r_max = 17;
nb_w_max = 18;
theta_max = 5;
ub = horzcat(repmat(r_max, 1, N * NS), repmat(nb_w_max, 1, N * NS), repmat(theta_max, 1, N)); % NV * N * NS

% Valeurs initiales 

r_init = randi([r_min, r_max], NP, N * NS);
nb_w_init = randi([nb_w_min, nb_w_max], NP, N * NS); 
theta_init = theta_min + (theta_max - theta_min) * rand(NP, N * NS);
x0 = horzcat(r_init, nb_w_init, theta_init);

% Contrainte sur les variables entières

intcon = find(horzcat(ones(1, N * NS), ones(1, N * NS), zeros(1, N * NS)));

% Récupération des variables

config_NS_N_NV = @(x) reshape(x, NS, N, NV);
config_NV_N_NS = @(x) permute(config_NS_N_NV(x), [3 2 1]);
config_NV_N_X_NS = @(x) reshape(config_NV_N_NS(x), NV, []);
get_var = @(x, i) reshape((feval(@(tmp) tmp(i, :, :), config_NV_N_NS(x))), 1, []); %#ok<FVAL>
get_sol = @(x, i) reshape((feval(@(tmp) tmp(i, :, :), config_NS_N_NV(x))), 1, []); %#ok<FVAL>

% Contraintes non linéaires

slit_width_hdl = @(radius, nb_width, theta) (nb_width - 1) .* 3 .* radius + 2 .* radius;
real_porosity_hdl = @(radius, nb_width, theta) (nb_width * depth_holes_number) .* pi .* radius.^2 / (cavities_width * cavities_depth);

slit_width_cstr = @(M) slit_width_hdl(radius_m(M(1,:)), M(2,:), M(3,:)) - cavities_width; % slit_width < cavities_width
real_porosity_inf_cstr = @(M) phi_min - real_porosity_hdl(radius_m(M(1,:)), M(2,:), M(3,:)) - phi_min; % phi > phi_min
real_porosity_sup_cstr = @(M) real_porosity_hdl(radius_m(M(1,:)), M(2,:), M(3,:)) - phi_max; % phi < phi_max

neq_cstr = {slit_width_cstr, real_porosity_inf_cstr, real_porosity_sup_cstr};
eq_cstr = {};

function [c, c_eq] = nonlconFcn(neq_cstr, eq_cstr, config_NV_N_X_NS)
    
    c = []; c_eq = [];
    for i = 1:length(neq_cstr)
        c = horzcat(c, neq_cstr{i}(config_NV_N_X_NS)); %#ok<AGROW>
    end

    for i = 1:length(eq_cstr)
        c_eq = horzcat(c_eq, eq_cstr{i}(config_NV_N_X_NS)); %#ok<AGROW>
    end
end

nonlconFcn_hdl = @(x) nonlconFcn(neq_cstr, eq_cstr, config_NV_N_X_NS(x));

%% =========================================================================
%%
%% Création des objets dynamiques
%%
%% =========================================================================

Objets = struct();

Objets.MPPSBH_i = @(config, i) classMPPSBH_Rectangular( ...
    classMPPSBH_Rectangular.create_explicit_rectangular_pattern_config( ...
        input_surface, ...
        N, ...
        ETS_cav_depth, ...
        ETS_cav_width, ...
        num2cell(radius_m(config(i, :, 1))), ...                  % radius
        num2cell(radius_m(config(i, :, 1)) * 3), ...              % dw
        repmat({depth_holes_distance}, 1, N),... 
        repmat({depth_holes_number}, 1, N),  ...
        num2cell(config(i, :, 2)), ...                   % pw
        repmat({ETS_plate_thickness}, 1, N), ...
        num2cell(perso_simplex_map(config(i, :, 3), cavities_total_thickness)) ...
        ) ...
    );

Objets.cell_of_MPPSBH = @(x) arrayfun( ...
    @(i) Objets.MPPSBH_i(config_NS_N_NV(x), i), 1:NS, 'UniformOutput', false);

Objets.assembly = @(x) ...
    classelementassembly( ...
        classelementassembly.create_config( ...
            Objets.cell_of_MPPSBH(x) ...
        ) ...
    );

%% ========================================================================
%%
%% Fonctions coût multi-objectifs 
%%
%% ========================================================================

handle_alpha = @(x, env, g_obj) subsref( ...
    Objets.assembly(x).absorption_coefficient(env, struct('HL_method','linear')), ...
    substruct('()', {g_obj(env)}));

handle_cost_one = @(x, env, g_obj) mean(1 - handle_alpha(x, env, g_obj));

handle_objective = @(x, env, g_cells) ...
    arrayfun(@(k) handle_cost_one(x, env, g_cells{k}), ...
             1:length(g_cells));

% objective = @(x) ...
%     handle_objective(x, env, {g_obj_h1, g_obj_h2, g_obj_h3, g_obj_h4, g_obj_lb});

objective = @(x) ...
    handle_objective(x, env, {g_obj_h1, g_obj_h2, g_obj_lb});

%% ========================================================================
%%
%% Lancement de(s) l'optimisation(s)
%%
%% ========================================================================

% % =======================
% % MULTI-OBJECTIVE NSGA-II
% % =======================
% 
% [xopti, fval, population, scores, eflag, timeNSGA2] = ...
%     run_nsga2_block( ...
%         objective, lb, ub, intcon, nonlconFcn_hdl, ...
%         x0, NP, ...
%         'MaxGen', 100, ...
%         'Pc', 0.5, ...
%         'Pm', 0.1, ...
%         'EtaC', 20, ...
%         'EtaM', 20, ...
%         'Display', "iter", ...
%         'FunctionTolerance', 1e-1, ...
%         'ConstraintTolerance', 1e-6, ...
%         'PlotFcn', {@nsga2_plot_pareto, @nsga2_plot_rank_diversity} ...
%     );

% ======================
% GENETIC ALGORITHM (GA)
% ======================

optionsGA = optimoptions('gamultiobj', ...
    'Display', 'iter', ...
    'PopulationSize', NP, ...
    'InitialPopulationMatrix', x0, ...
    'FunctionTolerance', 1e-1, ...
    'ConstraintTolerance', 1e-6, ...
    'MaxStallGenerations', 5, ...
    'MaxGenerations', 100, ...
    'MutationFcn', 'mutationadaptfeasible', ...
    'CrossoverFraction', 0.5, ...
    'MigrationInterval', 10, ...
    'MigrationFraction', 0.3, ...
    'PlotFcn', { ...
         @gaplotpareto, ...         % Pareto front
         @gaplotscorediversity ...  % Diversité
         % @(x,optimValues,state) perso_plot_constraints_violation(x,optimValues,state,Config)
     } ...
);

rng;  % Reproductibilité
tic;
[xopti, fval, eflag, outputGA, population, scores] = ...
    gamultiobj(objective, numel(x0(1,:)), ...
               [], [], [], [], ...
               lb, ub, ...
               nonlconFcn_hdl, ...
               intcon, ...
               optionsGA);
timeGA = toc;

%% ========================================================================
%%
%%  Conditionnement des configurations optimisées
%%
%% ========================================================================

xopti_to_cell_array_of_alpha = @(x, env) arrayfun(@(i) vertcat(Objets.assembly(x(i, :)).absorption_coefficient(env, struct('HL_method', 'linear'))), ...
                                                       1:size(x, 1), 'UniformOutput', false);


xopti_to_cell_array_of_Zs = @(x, env) arrayfun(@(i) vertcat(Objets.assembly(x(i, :)).surface_impedance(env, {})/env.air.parameters.Z0), ...
                                                    1:size(x, 1), 'UniformOutput', false);

% % On récupère les vecteurs d'absorption des meilleures configurations
% pareto_rank = scores(:,1);     % rang (1=front de Pareto)
% crowding    = scores(:,2);     % diversité
% 
% % Tri : meilleur rang, puis plus grande crowding distance
% [~, idx_sorted] = sortrows([pareto_rank crowding], [1 -2]);
% 
% sorted_xopti = xopti(idx_sorted, :);

[sorted_scores_opti, sorted_index_opti] = sort(fval);
sorted_xopti = xopti(sorted_index_opti(:, 1), :);

filtered_alpha = xopti_to_cell_array_of_alpha(sorted_xopti, env);
filtered_Zs = xopti_to_cell_array_of_Zs(sorted_xopti, env);

% Tracé interractif des meilleurs résultats de l'optimisation multi objectif
perso_interactive_multi_plot(env.w/(2*pi), filtered_alpha, filtered_Zs, 2000, Frequences);

% On rajoute des barres pour représenter les bandes d'optimisation
perso_plot_targetted_frequencies(Frequences, 1);

% selected_index = [40, 138, 198, 330, 449];
selected_index = input('Liste des configurations sélectionnées : ');

selected_xopti = xopti(selected_index, :);
alpha_selected = filtered_alpha(selected_index);
selected_assembly = arrayfun(@(i) Objets.assembly(selected_xopti(i,:)), 1:size(selected_xopti, 1), 'UniformOutput', false);

%% ========================================================================
%%
%%  Analyse détaillée des variables optimisée
%% ========================================================================
% 
% disp("=== MODULE F : Analyse détaillée des variables optimisées (1 run) ===");
% 
% % On suppose qu'il n'y a qu'un seul run, donc results(1)
% if ~isfield(results(1),'X') || isempty(results(1).X)
%     warning("Le run ne contient pas de X. Analyse impossible.");
%     return;
% end
% 
% X = results(1).X;    % Population finale optimisée
% Nk = size(X,1);
% 
% % Extraction variables (comme tu l'as défini)
% r_vals  = X(:, 1:NS);
% nL_vals = X(:, NS+1 : 2*NS);
% nP_vals = X(:, 2*NS+1 : 3*NS);
% por_vals = nL_vals .* nP_vals .* (pi .* r_vals.^2) / acoustic_section;
% 
% %% =========================================================================
% % 1) HISTOGRAMMES PAR TYPE DE VARIABLE
% % =========================================================================
% 
% figure; 
% tiledlayout(2,2,"TileSpacing","compact"); 
% 
% nexttile;
% histogram(r_vals(:), 25, 'Normalization','pdf');
% title("Distribution du rayon r (tous SDOF)");
% xlabel("r (m)");
% 
% nexttile;
% histogram(nL_vals(:), 25, 'Normalization','pdf');
% title("Distribution du nombre de lignes nL");
% xlabel("nL");
% 
% nexttile;
% histogram(nP_vals(:), 25, 'Normalization','pdf');
% title("Distribution du nombre de colonnes nP");
% xlabel("nP");
% 
% nexttile;
% histogram(por_vals(:), 25, 'Normalization','pdf');
% title("Distribution de la porosité finale");
% xlabel("porosité");
% 
% sgtitle("Histogrammes globaux des variables optimisées");
% 
% %% =========================================================================
% % 2) HISTOGRAMMES PAR SDOF (r, porosité)
% % =========================================================================
% figure;
% tiledlayout(NS,2,"TileSpacing","compact");
% 
% for j = 1:NS
%     nexttile;
%     histogram(r_vals(:,j), 20, 'Normalization', 'pdf');
%     title(sprintf("SDOF %d : r_j", j));
% 
%     nexttile;
%     histogram(por_vals(:,j), 20, 'Normalization', 'pdf');
%     title(sprintf("SDOF %d : porosité_j", j));
% end
% sgtitle("Distributions r_j et porosité_j par SDOF");
% 
% %% =========================================================================
% % 3) SCATTER PAIRS
% % =========================================================================
% 
% figure; tiledlayout(2,2,"TileSpacing","compact");
% 
% nexttile;
% scatter(r_vals(:), por_vals(:), 20, 'filled');
% xlabel("r"); ylabel("Porosité");
% title("r vs porosité");
% 
% nexttile;
% scatter(r_vals(:), nL_vals(:), 20, 'filled');
% xlabel("r"); ylabel("nL");
% title("r vs nL");
% 
% nexttile;
% scatter(r_vals(:), nP_vals(:), 20, 'filled');
% xlabel("r"); ylabel("nP");
% title("r vs nP");
% 
% nexttile;
% scatter(por_vals(:), nL_vals(:), 20, 'filled');
% xlabel("porosité"); ylabel("nL");
% title("porosité vs nL");
% 
% sgtitle("Relations entre variables (toutes dimensions confondues)");
% 
% %% =========================================================================
% % 4) BOXPLOTS GLOBAUX
% % =========================================================================
% 
% figure;
% boxplot([r_vals(:) nL_vals(:) nP_vals(:) por_vals(:)], ...
%         'Labels', {'r','nL','nP','porosité'});
% title("Boxplots des variables optimisées");
% 
% %% =========================================================================
% % 5) MATRICE DE CORRÉLATION
% % =========================================================================
% 
% DATA = [r_vals(:) nL_vals(:) nP_vals(:) por_vals(:)];
% C = corrcoef(DATA);
% 
% figure;
% heatmap({'r','nL','nP','poro'}, {'r','nL','nP','poro'}, C, ...
%     'Colormap', parula, 'ColorLimits', [-1 1]);
% title("Matrice de corrélation entre variables optimisées");
% 
% %% =========================================================================
% % 6) Statistiques globales
% % =========================================================================
% 
% Stats.mean_r = mean(r_vals(:));
% Stats.std_r  = std(r_vals(:));
% Stats.min_r  = min(r_vals(:));
% Stats.max_r  = max(r_vals(:));
% 
% Stats.mean_poro = mean(por_vals(:));
% Stats.std_poro  = std(por_vals(:));
% 
% disp("=== STATISTIQUES DES VARIABLES OPTIMISEES ===");
% disp(Stats);
% 
% disp("=== FIN MODULE F ===");

%% ========================================================================
%%
%%  Sauvergarde
%%
%% ========================================================================

env_saved = input('Sauvegarder l''environnement d''optimisation : ');

if env_saved ~= 1
    return
end

folder_full_name = uigetdir();
mkdir([folder_full_name, '\Assemblages Solidworks']);
save([folder_full_name, '\environnement matlab.mat']);

%% ========================================================================
%%
%% Validation
%%
%% ========================================================================

validation_folder_name = [folder_full_name, '\Validation'];
mkdir(validation_folder_name);

for i = 1:length(selected_index)

        sub_folder_name = [validation_folder_name, '\Configuration ', num2str(selected_index(i))];
        mkdir(sub_folder_name);

    for j = 1:NS

        sub_sub_folder_name = [sub_folder_name, '\MPPSBH ', num2str(j)];
        mkdir(sub_sub_folder_name);

        points_FEM = 10;
        env_FEM = handle_env_FEM(points_FEM);
        try
            MPPSBH = Objets.MPPSBH_i(config_NS_N_NV(selected_xopti(i,:)), j);
        catch
            continue
        end
        
        Tube3D_ap = ImpedanceTube3D(ImpedanceTube3D.create_config({MPPSBH}));
        Tube3D_ap = Tube3D_ap.launch_tube_measurement_ap(env_FEM);
        mphsave(Tube3D_ap.Configuration.ComsolModel, [sub_sub_folder_name, '\modèle numérique 3D-AP']);
        
        % Performance
        figure();
        hold on
        Tube3D_ap.plot_alpha('Modélisation numérique 3D - AP');
        alpha = MPPSBH.absorption_coefficient(env, struct('HL_method', 'linear'));
        plot(env.w/(2*pi), alpha, 'DisplayName', 'Modèle analytique linéaire');
        xlim([fmin, fmax])
        legend('Location','best')
        saveas(gcf, [sub_sub_folder_name, '\Performances', '.fig']);
        close(gcf);

        % Géométrie
        figure()
        mphgeom(Tube3D_ap.Configuration.ComsolModel);
        saveas(gcf, [sub_sub_folder_name, '\Géométrie', '.fig']);
        close(gcf);
    end
end

%% ========================================================================
%%
%% Géométries Solidworks
%%
%% ========================================================================

sdk_folder_name = [folder_full_name, '\Assemblages Solidworks'];
mkdir(sdk_folder_name);

for i = 1:length(selected_index)

        sub_folder_name = [sdk_folder_name, '\Configuration ', num2str(selected_index(i))];
        mkdir(sub_folder_name);

    for j = 1:NS

        sub_sub_folder_name = [sub_folder_name, '\MPPSBH ', num2str(j)];
        mkdir(sub_sub_folder_name);

        points_FEM = 10;
        env_FEM = handle_env_FEM(points_FEM);
        try
            MPPSBH = Objets.MPPSBH_i(config_NS_N_NV(selected_xopti(i,:)), j);
        catch
            continue
        end
        
        Tube3D_ap = ImpedanceTube3D(ImpedanceTube3D.create_config({MPPSBH}));
        Tube3D_ap = Tube3D_ap.launch_tube_measurement_ap(env_FEM);
        mphsave(Tube3D_ap.Configuration.ComsolModel, [sub_sub_folder_name, '\modèle numérique 3D-AP']);
        
        % Performance
        figure();
        hold on
        Tube3D_ap.plot_alpha('Modélisation numérique 3D - AP');
        alpha = MPPSBH.absorption_coefficient(env, struct('HL_method', 'linear'));
        plot(env.w/(2*pi), alpha, 'DisplayName', 'Modèle analytique linéaire');
        xlim([fmin, fmax])
        legend('Location','best')
        saveas(gcf, [sub_sub_folder_name, '\Performances', '.fig']);
        close(gcf);

        % Géométrie
        figure()
        mphgeom(Tube3D_ap.Configuration.ComsolModel);
        saveas(gcf, [sub_sub_folder_name, '\Géométrie', '.fig']);
        close(gcf);
    end
end

%% ========================================================================
%%
%% Validation
%%
%% ========================================================================
%% ========================================================================
%%
%% Performances des configurations optimisées
%%
%% ========================================================================

% x_TP_ETS(x_opti);
% x_TP_Poly(x_opti);
% top_plate(x_TP_ETS(x_opti)).Configuration % Plaque ETS
% top_plate(x_TP_Poly(x_opti)).Configuration % Plaque Poly
% 
% perso_figure('Prédiction des performances de la configuration optimale');
% hold on
% title('Prédiction des performances de la configuration optimale');
% perso_plot_targetted_frequencies(Frequences, 1);
% perso_configure_alpha_figure(3000);
% 
% saveas(gcf, [folder_full_name, '\Figures\Prédiction des performances de la configuration optimale.fig']);
% 
% perso_figure('Surface d''impédance de la configuration optimale')
% hold on
% title('Surface d''impédance de la configuration optimale');
% perso_plot_surface_impedance(Cartouches.cartouche_globale(x_opti).surface_impedance(env), env, 'Cartouche globale');
% % perso_plot_surface_impedance(Cartouches.cartouche_globale_HL_fp(x_opti).surface_impedance(env), env, 'Cartouche globale HL fp');
% perso_plot_surface_impedance(Cartouches.cartouche_globale_HL_iter(x_opti).surface_impedance_iter(env), env, 'Cartouche globale HL iter');
% 
% saveas(gcf, [folder_full_name, '\Figures\Surface d''impédance de la configuration optimale.fig']);
% 
% perso_figure('Prédiction des performances de la cartouche ETS');
% hold on
% title('Prédiction des performances de la cartouche ETS');
% Cartouches.cartouche_ETS(x_opti).plot_alpha(env, 'Cartouche ETS');
% % Cartouches.cartouche_ETS_HL_fp(x_opti).plot_alpha(env, 'Cartouche v HL fp');
% Cartouches.cartouche_ETS_HL_iter(x_opti).plot_alpha(env, 'Cartouche ETS HL fp iter', 'iter');
% perso_plot_targetted_frequencies(Frequences, 1);
% perso_configure_alpha_figure(3000);
% 
% saveas(gcf, [folder_full_name, '\Figures\Prédiction des performances de la cartouche ETS.fig']);
% 
% perso_figure('Surface d''impédance de la cartouche ETS')
% hold on
% title('Surface d''impédance de la cartouche ETS');
% perso_plot_surface_impedance(Cartouches.cartouche_ETS(x_opti).surface_impedance(env), env, 'cartouche ETS');
% % perso_plot_surface_impedance(Cartouches.cartouche_ETS_HL_fp(x_opti).surface_impedance(env), env, 'cartouche ETS HL fp');
% perso_plot_surface_impedance(Cartouches.cartouche_ETS_HL_iter(x_opti).surface_impedance_iter(env), env, 'cartouche ETS HL iter');
% 
% saveas(gcf, [folder_full_name, '\Figures\Surface d''impédance de la cartouche ETS.fig']);
% 
% perso_figure('Prédiction des performances de la cartouche Poly');
% hold on
% title('Prédiction des performances de la cartouche Poly');
% Cartouches.cartouche_Poly(x_opti).plot_alpha(env, 'Cartouche Poly');
% % Cartouches.cartouche_Poly_HL_fp(x_opti).plot_alpha(env, 'Cartouche v HL fp');
% Cartouches.cartouche_Poly_HL_iter(x_opti).plot_alpha(env, 'Cartouche Poly HL fp iter', 'iter');
% perso_plot_targetted_frequencies(Frequences, 1);
% perso_configure_alpha_figure(3000);
% 
% saveas(gcf, [folder_full_name, '\Figures\Prédiction des performances de la cartouche Poly.fig']);
% 
% perso_figure('Surface d''impédance de la cartouche Poly')
% hold on
% title('Surface d''impédance de la cartouche Poly');
% perso_plot_surface_impedance(Cartouches.cartouche_Poly(x_opti).surface_impedance(env), env, 'cartouche Poly');
% % perso_plot_surface_impedance(Cartouches.cartouche_Poly_HL_fp(x_opti).surface_impedance(env), env, 'cartouche Poly HL fp');
% perso_plot_surface_impedance(Cartouches.cartouche_Poly_HL_iter(x_opti).surface_impedance_iter(env), env, 'cartouche Poly HL iter');
% 
% saveas(gcf, [folder_full_name, '\Figures\Surface d''impédance de la cartouche Poly.fig']);

% %% Validation des contributions individuelles

%% ========================================================================
%%
%% Sauvegarde des rapports de configuration
%%
%% ========================================================================
% 
% % Rapport de configuration des plaques couvrantes
% report_root = [folder_full_name, '\Rapports de configuration des plaques couvrantes'];
% mkdir(report_root);
% 
% perso_top_plate_export_report(x_TP_ETS(x_opti), radius, [report_root, '\rapport de configuration plaque ETS.xlsx']);
% perso_top_plate_export_report(x_TP_Poly(x_opti), radius, [report_root, '\rapport de configuration plaque Poly.xlsx']);
% 
% % Rapport de configuration des MPPSBHs
% report_root = [folder_full_name, '\Rapports de configuration des MPPSBHs'];
% mkdir(report_root);
% 
% for i = 1:NS
%     Objets.MPPSBH_i(x_ETS(x_opti), radius(x_radius(x_opti)), i).export_report([report_root, '\rapport de configuration - MPPSBH ', num2str(i), '.xlsx'])
% end



