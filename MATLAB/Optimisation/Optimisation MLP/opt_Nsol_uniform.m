%% Paramètres des solutions optimisées

NS = 4; % Nombre de solutions
NV = 4; % Nombre de variables pour chaque solution
N =  1; %  Nombre de plaques (différentes) pour chaque solution
% N =  10; %  Nombre de plaques pour chaque solution
% perforations_radius_values = [4.5e-4 4.75e-4, 5e-4, 5.25e-4, 5.5e-4, 5.75e-4, 6e-4, 6.25e-4];
perforations_radius_values = [4.5e-4 4.75e-4];
eval_r = @(i) perforations_radius_values(i);
f_min_bf = 150;
f_max_bf = 400;
f_min_mb_mf = 400;
f_max_mb_mf = 600;
f_min_lb_hf = 600;
f_max_lb_hf = 1500;

%% Paramètres géométriques invariants
cavities_depth = 28e-3;
cavities_width = 29e-3; % parois inter-cellulaire de 1 mm
plates_thickness = 2e-3;
to_plate_thickness = 1e-3;
total_thickness = 100e-3;
rigid_backing_thickness = 2e-3;

%% Valeurs initiales en fonction du types de variable
r_init = randi([1, 2], N, 1, NS);
dw_init = reshape(4 * eval_r(r_init), N, 1, NS);
pd_init = randi([8, 11], N, 1, NS);
pw_init = randi([1, 7], N, 1, NS);
x0 = horzcat([r_init, dw_init, pd_init, pw_init]);

%% Matrices des bornes INF et SUP en fonction des types de variable
lb = repmat([1, 4 * eval_r(2), 5, 1], N, 1, NS);  
ub = repmat([2, 35e-4, 11, 10], N, 1, NS); 

%% Contrainte sur les variables entières
intcon = find(repmat([1 0 1 1], N, 1, NS)); 

%% Fonction de définitions de la matrice de contraintes non linéaires  

% Définition du handle avec paramètres capturés
handle_perso_nonlcon = @(x) perso_MPPSBHr_nonlconf(x, NV, NS, N, cavities_width, cavities_width, eval_r);

%% Gabarit

% Définition des plages fréquentielles d'interet pour la fonction cout
g_bf = @(env) (env.w / (2*pi) > f_min_bf & env.w / (2*pi) < f_max_lb_hf);
% g_lb_hf = @(env) (env.w / (2*pi) > f_min_lb_hf & env.w / (2*pi) < f_max_lb_hf);

%% Fonction coût

x0_to_MPPSBH_i = @(x0, i) classMPPSBH_Rectangular(classMPPSBH_Rectangular.create_explicit_config(10, cavities_depth, cavities_width, ...
                                                                                                {transpose(x0(:, 2, i) .* x0(:, 4, i))}, ... % largeur des fentes
                                                                                                {eval_r(x0(:, 1, i))}, ...  % rayon des perforations
                                                                                                {transpose(x0(:, 2, i))}, ... % distance entre les perforations dans le sens de la largeur
                                                                                                {transpose(x0(:, 3, i))}, ... % nombre de perforations dans le sens de la profondeur
                                                                                                {transpose(x0(:, 4, i))}, ... % nombre de perforations dans le sens de la largeur
                                                                                                {plates_thickness}, ... épaisseur des plaques
                                                                                                {round((total_thickness - rigid_backing_thickness - plates_thickness*N) / N, 4)}));

x0_to_list_of_MPPSBH = @(x0, NS) arrayfun(@(i) x0_to_MPPSBH_i(x0, i), 1:NS, 'UniformOutput', false);

params_to_MPPSBH_assembly = @(x0) classelementassembly(classelementassembly.create_config(x0_to_list_of_MPPSBH(x0, NS)));

cost_function = @(x0, env) sum(((params_to_MPPSBH_assembly(x0).alpha(env) - g_bf(env)) .* (g_bf(env) > 0.1)).^2);

objective = @(x0) cost_function(reshape(x0, N, NV, NS), env);

%% Fonction cout pondéree
% cost_function = @(x0, env, weighting) ...
%     sum( ...
%         ((params_to_MPPSBH_assembly(x0).alpha(env) - g_bf(env)) ... % calcul des écart à l'absorption idéale
%         .* (g_bf(env) > 0.1)) ... % fenétrage
%         .^2 ...
%         .* weighting / sum(weighting(g_bf(env)))); % pondération 
% 
% % Pondération logarythmique
% weighting = perso_get_freq_log_weights(env.w/(2*pi));
% 
% objective = @(x0) cost_function(reshape(x0, N, NV, NS), env, weighting);

%% Genetic Algorithm

options = optimoptions('ga', ...
                       'Display', 'iter', ...
                       'PlotFcn', {@gaplotbestf, @gaplotmaxconstr, @gaplotbestindiv}, ...
                       'FunctionTolerance', 1e-6, ...
                       'MaxStallGenerations', 20, ...
                       'MaxGenerations', 200, ...
                       'MutationFcn', @mutationadaptfeasible, ... 
                       'InitialPopulationMatrix', reshape(x0, 1, [])); 

rng; % For reproducibility"
tic;
[xopti, fval, eflag, output, population, scores] = ga(objective, numel(x0), [], [], [], [], lb, ub, handle_perso_nonlcon, intcon, options);
timeGa = toc;


%% Résultats

% Solutions et configurations optimisée
assembly_bf_opti = params_to_MPPSBH_assembly(reshape(xopti, N, NV, NS));
MPPSBH_bf_1 = assembly_bf_opti.Configuration.ListOfElements{1};
% MPPSBH_bf_2 = assembly_bf_opti.Configuration.ListOfElements{2};
MPPSBH_bf_1_config = MPPSBH_bf_1.Configuration;
% MPPSBH_bf_2_config = MPPSBH_bf_2.Configuration;

% Affichage graphique
figure()
plot(env.w/(2*pi), g_bf(env) ,"--", env.w/ (2*pi), assembly_bf_opti.alpha(env));
xlim([0 2000]);

% % Validation numérique
% Tube_bf = ImpedanceTube2D(ImpedanceTube2D.create_config(assembly_bf_opti.ListOfElements));
% Tube_bf = Tube_bf.lauch_tube_measurement();
% Tube_bf.plot_alpha(env, 'solution basse fréquence');
% mphsave(Tube_bf.Configuration.ComsolModel, ['E:\OneDrive - ETS\CRIAQ-REAR\Maitrise LB\' ...
%                                             'Présentations\Présentations Thomas\25.04.08 - résultats optimisation pour Hutchinson\' ...
%                                             'validation numérique basse fréquence 1 solution'])

% Indicateurs
alpha_mean_bf_out_band = assembly_bf_opti.alpha_mean(env, f_min_mb_mf, f_max_lb_hf);
alpha_mean_bf_in_band = assembly_bf_opti.alpha_mean(env, f_min_bf, f_max_bf);
[f_peak_bf, alpha_peak_bf] = assembly_bf_opti.alpha_peak(env, f_min_bf, f_max_bf);

% % Export Solidworks
% MPPSBH_bf_1.launch_in_solidworks('MPPSBH_bf_1')