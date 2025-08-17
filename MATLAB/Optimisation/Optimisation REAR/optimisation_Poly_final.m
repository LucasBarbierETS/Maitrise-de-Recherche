clear 
launch_environnement()

%% Sélection du dossier de destination des élements sauvegardés

% folderName = uigetdir();
folderName = 'C:\Users\lucas.barbier\Documents\Maitrise dossier secondaire\MATLAB\Optimisation\Optimisation REAR';
% folderName = 'C:\Users\lucas.barbier\Documents\Maitrise dossier secondaire\MATLAB\Optimisation\Optimisation REAR\Validation numérique';

%% Ouverture de l'environnement matlab

% load(uigetfile(folderName));

%% Niveau Sonore, Fréquences cibles

% Limites des bandes de fréquences 
f_min_obj0 = 230;
f_max_obj0 = 250;
f_min_obj1 = 200;
f_max_obj1 = 400;
f_min_obj2 = 400;
f_max_obj2 = 600;
f_min_obj3 = 600;
f_max_obj3 = 1500;

% Niveau sonore
dB = 100;

%% Paramètres géométriques invariants

total_thickness = 102e-3;
rigid_backing_thickness = 1e-3;
total_depth = 120e-3; 
total_width = 72e-3;
total_input_surface = total_depth * total_width;

% Epaisseur de l'interstice
air_gap_thickness = 1e-3;
% air_gap_thickness = 10e-3;

% Plaque couvrante
top_plate_thickness = 1e-3;

% Liste des diamètres de foret en pouces
diameters_inch = [1/32, 1/30, 3/64, 1/16, 5/64, 3/32, 7/64, 1/8, 9/64, 5/32, 11/64, 3/16];
diameters_mm = diameters_inch * 25.4;
radius_mm = diameters_mm/2;
handle_config = @(x) [radius_mm(x(1))*1e-3, x(2), x(3)];

% Solutions Poly
Poly_cavities_width = 28e-3; % bords externes : 30 mm
Poly_cavities_depth = 28e-3; % bords externes : 30 mm
Poly_cavities_input_section = Poly_cavities_width * Poly_cavities_depth; 
Poly_input_surface = 30e-3^2;

% Solutions HR
yellow_cavities_thickness = total_thickness - top_plate_thickness - air_gap_thickness - rigid_backing_thickness;
yellow_cavities_width = 10e-3; % bords externes : 12 mm
yellow_cavities_depth = 28e-3; % bords externes : 30 mm
yellow_cavities_input_section = yellow_cavities_width * yellow_cavities_depth;
yellow_cavities_input_surface = 12e-3*30e-3;

%% Structure des variables optimisées

NTP = 3; % (rayon, nombre de perf par ligne (width), nombre de perfs par colonne (depth))
NS = 8;

NP = 500; % Nombre de points de départ
% NP = 100;
% NP = 50;
% NP = 10;

%% Valeurs minimales

tp_phi_min = 0.01;
tp_r_min = 1;
tp_whn_min = 1;
tp_dhn_min = 1;

lb_TP = [tp_r_min, tp_whn_min, tp_dhn_min];

%% Valeurs maximales

tp_phi_max = 0.4;
tp_r_max = 12;
tp_whn_max = 25;
tp_dhn_max = 25;

ub_TP = [tp_r_max, tp_whn_max, tp_dhn_max];

%% Valeurs initiales

tp_r_init = randi([tp_r_min, tp_r_max], NP, 1);
tp_whn_init = randi([tp_whn_min, tp_whn_max], NP, 1);
tp_dhn_init = randi([tp_dhn_min, tp_dhn_max], NP, 1);

x0 = horzcat(tp_r_init, tp_whn_init, tp_dhn_init);

% Debog : Affichage des porosités simulées
figure()
p = [];
for i = 1:size(x0, 1)
    p(end+1) = top_plate(handle_config(x0(i, :))).Configuration.Porosity;
end
histogram(p, 20);
title('Porosités simulées')

%% Contrainte sur les variables entières

intcon = [1, 2, 3];

%% Gabarits

% Définition des plages fréquentielles d'interet pour la fonction cout
g_obj0 = @(env) (env.w / (2*pi) > f_min_obj0 & env.w / (2*pi) < f_max_obj0);
g_obj1 = @(env) (env.w / (2*pi) > f_min_obj1 & env.w / (2*pi) < f_max_obj1);
g_obj2 = @(env) (env.w / (2*pi) > f_min_obj2 & env.w / (2*pi) < f_max_obj2);
g_obj3 = @(env) (env.w / (2*pi) > f_min_obj1 & env.w / (2*pi) < f_max_obj3);

%% Importation de l'élement expérimental

% % Importation de l'impédance de surface de l'élement expérimental en parallèle
% data = perso_load_mecanum_files(['C:\Users\lucas.barbier\Documents\Maitrise dossier secondaire\' ...
%     'Mesures expérimentales\Echantillons Hutchinson 1ère itération\Echantillon Poly Hutchinson\Export_Data']);
% Zsn = data.NormalizedSurfaceImpedanceOnCavity;
% alpha = data.AbsorptionCoefficientOnCavity;
% frequency_support = Zsn.Sample1_Imag_Frequency_Hz_;
% surface_impedance = Zsn.NormalizedSurfaceImpedanceOnCavity + 1i * Zsn.NormalizedSurfaceImpedanceOnCavity_1;
% alpha100 = alpha.AbsorptionCoefficientOnCavity;

data = load(['C:\Users\lucas.barbier\Documents\Maitrise dossier secondaire\Mesures expérimentales\' ...
    'Echantillons Hutchinson 1ère itération\Echantillon Poly Hutchinson\25.05.27- Niloofar solution - numercial evaluation - Surface impedance.txt']);
frequency_support = data(:, 1);
surface_impedance = data(:, 2) + 1i * data(:, 3);

[Zs, imported_Poly_subelement] = classsubelement_imported(classsubelement_imported.create_config( ...
        frequency_support, surface_impedance, Poly_cavities_width, Poly_cavities_depth)).surface_impedance(env(dB));

imported_Poly_element = classelement(classelement.create_config({imported_Poly_subelement}, 'closed', Poly_input_surface));
imported_element_assembly = classelementassembly(classelementassembly.create_config(repmat({imported_Poly_element}, 1, 4)));

numerical_Poly_subelement = classNiloofar(classNiloofar.create_config(99e-3, 28e-3, 118e-3, 1e-3, 5e-4, 9e-3, 5e-3, 8e-3, 9e-3, 9e-3, 15));
numerical_Poly_element = classelement(classelement.create_config({numerical_Poly_subelement}, 'closed', Poly_input_surface));
numerical_Poly_element_assembly = classelementassembly(classelementassembly.create_config(repmat({numerical_Poly_element}, 1, 4)));

% % Debog : Tracé de l'impédance de surface
% figure()
% subplot(2, 1, 1)
% plot(frequency_support, real(surface_impedance));
% subplot(2, 1, 2)
% plot(frequency_support, imag(surface_impedance));

% Debog : Comparaison de l'élement importé et l'élement simulé
% 
% figure()
% imported_Poly_element.plot_alpha(env(dB), 'Element importé');
% Tube_Poly = ImpedanceTube2D(ImpedanceTube2D.create_config({numerical_Poly_element}));
% Tube_Poly = Tube_Poly.lauch_tube_measurement(env(dB));
% Tube_Poly.plot_alpha(env(100), 'Element simulé');

%% Création dynamique des objets de classe et des assemblages

% Plaque couvrante
covering_plate = @(r, w, d, pw, pd) classMPP_Circular( ... 
classMPP_Circular.create_explicit_rectangular_plate_config( ...
    top_plate_thickness, r, w, d, pw, pd));

% Plaque supérieure (optimisée)
top_plate = @(config) covering_plate(config(1), total_width, total_depth, config(2), config(3));

% Distance Plaque - Solutions
air_gap = classcavity(classcavity.create_config(air_gap_thickness, total_width, total_depth));

% Cavité Jaune
yellow_cavity = classcavity(classcavity.create_config(yellow_cavities_thickness, yellow_cavities_width, yellow_cavities_depth));
% yellow_cavity = classQWL_Slit(classQWL_Slit.create_config(yellow_cavities_thickness, yellow_cavities_width, yellow_cavities_depth));
yellow_cavity_element = classelement(classelement.create_config({yellow_cavity}, 'closed', yellow_cavities_input_surface));

% % Debog :  Affichage des performance de la cavité jaune
% figure();
% perso_plot_surface_impedance(env(dB).w/(2*pi), yellow_cavity_element.surface_impedance(env(dB)), env(dB));

%% Création dynamique des contributions des solutions individuelles

Contributions = struct();

Contributions.contribution_Poly_element = @(config) classelement(classelement.create_config( ...
    {perso_modify_subelement_dimensions(top_plate(config), Poly_cavities_width, Poly_cavities_depth), ...
     perso_modify_subelement_dimensions(air_gap, Poly_cavities_width, Poly_cavities_depth), ...
     imported_Poly_subelement}, 'closed', Poly_input_surface));

Contributions.contribution_Poly_numerical_element = @(config) classelement(classelement.create_config( ...
    {perso_modify_subelement_dimensions(top_plate(config), Poly_cavities_width, Poly_cavities_depth), ...
     perso_modify_subelement_dimensions(air_gap, Poly_cavities_width, Poly_cavities_depth), ...
     numerical_Poly_subelement}, 'closed', Poly_input_surface));

Contributions.cell_of_Poly_element_contribution = @(config) arrayfun(@(i) ...
    Contributions.contribution_Poly_element(config), 1:NS ,'UniformOutput', false);

Contributions.contribution_Poly_yellow_cavity = @(config) classelement(classelement.create_config( ...
    {perso_modify_subelement_dimensions(top_plate(config), yellow_cavities_width, yellow_cavities_depth), ...
     perso_modify_subelement_dimensions(air_gap, yellow_cavities_width, yellow_cavities_depth), ...
     yellow_cavity}, 'closed', yellow_cavities_input_surface));

Contributions.cell_of_Poly_yellow_cavity_contributions = @(config) arrayfun(@(i) ...
    Contributions.contribution_Poly_yellow_cavity(config), 1:4 ,'UniformOutput', false);

%% Création dynamique des modules

Modules = struct();

Modules.module_Poly = @(config) classelementassembly(classelementassembly.create_config( ...
                [repmat({imported_Poly_element}, 1, NS), ... % Solutions Poly
                    repmat({yellow_cavity_element}, 1, 4)])); % Solutions HR 

Modules.module_Poly_sans_HR = @(config) classelementassembly(classelementassembly.create_config(repmat({imported_Poly_element}, 1, NS)));

%% Création dynamique des cartouches

Cartouches = struct();

Cartouches.cartouche_Poly = @(config) classelement(classelement.create_config( ...
    {top_plate(config), air_gap, Modules.module_Poly(config)}, 'closed', total_input_surface));

Cartouches.cartouche_Poly_sans_HR = @(config) classelement(classelement.create_config( ...
    {top_plate(config), air_gap, Modules.module_Poly_sans_HR(config)}, 'closed', total_input_surface));

Cartouches.cartouche_Poly_contributions = @(config) classelementassembly(classelementassembly.create_config( ...
    [Contributions.cell_of_Poly_element_contribution(config), Contributions.cell_of_Poly_yellow_cavity_contributions(config)]));

Cartouches.cartouche_Poly_sans_HR_contributions = @(config) classelementassembly(classelementassembly.create_config( ...
    Contributions.cell_of_Poly_element_contribution(config)));

%% Contraintes dynamiques nonlinéaires 

handle_Poly_nonlconf = @(x) perso_top_plate_nonlconf(top_plate(handle_config(x)), tp_phi_min, tp_phi_max);

%% Fonctions coût

% Evaluation du coût sur la cartouche Poly
cost_function_Poly_obj0 = @(x, env) sum(((Cartouches.cartouche_Poly(handle_config(x)).alpha(env) - g_obj0(env)) .* (g_obj0(env) > 0.1)).^2, 'omitnan');
cost_function_Poly_obj1 = @(x, env) sum(((Cartouches.cartouche_Poly(handle_config(x)).alpha(env) - g_obj1(env)) .* (g_obj1(env) > 0.1)).^2, 'omitnan');
cost_function_Poly_obj2 = @(x, env) sum(((Cartouches.cartouche_Poly(handle_config(x)).alpha(env) - g_obj2(env)) .* (g_obj2(env) > 0.1)).^2, 'omitnan');
cost_function_Poly_obj3 = @(x, env) sum(((Cartouches.cartouche_Poly(handle_config(x)).alpha(env) - g_obj3(env)) .* (g_obj3(env) > 0.1)).^2, 'omitnan');

% objective = @(x) [cost_function_Poly_obj0(x, env(dB)), cost_function_Poly_obj1(x, env(dB))];
% objective = @(x) [cost_function_Poly_obj1(x, env(dB)), cost_function_Poly_obj2(x, env(dB))];
objective = @(x) [cost_function_Poly_obj0(x, env(dB)), cost_function_Poly_obj1(x, env(dB)), cost_function_Poly_obj2(x, env(dB)), cost_function_Poly_obj3(x, env(dB))];

%% GENETIC ALGORITHM

options = optimoptions('ga', ...
                       'Display', 'iter', ...
                       'PopulationSize', NP, ... % nombre de points dans la population initiale
                       'FunctionTolerance', 1e-1, ...
                       'ConstraintTolerance', 1e-6, ...
                       'MaxStallGenerations', 5, ...
                       'MaxGenerations', 100, ...
                       'MutationFcn',  'mutationadaptfeasible',... {@mutationgaussian, 2, 0.5}, ... %'mutationuniform', ... 
                       'CrossoverFraction', 0.5, ...
                       'MigrationInterval', 10, ...
                       'MigrationFraction', 0.3, ...
                       'InitialPopulationMatrix', x0); 

% Options d'affichage
% options.PlotFcn = {@gaplotbestf, @gaplotmaxconstr, @gaplotbestindiv}; % Pour un seul objectif
% options.PlotFcn = {@gaplotpareto, ... % Pour deux objectifs ou plus
%                    @gaplotscorediversity}; % , ...
%                    % @(x, optimValues, state) perso_plot_constraints_violation(x, optimValues, state, NS, N)}; 


rng; % For reproducibility"
tic;
[xopti, fval, eflag, ~, population, scores] = gamultiobj(objective, numel(x0(1, :)), [], [], [], [], lb_TP, ub_TP, handle_Poly_nonlconf, intcon, options);
timeGa = toc;

% Debog : Affichage des porosités optimisées
figure()
p = [];
for i = 1:size(xopti, 1)
    p(end+1) = top_plate(handle_config(xopti(i, :))).Configuration.Porosity;
end
histogram(p, 20);
title('Porosités optimisées')

%% Conditionnement du vecteur d'optimisation

xopti_to_cell_array_of_Poly_assembly_alpha = @(x, env) arrayfun(@(i) Cartouches.cartouche_Poly(handle_config(x(i, :))).alpha(env), 1:size(x, 1), 'UniformOutput', false);

cell_of_Poly_assembly_alpha_to_mean_alpha = @(alpha_cell_array, gabarit) arrayfun(@(i) mean(alpha_cell_array{i}(gabarit)), 1:size(alpha_cell_array, 2), 'UniformOutput', false);

% On récupère les vecteurs d'absorption des meilleures configurations
[sorted_scores_opti, sorted_index_opti] = sort(fval);
sorted_xopti = xopti(sorted_index_opti(:, 1), :);
filtered_alpha = xopti_to_cell_array_of_Poly_assembly_alpha(sorted_xopti, env(dB));

% On récupère, pour ces vecteurs, les alphas moyens sur différentes bandes fréquentielles d'intérêt
mean_alpha_obj1 = cell_of_Poly_assembly_alpha_to_mean_alpha(filtered_alpha, g_obj1(env(dB)));
mean_alpha_obj2 = cell_of_Poly_assembly_alpha_to_mean_alpha(filtered_alpha, g_obj2(env(dB)));

% Tracé interractif des meilleurs résultats de l'optimisation multi objectif
perso_interactive_multi_plot(env(dB).w/(2*pi), filtered_alpha, mean_alpha_obj1, mean_alpha_obj2, 2000);

%% Résultats et sélection de la solution 

chosed_index = input('Veuillez entrer le numéro de la configuration choisie : ');
x_opti = sorted_xopti(chosed_index, :);
x_TP(x_opti);
top_plate_opti_config = top_plate(handle_config(x_opti)).Configuration;

%% Sauvergarde

env_saved = input('Sauvegarder l''environnement d''optimisation : ');

if env_saved == 1
    currentTime = char(datetime('now', 'Format', 'yyyy_MM_dd_HH_mm_ss'));
    mkdir([folderName, '\optimisation_Poly_', currentTime]);
    mkdir([folderName, '\optimisation_Poly_', currentTime, '\Figures']);
    save([folderName, '\optimisation_Poly_', currentTime '\environnement matlab.mat']);
else
    return
end

%% Affichage des performances et des paramètres optimisés

figure()
Cartouches.cartouche_Poly(handle_config(x_opti)).plot_alpha(env(dB), 'Cartouche Poly');
Cartouches.cartouche_Poly_contributions(handle_config(x_opti)).plot_alpha(env(dB), 'Cartouche Poly - réaction localisée');

% Contribution de l'élement importé
Contributions.contribution_Poly_element(handle_config(x_opti)).plot_alpha(env(dB), 'Contribution élement importé');

% Contribution de la cavité jaune
Contributions.contribution_Poly_yellow_cavity(handle_config(x_opti)).plot_alpha(env(dB), 'Contribution cavité jaune');
perso_configure_alpha_figure(2000);
saveas(gcf, [folderName, '\optimisation_Poly_', currentTime, '\Figures\Validation de la configuration optimale.fig']);

%% Validation des contributions individuelles

figure()
% Element importé seul
imported_Poly_element.plot_alpha(env(dB), 'Element importé');

% Contribution de l'élement importé
Contributions.contribution_Poly_element(handle_config(x_opti)).plot_alpha(env(dB), 'Contribution élement importé');

% Validation numérique de la contribution de la solution Poly
Tube_Poly_element_contrib = ImpedanceTube2D(ImpedanceTube2D.create_config({Contributions.contribution_Poly_numerical_element(handle_config(x_opti))}));
Tube_Poly_element_contrib = Tube_Poly_element_contrib.launch_tube_measurement(env(dB));
Tube_Poly_element_contrib.plot_alpha(env(dB), 'Contribution solution Poly');
perso_configure_alpha_figure(2000);
saveas(gcf, [folderName, '\optimisation_Poly_', currentTime, '\Figures\Validation de la contribution de la solution Poly.fig']);
mphsave(Tube_Poly_element_contrib.Configuration.ComsolModel, [folderName, '\optimisation_Poly_', currentTime '\validation contribution element Poly.mph']);

% Validation numérique de la contribution de la cavité jaune

figure()
Tube_Poly_yc_contrib = ImpedanceTube2D(ImpedanceTube2D.create_config({Contributions.contribution_Poly_yellow_cavity(handle_config(x_opti))}));
Tube_Poly_yc_contrib = Tube_Poly_yc_contrib.launch_tube_measurement(env(dB));
figure();
Tube_Poly_yc_contrib.plot_alpha(env(dB), 'Contribution cavité jaune');
mphsave(Tube_Poly_yc_contrib.Configuration.ComsolModel, [folderName, '\optimisation_Poly_', currentTime '\validation contribution cavité jaune.mph']);
perso_configure_alpha_figure(2000);
saveas(gcf, [folderName, '\optimisation_Poly_', currentTime, '\Figures\Validation de la contribution de la cavité jaune.fig']);