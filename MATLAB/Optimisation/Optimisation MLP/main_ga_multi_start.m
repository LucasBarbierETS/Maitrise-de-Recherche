%% Paramètres de la procédure itérative

N_points = 20;  % Nombre de points de départ
tolerance_threshold = 150; % Valeur max pour le coût
crossover_threshold = 1e-3; % Distance max pour croisement
crossover_possible = true;
iter = 0; % Nombre d'itération de l'optimisation combinée

%% Paramètres des solutions optimisées

N_solutions = 4; % Nombre de solutions
N_variables = 4; % Nombre de variables pour chaque solution
N_plates =  6; % Nombre de plaques pour chaque solution

% perforations_radius_values = [4.5e-4 4.75e-4, 5e-4, 5.25e-4, 5.5e-4, 5.75e-4, 6e-4, 6.25e-4];
perforations_radius_values = [4.5e-4 4.75e-4];
eval_r = @(i) perforations_radius_values(i);

f_min = 150; % 1er pic à 2000 RPM
f_max = 1500; % Décroissance significative des harmoniques pour tous les régimes moteurs

%% Paramètres géométriques invariants
cavities_depth = 28e-3;
cavities_width = 29e-3; % parois inter-cellulaire de 1mm
top_plate_thickness = 1e-3; % perforations intégrées à la plaque couvrant le carénage
plates_thickness = 2e-3;
total_thickness = 100e-3;
rigid_backing_thickness = 2e-3;

%% Solution flottante

x0_to_MPPSBH_i = @(x0, i) classMPPSBH_Rectangular(classMPPSBH_Rectangular.create_explicit_config(N_plates, cavities_depth, cavities_width, ...
                                                                                                {transpose(x0(:, 2, i) .* x0(:, 4, i))}, ... % largeur des fentes
                                                                                                {eval_r(x0(:, 1, i))}, ...  % rayon des perforations
                                                                                                {transpose(x0(:, 2, i))}, ... % distance entre les perforations dans le sens de la largeur
                                                                                                {transpose(x0(:, 3, i))}, ... % nombre de perforations dans le sens de la profondeur
                                                                                                {transpose(x0(:, 4, i))}, ... % nombre de perforations dans le sens de la largeur
                                                                                                {top_plate_thickness, plates_thickness}, ... épaisseur des plaques
                                                                                                {round((total_thickness - rigid_backing_thickness - plates_thickness*N_plates) / N_plates, 4)}));

%% Matrices des bornes INF et SUP en fonction des types de variable
lb = repmat([1, 3 * eval_r(2), 5, 1], N_plates, 1, N_solutions);  
ub = repmat([2, 5 * eval_r(2), 11, 10], N_plates, 1, N_solutions); 

%% Contrainte sur les variables entières
intcon = find(repmat([1 0 1 1], N, 1, NS)); 

%% Fonction de définitions de la matrice de contraintes non linéaires  

% Définition du handle avec paramètres capturés
handle_perso_nonlcon = @(x) perso_MPPSBHr_nonlconf(x, NV, NS, N, cavities_width, cavities_depth, eval_r);

%% Fonction objectif

% Définition des plages fréquentielles d'interet pour la fonction objectif
g_lb_hf = @(env) (env.w / (2*pi) > f_min & env.w / (2*pi) < f_max);

% Liste des solutions flottantes
x0_to_list_of_MPPSBH = @(x0, NS) arrayfun(@(i) x0_to_MPPSBH_i(x0, i), 1:NS, 'UniformOutput', false);

% Assemblage flottant des solutions
params_to_MPPSBH_assembly = @(x0) classelementassembly(classelementassembly.create_config(x0_to_list_of_MPPSBH(x0, NS)));

% Calcul flottant de la somme des écarts au carré sur la plage fréquentielle délimitée par le gabarit
cost_function = @(x0, env) sum(((params_to_MPPSBH_assembly(x0).alpha(env) - g_lb_hf(env)) .* (g_lb_hf(env) > 0.1)).^2);

% Appel flottant de la fonction coùt à partir du vecteur des variables en cours d'optimisation
objective = @(x0) cost_function(reshape(x0, N, NV, NS), env);

%% Options d'optimisation

% gaplotfeasibility = @(options, state, flag) perso_gaplotfeasibility(handle_perso_nonlcon, options, state, flag);

options = @(pop) optimoptions('ga', ...
                       'Display', 'iter', ...
                       'PlotFcn',  {@gaplotbestf, @gaplotmaxconstr, @gaplotbestindiv, @gaplotscorediversity}, ... % {@gaplotfeasibility}, ... % {@perso_plotMaxDistancePlotFcn}
                       'PopulationSize', 20, ...
                       'FunctionTolerance', 1e-6, ...
                       'MaxStallGenerations', 5, ...
                       'MaxGenerations', 10, ...
                       'MutationFcn',  'mutationadaptfeasible',... {@mutationgaussian, 2, 0.5}, ... %'mutationuniform', ... 
                       'CrossoverFraction', 0.5, ...
                       'MigrationInterval', 10, ...
                       'MigrationFraction', 0.3, ...
                       'InitialPopulationMatrix', reshape(permute(pop, [4, 1, 2, 3]), N_points, N_plates * N_variables * N_solutions)); 

% Génération des points de départ
population = perso_generate_initial_population(N_points, N_solutions, N_variables, N_plates, lb, ub, intcon);

% Ici on veut que les nombres de perforations et les espaces
% inter-perforations soient de plus en plus petit. On réalise un tri sur
% les données aléatoires simulées pour créer des points de fonctionnement
% qui nous conviennent
population(:, [2, 3, 4], :, :) = sort(population(:, [2, 3, 4], :, :), 1, "descend");

[local_optimum, fitness, ~, ~, ~, ~] = ga(objective, numel(population(:, :, :, 1)), [], [], [], [], lb, ub, handle_perso_nonlcon, intcon, options(population));

% while crossover_possible == true
% 
%     iter = iter + 1;
%     fprintf('\n---- Itération %d ----\n', iter);
% 
%     local_optima = zeros(N_plates, N_variables, N_solutions, N_points);
%     fitness = zeros(1, N_points);
%     for i = 1:N_points
% 
%         % On exécute l'algorithme génétique pour chaque point de départ
%         x = population(:, :, :, i);
%         [local_optimum, fitness(i), ~, ~, ~, ~] = ga(objective, numel(x), [], [], [], [], lb, ub, handle_perso_nonlcon, intcon, options(population));
%         local_optima(:, :, :, i) = reshape(local_optimum, N_plates, N_variables, N_solutions);
%     end
% 
%     % On filtre les minimums locaux pour lesquels la valeur de sortie est inférieure à un seuil de tolérance
%     local_optima_accepted = local_optima(:, :, :,fitness < tolerance_threshold);
% 
%     % Croisement des extrêmes locaux pour régénérer les points de départs
%     [population, crossover_possible] = perso_crossover_local_optima(local_optima_accepted, N_plates, N_variables, N_solutions, lb, ub, crossover_threshold);
% end
% 
% fprintf('\nMeilleures solutions trouvées :\n');
% disp(population);

%% Résultats

% Solutions et configurations optimisée
assembly_lb_hf_opti = params_to_MPPSBH_assembly(reshape(local_optimum, N, NV, NS));
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

% % Validation numérique
% Tube_lb_hf = ImpedanceTube2D(ImpedanceTube2D.create_config(assembly_lb_hf_opti.ListOfElements));
% Tube_lb_hf = Tube_lb_hf.lauch_tube_measurement();
% Tube_lb_hf.plot_alpha(env, 'solution large bande');
% mphsave(Tube_lb_hf.Configuration.ComsolModel, ['E:\OneDrive - ETS\CRIAQ-REAR\Maitrise LB\' ...
%                                             'Présentations\Présentations Thomas\25.04.08 - résultats optimisation pour Hutchinson\' ...
%                                             'validation numérique haute fréquence 2 solutions'])

% Indicateurs
alpha_mean_lb_hf_in_band = assembly_lb_hf_opti.alpha_mean(env, f_min, f_max);
