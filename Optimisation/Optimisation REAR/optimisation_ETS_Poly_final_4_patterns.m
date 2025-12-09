%% ========================================================================
%%
%%  Chargement des données optimisées (Aout 2025)
%%
%% =========================================================================

local_root = [env.Root, '\Optimisation\Optimisation REAR'];
folder_name = [local_root, '\Optimisations finales\optimisation_ETS_Poly_H1-4_08_25_06_14'];
load([folder_name, '\Objets MATLAB\x_opti.mat'])

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

data = readmatrix([env.Root, '\Optimisation\Optimisation REAR\Données pression pariétale\stator_spectrum_data.txt'], ...
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
env134 = handle_env(134, M);
env140 = handle_env(140, M);
% env0 = handle_env(dB, 0);

%% Paramètres géométriques invariants

total_thickness_ETS = 117e-3;
total_thickness_Poly = 102e-3;
total_depth = 120e-3; 
total_width = 72e-3;
total_input_surface = total_depth * total_width;

% Epaisseur de l'interstice
air_gap_thickness = 1e-3;
% air_gap_thickness = 10e-3;

% Plaque couvrante
top_plate_thickness = 1e-3;

% Liste des diamètres de foret en pouces
diameters_inch = [1/32, 3/64, 1/16, 5/64]; %, 3/32, 7/64, 1/8, 9/64, 5/32, 11/64, 3/16];
diameters_mm = diameters_inch * 25.4;
radius = diameters_mm/2*1e-3;

% Solution ETS
ETS_width = 30e-3;
ETS_depth = 30e-3;
ETS_cavities_width = 28e-3; 
ETS_cavities_depth = 28e-3; 
ETS_input_surface = ETS_width * ETS_depth;
plates_thickness = 2e-3;
rigid_backing_thickness = 1e-3;
depth_holes_number = 10;
depth_holes_distance = ETS_cavities_depth / (depth_holes_number + 1);
ETS_cavities_thickness = 17.17e-3;

% Solutions Poly
Poly_width = 30e-3;
Poly_depth = 30e-3;
Poly_cavities_width = 28e-3; 
Poly_cavities_depth = 28e-3;
Poly_cavities_input_section = Poly_cavities_width * Poly_cavities_depth; 
Poly_input_surface = Poly_width * Poly_depth;

% Solutions HR
yc_width = 12e-3;
yc_depth = 30e-3;
yellow_cavities_thickness_ETS = total_thickness_ETS - top_plate_thickness - air_gap_thickness - rigid_backing_thickness;
yellow_cavities_thickness_Poly = total_thickness_Poly - top_plate_thickness - air_gap_thickness - rigid_backing_thickness;
yellow_cavities_width = 10e-3; 
yellow_cavities_depth = 28e-3;
yellow_cavities_input_section = yellow_cavities_width * yellow_cavities_depth;
yc_input_surface = yc_width * yc_depth;

%% Structure des variables optimisées

NTP = 2; %  Rayons des perfs, distance inter-perf (pattern carré)
% NTP = 3; % (rayon, nombre de perf par ligne (width), nombre de perfs par colonne (depth))
NS = 8; % Nombre de MPPSBH optimisés
NV = 2;
% NV = 3; % Nombre de variables pour chaque solution (rayon des perforations, nombre de perfs en largeur, espacement des perfs en largeur)
N = 5; % Nombre de plaques optimisées indépendantes pour chaque solution

NP = 500; % Nombre de points de départ
% NP = 100;
% NP = 50;
% NP = 10;
% NP = 5;
% NP = 2;

% Récupération des parties du vecteur d'optimisation
x_TP_ETS = @(x) x(:, 1 : NTP); % Plaque couvrante ETS
x_TP_Poly = @(x) x(:, NTP+1 : 2*NTP); % Plaque couvrante Poly
x_ETS = @(x) permute(reshape(x(:, 2*NTP+1 : 2*NTP + N*NV*NS), [], NS, N, NV), [2, 3, 4, 1]); % Solutions ETS
x_SPLX = @(x) x(:, 2*NTP + N*NV*NS + 1 : 2*NTP + N*NV*NS + N); % Epaisseur des cavités ETS
x_radius = @(x) x(:, 2*NTP + N*NV*NS + N + 1 : end); % Rayons des solutions ETS

%% Valeurs minimales en fonction du type de variable

% Plaque couvrante
tp_phi_min = 0.01;
tp_r_min = 1;
tp_whn_min = 2;
tp_dhn_min = 4;
% tp_whn_yc_min = 1;
% tp_dhn_yc_min = 4;
tp_dw_min = 3 * radius(4);

% Solution ETS
dw_min = 3 * radius(3);
pw_min = 1;
r_min = 1;

theta_min = 1;

lb_TP = repmat([tp_r_min, tp_dw_min], 1, 2); 
lb = horzcat(lb_TP, repmat(dw_min, 1, N * NS), ones(1, N * NS), repmat(theta_min, 1, N), repmat(r_min, 1, N));

%% Valeurs maximales en fonction du type de variable

% Plaque couvrante
tp_phi_max = 0.3;
tp_r_max = 4;
tp_whn_max = 20;
tp_dhn_max = 40;
% tp_whn_yc_max = 10;
% tp_dhn_yc_max = 40;
tp_dw_max = 20 * radius(1);

% Solution ETS
% dw_max = 10 * radius(1);
dw_max =  depth_holes_distance;
pw_max = depth_holes_number;
r_max = 3;

theta_max = 5;

ub_TP = repmat([tp_r_max, tp_dw_max], 1, 2); 
ub = horzcat(ub_TP, repmat(dw_max, 1, N * NS), repmat(pw_max, 1, N * NS), repmat(theta_max, 1, N), repmat(r_max, 1, N));

% Debog : Porosité max et min
% phi_min = pi * radius(1)^2 / tp_dw_max^2; % < 1 %
% phi_max = pi * radius(4)^2 / tp_dw_min^2; % > 30 %

%% Valeurs initiales en fonction du types de variable

% Plaque supérieure 
tp_r_init = randi([tp_r_min, tp_r_max], NP, 2);
tp_dw_init = tp_dw_min + (tp_dw_max - tp_dw_min) * rand(NP, 2);

% Rayon des perforations
r_init = randi([r_min, r_max], NP, N);

% Distance inter-perforation en largeur
dw_init = dw_min + (dw_max - dw_min) * rand(NP, N * NS);
% dw_init_sorted = sort(dw_init, 2, "descend");

% Nombre de perforation en largeur
pw_init = randi([pw_min, pw_max], NP, N * NS);
% pw_init_sorted = sort(pw_init, 2, "descend"); 

% Paramètres de répartition de l'épaisseur
theta_init = theta_min + (theta_max - theta_min) * rand(NP, N);

x0_TP_ETS = horzcat(tp_r_init(:, 1), tp_dw_init(:, 1));
x0_TP_Poly = horzcat(tp_r_init(:, 2), tp_dw_init(:, 2));
x0 = horzcat(x0_TP_ETS, x0_TP_Poly, dw_init, pw_init, theta_init, r_init);
% x0 = horzcat(x0_TP_ETS, x0_TP_Poly, dw_init_sorted, pw_init_sorted);
% changement 2
% % Debog : Largeur des fentes crées
% figure();
% sw_init = repmat(2 * radius(r_init), 1, NS) + dw_init .* (pw_init - 1);
% histogram(sw_init, 20);
% title('Largeur des fentes dans les MPPSBHs')

% % Debog : Porosité des plaques crées
% figure();
% hold on
% phi_init_app = (pi * (repmat(radius(r_init), 1, NS)).^2 * depth_holes_number .* pw_init) / (ETS_cavities_width * ETS_cavities_depth);
% phi_init = (pi * (repmat(radius(r_init), 1, NS)).^2 * depth_holes_number .* pw_init) ./ (sw_init * ETS_cavities_depth);
% histogram(phi_init_app, 20, 'DisplayName', 'Porosité apparente de la plaque');
% histogram(phi_init, 20, 'DisplayName', 'Porosité effective de la zone perforée');
% title('Porosités des plaques dans les MPPSBHs');
% legend()

%% Contrainte sur les variables entières

intcon = find(horzcat([1, 0, 1, 0], zeros(1, N*NS), ones(1, N*NS), zeros(1, N), ones(1, N)));

%% Importation de l'élement expérimental

% % Importation de l'impédance de surface de l'élement expérimental en parallèle
% data = perso_load_mecanum_files(['C:\Users\lucas.barbier\Documents\Maitrise dossier secondaire\' ...
%     'Mesures expérimentales\Echantillons Hutchinson 1ère itération\Echantillon Poly Hutchinson\Export_Data']);
% Zsn = data.NormalizedSurfaceImpedanceOnCavity;
% alpha = data.AbsorptionCoefficientOnCavity;
% frequency_support = Zsn.Sample1_Imag_Frequency_Hz_;
% surface_impedance = Zsn.NormalizedSurfaceImpedanceOnCavity + 1i * Zsn.NormalizedSurfaceImpedanceOnCavity_1;
% alpha100 = alpha.AbsorptionCoefficientOnCavity;

data = load([env.Root, '\Mesures expérimentales\Echantillons Hutchinson 1ère itération\' ...
    'Echantillon Poly Hutchinson\25.05.27- Niloofar solution - numercial evaluation - Surface impedance.txt']);

frequency_support = data(:, 1);
surface_impedance = data(:, 2) + 1i * data(:, 3);

[Zs, imported_Poly_subelement] = classelement_imported(classelement_imported.create_config( ...
        frequency_support, surface_impedance, Poly_cavities_width * Poly_cavities_depth)).surface_impedance(env);

imported_Poly_element = classelement(classelement.create_config({imported_Poly_subelement}, 'closed', Poly_input_surface));
imported_element_assembly = classelementassembly(classelementassembly.create_config(repmat({imported_Poly_element}, 1, 4)));

% % Debog : Tracé de l'impédance de surface
% figure()
% subplot(2, 1, 1)
% plot(frequency_support, real(surface_impedance));
% subplot(2, 1, 2)
% plot(frequency_support, imag(surface_impedance));

% Debog : Comparaison de l'élement importé et l'élement simulé
% 
% figure()
% imported_Poly_element.plot_alpha(env, 'Element importé');
% Tube_Poly = ImpedanceTube2D(ImpedanceTube2D.create_config({numerical_Poly_element}));
% Tube_Poly = Tube_Poly.lauch_tube_measurement(env);
% Tube_Poly.plot_alpha(env, 'Element simulé');

%% Création dynamique des MPPSBHs

Objets = struct();

% Construction du ième MPPSBH à partir d'une découpe du vecteur d'optimisation
Objets.MPPSBH_i = @(x_ETS, x_radius, i) classMPPSBH_Rectangular( ...
    classMPPSBH_Rectangular.create_explicit_slit_pattern_config( ...
        ETS_input_surface, N, ETS_cavities_depth, ETS_cavities_width, ...
        {x_radius}, ... {radius(x_ETS(i, :, 1))}, ... {eval_r(x0(:, 1, i))}, ... % rayon des perforations
        {x_ETS(i, :, 1)}, ... % distance entre perforations (width)
        {ETS_cavities_depth/depth_holes_number}, ... % distance entre perforations (depth)
        {depth_holes_number}, ... {transpose(x0(:, 3, i))}, ... % nombre de perforations en profondeur
        {x_ETS(i, :, 2)}, ... % nombre de perforations en largeur
        {plates_thickness}, ... % épaisseur des plaques (supérieure + internes)
        {ETS_cavities_thickness})); %;  % épaisseur de cavité

% Debog (OK)
% figure()
% Objets.MPPSBH_i(x_ETS(x0(1, :)), x_SPLX(x0(1, :)), 1).plot_alpha(env, 'modèle linéaire');
% close();


% Construction d'une solution en rajoutant une cavité au dessus de la solution MPPSBH
Objets.MPPSBH_element_i = @(x, i) classelement( ...
    classelement.create_config({ ...
    classcavity(classcavity.create_config(ETS_cavities_width * ETS_cavities_depth, ETS_cavities_thickness)) ...
    Objets.MPPSBH_i(x_ETS(x), radius(x_radius(x)), i)}, 'closed', ETS_input_surface));

% % Debog : MPPSBH_element_i
% figure();
% Objets.MPPSBH_element_i(x_ETS(x0(1, :)), 1).plot_alpha(env, 'MPPSBH element 1');

% Construction d'un cell array contenant les objets de classe MPPSBH
Objets.cell_of_MPPSBH_elements = @(x) arrayfun(@(i) ...
    Objets.MPPSBH_element_i(x, i), 1:NS ,'UniformOutput', false);


%% Plaques couvrantes, Airs gaps, Cavités jaunes

porosity = @(x) pi * (radius(x(1)))^2 / x(2)^2;

top_plate = @(x_TP) classMPP_Circular(classMPP_Circular.create_config(total_input_surface,  ...
top_plate_thickness, radius(x_TP(1)), porosity(x_TP)));

top_plate_ETS = @(x_TP_ETS) classMPP_Circular(classMPP_Circular.create_config(ETS_input_surface, ...
top_plate_thickness, radius(x_TP_ETS(1)), top_plate(x_TP_ETS).Configuration.Porosity));

top_plate_Poly = @(x_TP_Poly) classMPP_Circular(classMPP_Circular.create_config(Poly_input_surface, ...
top_plate_thickness, radius(x_TP_Poly(1)), top_plate(x_TP_Poly).Configuration.Porosity));

top_plate_yc = @(x_TP_yc) classMPP_Circular(classMPP_Circular.create_config(yc_input_surface, ...
top_plate_thickness, radius(x_TP_yc(1)), top_plate(x_TP_yc).Configuration.Porosity));

% Distance Plaque - Solutions

air_gap = classcavity(classcavity.create_config(total_width * total_depth, air_gap_thickness));

air_gap_ETS = classcavity(classcavity.create_config(air_gap_thickness, ETS_width * ETS_depth));

air_gap_Poly = classcavity(classcavity.create_config(Poly_cavities_width * Poly_cavities_depth, air_gap_thickness));

air_gap_yc = classcavity(classcavity.create_config(yellow_cavities_width * yellow_cavities_depth, air_gap_thickness));

% Cavité Jaune
yellow_cavity_ETS = classcavity(classcavity.create_config(yellow_cavities_width * yellow_cavities_depth, yellow_cavities_thickness_ETS));
yellow_cavity_Poly = classcavity(classcavity.create_config(yellow_cavities_width * yellow_cavities_depth, yellow_cavities_thickness_Poly));
yellow_cavity_element_ETS = classelement(classelement.create_config({yellow_cavity_ETS}, 'closed', yc_input_surface));
yellow_cavity_element_Poly = classelement(classelement.create_config({yellow_cavity_Poly}, 'closed', yc_input_surface));

% % Debog :  Affichage des performance de la cavité jaune
% figure();
% perso_plot_surface_impedance(yellow_cavity_element_ETS.surface_impedance(env), env, 'Cavité jaune seule module ETS');

%% Création dynamique des contributions des solutions individuelles

Contributions = struct();

Contributions.contribution_MPPSBH_element_i = @(x, i) classelement(classelement.create_config( ...
    {top_plate_ETS(x_TP_ETS(x)), ...
     air_gap_ETS, ...
     classcavity(classcavity.create_config(ETS_cavities_width * ETS_cavities_depth, ETS_cavities_thickness)), ...
     Objets.MPPSBH_i(x_ETS(x), radius(x_radius(x)), i)}, 'closed', ETS_input_surface));

% % Debog (OK)
% figure()
% Contributions.contribution_MPPSBH_element_i(x0(1, :), 1).plot_alpha(env, 'Contribution MPPSBH élement 1');
% close();

% % Debog : Approche itérative (OK)
% Contributions.contribution_MPPSBH_element_HL_iter_i(x0(1, :), 1).plot_alpha(env, 'Contribution Element MPPSBH HL', 'iter');
% perso_configure_alpha_figure(2000)
% close();


Contributions.contribution_cell_of_MPPSBH_element = @(x) arrayfun(@(i) ...
    Contributions.contribution_MPPSBH_element_i(x, i), 1:NS ,'UniformOutput', false);

Contributions.contribution_Poly_element = @(x) classelement(classelement.create_config( ...
    {top_plate_Poly(x_TP_Poly(x)), ...
     air_gap_Poly, ...
     imported_Poly_subelement}, 'closed', Poly_input_surface));

Contributions.contribution_Poly_numerical_element = @(x) classelement(classelement.create_config( ...
    {top_plate_Poly(x_TP_Poly(x)), ...
     air_gap_Poly, ...
     numerical_Poly_subelement}, 'closed', Poly_input_surface));

Contributions.cell_of_Poly_element_contribution = @(x) arrayfun(@(i) ...
    Contributions.contribution_Poly_element(x), 1:NS ,'UniformOutput', false);

Contributions.contribution_ETS_yellow_cavity = @(x) classelement(classelement.create_config( ...
    {top_plate_yc(x_TP_ETS(x)), ...
     air_gap_yc, ...
     yellow_cavity_ETS}, 'closed', yc_input_surface));

Contributions.cell_of_ETS_yellow_cavity_contributions = @(x) arrayfun(@(i) ...
    Contributions.contribution_ETS_yellow_cavity(x), 1:4 ,'UniformOutput', false);

% % Debog : Approche itérative (OK)
% Contributions.cell_of_ETS_yellow_cavity_contributions(x0(1, :)).plot_alpha(env, 'Contribution cavités jaunes module ETS');
% classelementassembly(classelementassembly.create_config(Contributions.cell_of_ETS_HL_iter_yellow_cavity_contributions(x0(1, :)))).plot_alpha(env, 'Contribution cavités jaunes module ETS HL', 'iter');
% perso_configure_alpha_figure(2000)
% close();

Contributions.contribution_Poly_yellow_cavity = @(x) classelement(classelement.create_config( ...
    {top_plate_yc(x_TP_Poly(x)), ...
     air_gap_yc, ...
     yellow_cavity_Poly}, 'closed', yc_input_surface));

Contributions.cell_of_Poly_yellow_cavity_contributions = @(x) arrayfun(@(i) ...
    Contributions.contribution_Poly_yellow_cavity(x), 1:4 ,'UniformOutput', false);

%% Validation numérique 2D des contributions (honnête)

% Tube_MPPSBH_element_contrib = ImpedanceTube2D(ImpedanceTube2D.create_config({Contributions.contribution_MPPSBH_element_i(x0(1, :), 1)}));
% Tube_MPPSBH_element_contrib = Tube_MPPSBH_element_contrib.launch_tube_measurement(env);
% Tube_MPPSBH_element_contrib.plot_alpha(env, 'Contribution MPPSBH');
% figure()
% mphgeom(Tube_MPPSBH_element_contrib.Configuration.ComsolModel)

% Tube_ETS_yc_contrib = ImpedanceTube2D(ImpedanceTube2D.create_config({Contributions.contribution_ETS_yellow_cavity(x0(1, :))}));
% Tube_ETS_yc_contrib = Tube_ETS_yc_contrib.launch_tube_measurement(env);
% Tube_ETS_yc_contrib.plot_alpha(env, 'Contribution ETS yellow cavity');

%% Création dynamique des modules

Modules = struct();
Modules.module_ETS = @(x) classelementassembly(classelementassembly.create_config( ...
        [Objets.cell_of_MPPSBH_elements(x), ... % Solutions ETS
            repmat({yellow_cavity_element_ETS}, 1, 4)])); % Solutions HR 

% % Debog : Approche itérative (OK)
% Modules.module_ETS(x0(1, :)).plot_alpha(env, 'Module ETS');
% Modules.module_ETS_HL_iter(x0(1, :)).plot_alpha(env, 'Module ETS HL', 'iter');
% perso_configure_alpha_figure(2000);
% close();

Modules.module_Poly = @(x) classelementassembly(classelementassembly.create_config( ...
                [repmat({imported_Poly_element}, 1, NS), ... % Solutions Poly
                    repmat({yellow_cavity_element_Poly}, 1, 4)])); % Solutions HR 

%% Création dynamique des cartouches

Cartouches = struct();

% Cartouches ETS
Cartouches.cartouche_ETS = @(x) classelement(classelement.create_config( ...
    {top_plate(x_TP_ETS(x)), air_gap, Modules.module_ETS(x)}, 'closed', total_input_surface));

% % Debog : Approche itérative (OK)
% Cartouches.cartouche_ETS(x0(1, :)).plot_alpha(env, 'Module ETS');
% Cartouches.cartouche_ETS_HL(x0(1, :)).plot_alpha(env, 'Module ETS HL', 'iter');
% perso_configure_alpha_figure(2000);
% close();

Cartouches.cartouche_ETS_contributions = @(x) classelement(classelement.create_config( ...
    {classelementassembly(classelementassembly.create_config( ...
    [Contributions.contribution_cell_of_MPPSBH_element(x), Contributions.cell_of_ETS_yellow_cavity_contributions(x)]))}, 'closed', total_input_surface));

% Cartouches Poly
Cartouches.cartouche_Poly = @(x) classelement(classelement.create_config( ...
    {top_plate(x_TP_Poly(x)), air_gap, Modules.module_Poly(x)}, 'closed', total_input_surface));

Cartouches.cartouche_Poly_contributions = @(x) classelement(classelement.create_config( ...
    {classelementassembly(classelementassembly.create_config( ...
    [Contributions.cell_of_Poly_element_contribution(x), Contributions.cell_of_Poly_yellow_cavity_contributions(x)]))}, 'closed', total_input_surface));

% Cartouches globales
Cartouches.cartouche_globale = @(x) classelementassembly(classelementassembly.create_config({Cartouches.cartouche_ETS(x), Cartouches.cartouche_Poly(x)}));

Cartouches.cartouche_globale_contributions = @(x) classelementassembly(classelementassembly.create_config({Cartouches.cartouche_ETS_contributions(x), Cartouches.cartouche_Poly_contributions(x)}));

%% Fonction de définitions de la matrice de contraintes non linéaires  

% Définition du handle avec paramètres capturés
handle_nonlconf = @(x) perso_nonlconf(x_ETS(x), N, NS, top_plate_ETS(x_TP_ETS(x)), top_plate_Poly(x_TP_Poly(x)), ...
                ETS_cavities_width, ETS_cavities_depth, tp_phi_min, tp_phi_max, radius(x_radius(x)));

% % Debog : Test des contraintes non-linéaires sur les configurations initiales
% [c, ceq] = handle_nonlconf(x0);
% ratio = sum(~any(c > 0, 2))/NP * 100;
% sprintf('%f pourcents de configurations respectant les contraintes non-linéaires', ratio)

%% Affichage des porosités simulées

% figure()
% hold on
% p_ETS = zeros(1, NP);
% p_Poly = zeros(1, NP);
% for i = 1:NP
%     p_ETS(i) = top_plate(x_TP_ETS(x0(i, :))).Configuration.Porosity;
%     p_Poly(i) = top_plate(x_TP_Poly(x0(i, :))).Configuration.Porosity;
% end
% 
% histogram(p_ETS, 20, 'DisplayName', 'Cartouche ETS');
% histogram(p_Poly, 20, 'DisplayName', 'Cartouche Poly');
% title('Porosités des plaques couvrantes simulées');
% legend()

%% Fonctions coût

% handle_alpha = @(x, env, g_obj) subsref(Cartouches.cartouche_globale_HL_iter(x).absorption_coefficient(env, 'iter'), substruct('()', {g_obj(env)}));
handle_alpha = @(x, env, g_obj) subsref(Cartouches.cartouche_globale(x).absorption_coefficient(env, {'HL', 'linear'}), substruct('()', {g_obj(env)}));
handle_cost_function = @(x, env, g_obj) mean(1 - handle_alpha(x, env, g_obj));
handle_objective = @(x, env, g_obj_cell) arrayfun(@(i) handle_cost_function(x, env, g_obj_cell{i}), 1:length(g_obj_cell) ,'UniformOutput', false);

% Choix des objectifs
% objective = @(x) cell2mat(handle_objective(x, env, {g_obj_h1, g_obj_h3, g_obj_4, g_obj_lb})); % Objectif Cartouche ETS
%
% objective = @(x) cell2mat(handle_objective(x, env, {g_obj_h1})); % Objectif Cartouche Poly
% objective = @(x) cell2mat(handle_objective(x, env, {g_obj_h2})); % Objectif Cartouche Poly
% objective = @(x) cell2mat(handle_objective(x, env, {g_obj_h3, g_obj_h4})); % Objectif Cartouche Poly
% objective = @(x) cell2mat(handle_objective(x, env, {g_obj_h2, g_obj_lb})); % Objectif Cartouche Poly

objective = @(x) cell2mat(handle_objective(x, env, {g_obj_h1, g_obj_h2, g_obj_h3, g_obj_h4, g_obj_lb})); % Objectif Cartouche globale

%% Debog des performances et des contributions

% temp_plot_cartouches = @(x) plot_cartouches(x, Cartouches, env);
% temp_plot_cartouches(x0(1, :));

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
options.PlotFcn = {@gaplotpareto, ... % Pour deux objectifs ou plus
                   @gaplotscorediversity}; % , ...
                   % @(x, optimValues, state) perso_plot_constraints_violation(x, optimValues, state, NS, N)}; 

rng; % For reproducibility"
tic;
[xopti, fval, eflag, ~, population, scores] = gamultiobj(objective, numel(x0(1, :)), [], [], [], [], lb, ub, handle_nonlconf, intcon, options);
timeGa = toc;

%% =========================================================================
%%
%% Conditionnement du vecteur d'optimisation
%%
%% =========================================================================

xopti_to_cell_array_of_alpha = @(x, env) arrayfun(@(i) vertcat(Cartouches.cartouche_globale(x(i, :)).absorption_coefficient(env, {'HL', 'linear'}), ...
                                                       1:size(x, 1), 'UniformOutput', false));


xopti_to_cell_array_of_Zs = @(x, env) arrayfun(@(i) vertcat(Cartouches.cartouche_globale(x(i, :)).surface_impedance(env)/env.air.parameters.Z0, ...
                                                    1:size(x, 1), 'UniformOutput', false));

% On récupère les vecteurs d'absorption des meilleures configurations
[sorted_scores_opti, sorted_index_opti] = sort(fval);
sorted_xopti = xopti(sorted_index_opti(:, 1), :);
filtered_alpha = xopti_to_cell_array_of_alpha(sorted_xopti, env);
filtered_Zs = xopti_to_cell_array_of_Zs(sorted_xopti, env);

% Tracé interractif des meilleurs résultats de l'optimisation multi objectif
perso_interactive_multi_plot(env.w/(2*pi), filtered_alpha, filtered_Zs, 2000, Frequences);

% On rajoute des barres pour représenter les bandes d'optimisation
perso_plot_targetted_frequencies(Frequences, 1)

% Résultats et sélection de la solution 

chosed_index = input('Veuillez entrer le numéro de la configuration choisie : ');
x_opti = sorted_xopti(chosed_index, :);

%% =========================================================================
%%
%% Sauvergarde
%%
%% =========================================================================

env_saved = input('Sauvegarder l''environnement d''optimisation : ');

if env_saved ~= 1
    return
end

% currentTime = char(datetime('now', 'Format', 'MM_dd_HH_mm'));
% 
% optimisation_type = '\optimisation_ETS_Poly_';
% 
% % objective_type = 'H1_';
% % objective_type = 'H2_';
% % objective_type = 'H1_H2_';
% objective_type = 'H1-4_';
% % objective_type = 'neutre_';

% folder_full_name = [folderName, optimisation_type, objective_type, currentTime];
% mkdir(folder_full_name);
% mkdir([folder_full_name, '\Figures']);
% save([folder_full_name, '\environnement matlab.mat']);

folder_full_name = [env.Root, '\Optimisation\Optimisation REAR\Optimisations finales\optimisation_ETS_Poly_H1-4_08_25_06_14'];

%% =========================================================================
%%
%% Affichage des performances et des contributions
%%
%% =========================================================================

% temp_plot_MPPSBH_results(x_opti, 1);
% temp_plot_module_ETS(x_opti);
% temp_plot_cartouche_ETS(x_opti);
% temp_plot_cartouches(x_opti);

x_TP_ETS(x_opti);
x_TP_Poly(x_opti);
top_plate(x_TP_ETS(x_opti)).Configuration % Plaque ETS
top_plate(x_TP_Poly(x_opti)).Configuration % Plaque Poly

%%%%%%%%%%%%%%%
% Cartouche Globale
%%%%%%%%%%%%%%%

perso_figure('Prédiction des performances de la configuration optimale');
hold on
title('Prédiction des performances de la configuration optimale');

lcl_compute_alpha = @(xopti, method, env) Cartouches.cartouche_globale(x_opti).absorption_coefficient(env, struct('HL_method', method));

alpha_linear = lcl_compute_alpha(x_opti, 'linear', env);
% alpha_first = lcl_compute_alpha(x_opti, 'first');
alpha_all = lcl_compute_alpha(x_opti, 'all', env);
alpha_all134 = lcl_compute_alpha(x_opti, 'all', env134);
alpha_all140 = lcl_compute_alpha(x_opti, 'all', env140);
% alpha_retropropagation = lcl_compute_alpha(x_opti, 'retropropagation');

plot(env.w/(2*pi), alpha_linear, 'DisplayName', 'Modèle linéaire');
% plot(env.w/(2*pi), alpha_first, 'DisplayName', 'Modèle forts niveaux première plaque');
plot(env.w/(2*pi), alpha_all, 'DisplayName', 'Modèle forts niveaux toutes plaques 1/3 d''octave');
plot(env.w/(2*pi), alpha_all134, 'DisplayName', 'Modèle forts niveaux toutes plaques 134 dB');
plot(env.w/(2*pi), alpha_all140, 'DisplayName', 'Modèle forts niveaux toutes plaques 140 dB');
% plot(env.w/(2*pi), alpha_retropropagation, 'DisplayName', 'Modèle forts niveaux retropropagatif');

perso_plot_targetted_frequencies(Frequences, 1);
perso_configure_alpha_figure(2000);

saveas(gcf, [folder_full_name, '\Figures\Prédiction des performances de la configuration optimale.fig']);

%%%%%%%%%%%%%%%
% Cartouche ETS
%%%%%%%%%%%%%%%

perso_figure('Prédiction des performances de la cartouche ETS');
hold on
title('Prédiction des performances de la cartouche ETS');

lcl_compute_alpha = @(xopti, method, env) Cartouches.cartouche_ETS(x_opti).absorption_coefficient(env, struct('HL_method', method));

alpha_linear = lcl_compute_alpha(x_opti, 'linear', env);
% alpha_first = lcl_compute_alpha(x_opti, 'first');
alpha_all = lcl_compute_alpha(x_opti, 'all', env);
alpha_all134 = lcl_compute_alpha(x_opti, 'all', env134);
alpha_all140 = lcl_compute_alpha(x_opti, 'all', env140);
% alpha_retropropagation = lcl_compute_alpha(x_opti, 'retropropagation');

plot(env.w/(2*pi), alpha_linear, 'DisplayName', 'Modèle linéaire');
% plot(env.w/(2*pi), alpha_first, 'DisplayName', 'Modèle forts niveaux première plaque');
plot(env.w/(2*pi), alpha_all, 'DisplayName', 'Modèle forts niveaux toutes plaques 1/3 d''octave');
plot(env.w/(2*pi), alpha_all134, 'DisplayName', 'Modèle forts niveaux toutes plaques 134 dB');
plot(env.w/(2*pi), alpha_all140, 'DisplayName', 'Modèle forts niveaux toutes plaques 140 dB');

% plot(env.w/(2*pi), alpha_retropropagation, 'DisplayName', 'Modèle forts niveaux retropropagatif');

perso_plot_targetted_frequencies(Frequences, 1);
perso_configure_alpha_figure(2000);

saveas(gcf, [folder_full_name, '\Figures\Prédiction des performances de la cartouche ETS.fig']);

%%%%%%%%%%%%%%%%
% Cartouche Poly
%%%%%%%%%%%%%%%%

perso_figure('Prédiction des performances de la cartouche Poly');
hold on
title('Prédiction des performances de la cartouche Poly');

lcl_compute_alpha = @(xopti, method, env) Cartouches.cartouche_Poly(x_opti).absorption_coefficient(env, struct('HL_method', method));

alpha_linear = lcl_compute_alpha(x_opti, 'linear', env);
% alpha_first = lcl_compute_alpha(x_opti, 'first');
alpha_all = lcl_compute_alpha(x_opti, 'all', env);
alpha_all134 = lcl_compute_alpha(x_opti, 'all', env134);
alpha_all140 = lcl_compute_alpha(x_opti, 'all', env140);
% alpha_retropropagation = lcl_compute_alpha(x_opti, 'retropropagation');

plot(env.w/(2*pi), alpha_linear, 'DisplayName', 'Modèle linéaire');
% plot(env.w/(2*pi), alpha_first, 'DisplayName', 'Modèle forts niveaux première plaque');
plot(env.w/(2*pi), alpha_all, 'DisplayName', 'Modèle forts niveaux toutes plaques 1/3 d''octave');
plot(env.w/(2*pi), alpha_all134, 'DisplayName', 'Modèle forts niveaux toutes plaques 134 dB');
plot(env.w/(2*pi), alpha_all140, 'DisplayName', 'Modèle forts niveaux toutes plaques 140 dB');

perso_plot_targetted_frequencies(Frequences, 1);
perso_configure_alpha_figure(2000);

saveas(gcf, [folder_full_name, '\Figures\Prédiction des performances de la cartouche Poly.fig']);

%% =========================================================================
%%
%% Validation des contributions individuelles
%%
%% =========================================================================

lcl_compute_alpha = @(xopti, i, method) Contributions.contribution_MPPSBH_element_i(x_opti, i).absorption_coefficient(env, struct('HL_method', method));

% Contributions des élements MPPSBHs
for i = 1:NS
    figure()
    hold on
    % Tube_MPPSBH_element_contrib = ImpedanceTube2D(ImpedanceTube2D.create_config({Contributions.contribution_MPPSBH_element_i(x_opti, i)}));
    % Tube_MPPSBH_element_contrib = Tube_MPPSBH_element_contrib.launch_tube_measurement(env);
    % Tube_MPPSBH_element_contrib.plot_alpha(env, ['Contribution MPPSBH' num2str(i)]);
    alpha_linear = lcl_compute_alpha(x_opti, i, 'linear');
    % alpha_first = lcl_compute_alpha(x_opti, i, 'first');
    alpha_all = lcl_compute_alpha(x_opti, i, 'all');
    alpha_retropropagation = lcl_compute_alpha(x_opti, i, 'retropropagation');

    plot(env.w/(2*pi), alpha_linear, 'DisplayName', 'Modèle linéaire');
    % plot(env.w/(2*pi), alpha_first, 'DisplayName', 'Modèle forts niveaux première plaque');
    plot(env.w/(2*pi), alpha_all, 'DisplayName', 'Modèle forts niveaux toutes plaques');
    plot(env.w/(2*pi), alpha_retropropagation, 'DisplayName', 'Modèle forts niveaux retropropagatif');

    perso_configure_alpha_figure(2000);
    saveas(gcf, [folder_name, '\Figures\Validation de la contribution de MPPSBH' num2str(i) '.fig']);

    % figure()
    % mphgeom(Tube_MPPSBH_element_contrib.Configuration.ComsolModel);
    % saveas(gcf, [folder_full_name, '\Figures\Géométrie de l''élement MPPSBH' num2str(i) '.fig']);
    % mphsave(Tube_MPPSBH_element_contrib.Configuration.ComsolModel, [folder_full_name, '\validation_2D_MPPSBH_', num2str(i), '.mph']);
end

% Contribution de la cavité jaune dans la cartouche ETS
% Tube_ETS_yc_contrib = ImpedanceTube2D(ImpedanceTube2D.create_config({Contributions.contribution_ETS_yellow_cavity(x_opti)}));
% Tube_ETS_yc_contrib = Tube_ETS_yc_contrib.launch_tube_measurement(env);
figure();
% Tube_ETS_yc_contrib.plot_alpha(env, 'Contribution ETS cavité jaune');
Contributions.contribution_ETS_yellow_cavity(x_opti).plot_alpha(env, 'modèle linéaire');
Contributions.contribution_ETS_HL_yellow_cavity(x_opti).plot_alpha(env, 'modèle HL');
perso_configure_alpha_figure(2000);
saveas(gcf, [folder_full_name, '\Figures\Validation de la contribution de la cavité jaune de la cartouche ETS.fig']);
% mphsave(Tube_ETS_yc_contrib.Configuration.ComsolModel, [folder_full_name, '\validation_2D_ETS_yellow_cavity.mph']);

% Contribution de la solution Poly
% Tube_Poly_element_contrib = ImpedanceTube2D(ImpedanceTube2D.create_config({Contributions.contribution_Poly_numerical_element(x_opti)}));
% Tube_Poly_element_contrib = Tube_Poly_element_contrib.launch_tube_measurement(env);
figure();
imported_Poly_element.plot_alpha(env,'élement importé seul');
% Tube_Poly_element_contrib.plot_alpha(env, 'Contribution Poly élement numérique');
Contributions.contribution_Poly_element(x_opti).plot_alpha(env, 'Contribution Poly élement numérique - modèle linéaire');
Contributions.contribution_Poly_HL_element(x_opti).plot_alpha(env, 'modèle HL');

perso_configure_alpha_figure(2000);
saveas(gcf, [folder_full_name, '\Figures\Validation de la contribution de la solution de Poly.fig']);
% mphsave(Tube_Poly_element_contrib.Configuration.ComsolModel, [folder_full_name, '\validation_2D_Poly_numerical_element.mph']);

% Contribution de la cavité jaune dans la cartouche ETS
% Tube_Poly_yc_contrib = ImpedanceTube2D(ImpedanceTube2D.create_config({Contributions.contribution_Poly_yellow_cavity(x_opti)}));
% Tube_Poly_yc_contrib = Tube_Poly_yc_contrib.launch_tube_measurement(env);
figure();
% Tube_Poly_yc_contrib.plot_alpha(env, 'Contribution Poly cavité jaune');
Contributions.contribution_Poly_yellow_cavity(x_opti).plot_alpha(env, 'modèle linéaire');
Contributions.contribution_Poly_HL_yellow_cavity(x_opti).plot_alpha(env, 'modèle HL');

perso_configure_alpha_figure(2000);
saveas(gcf, [folder_full_name, '\Figures\Validation de la contribution de la cavité jaune de la cartouche Poly.fig']);
% mphsave(Tube_Poly_yc_contrib.Configuration.ComsolModel, [folder_full_name, '\validation_2D_Poly_yellow_cavity.mph']);

%% =========================================================================
%%
%% Sauvegarde des rapports de configuration
%%
%% =========================================================================
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
