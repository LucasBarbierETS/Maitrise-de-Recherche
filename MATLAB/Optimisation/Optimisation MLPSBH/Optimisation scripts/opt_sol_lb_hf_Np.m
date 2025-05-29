% % Sélection du dossier de destination des élements sauvegardés
folderName = uigetdir();

%% Paramètres des solutions optimisées

% NS = 4; % Nombre de solutions
% NS = 2; % Nombre de solutions
NS = 1; % Nombre de solutions

NV = 4; % Nombre de variables pour chaque solution
% NV = 2; % Nombre de variables pour chaque solution

% N =  6; % Nombre de plaques pour chaque solution
N =  4; % Nombre de plaques pour chaque solution
% N =  10; %  Nombre de plaques pour chaque solution

NP = 100; % Nombre de points de départ
% NP = 10; % Nombre de points de départ

perforations_radius_values = [4.5e-4 4.75e-4, 5e-4, 5.25e-4, 5.5e-4, 5.75e-4, 6e-4, 6.25e-4];
eval_r = @(index_mat) reshape(perforations_radius_values(index_mat), size(index_mat));
f_min_bf = 150;
f_max_bf = 400;
f_min_mf = 400;
f_max_mf = 600;
f_min_hf = 600;
f_max_hf = 1500;

%% Paramètres géométriques invariants
cavities_depth = 28e-3;
cavities_width = 28e-3; % parois inter-cellulaire de 2mm
input_section = cavities_depth * cavities_width;

top_plate_thickness = 1e-3;
% top_plate_thickness = 2e-3;

plates_thickness = 2e-3;

total_thickness = 100e-3;
% total_thickness = 62e-3;

rigid_backing_thickness = 2e-3;
cavities_thickness = (total_thickness - rigid_backing_thickness - plates_thickness * (N-1)) / N;

%% Valeurs initiales en fonction du types de variable
r_init = randi([1, 7], N, 1, NS, NP);
dw_init = reshape(3 * eval_r(r_init), N, 1, NS, NP);
pd_init = randi([5, 12], N, 1, NS, NP);
pw_init = randi([1, 12], N, 1, NS, NP);

x0 = horzcat([r_init, dw_init, pd_init, pw_init]); % cat(2, ...
% x0 = cat(2, pd_init, pw_init);
x0_sorted = sort(x0, 1, "descend");

%% Matrices des bornes INF et SUP en fonction des types de variable
lb = repmat([1, 3 * eval_r(1), 5, 1], N, 1, NS);
% lb = repmat([5, 1], N, 1, NS);
ub = repmat([7, 6 * eval_r(1), 12, 12], N, 1, NS); 
% ub = repmat([12, 12], N, 1, NS);

%% Contrainte sur les variables entières
intcon = find(repmat([1 0 1 1], N, 1, NS)); 
% intcon = find(repmat([1 1], N, 1, NS)); 

%% Fonction de définitions de la matrice de contraintes non linéaires  

% Définition du handle avec paramètres capturés
handle_perso_nonlcon = @(x) perso_MPPSBHr_nonlconf(x, NV, NS, N, cavities_width, cavities_depth, eval_r);

%% Gabarits

% Définition des plages fréquentielles d'interet pour la fonction cout
g_bf = @(env) (env.w / (2*pi) > f_min_bf & env.w / (2*pi) < f_max_bf);
g_mf = @(env) (env.w / (2*pi) > f_min_mf & env.w / (2*pi) < f_max_mf);
g_hf = @(env) (env.w / (2*pi) > f_min_bf & env.w / (2*pi) < f_max_hf);
g_bf_mf = @(env) (env.w / (2*pi) > f_min_bf & env.w / (2*pi) < f_max_mf);
g_mf_hf = @(env) (env.w / (2*pi) > f_min_mf & env.w / (2*pi) < f_max_hf);
g_bf_hf = @(env) (env.w / (2*pi) > f_min_bf & env.w / (2*pi) < f_max_hf);

%% Fonction coût - Création d'un assemblage acoustique multicouche dynamique

% --- Définition d'un élément MPPSBH à partir d'un sous-vecteur x0(:,:,i) ---

x0_part_i_to_MPPSBH = @(x0, i) classMPPSBH_Rectangular( ...
    classMPPSBH_Rectangular.create_explicit_config( ...
        N, cavities_depth, cavities_width, ...
        {transpose(x0(:, 2, i) .* x0(:, 4, i))}, ...        % largeur des fentes = pas * nb de trous
        {eval_r(x0(:, 1, i))}, ...                          % rayon des perforations
        {transpose(x0(:, 2, i))}, ...                       % distance entre perforations (dans le sens de la largeur)
        {transpose(x0(:, 3, i))}, ...                       % nombre de perforations en profondeur
        {transpose(x0(:, 4, i))}, ...                       % nombre de perforations en largeur
        {top_plate_thickness, plates_thickness}, ...        % épaisseur des plaques (supérieure + internes)
        {round((total_thickness - rigid_backing_thickness - plates_thickness * N) / N, 4)}));  % épaisseur de cavité

% --- (Alternative) Création simplifiée selon un modèle standardisé ---
% % x0_to_MPPSBH_i = @(x0, i) classMPPSBH_Rectangular( ...
%     classMPPSBH_Rectangular.create_explicit_config(N, cavities_depth, cavities_width, ...
%         {3 * eval_r(1) .* x0(:, 2, i)}, ...
%         {eval_r(1)}, ...
%         {3 * eval_r(1)}, ...
%         {transpose(x0(:, 1, i))}, ...
%         {transpose(x0(:, 2, i))}, ...
%         {plates_thickness}, ...
%         {round((total_thickness - rigid_backing_thickness - plates_thickness * N) / N, 4)}));

% --- Conversion d'un vecteur ligne x0 (de taille N*NV*NS) en cell array d’objets MPPSBH ---
x0_to_cell_of_MPPSBH = @(x0, NS) ...
    arrayfun(@(i) x0_part_i_to_MPPSBH(reshape(x0, N, NV, NS), i), 1:NS, 'UniformOutput', false);

% --- Optimisation standard : Assemblage global uniquement à partir des MPPSBH ---
x0_to_global_assembly = @(x0) ...
  classelementassembly(classelementassembly.create_config( ...
      x0_to_cell_of_MPPSBH(x0, NS)));

% % --- Optimisation combinée : Importation d'un élement numérique 
% 
% % Importation de l'impédance de surface de l'élement en parallèle
% % 
% % % --- Si pas d'élement importé, création d'un sous-élément de classe classNiloofar  ---
% % % Utilise la même section d’entrée que la plaque supérieure (pour continuité géométrique)
% %
% % Changer cette partie pour ajouter les données importées. Pour l'instant
% % l'élement importé est une mousse de mélamine
% %
% % % Référence : Validation classJCA_Rigid
% % phi = 0.958;
% % tor = 1.94;
% % sig = 11188;
% % vl = 70e-6;
% % tl = 209e-6;
% % D = 98e-3;
% % E = classJCA_Rigid(classJCA_Rigid.create_config(phi, tor, sig, vl, tl, D, input_section));
% % surface_impedance = E.surface_impedance(env);
% % frequency_support = env.w /(2*pi);
% %
% % solN = classNiloofar(classNiloofar.create_config(50e-3, 30e-3, 1e-3, 5e-4, 6e-3, 5e-3, 7.4e-3, 8e-3, 8e-3, 15, 30e-3^2));
% % tubeN = ImpedanceTube2D(ImpedanceTube2D.create_config({solN}));
% % tubeN = tubeN.lauch_tube_measurement();
% % frequency_support = tubeN.Configuration.Data2D(:, 1);
% % surface_impedance = env.air.parameters.Z0 * (tubeN.Configuration.Data2D(:, 5) + 1i * tubeN.Configuration.Data2D(:, 5));
% % 
% % data = load([foldername, '\25.05.27- Niloofar solution - numercial evaluation - Surface impedance.txt']);
% % frequency_support = data(:, 1);
% % surface_impedance = data(:, 2) + 1i * data(:, 3);
% % 
% % imported_subelement = @(input_section) ...
% %     classsubelement_imported(classsubelement_imported.create_config( ...
% %         frequency_support, surface_impedance, input_section));
% % 
% % imported_subelement(input_section).plot_alpha(env, 'Element importé');
% % perso_configure_alpha_figure(frequency_support(end))
% %
% % % Vérification de l'élement importé
% % figure()
% % hold on
% % subplot(2, 1, 1)
% % plot(frequency_support, real(surface_impedance), 'DisplayName', 'Résistance accoustique');
% % legend()
% % subplot(2, 1, 2)
% % plot(frequency_support, imag(surface_impedance), 'DisplayName', 'Réactance accoustique');
% % legend()
% 
% % % --- Création d’un élément combiné : plaque MPPSBH + sous-élément importé ---
% % combined_element = @(top_MPP) ...
% %     classelement(classelement.create_config( ...
% %         {top_MPP, imported_subelement(top_MPP.Configuration.InputSection)}, ... % liste des sous-éléments
% %         'closed', ...                                                           % assemblage fermé (face arrière rigide)
% %         top_MPP.Configuration.InputSection));                                   % section d’entrée commune
% 
% % % --- Conversion d'une liste de plaques supérieures en une liste d’éléments combinés ---
% % cell_of_top_plates_to_cell_of_combined_element = @(cell_of_top_plates) ...
% %     arrayfun(@(i) combined_element(cell_of_top_plates{i}), 1:size(cell_of_top_plates, 2), 'UniformOutput', false);
% 
% % % --- Extraction de la plaque supérieure (le premier sous-élément) de chaque MPPSBH ---
% % cell_of_MPPSBH_to_cell_of_top_plates = @(cell_of_MPPSBH) ...
% %     arrayfun(@(i) cell_of_MPPSBH{i}.Configuration.ListOfSubelements{1}.Configuration.ListOfSubelements{1}, ...
% %              1:size(cell_of_MPPSBH, 2), 'UniformOutput', false);
% 
% % % --- Assemblage global : objets MPPSBH + élements combinés
% % x0_to_global_assembly = @(x0) ...
% %     classelementassembly(classelementassembly.create_config( ...
% %         [x0_to_cell_of_MPPSBH(x0, NS),... % objets MPPSBH 
% %          cell_of_top_plates_to_cell_of_combined_element( ...
% %             cell_of_MPPSBH_to_cell_of_top_plates(x0_to_cell_of_MPPSBH(x0, NS)))])); % élements combinés

% --- Evaluation du coût de la configuration 
cost_function_bf = @(x0, env) sum(((x0_to_global_assembly(x0).alpha(env) - g_bf(env)) .* (g_bf(env) > 0.1)).^2);
cost_function_mf = @(x0, env) sum(((x0_to_global_assembly(x0).alpha(env) - g_mf(env)) .* (g_mf(env) > 0.1)).^2);
cost_function_hf = @(x0, env) sum(((x0_to_global_assembly(x0).alpha(env) - g_hf(env)) .* (g_hf(env) > 0.1)).^2);
cost_function_bf_mf = @(x0, env) sum(((x0_to_global_assembly(x0).alpha(env) - g_bf_mf(env)) .* (g_bf_mf(env) > 0.1)).^2);
cost_function_mf_hf = @(x0, env) sum(((x0_to_global_assembly(x0).alpha(env) - g_bf_mf(env)) .* (g_bf_hf(env) > 0.1)).^2);
cost_function_bf_hf = @(x0, env) sum(((x0_to_global_assembly(x0).alpha(env) - g_bf_hf(env)) .* (g_bf_hf(env) > 0.1)).^2);

objective = @(x0) [cost_function_bf(x0, env), cost_function_mf_hf(x0, env)];

%% Genetic Algorithm
% gaplotfeasibility = @(options, state, flag) perso_gaplotfeasibility(handle_perso_nonlcon, options, state, flag);

options = optimoptions('ga', ...
                       'Display', 'iter', ...
                       'PlotFcn',  {@gaplotpareto, @gaplotscorediversity},... {@gaplotbestf, @gaplotmaxconstr, @gaplotbestindiv}, ... {@gaplotfeasibility}, ... % {@perso_plotMaxDistancePlotFcn}
                       'PopulationSize', size(x0_sorted, 4), ... % nombre de points dans la population initiale
                       'FunctionTolerance', 1e-2, ...
                       'ConstraintTolerance', 1, ...
                       'MaxStallGenerations', 10, ...
                       'MaxGenerations', 100, ...
                       'MutationFcn',  'mutationadaptfeasible',... {@mutationgaussian, 2, 0.5}, ... %'mutationuniform', ... 
                       'CrossoverFraction', 0.5, ...
                       'MigrationInterval', 10, ...
                       'MigrationFraction', 0.3, ...
                       'InitialPopulationMatrix', reshape(permute(x0_sorted, [4, 1, 2, 3]), size(x0, 4), [])); 

rng; % For reproducibility"
tic;
[xopti_lb_hf, fval, eflag, output, population, scores] = gamultiobj(objective, numel(x0_sorted(:, :, :, 1)), [], [], [], [], lb, ub, handle_perso_nonlcon, intcon, options);
timeGa = toc;

% Affichage 
figure()
hold on
% On trie les meileurs scores obtenus
[filtered_scores, filtered_index] = perso_convex_pareto_filter(scores);
scatter(filtered_scores(:, 1), filtered_scores(:, 2), 'r');

xopti_to_cell_array_of_global_assembly_alpha = @(x, env) arrayfun(@(i) x0_to_global_assembly(x(i, :)).alpha(env), 1:size(x, 1), 'UniformOutput', false);
cell_of_MPPSBH_assembly_alpha_to_mean_alpha = @(alpha_cell_array, gabarit) arrayfun(@(i) mean(alpha_cell_array{i}(gabarit)), 1:size(alpha_cell_array, 2), 'UniformOutput', false);

% On récupère les vecteurs d'absorption des meilleures configurations
[sorted_scores_opti, sorted_index_opti] = sort(fval);
sorted_xopti = xopti_lb_hf(sorted_index_opti(:, 1), :);
filtered_alpha = xopti_to_cell_array_of_global_assembly_alpha(sorted_xopti, env);

% On récupère, pour ces vecteurs, les alphas moyens sur différentes bandes fréquentielles d'intérêt
mean_alpha_bf = cell_of_MPPSBH_assembly_alpha_to_mean_alpha(filtered_alpha, g_bf(env));
mean_alpha_lb_hf = cell_of_MPPSBH_assembly_alpha_to_mean_alpha(filtered_alpha, g_hf(env));

% Tracé interractif des meilleurs résultats de l'optimisation multi objectif
perso_interactive_multi_plot(env.w /(2*pi), filtered_alpha, mean_alpha_bf, mean_alpha_lb_hf, 2000);

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

chosed_index = input('Veuillez entrer le numéro de la configuration choisie : ');

% % Solutions et configurations optimisée
assembly_lb_hf_opti = x0_to_global_assembly(reshape(sorted_xopti(chosed_index, :), N, NV, NS));
MPPSBH_lb_hf_1 = assembly_lb_hf_opti.Configuration.ListOfElements{1};
% MPPSBH_lb_hf_2 = assembly_lb_hf_opti.Configuration.ListOfElements{2};
% MPPSBH_lb_hf_3 = assembly_lb_hf_opti.Configuration.ListOfElements{3};
% MPPSBH_lb_hf_4 = assembly_lb_hf_opti.Configuration.ListOfElements{4};
MPPSBH_lb_hf_1_config = MPPSBH_lb_hf_1.Configuration;
% MPPSBH_lb_hf_2_config = MPPSBH_lb_hf_2.Configuration;
% MPPSBH_lb_hf_3_config = MPPSBH_lb_hf_3.Configuration;
% MPPSBH_lb_hf_4_config = MPPSBH_lb_hf_4.Configuration;
%
% % Affichage graphique
figure()
hold on
plot(env.w/(2*pi), g_hf(env) , "--", 'DisplayName', 'Gabarit');
plot(env.w/ (2*pi), assembly_lb_hf_opti.alpha(env), 'DisplayName', 'Assemblage');
perso_configure_alpha_figure(2000);
% 
% % Indicateurs
% alpha_mean_lb_hf_in_band = assembly_lb_hf_opti.alpha_mean(env, f_min_lb_hf, f_max_lb_hf);
% alpha_mean_lb_hf_out_band = assembly_lb_hf_opti.alpha_mean(env, f_min_bf, f_max_mb_mf);
% alpha_mean = assembly_lb_hf_opti.alpha_mean(env, f_min_bf, f_max_lb_hf);

% Validation numérique

% Tube_lb_hf = ImpedanceTube2D(ImpedanceTube2D.create_config(assembly_lb_hf_opti.Configuration.ListOfElements));
% Tube_lb_hf = Tube_lb_hf.lauch_tube_measurement();
% Tube_lb_hf.plot_alpha(env, f_min_bf, f_max_lb_hf, 'solution large bande');
% mphsave(Tube_lb_hf.Configuration.ComsolModel, ['E:\Montréal 2023 - 2025\Maitrise LB\Présentations\Présentation groupe REAR\25.05.08 - configurations finales pour 1ère itération\' ...
%                                                'validation numérique de la solution fournie par ETS'])

% Sauvegarde des rapports de configuration
% report_root = 'E:\Montréal 2023 - 2025\Maitrise LB\Présentations\Présentation groupe REAR\25.05.08 - configurations finales pour 1ère itération\';
% MPPSBH_lb_hf_1.export_report([report_root, 'rapport de configuration - solution 1.xlsx'])
% MPPSBH_lb_hf_2.export_report([report_root, 'rapport de configuration - solution 2.xlsx'])
% MPPSBH_lb_hf_3.export_report([report_root, 'rapport de configuration - solution 3.xlsx'])
% MPPSBH_lb_hf_4.export_report([report_root, 'rapport de configuration - solution 4.xlsx'])

% Export de fichier de découpe 
MPPSBH_lb_hf_1.export_DXF();

% % Enregistrement de l'environnement
save([folderName, '\environnement matlab.mat']);