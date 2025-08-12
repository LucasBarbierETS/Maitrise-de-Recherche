%% Description

% L'optimisation finale porte sur une cellule unitaire de la cartouche
% comprenant : 
% - une plaque couvrante
% - un air gap sur toute la section de la plaque
% - en parallèle : 
%   - les solutions de l'ETS (MPPSBH)
%   - les solutions de Poly (MLP)
%   - les cavités résonantes (SDOF)

%% Sélection du dossier de destination des élements sauvegardés

% folderName = uigetdir();
folderName = 'C:\Users\lucas.barbier\Documents\Maitrise dossier secondaire\MATLAB\Optimisation\Optimisation REAR';
% folderName = 'C:\Users\lucas.barbier\Documents\Maitrise dossier secondaire\MATLAB\Optimisation\Optimisation REAR\Validation numérique';

%% Ouverture de l'environnement matlab

% load(uigetfile(folderName));


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
% dB_data = load('C:\Users\lucas.barbier\Documents\Maitrise dossier secondaire\MATLAB\Optimisation\Optimisation REAR\niveau sonore.txt');
% f = dB_data(:, 1);
% dB = dB_data(:, 2);
% mask =  f <= env(dB).w(end)/(2*pi);
% [f_interp, dB_interp] = perso_interpole_et_lisse(f(mask), dB(mask), length(env(dB).w), 10);
% figure();
% plot(log10(f_interp), dB_interp);

%% Paramètres géométriques invariants

total_thickness = 115e-3;
total_depth = 120e-3; 
total_width = 72e-3;
total_input_surface = total_depth * total_width;

% Epaisseur de l'interstice
air_gap_thickness = 1e-3;
% air_gap_thickness = 10e-3;

% Plaque couvrante
top_plate_thickness = 1e-3;
% radius = [1.588, 1.984, 2.381, 2.778, 3.175]/2 * 1e-3;

% Solution ETS
ETS_cavities_width = 28e-3; % bords externes : 30 mm
ETS_cavities_depth = 28e-3; % bords externes : 30 mm
ETS_input_surface = 30e-3^2;
plates_thickness = 2e-3;
plates_holes_radius = 4.5e-4;
rigid_backing_thickness = 1e-3;

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
yc_input_surface = 12e-3*30e-3;

%% Structure des variables optimisées

NTP = 3; % (rayon, nombre de perf par ligne (width), nombre de perfs par colonne (depth))
NS = 8; % Nombre de MPPSBH optimisés
NV = 2; % Nombre de variables pour chaque solution (nombre de perfs en largeur, espacement des perfs en largeur)
N = 5; % Nombre de plaques optimisées indépendantes pour chaque solution

% NP = 500; % Nombre de points de départ
NP = 100;
% NP = 50;
% NP = 10;

ETS_cavities_thickness = round((total_thickness - top_plate_thickness - air_gap_thickness - N * plates_thickness) / (N+1), 4);

% Récupération des parties du vecteur d'optimisation
x_TP1 = @(x) x(1 : NTP);
x_TP2 = @(x) x(NTP+1 : 2*NTP);
x_ETS = @(x) reshape(x(2*NTP+1 : 2*NTP + N*NV*NS), NS, N, NV);
x_SPLX = @(x) x(2*NTP + N*NV*NS + 1 : end);

% Récupération des paramètres de la plaque supérieur
tp_width_holes_distance = @(x_TP) total_width / x_TP(2);
tp_depth_holes_distance = @(x_TP) total_depth / x_TP(3);

% Définition des nombres de perforation maximisés en fonction de la surface d'entrée de la plaque

% Explication
% On calcule le nombre maximal de perforations qu'on peut faire tenir dans
% les dimensions de la surface d'entrée en évitant des perforations
% partiellement obstruées.
% On renvoie le nombre de perforation (entier) maximal tel que les bords
% extremes sont éloignés de moins que la dimension considérée

plate_width_holes_number = @(x_TP, input_width) floor((input_width - 2*x_TP(1))/tp_width_holes_distance(x_TP) + 1);
plate_depth_holes_number = @(x_TP, input_depth) floor((input_depth - 2*x_TP(1))/tp_depth_holes_distance(x_TP) + 1);

%% Valeurs minimales en fonction du type de variable

% Plaque couvrante
tp_phi_min = 0.05;
% tp_r_min = 1;
tp_r_min = 4e-4;
tp_whn_min = 15;
tp_dhn_min = 15;

% Solution ETS
dw_min = 3 * plates_holes_radius;
pw_min = 1;

lb_TP = repmat([tp_r_min, tp_whn_min, tp_dhn_min], 1, 2);
lb = horzcat(lb_TP, repmat(dw_min, 1, N * NS), ones(1, N * NS));

%% Valeurs maximales en fonction du type de variable

% Plaque couvrante
tp_phi_max = 0.4;
% tp_r_max = 5;
tp_r_max = 3e-3;
tp_whn_max = 100;
tp_dhn_max = 100;

% Solution ETS
dw_max = 6 * plates_holes_radius;
pw_max = floor((ETS_cavities_width - dw_max) / (dw_max));
ub_TP = repmat([tp_r_max, tp_whn_max, tp_dhn_max], 1, 2);
ub = horzcat(ub_TP, repmat(dw_max, 1, N * NS), repmat(pw_max, 1, N * NS));

%% Valeurs initiales en fonction du types de variable

% Plaque supérieure 
% tp_r_init = randi(tp_r_max, NP, 1);
tp_r_init = tp_r_min + (tp_r_max - tp_r_min) * rand(NP, 2);
tp_phi_init = tp_phi_min + (tp_phi_max - tp_phi_min) * rand(NP, 2);
tp_hole_number_init = @(phi, r) round(total_width * total_depth * phi / (pi*r^2));
[tp_width_holes_number_init, tp_depth_holes_number_init] = arrayfun( ...
    @(i,j) perso_distribute_holes( ...
        total_width, total_depth, ...
        tp_hole_number_init(tp_phi_init(i,j), tp_r_init(i,j)) ...
    ), ...
    repmat((1:NP)', 1, 2), ... % ligne i
    repmat(1:2, NP, 1) ...     % colonne j
);

% Distance inter-perforation en largeur
dw_init = dw_min + (dw_max - dw_min) * rand(NP, N * NS);
% dw_init_sorted = sort(dw_init, 2, "descend");

% Nombre de perforation en largeur
pw_init = randi([pw_min, pw_max], NP, N * NS);
% pw_init_sorted = sort(pw_init, 2, "descend");

% Paramètres de répartition de l'épaisseur
x0_TP1 = horzcat(tp_r_init(:, 1), tp_width_holes_number_init(:, 1), tp_depth_holes_number_init(:, 1));
x0_TP2 = horzcat(tp_r_init(:, 2), tp_width_holes_number_init(:, 2), tp_depth_holes_number_init(:, 2));
x0 = horzcat(x0_TP1, x0_TP2, dw_init, pw_init);
% x0 = horzcat(x0_TP1, x0_TP2, dw_init_sorted, pw_init_sorted);

%% Contrainte sur les variables entières

intcon = find(horzcat([0, 1, 1, 0, 1, 1], zeros(1, N*NS), ones(1, N*NS)));

%% Fonction de définitions de la matrice de contraintes non linéaires  

% Définition du handle avec paramètres capturés
handle_perso_nonlcon = @(x) perso_MPPSBHr_nonlconf(x_ETS(x), NV, NS, N, ETS_cavities_width, ETS_cavities_depth);

% % Debog : Test des contraintes non-linéaires sur les configurations initiales
% [c, ceq] = handle_perso_nonlcon(x0(1, :));

%% Gabarits

% Définition des plages fréquentielles d'interet pour la fonction cout
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

Objets = struct();

% Construction du ième MPPSBH à partir d'une découpe du vecteur d'optimisation
Objets.MPPSBH_i = @(x_ETS, i) classMPPSBH_Rectangular( ...
    classMPPSBH_Rectangular.create_explicit_slit_pattern_config( ...
        ETS_input_surface, N, ETS_cavities_depth, ETS_cavities_width, ...
        {4.5e-4}, ... {eval_r(x0(:, 1, i))}, ... % rayon des perforations
        {x_ETS(i, :, 1)}, ... % distance entre perforations (width)
        {ETS_cavities_depth/8}, ... % distance entre perforations (depth)
        {8}, ... {transpose(x0(:, 3, i))}, ... % nombre de perforations en profondeur
        {x_ETS(i, :, 2)}, ... % nombre de perforations en largeur
        {plates_thickness}, ... % épaisseur des plaques (supérieure + internes)
        {ETS_cavities_thickness}));  % épaisseur de cavité

% Construction d'une solution en rajoutant une cavité au dessus de la solution MPPSBH

Objets.MPPSBH_element_i = @(x_ETS, i) classelement( ...
    classelement.create_config({ ...
    classcavity(classcavity.create_config(ETS_cavities_thickness, ETS_cavities_width, ETS_cavities_depth)) ...
    Objets.MPPSBH_i(x_ETS, i)}, 'closed', ETS_input_surface));

% % Debog : MPPSBH_element_i
% figure();
% Objets.MPPSBH_element_i(x_ETS(x0(1, :)), 1).plot_alpha(env(dB), 'MPPSBH element 1');

% Construction d'un cell array contenant les objets de classe MPPSBH
Objets.cell_of_MPPSBH_elements = @(x) arrayfun(@(i) ...
    Objets.MPPSBH_element_i(x_ETS(x), i), 1:NS ,'UniformOutput', false);

% Plaque couvrante
covering_plate = @(r, w, d, pw, pd) classMPP_Circular( ... 
classMPP_Circular.create_explicit_rectangular_plate_config( ...
    top_plate_thickness, r, w, d, pw, pd));

% Plaque supérieure (optimisée)
top_plate = @(x_TP) covering_plate(x_TP(1), total_width, total_depth, x_TP(2), x_TP(3));

% Distance Plaque - Solutions
air_gap = classcavity(classcavity.create_config(air_gap_thickness, total_width, total_depth));

% Cavité Jaune
yellow_cavity = classcavity(classcavity.create_config(yellow_cavities_thickness, yellow_cavities_width, yellow_cavities_depth));
% yellow_cavity = classQWL_Slit(classQWL_Slit.create_config(yellow_cavities_thickness, yellow_cavities_width, yellow_cavities_depth));
yellow_cavity_element = classelement(classelement.create_config({yellow_cavity}, 'closed', yc_input_surface));

% % Debog :  Affichage des performance de la cavité jaune
% figure();
% perso_plot_surface_impedance(env(dB).w/(2*pi), yellow_cavity_element.surface_impedance(env(dB)), env(dB));

%% Création dynamique des contributions des solutions individuelles

Contributions = struct();

Contributions.contribution_MPPSBH_element_i = @(x, i) classelement(classelement.create_config( ...
    {perso_modify_subelement_dimensions(top_plate(x_TP1(x)), ETS_cavities_width, ETS_cavities_depth), ...
     perso_modify_subelement_dimensions(air_gap, ETS_cavities_width, ETS_cavities_depth), ...
     classcavity(classcavity.create_config(ETS_cavities_thickness, ETS_cavities_width, ETS_cavities_depth)), ...
     Objets.MPPSBH_i(x_ETS(x), i)}, 'closed', ETS_input_surface));

Contributions.contribution_cell_of_MPPSBH_element = @(x) arrayfun(@(i) ...
    Contributions.contribution_MPPSBH_element_i(x, i), 1:NS ,'UniformOutput', false);

Contributions.contribution_Poly_element = @(x) classelement(classelement.create_config( ...
    {perso_modify_subelement_dimensions(top_plate(x_TP2(x)), Poly_cavities_width, Poly_cavities_depth), ...
     perso_modify_subelement_dimensions(air_gap, Poly_cavities_width, Poly_cavities_depth), ...
     imported_Poly_subelement}, 'closed', Poly_input_surface));

Contributions.contribution_Poly_numerical_element = @(x) classelement(classelement.create_config( ...
    {perso_modify_subelement_dimensions(top_plate(x_TP2(x)), Poly_cavities_width, Poly_cavities_depth), ...
     perso_modify_subelement_dimensions(air_gap, Poly_cavities_width, Poly_cavities_depth), ...
     numerical_Poly_subelement}, 'closed', Poly_input_surface));

Contributions.cell_of_Poly_element_contribution = @(x) arrayfun(@(i) ...
    Contributions.contribution_Poly_element(x), 1:NS ,'UniformOutput', false);

Contributions.contribution_ETS_yellow_cavity = @(x) classelement(classelement.create_config( ...
    {perso_modify_subelement_dimensions(top_plate(x_TP1(x)), yellow_cavities_width, yellow_cavities_depth), ...
     perso_modify_subelement_dimensions(air_gap, yellow_cavities_width, yellow_cavities_depth), ...
     yellow_cavity}, 'closed', yc_input_surface));

Contributions.cell_of_ETS_yellow_cavity_contributions = @(x) arrayfun(@(i) ...
    Contributions.contribution_ETS_yellow_cavity(x), 1:4 ,'UniformOutput', false);

Contributions.contribution_Poly_yellow_cavity = @(x) classelement(classelement.create_config( ...
    {perso_modify_subelement_dimensions(top_plate(x_TP2(x)), yellow_cavities_width, yellow_cavities_depth), ...
     perso_modify_subelement_dimensions(air_gap, yellow_cavities_width, yellow_cavities_depth), ...
     yellow_cavity}, 'closed', yc_input_surface));

Contributions.cell_of_Poly_yellow_cavity_contributions = @(x) arrayfun(@(i) ...
    Contributions.contribution_Poly_yellow_cavity(x), 1:4 ,'UniformOutput', false);

%% Validation numérique 2D des contributions (honnête)

% Tube_MPPSBH_element_contrib = ImpedanceTube2D(ImpedanceTube2D.create_config({Contributions.contribution_MPPSBH_element_i(x0(1, :), 1)}));
% Tube_MPPSBH_element_contrib = Tube_MPPSBH_element_contrib.launch_tube_measurement(env(dB));
% Tube_MPPSBH_element_contrib.plot_alpha(env(dB), 'Contribution MPPSBH');
% figure()
% mphgeom(Tube_MPPSBH_element_contrib.Configuration.ComsolModel)

% Tube_ETS_yc_contrib = ImpedanceTube2D(ImpedanceTube2D.create_config({Contributions.contribution_ETS_yellow_cavity(x0(1, :))}));
% Tube_ETS_yc_contrib = Tube_ETS_yc_contrib.launch_tube_measurement(env(dB));
% Tube_ETS_yc_contrib.plot_alpha(env(dB), 'Contribution ETS yellow cavity');

%% Création dynamique des modules

Modules = struct();
Modules.module_ETS = @(x) classelementassembly(classelementassembly.create_config( ...
        [Objets.cell_of_MPPSBH_elements(x), ... % Solutions ETS
            repmat({yellow_cavity_element}, 1, 4)])); % Solutions HR 

Modules.module_ETS_sans_HR = @(x) classelementassembly(classelementassembly.create_config(Objets.cell_of_MPPSBH_elements(x))); 

Modules.module_Poly = @(x) classelementassembly(classelementassembly.create_config( ...
                [repmat({imported_Poly_element}, 1, NS), ... % Solutions Poly
                    repmat({yellow_cavity_element}, 1, 4)])); % Solutions HR 

Modules.module_Poly_sans_HR = @(x) classelementassembly(classelementassembly.create_config(repmat({imported_Poly_element}, 1, NS)));

%% Création dynamique des cartouches

Cartouches = struct();

Cartouches.cartouche_ETS = @(x) classelement(classelement.create_config( ...
    {top_plate(x_TP1(x)), air_gap, Modules.module_ETS(x)}, 'closed', total_input_surface));

Cartouches.cartouche_ETS_sans_HR = @(x) classelement(classelement.create_config( ...
    {top_plate(x_TP1(x)), air_gap, Modules.module_ETS_sans_HR(x)}, 'closed', total_input_surface));

Cartouches.cartouche_ETS_contributions = @(x) classelementassembly(classelementassembly.create_config( ...
    [Contributions.contribution_cell_of_MPPSBH_element(x), Contributions.cell_of_ETS_yellow_cavity_contributions(x)]));

Cartouches.cartouche_ETS_sans_HR_contributions = @(x) classelementassembly(classelementassembly.create_config( ...
    Contributions.contribution_cell_of_MPPSBH_element(x)));

Cartouches.cartouche_Poly = @(x) classelement(classelement.create_config( ...
    {top_plate(x_TP2(x)), air_gap, Modules.module_Poly(x)}, 'closed', total_input_surface));

Cartouches.cartouche_Poly_sans_HR = @(x) classelement(classelement.create_config( ...
    {top_plate(x_TP2(x)), air_gap, Modules.module_Poly_sans_HR(x)}, 'closed', total_input_surface));

Cartouches.cartouche_Poly_contributions = @(x) classelementassembly(classelementassembly.create_config( ...
    [Contributions.cell_of_Poly_element_contribution(x), Contributions.cell_of_Poly_yellow_cavity_contributions(x)]));

Cartouches.cartouche_Poly_sans_HR_contributions = @(x) classelementassembly(classelementassembly.create_config( ...
    Contributions.cell_of_Poly_element_contribution(x)));

Cartouches.cartouche_globale = @(x) classelementassembly(classelementassembly.create_config({Cartouches.cartouche_ETS(x), Cartouches.cartouche_Poly(x)}));

%% Fonctions coût

% Evaluation du coût sur la cartouche ETS
cost_function_ETS_obj1 = @(x, env) sum(((Cartouches.cartouche_ETS(x).alpha(env) - g_obj1(env)) .* (g_obj1(env) > 0.1)).^2, 'omitnan');
cost_function_ETS_obj2 = @(x, env) sum(((Cartouches.cartouche_ETS(x).alpha(env) - g_obj2(env)) .* (g_obj2(env) > 0.1)).^2, 'omitnan');
cost_function_ETS_obj3 = @(x, env) sum(((Cartouches.cartouche_ETS(x).alpha(env) - g_obj3(env)) .* (g_obj3(env) > 0.1)).^2, 'omitnan');

% Evaluation du coût sur la cartouche Poly
cost_function_Poly_obj1 = @(x, env) sum(((Cartouches.cartouche_Poly(x).alpha(env) - g_obj1(env)) .* (g_obj1(env) > 0.1)).^2, 'omitnan');
cost_function_Poly_obj2 = @(x, env) sum(((Cartouches.cartouche_Poly(x).alpha(env) - g_obj2(env)) .* (g_obj2(env) > 0.1)).^2, 'omitnan');
cost_function_Poly_obj3 = @(x, env) sum(((Cartouches.cartouche_Poly(x).alpha(env) - g_obj3(env)) .* (g_obj3(env) > 0.1)).^2, 'omitnan');

% Evaluation du coût sur la cartouche globale
cost_function_obj1 = @(x, env) sum(((Cartouches.cartouche_globale(x).alpha(env) - g_obj1(env)) .* (g_obj1(env) > 0.1)).^2, 'omitnan');
cost_function_obj2 = @(x, env) sum(((Cartouches.cartouche_globale(x).alpha(env) - g_obj2(env)) .* (g_obj2(env) > 0.1)).^2, 'omitnan');
cost_function_obj3 = @(x, env) sum(((Cartouches.cartouche_globale(x).alpha(env) - g_obj3(env)) .* (g_obj3(env) > 0.1)).^2, 'omitnan');

% objective = @(x) cost_function_obj1(x, env(dB));
% objective = @(x) [cost_function_obj1(x, env(dB)), cost_function_obj2(x, env(dB))];
objective = @(x) [cost_function_obj1(x, env(dB)), cost_function_obj2(x, env(dB)), cost_function_obj3(x, env(dB))];

% objective = @(x) [cost_function_ETS_obj1(x, env(dB)), cost_function_ETS_obj2(x, env(dB))];
% objective = @(x) [cost_function_ETS_obj1(x, env(dB)), cost_function_ETS_obj2(x, env(dB)), cost_function_ETS_obj3(x, env(dB))];

% Objectifs mixtes
% objective = @(x) [cost_function_Poly_obj1(x, env(dB)), cost_function_ETS_obj2(x, env(dB)), cost_function_ETS_obj3(x, env(dB))];

%% Fonction d'affichage des résultats temporaires

temp_plot_MPPSBH_results = @(x, i) plot_MPPSBH_results(x, i, x_ETS, Objets, Contributions, env(dB));

temp_plot_module_ETS = @(x) plot_module_ETS(x, x_ETS, Objets, Modules, env(dB));

temp_plot_cartouche_ETS = @(x) plot_cartouche_ETS(x, Contributions, Cartouches, env(dB));  

temp_plot_cartouches = @(x) plot_cartouches(x, Cartouches, env(dB));

temp_plot_contributions = @(x) plot_contributions(x, x_ETS, MPPSBH_i, contribution_MPPSBH_element_i, ...
    contribution_ETS_yellow_cavities, contribution_Poly_yellow_cavity, ...
    contribution_Poly_element, module_ETS, module_Poly, ...
    cartouche_ETS, cartouche_Poly, cartouche_globale, env(dB), NS);

%% Debog des performances et des contributions

% temp_plot_MPPSBH_results(x0(1, :));
% temp_plot_contributions(x0(1, :));
% temp_plot_MPPSBH_results(x0(1, :), 1);
% temp_plot_module_ETS(x0(1, :));
% temp_plot_cartouche_ETS(x0(1, :));
% temp_plot_cartouches(x0(1, :));

%% GENETIC ALGORITHM

options = optimoptions('ga', ...
                       'Display', 'iter', ...
                       'PopulationSize', NP, ... % nombre de points dans la population initiale
                       'FunctionTolerance', 1e-2, ...
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
options.PlotFcn = {@gaplotpareto, ... % Pour deux objectifs ou plus
                   @gaplotscorediversity}; % , ...
                   % @(x, optimValues, state) perso_plot_constraints_violation(x, optimValues, state, NS, N)}; 


rng; % For reproducibility"
tic;
[xopti, fval, eflag, ~, population, scores] = gamultiobj(objective, numel(x0(1, :)), [], [], [], [], lb, ub, handle_perso_nonlcon, intcon, options);
timeGa = toc;

%% Conditionnement du vecteur d'optimisation

xopti_to_cell_array_of_global_assembly_alpha = @(x, env) arrayfun(@(i) Cartouches.cartouche_globale(x(i, :)).alpha(env), 1:size(x, 1), 'UniformOutput', false);
% xopti_to_cell_array_of_global_assembly_alpha = @(x, env) arrayfun(@(i) Cartouches.cartouche_ETS(x(i, :)).alpha(env), 1:size(x, 1), 'UniformOutput', false);

cell_of_MPPSBH_assembly_alpha_to_mean_alpha = @(alpha_cell_array, gabarit) arrayfun(@(i) mean(alpha_cell_array{i}(gabarit)), 1:size(alpha_cell_array, 2), 'UniformOutput', false);

% On récupère les vecteurs d'absorption des meilleures configurations
[sorted_scores_opti, sorted_index_opti] = sort(fval);
sorted_xopti = xopti(sorted_index_opti(:, 1), :);
filtered_alpha = xopti_to_cell_array_of_global_assembly_alpha(sorted_xopti, env(dB));

% On récupère, pour ces vecteurs, les alphas moyens sur différentes bandes fréquentielles d'intérêt
mean_alpha_obj1 = cell_of_MPPSBH_assembly_alpha_to_mean_alpha(filtered_alpha, g_obj1(env(dB)));
mean_alpha_obj2 = cell_of_MPPSBH_assembly_alpha_to_mean_alpha(filtered_alpha, g_obj2(env(dB)));

% Tracé interractif des meilleurs résultats de l'optimisation multi objectif
perso_interactive_multi_plot(env(dB).w/(2*pi), filtered_alpha, mean_alpha_obj1, mean_alpha_obj2, 2000);

%% Résultats et sélection de la solution 

chosed_index = input('Veuillez entrer le numéro de la configuration choisie : ');
x_opti = sorted_xopti(chosed_index, :);

%% Sauvergarde

env_saved = input('Sauvegarder l''environnement d''optimisation : ');

if env_saved == 1
    % save([folderName, '\' name '.mat']);
    currentTime = char(datetime('now', 'Format', 'yyyy_MM_dd_HH_mm_ss'));
    perso_save([folderName, '\optimisation_ETS_Poly_', currentTime], '\environnement matlab');
else
    return
end

%% Affichage des performances et des contributions

% temp_plot_MPPSBH_results(x_opti, 1);
temp_plot_module_ETS(x_opti);
% temp_plot_cartouche_ETS(x_opti);
temp_plot_cartouches(x_opti);

%% Indicateurs

% alpha_mean_lb_hf_in_band = assembly_lb_hf_opti.alpha_mean(env(dB), f_min_obj1, f_max_obj1);
% alpha_mean_lb_hf_out_band = assembly_lb_hf_opti.alpha_mean(env(dB), f_min_obj2, f_max_hf);
% alpha_mean = assembly_lb_hf_opti.alpha_mean(env(dB), f_min_obj1, f_max_hf);

%% Validation numérique des objects individuels

% Validation des MPPSBHs

i = 1;

Tube_MPPSBH = ImpedanceTube2D(ImpedanceTube2D.create_config({Objets.MPPSBH_element_i(x_ETS(x_opti), i)}));
Tube_MPPSBH = Tube_MPPSBH.launch_tube_measurement(env(dB));
Tube_MPPSBH.plot_alpha(env(dB), ['MPPSBH ' num2str(i)]);
figure();
mphgeom(Tube_MPPSBH.Configuration.ComsolModel);
MPPSBH = Objets.MPPSBH_i(x_ETS(x_opti), i);
MPPSBH_config = MPPSBH.Configuration;
Objets.MPPSBH_i(x_ETS(x_opti), i).plot_alpha(env(dB), 'analytique');
mphsave(Tube_MPPSBH.Configuration.ComsolModel, [folderName, '\optimisation_', currentTime, '\validation_2D_MPPSBH_', num2str(i), '.mph']);
mphgeom(Tube_MPPSBH.Configuration.ComsolModel)

% % Validation des cavités HR
% 
% Tube = ImpedanceTube2D(ImpedanceTube2D.create_config({}));
% Tube = Tube.lauch_tube_measurement();
% Tube.plot_alpha(env(dB), 'MPPSBH 1');
% figure();
% mphgeom(Tube.Configuration.ComsolModel);
% Objets.MPPSBH_i(x_ETS(x0(1, :)), 1).plot_alpha(env(dB), 'analytique');
% mphsave(Tube.Configuration.ComsolModel, [folderName, '\optimisation_', currentTime, '\validation_2D_MPPSBH_1.mph']);

% %  Validation des solutions de Poly
% 
% Tube_Poly = ImpedanceTube2D(ImpedanceTube2D.create_config({numerical_Poly_subelement}));
% Tube_Poly = Tube_Poly.lauch_tube_measurement();
% 
% figure();
% hold on
% alpha_COMSOL_Poly_subelement = perso_plot_alpha_from_COMSOL_model(Tube_Poly.Configuration.ComsolModel, 'sous-élement Poly numérique');
% imported_Poly_subelement.plot_alpha(env(dB), 'sous-élement importé');
% 
% mphgeom(Tube_Poly.Configuration.ComsolModel);
% mphsave(Tube_Poly.Configuration.ComsolModel, [folderName, '\optimisation_', currentTime, '\validation_2D_solution_Poly.mph']);

%% Validation des contributions individuelles

figure()
for i = 1:NS
    Tube_MPPSBH_element_contrib = ImpedanceTube2D(ImpedanceTube2D.create_config({Contributions.contribution_MPPSBH_element_i(x_opti, i)}));
    Tube_MPPSBH_element_contrib = Tube_MPPSBH_element_contrib.launch_tube_measurement(env(dB));
    subplot(4, 4, 2*(i-1) + 1)
    Tube_MPPSBH_element_contrib.plot_alpha(env(dB), ['Contribution MPPSBH' num2str(i)]);
    subplot(4, 4, 2*(i-1) + 2)
    mphgeom(Tube_MPPSBH_element_contrib.Configuration.ComsolModel);
end

Tube_ETS_yc_contrib = ImpedanceTube2D(ImpedanceTube2D.create_config({Contributions.contribution_ETS_yellow_cavity(x_opti)}));
Tube_ETS_yc_contrib = Tube_ETS_yc_contrib.launch_tube_measurement(env(dB));
figure();
Tube_ETS_yc_contrib.plot_alpha(env(dB), 'Contribution ETS yellow cavity');

Tube_Poly_element_contrib = ImpedanceTube2D(ImpedanceTube2D.create_config({Contributions.contribution_Poly_numerical_element(x_opti)}));
Tube_Poly_element_contrib = Tube_Poly_element_contrib.launch_tube_measurement(env(dB));
figure();
Tube_Poly_element_contrib.plot_alpha(env(dB), 'Contribution Poly numerical element');
Contributions.contribution_Poly_element(x_opti).plot_alpha(env(dB), 'Contribution élement importé');
perso_configure_alpha_figure(2000);

Tube_Poly_yc_contrib = ImpedanceTube2D(ImpedanceTube2D.create_config({Contributions.contribution_Poly_yellow_cavity(x_opti)}));
Tube_Poly_yc_contrib = Tube_Poly_yc_contrib.launch_tube_measurement(env(dB));
figure();
Tube_Poly_yc_contrib.plot_alpha(env(dB), 'Contribution Poly yellow cavity');

%% Validation numérique des cartouches

% Cartouche_ETS_numerical_2D_validation = ...
%     @(x, i, name) Cartouche_ETS_numerical_2D_validation( ...
%     Cartouches.cartouche_ETS(x), env(dB), folderName, name);
% 
% model = contribution_MPPSBH_element_i_numerical_2D_validation(x0(1, :), 1, 'validation_MPPSBH_element_1');
% mphsave(model, [folderName, '\validation_MPPSBH_element_1.mph']);
% perso_plot_alpha_from_COMSOL_model(model, 'MPPSBH_element_1');

% handle_Cartouche_Poly_numerical_2D_validation = @(x, solN, name) Cartouche_Poly_numerical_2D_validation( ...
%     Cartouches.cartouche_Poly(x), solN, env(dB), folderName, name);
% 
% model = handle_Cartouche_Poly_numerical_2D_validation(x0(1, :), solN, 'validation_cartouche_Poly');
% mphsave(model, [folderName, '\validation_cartouche_Poly.mph']);
% perso_plot_alpha_from_COMSOL_model(model, 'MPPSBH_element_1');

% % Importation du modèle résolu de la Cartouche Poly
% model = mphload([folderName, '\validation_cartouche_Poly.mph']);
% model = perso_create_results_table(model);
% perso_plot_alpha_from_COMSOL_model(model);

%% Sauvegarde des rapports de configuration

% report_root = 'E:\Montréal 2023 - 2025\Maitrise LB\Présentations\Présentation groupe REAR\25.05.08 - configurations finales pour 1ère itération\';
% MPPSBH_lb_hf_1.export_report([report_root, 'rapport de configuration - solution 1.xlsx'])
% MPPSBH_lb_hf_2.export_report([report_root, 'rapport de configuration - solution 2.xlsx'])
% MPPSBH_lb_hf_3.export_report([report_root, 'rapport de configuration - solution 3.xlsx'])
% MPPSBH_lb_hf_4.export_report([report_root, 'rapport de configuration - solution 4.xlsx'])

