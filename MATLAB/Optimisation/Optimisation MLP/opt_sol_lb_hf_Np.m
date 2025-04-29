%% Paramètres des solutions optimisées

NS = 4; % Nombre de solutions
NV = 4; % Nombre de variables pour chaque solution
N =  6; %  Nombre de plaques pour chaque solution
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
cavities_width = 29e-3; % parois inter-cellulaire de 1mm
plates_thickness = 2e-3;
total_thickness = 100e-3;
rigid_backing_thickness = 2e-3;

%% Valeurs initiales en fonction du types de variable
r_init = randi([1, 2], N, 1, NS);
dw_init = 4 * eval_r(r_init);
pd_init = randi([7, 11], N, 1, NS);
pw_init = randi([1, 6], N, 1, NS);
x0 = horzcat([r_init, dw_init, pd_init, pw_init]);

%% Matrices des bornes INF et SUP en fonction des types de variable
lb = repmat([1, 4 * eval_r(1), 5, 1], N, 1, NS);  
ub = repmat([2, 35e-4, 11, 10], N, 1, NS); 

%% Contrainte sur les variables entières
intcon = find(repmat([1 0 1 1], N, 1, NS)); 

%% Fonction de définitions de la matrice de contraintes non linéaires  

% Définition du handle avec paramètres capturés
handle_perso_nonlcon = @(x) perso_MPPSBHr_nonlconf(x, NV, NS, N, cavities_width, cavities_depth, eval_r);

%% Gabarit

% Définition des plages fréquentielles d'interet pour la fonction cout
g_lb_hf = @(env) (env.w / (2*pi) > f_min_bf & env.w / (2*pi) < f_max_lb_hf);

%% Fonction coût

x0_to_MPPSBH_i = @(x0, i) classMPPSBH_Rectangular(classMPPSBH_Rectangular.create_explicit_config(N, cavities_depth, cavities_width, ...
                                                                                                {transpose(x0(:, 2, i) .* x0(:, 4, i))}, ... % largeur des fentes
                                                                                                {eval_r(x0(:, 1, i))}, ...  % rayon des perforations
                                                                                                {transpose(x0(:, 2, i))}, ... % distance entre les perforations dans le sens de la largeur
                                                                                                {transpose(x0(:, 3, i))}, ... % nombre de perforations dans le sens de la profondeur
                                                                                                {transpose(x0(:, 4, i))}, ... % nombre de perforations dans le sens de la largeur
                                                                                                {plates_thickness}, ... épaisseur des plaques
                                                                                                {round((total_thickness - rigid_backing_thickness - plates_thickness*N) / N, 4)}));

x0_to_list_of_MPPSBH = @(x0, NS) arrayfun(@(i) x0_to_MPPSBH_i(x0, i), 1:NS, 'UniformOutput', false);

params_to_MPPSBH_assembly = @(x0) classelementassembly(x0_to_list_of_MPPSBH(x0, NS));

cost_function = @(x0, env) sum(((params_to_MPPSBH_assembly(x0).alpha(env) - g_lb_hf(env)) .* (g_lb_hf(env) > 0.1)).^2);

objective = @(x0) cost_function(reshape(x0, N, NV, NS), env);

%% Genetic Algorithm

% gaplotfeasibility = @(options, state, flag) perso_gaplotfeasibility(handle_perso_nonlcon, options, state, flag);

options = optimoptions('ga', ...
                       'Display', 'iter', ...
                       'PlotFcn',  {@gaplotbestf, @gaplotmaxconstr, @gaplotbestindiv}, ... % {@gaplotfeasibility}, ... % {@perso_plotMaxDistancePlotFcn}
                       'FunctionTolerance', 1e-6, ...
                       'MaxStallGenerations', 20, ...
                       'MaxGenerations', 200, ...
                       'MutationFcn', {@mutationadaptfeasible, 1, 1}, ... 
                       'InitialPopulationMatrix', reshape(x0, 1, [])); 

rng; % For reproducibility"
tic;
[xopti_lb_hf, fval, eflag, output, population, scores] = ga(objective, numel(x0), [], [], [], [], lb, ub, handle_perso_nonlcon, intcon, options);
timeGa = toc;


%% Résultats

% Solutions et configurations optimisée
assembly_lb_hf_opti = params_to_MPPSBH_assembly(reshape(xopti_lb_hf, N, NV, NS));
MPPSBH_lb_hf_1 = assembly_lb_hf_opti.ListOfElements{1};
MPPSBH_lb_hf_2 = assembly_lb_hf_opti.ListOfElements{2};
MPPSBH_lb_hf_3 = assembly_lb_hf_opti.ListOfElements{3};
MPPSBH_lb_hf_4 = assembly_lb_hf_opti.ListOfElements{4};
MPPSBH_lb_hf_1_config = MPPSBH_lb_hf_1.Configuration;
MPPSBH_lb_hf_2_config = MPPSBH_lb_hf_2.Configuration;
MPPSBH_lb_hf_3_config = MPPSBH_lb_hf_3.Configuration;
MPPSBH_lb_hf_4_config = MPPSBH_lb_hf_4.Configuration;

% Affichage graphique
figure()
plot(env.w/(2*pi), g_lb_hf(env) ,"--", env.w/ (2*pi), assembly_lb_hf_opti.alpha(env));
xlim([0 2000]);

% % Validation numérique
% Tube_lb_hf = ImpedanceTube2D(ImpedanceTube2D.create_config(assembly_lb_hf_opti.ListOfElements));
% Tube_lb_hf = Tube_lb_hf.lauch_tube_measurement();
% Tube_lb_hf.plot_alpha(env, 'solution large bande');
% mphsave(Tube_lb_hf.Configuration.ComsolModel, ['E:\OneDrive - ETS\CRIAQ-REAR\Maitrise LB\' ...
%                                             'Présentations\Présentations Thomas\25.04.08 - résultats optimisation pour Hutchinson\' ...
%                                             'validation numérique haute fréquence 2 solutions'])

% Indicateurs
alpha_mean_lb_hf_in_band = assembly_lb_hf_opti.alpha_mean(env, f_min_lb_hf, f_max_lb_hf);
alpha_mean_lb_hf_out_band = assembly_lb_hf_opti.alpha_mean(env, f_min_bf, f_max_mb_mf);
alpha_mean = assembly_lb_hf_opti.alpha_mean(env, f_min_bf, f_max_lb_hf);


