%% Description

% L'optimisation finale porte sur les paramètres de la plaque couvrante
% utilisée avec le traitement poreux

%% Sélection du dossier de destination des élements sauvegardés

% folderName = uigetdir();
folderName = 'C:\Users\lucas.barbier\Documents\Maitrise dossier secondaire\MATLAB\Optimisation\Optimisation REAR';
% folderName = 'C:\Users\lucas.barbier\Documents\Maitrise dossier secondaire\MATLAB\Optimisation\Optimisation REAR\Validation numérique';

%% Ouverture de l'environnement matlab

% load([folderName, '\environnement matlab.mat']);

%% Niveau Sonore, Fréquences cibles

% Limites des bandes de fréquences 
f_min_obj1 = 200;
f_max_obj1 = 400;
f_min_obj2 = 400;
f_max_obj2 = 600;
f_min_obj3 = 600;
f_max_obj3 = 1500;

% Niveau sonore
dB = 100;

%% Paramètres géométriques invariants

total_thickness = 115e-3;
total_depth = 120e-3; 
total_width = 72e-3;
total_input_surface = total_depth * total_width;

% Plaque couvrante
top_plate_thickness = 1e-3;

% radius = [1.588, 1.984, 2.381, 2.778, 3.175]/2 * 1e-3;

%% Structure des variables optimisées

NTP = 3; % (rayon, nombre de perf par ligne (width), nombre de perfs par colonne (depth))

NP = 200; % Nombre de points de départ
% NP = 50;
% NP = 10;

JCAmat_thickness = total_thickness - top_plate_thickness;

%% Valeurs minimales en fonction du type de variable

% Plaque couvrante
tp_phi_min = 0.05;
% tp_r_min = 1;
tp_r_min = 4.5e-4;
tp_whn_min = 5;
tp_dhn_min = 10;

lb = [tp_r_min, tp_whn_min, tp_dhn_min];

%% Valeurs maximales en fonction du type de variable

% Plaque couvrante
tp_phi_max = 1;
% tp_r_max = 5;
tp_r_max = 3e-3;
tp_whn_max = 30;
tp_dhn_max = 30;

ub = [tp_r_max, tp_whn_max, tp_dhn_max];

%% Valeurs initiales en fonction du types de variable

% Plaque supérieure 
% tp_r_init = randi(tp_r_max, NP, 1);
tp_r_init = tp_r_min + (tp_r_max - tp_r_min) * rand(NP, 1);
tp_whn_init = tp_whn_min + (tp_whn_max - tp_whn_min - 10) * rand(NP, 1);
tp_dhn_init = tp_dhn_min + (tp_dhn_max - tp_dhn_min - 10) * rand(NP, 1);

x0 = horzcat(tp_r_init, tp_whn_init, tp_dhn_init);

%% Contraintes dynamiques nonlinéaires 

handle_Hutchinson_nonlconf = @(x) perso_Hutchinson_nonlconf(x, top_plate, tp_phi_max);

%% Contrainte sur les variables entières

intcon = find([0, 1, 1]);

%% Gabarits

% Définition des plages fréquentielles d'interet pour la fonction cout
g_obj1 = @(env) (env.w / (2*pi) > f_min_obj1 & env.w / (2*pi) < f_max_obj1);
g_obj2 = @(env) (env.w / (2*pi) > f_min_obj2 & env.w / (2*pi) < f_max_obj2);
g_obj3 = @(env) (env.w / (2*pi) > f_min_obj1 & env.w / (2*pi) < f_max_obj3);

%% Création de l'objet JCA
phi = 0.99;
tor = 1;
sig = 12340;
vl = 0.000105;
tl = 0.000316;
JCAmat = classJCA_Rigid(classJCA_Rigid.create_config(total_width*total_depth, JCAmat_thickness, phi, tor, sig, vl, tl, total_width, total_depth));

% % Debog : Comportement du poreux seul
% figure()
% JCAmat.plot_alpha(env(dB), 'Traitement poreux seul');
% 
% % Validation numérique du poreux seul
% JCAelement = classelement(classelement.create_config({JCAmat}, 'closed', total_input_surface));
% Tube_JCA = ImpedanceTube2D(ImpedanceTube2D.create_config({JCAelement}));
% Tube_JCA = Tube_JCA.lauch_tube_measurement(env(100));
% Tube_JCA.plot_alpha(env(100), 'Matériau poreux');

perso_configure_alpha_figure(2000);


%% Création dynamique de la plaque couvrante

% Plaque couvrante
covering_plate = @(r, w, d, pw, pd) classMPP_Circular( ... 
classMPP_Circular.create_explicit_rectangular_plate_config( ...
    top_plate_thickness, r, w, d, pw, pd));

% Plaque supérieure (optimisée)
top_plate = @(x) classMPP_Circular(classMPP_Circular.create_explicit_rectangular_plate_config( ...
top_plate_thickness, x(1), total_width, total_depth, x(2), x(3)));

Cartouche_Hutchinson = @(x) classelement(classelement.create_config({top_plate(x), JCAmat}, 'closed', total_input_surface));

%% Fonctions coût

% Evaluation du coût sur la cartouche globale
cost_function_obj1 = @(x, env) sum(((Cartouche_Hutchinson(x).alpha(env) - g_obj1(env)) .* (g_obj1(env) > 0.1)).^2, 'omitnan');
cost_function_obj2 = @(x, env) sum(((Cartouche_Hutchinson(x).alpha(env) - g_obj2(env)) .* (g_obj2(env) > 0.1)).^2, 'omitnan');

objective = @(x) [cost_function_obj1(x, env(dB)), cost_function_obj2(x, env(dB))];

% %% Validation de l'approche numérique sur la configuration initiale (OK)
% Tube_Cartouche = ImpedanceTube2D(ImpedanceTube2D.create_config({Cartouche_Hutchinson(x0(1, :))}));
% Tube_Cartouche = Tube_Cartouche.lauch_tube_measurement(env(100));
% Tube_Cartouche.plot_alpha(env(100), 'Cartouche Hutchinson');
% perso_configure_alpha_figure(2000);

%% Genetic Algorithm

options = optimoptions('ga', ...
                       'Display', 'iter', ...
                       'PopulationSize', NP, ... % nombre de points dans la population initiale
                       'FunctionTolerance', 1e-2, ...
                       'ConstraintTolerance', 1e-2, ...
                       'MaxStallGenerations', 5, ...
                       'MaxGenerations', 100, ...
                       'MutationFcn',  'mutationadaptfeasible',... {@mutationgaussian, 2, 0.5}, ... %'mutationuniform', ... 
                       'CrossoverFraction', 0.5, ...
                       'MigrationInterval', 10, ...
                       'MigrationFraction', 0.3, ...
                       'InitialPopulationMatrix', x0); 

% Options d'affichage
% options.PlotFcn = {@gaplotbestf, @gaplotmaxconstr, @gaplotbestindiv}; % Pour un seul objectif
options.PlotFcn = {@gaplotpareto, @gaplotscorediversity}; % Pour deux objectifs ou plus

rng; % For reproducibility"
tic;
[xopti, fval, eflag, output, population, scores] = gamultiobj(objective, numel(x0(1, :)), [], [], [], [], lb, ub, handle_Hutchinson_nonlconf, intcon, options);
timeGa = toc;

%% Conditionnement  des solutions optimisées

xopti_to_cell_array_of_Hutchinson_element_alpha = @(x, env) arrayfun(@(i) Cartouche_Hutchinson(x(i, :)).alpha(env), 1:size(x, 1), 'UniformOutput', false);
% xopti_to_cell_array_of_global_assembly_alpha = @(x, env) arrayfun(@(i) Cartouches.Cartouche_ETS(x(i, :)).alpha(env), 1:size(x, 1), 'UniformOutput', false);

cell_of_MPPSBH_assembly_alpha_to_mean_alpha = @(alpha_cell_array, gabarit) arrayfun(@(i) mean(alpha_cell_array{i}(gabarit)), 1:size(alpha_cell_array, 2), 'UniformOutput', false);

% On récupère les vecteurs d'absorption des meilleures configurations
[sorted_scores_opti, sorted_index_opti] = sort(fval);
sorted_xopti = xopti(sorted_index_opti(:, 1), :);
filtered_alpha = xopti_to_cell_array_of_Hutchinson_element_alpha(sorted_xopti, env(dB));

% On récupère, pour ces vecteurs, les alphas moyens sur différentes bandes fréquentielles d'intérêt
mean_alpha_obj1 = cell_of_MPPSBH_assembly_alpha_to_mean_alpha(filtered_alpha, g_obj1(env(dB)));
mean_alpha_obj2 = cell_of_MPPSBH_assembly_alpha_to_mean_alpha(filtered_alpha, g_obj2(env(dB)));

% Tracé interractif des meilleurs résultats de l'optimisation multi objectif
perso_interactive_multi_plot(env(dB).w/(2*pi), filtered_alpha, mean_alpha_obj1, mean_alpha_obj2, 2000);

%% Résultats et sélection de la solution 

chosed_index = input('Veuillez entrer le numéro de la configuration choisie : ');
x_opti = sorted_xopti(chosed_index, :);

%% Validation numérique 2D de la configuration choisie
Tube_Cartouche = ImpedanceTube2D(ImpedanceTube2D.create_config({Cartouche_Hutchinson(x0(1, :))}));
Tube_Cartouche = Tube_Cartouche.lauch_tube_measurement(env(100));

figure();
JCAmat.plot_alpha(env(dB), 'Traitement poreux seul');
Tube_Cartouche.plot_alpha(env(100), 'Cartouche Hutchinson optimisée');

%% Sauvergarde

env_saved = input('Sauvegarder l''environnement d''optimisation : ');

if env_saved == 1
    % save([folderName, '\' name '.mat']);
    save([folderName, '\' 'optimisation cartouche Hutchinson' '.mat']);
end

top_plate(x_opti).Configuration;
handle_Hutchinson_nonlconf(x_opti)