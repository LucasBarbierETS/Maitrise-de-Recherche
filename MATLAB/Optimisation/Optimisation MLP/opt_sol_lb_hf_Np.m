%% Paramètres des solutions optimisées

NS = 4; % Nombre de solutions
NV = 4; % Nombre de variables pour chaque solution
% NV = 2; % Nombre de variables pour chaque solution
N =  6; % Nombre de plaques pour chaque solution
% N =  10; %  Nombre de plaques pour chaque solution
NP = 100; % Nombre de points de départ

perforations_radius_values = [4.5e-4 4.75e-4, 5e-4, 5.25e-4, 5.5e-4, 5.75e-4, 6e-4, 6.25e-4];
eval_r = @(i) perforations_radius_values(i);
f_min_bf = 150;
f_max_bf = 400;
f_min_mb_mf = 400;
f_max_mb_mf = 600;
f_min_lb_hf = 600;
f_max_lb_hf = 1500;

%% Paramètres géométriques invariants
cavities_depth = 28e-3;
cavities_width = 28e-3; % parois inter-cellulaire de 1mm
top_plate_thickness = 1e-3;
plates_thickness = 2e-3;
total_thickness = 100e-3;
rigid_backing_thickness = 2e-3;
cavities_thickness = (total_thickness - rigid_backing_thickness - plates_thickness*(N-1)) / N;

%% Valeurs initiales en fonction du types de variable
r_init = randi([1, 2], N, 1, NS, NP);
dw_init = reshape(3 * eval_r(r_init), N, 1, NS, NP);
pd_init = randi([8, 12], N, 1, NS, NP);
pw_init = randi([1, 12], N, 1, NS, NP);

x0 = horzcat([r_init, dw_init, pd_init, pw_init]); % cat(2, ...
% x0 = cat(2, pd_init, pw_init);
x0_sorted = sort(x0, 1, "descend");

%% Matrices des bornes INF et SUP en fonction des types de variable
lb = repmat([1, 3 * eval_r(1), 5, 1], N, 1, NS);
% lb = repmat([5, 1], N, 1, NS);
ub = repmat([2, 6 * eval_r(1), 12, 12], N, 1, NS); 
% ub = repmat([12, 12], N, 1, NS);

%% Contrainte sur les variables entières
intcon = find(repmat([1 0 1 1], N, 1, NS)); 
% intcon = find(repmat([1 1], N, 1, NS)); 

%% Fonction de définitions de la matrice de contraintes non linéaires  

% Définition du handle avec paramètres capturés
handle_perso_nonlcon = @(x) perso_MPPSBHr_nonlconf(x, NV, NS, N, cavities_width, cavities_depth, eval_r);

%% Gabarit

% Définition des plages fréquentielles d'interet pour la fonction cout
g_lb_hf = @(env) (env.w / (2*pi) > f_min_bf & env.w / (2*pi) < f_max_lb_hf);

%% Fonction coût

% objet flottant à partir de 4 variables
x0_to_MPPSBH_i = @(x0, i) classMPPSBH_Rectangular(classMPPSBH_Rectangular.create_explicit_config(N, cavities_depth, cavities_width, ...
                                                                                                {transpose(x0(:, 2, i) .* x0(:, 4, i))}, ... % largeur des fentes
                                                                                                {eval_r(x0(:, 1, i))}, ...  % rayon des perforations
                                                                                                {transpose(x0(:, 2, i))}, ... % distance entre les perforations dans le sens de la largeur
                                                                                                {transpose(x0(:, 3, i))}, ... % nombre de perforations dans le sens de la profondeur
                                                                                                {transpose(x0(:, 4, i))}, ... % nombre de perforations dans le sens de la largeur
                                                                                                {top_plate_thickness, plates_thickness}, ... épaisseur des plaques
                                                                                                {round((total_thickness - rigid_backing_thickness - plates_thickness*N) / N, 4)}));

% % objet flottant à partir des nombres de perforations seulement
% x0_to_MPPSBH_i = @(x0, i) classMPPSBH_Rectangular(classMPPSBH_Rectangular.create_explicit_config(N, cavities_depth, cavities_width, ...
%                                                                                                 {3 * eval_r(1) .* x0(:, 2, i)}, ... % largeur des fentes
%                                                                                                 {eval_r(1)}, ...  % rayon des perforations
%                                                                                                 {3 * eval_r(1)}, ... % distance entre les perforations dans le sens de la largeur
%                                                                                                 {transpose(x0(:, 1, i))}, ... % nombre de perforations dans le sens de la profondeur
%                                                                                                 {transpose(x0(:, 2, i))}, ... % nombre de perforations dans le sens de la largeur
%                                                                                                 {plates_thickness}, ... épaisseur des plaques
%                                                                                                 {round((total_thickness - rigid_backing_thickness - plates_thickness*N) / N, 4)}));

x0_to_list_of_MPPSBH = @(x0, NS) arrayfun(@(i) x0_to_MPPSBH_i(x0, i), 1:NS, 'UniformOutput', false);

params_to_MPPSBH_assembly = @(x0) classelementassembly(classelementassembly.create_config(x0_to_list_of_MPPSBH(x0, NS)));

cost_function = @(x0, env) sum(((params_to_MPPSBH_assembly(x0).alpha(env) - g_lb_hf(env)) .* (g_lb_hf(env) > 0.1)).^2);

objective = @(x0) cost_function(reshape(x0, N, NV, NS), env);

% Genetic Algorithm

% gaplotfeasibility = @(options, state, flag) perso_gaplotfeasibility(handle_perso_nonlcon, options, state, flag);

options = optimoptions('ga', ...
                       'Display', 'iter', ...
                       'PlotFcn',  {@gaplotbestf, @gaplotmaxconstr, @gaplotbestindiv}, ... % {@gaplotfeasibility}, ... % {@perso_plotMaxDistancePlotFcn}
                       'PopulationSize', size(x0_sorted, 4), ... % nombre de points dans la population initiale
                       'FunctionTolerance', 1e-2, ...
                       'ConstraintTolerance', 1, ...
                       'MaxStallGenerations', 10, ...
                       'MaxGenerations', 50, ...
                       'MutationFcn',  'mutationadaptfeasible',... {@mutationgaussian, 2, 0.5}, ... %'mutationuniform', ... 
                       'CrossoverFraction', 0.5, ...
                       'MigrationInterval', 10, ...
                       'MigrationFraction', 0.3, ...
                       'InitialPopulationMatrix', reshape(permute(x0_sorted, [4, 1, 2, 3]), size(x0, 4), [])); 

rng; % For reproducibility"
tic;
[xopti_lb_hf, fval, eflag, output, population, scores] = ga(objective, numel(x0_sorted(:, :, :, 1)), [], [], [], [], lb, ub, handle_perso_nonlcon, intcon, options);
timeGa = toc;

% % Multistart
% 
% % Paramètres
% num_starts = 50; % Nombre de démarrages aléatoires
% 
% % Création de l'objet multistart
% ms = MultiStart('UseParallel', true, 'Display', 'iter');
% 
% % Fonction d'affichage de l'absorption de la meilleure configuration
% handle_plot_alpha = @(x, ~, ~) perso_plot_alpha(params_to_MPPSBH_assembly(reshape(x, N, NV, NS)).alpha(env), ...
%                                           env, ...
%                                           g_lb_hf);
% % Définition du problème d'optimisation
% options = optimoptions(@fmincon, ...
%                        'Algorithm', 'sqp', ...
%                        'Display', 'iter-detailed', ...
%                        'MaxIteration', 5, ...
%                        'ConstraintTolerance', 1, ...
%                        'FunctionTolerance', 1e-2, ...
%                        'StepTolerance', 1e-1); %, ...
%                        % 'OutputFcn', {@handle_plot_alpha});
% 
% random_start_point = @() fix(lb + rand(size(lb)) .* (ub - lb));
% sorted_start_point = @() sort(random_start_point(), 1, "descend");
% 
% problem = createOptimProblem('fmincon', 'objective', objective, 'x0', sorted_start_point(), 'lb', lb, 'ub', ub, 'nonlcon', handle_perso_nonlcon, 'intcon', intcon, options', options);
% [xopti_lb_hf, best_cost, ~, ~, local_optima] = run(ms, problem, num_starts);

%% Résultats

% Solutions et configurations optimisée
assembly_lb_hf_opti = params_to_MPPSBH_assembly(reshape(xopti_lb_hf, N, NV, NS));
MPPSBH_lb_hf_1 = assembly_lb_hf_opti.Configuration.ListOfElements{1};
MPPSBH_lb_hf_2 = assembly_lb_hf_opti.Configuration.ListOfElements{2};
MPPSBH_lb_hf_3 = assembly_lb_hf_opti.Configuration.ListOfElements{3};
MPPSBH_lb_hf_4 = assembly_lb_hf_opti.Configuration.ListOfElements{4};
MPPSBH_lb_hf_1_config = MPPSBH_lb_hf_1.Configuration;
MPPSBH_lb_hf_2_config = MPPSBH_lb_hf_2.Configuration;
MPPSBH_lb_hf_3_config = MPPSBH_lb_hf_3.Configuration;
MPPSBH_lb_hf_4_config = MPPSBH_lb_hf_4.Configuration;

% Affichage graphique
figure()
plot(env.w/(2*pi), g_lb_hf(env) , "--", env.w/ (2*pi), assembly_lb_hf_opti.alpha(env));
xlim([0 2000]);

% Indicateurs
alpha_mean_lb_hf_in_band = assembly_lb_hf_opti.alpha_mean(env, f_min_lb_hf, f_max_lb_hf);
alpha_mean_lb_hf_out_band = assembly_lb_hf_opti.alpha_mean(env, f_min_bf, f_max_mb_mf);
alpha_mean = assembly_lb_hf_opti.alpha_mean(env, f_min_bf, f_max_lb_hf);

%% Validation numérique
% Tube_lb_hf = ImpedanceTube2D(ImpedanceTube2D.create_config(assembly_lb_hf_opti.Configuration.ListOfElements));
% Tube_lb_hf = Tube_lb_hf.lauch_tube_measurement();
% Tube_lb_hf.plot_alpha(env, f_min_bf, f_max_lb_hf, 'solution large bande');
% mphsave(Tube_lb_hf.Configuration.ComsolModel, ['E:\Montréal 2023 - 2025\Maitrise LB\Présentations\Présentation groupe REAR\25.05.08 - configurations finales pour 1ère itération\' ...
%                                                'validation numérique de la solution fournie par ETS'])

%% Sauvegarde des rapport
% report_root = 'E:\Montréal 2023 - 2025\Maitrise LB\Présentations\Présentation groupe REAR\25.05.08 - configurations finales pour 1ère itération\';
MPPSBH_lb_hf_1.export_report([report_root, 'rapport de configuration - solution 1.xlsx'])
MPPSBH_lb_hf_2.export_report([report_root, 'rapport de configuration - solution 2.xlsx'])
MPPSBH_lb_hf_3.export_report([report_root, 'rapport de configuration - solution 3.xlsx'])
MPPSBH_lb_hf_4.export_report([report_root, 'rapport de configuration - solution 4.xlsx'])