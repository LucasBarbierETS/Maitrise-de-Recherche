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

%% Niveau Sonore, Fréquences cibles, Gabarits

% % Objectif larges bande

f_min_lb = 200;
f_max_lb = 1500;
g_obj_lb = @(env) (env.w / (2*pi) > f_min_lb & env.w / (2*pi) < f_max_lb);

% Objectifs tonaux
% On définit une largeur de bande associée à la variation du régime moteur de 3000 à 3500 RPM
% On définit les bandes de variations des harmoniques tant que celles-ci ne se recoupent pas

% Première harmonique (Fondamentale) : 233 Hz
f_min_h1 = 200;
f_max_h1 = 250;
g_obj_h1 = @(env) (env.w / (2*pi) > f_min_h1 & env.w / (2*pi) < f_max_h1);

% Deuxième harmonique : 467 Hz
f_min_h2 = 380;
f_max_h2 = 480;
g_obj_h2 = @(env) (env.w / (2*pi) > f_min_h2 & env.w / (2*pi) < f_max_h2);

% Troisième harmonique : 700 Hz
f_min_h3 = 550;
f_max_h3 = 700;
g_obj_h3 = @(env) (env.w / (2*pi) > f_min_h3 & env.w / (2*pi) < f_max_h3);

% Quatrième harmonique : 933 Hz
f_min_h4 = 750;
f_max_h4 = 950;
g_obj_h4 = @(env) (env.w / (2*pi) > f_min_h4 & env.w / (2*pi) < f_max_h4);

g_obj_harm =  @(env) g_obj_h1(env) + g_obj_h2(env) + g_obj_h3(env) + g_obj_h4(env) > 0;

% % Définition du niveau sonore à partir des similations Numériques d'ELissa 
%
% dB = 100; % faible niveau
% % dB_data = load('C:\Users\lucas.barbier\Documents\Maitrise dossier secondaire\MATLAB\Optimisation\Optimisation REAR\niveau sonore.txt');
% dB_data = load('C:\Users\lucas.barbier\Documents\Maitrise dossier secondaire\MATLAB\Optimisation\Optimisation REAR\niveau sonore Elissa.txt');
% % dB_data = load('C:\Users\lucas.barbier\Documents\Maitrise dossier secondaire\MATLAB\Optimisation\Optimisation REAR\niveau sonore Elissa plan du rotor.txt');
% dB_data_stator = load('C:\Users\lucas.barbier\Documents\Maitrise dossier secondaire\MATLAB\Optimisation\Optimisation REAR\stator_spectrum_data.txt');
% dB_data_rotor = load('C:\Users\lucas.barbier\Documents\Maitrise dossier secondaire\MATLAB\Optimisation\Optimisation REAR\rotor_spectrum_data.txt');
% figure();
% plot(dB_data_stator(:, 3)', dB_data_stator(:, 5)');
% dB_stator = interp1(dB_data_stator(:, 3)', dB_data_stator(:, 5)', env.w/(2*pi));
% dB_rotor = interp1(dB_data_rotor(:, 3)', dB_data_rotor(:, 5)', env.w/(2*pi));
% figure();
% hold on
% plot(env.w/(2*pi), dB_stator, 'DisplayName', 'plan du stator');
% plot(env.w/(2*pi), dB_rotor, 'DisplayName', 'plan du rotor');
% 
%
% p_ref = 20e-6;
% dB_spectrum_stator = interp1(dB_data_stator(:, 3)', dB_data_stator(:, 5)', env.w/(2*pi));
% plot(env.w/(2*pi), dB_spectrum_stator);
% p = p_ref*10.^(dB_spectrum_stator/20);
% plot(env.w/(2*pi), p);
% p_rms_stator = sqrt(mean(p.^2, 'omitmissing'));
% dB_rms_stator = 20*log10(p_rms_stator/p_ref);
% % % Calcul des niveaux RMS
% df = f(2:end) - f(1:end-1);
% p_rms = sqrt(sum(p(1:end-1).*df));
% dB_rms = 20*log10(p_rms/20e-6);
% dB_max = max(dB_spectrum_stator);
% 
% dB_spectrum_stator = interp1(dB_data_stator(:, 3)', dB_data_stator(:, 5)', env.w/(2*pi));
% plot(env.w/(2*pi), dB_spectrum_stator);
% p = 20e-6*10.^(dB_spectrum_stator/20);
% figure()
% plot(env.w/(2*pi), p);
% 
% figure();
% plot(f, dB_spectrum);
% yline(dB_rms, 'Label', 'dB RMS');
% yline(dB_max, 'Label', 'dB max');
%
% On construit un niveau par bande correspondant au niveau de l'harmonique contenue dans chaque bande
% max1 = max(dB_stator(g_obj_h1(env)));
% max2 = max(dB_stator(g_obj_h2(env)));
% max_rest = max(dB_stator(env.w/(2*pi) >= f_max_h2));
% max3 = max(dB_stator(g_obj_h3(env)));
% max4 = max(dB_stator(g_obj_h4(env)));
% dB = max1 * double(env.w/(2*pi) < f_max_h1) ...
%    + max2 * double((env.w/(2*pi) < f_max_h2) & (env.w/(2*pi) >= f_max_h1)) ...
%    + max_rest * double(env.w/(2*pi) >= f_max_h2);
   % + max3 * double((env.w/(2*pi) < f_max_h3) & (env.w/(2*pi) >= f_max_h2)) ...
   % + max4 * double(env.w/(2*pi) >= f_max_h3);
% plot(env.w/(2*pi), dB, 'DisplayName', 'Niveau considéré pour l''optimisation');
% xlim([0 2000]);
% title('Niveau de pression pariétale');
% legend();
% % On rajoute des barres pour représenter les bandes d'optimisation
% patch([f_min_h1, f_min_h1, f_max_h1, f_max_h1], [0, 140, 140, 0], 'red', ...
%       'FaceAlpha', 0.2, 'EdgeColor','none', 'DisplayName', 'Bande d''optimisation 1');
% patch([f_min_h2, f_min_h2, f_max_h2, f_max_h2], [0, 140, 140, 0], 'red', ...
%       'FaceAlpha', 0.2, 'EdgeColor','none', 'DisplayName', 'Bande d''optimisation 2');
% patch([f_min_h3, f_min_h3, f_max_h3, f_max_h3], [0, 140, 140, 0], 'red', ...
%       'FaceAlpha', 0.2, 'EdgeColor','none', 'DisplayName', 'Bande d''optimisation 3');
% patch([f_min_h4, f_min_h4, f_max_h4, f_max_h4], [0, 140, 140, 0], 'red', ...
%       'FaceAlpha', 0.2, 'EdgeColor','none', 'DisplayName', 'Bande d''optimisation 4');
% patch([f_min_lb, f_min_lb, f_max_obj3, f_max_obj3], [0, 140, 140, 0], 'green', ...
%       'FaceAlpha', 0.2, 'EdgeColor','none', 'DisplayName', 'Bande d''optimisation élargie');

dB = 121;

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
diameters_inch = [1/32, 1/30, 3/64, 1/16, 5/64, 3/32, 7/64, 1/8, 9/64, 5/32, 11/64, 3/16];
diameters_mm = diameters_inch * 25.4;
radius_mm = diameters_mm/2;

% Solution ETS
ETS_width = 30e-3;
ETS_depth = 30e-3;
ETS_cavities_width = 28e-3; 
ETS_cavities_depth = 28e-3; 
ETS_input_surface = ETS_width * ETS_depth;
plates_thickness = 2e-3;
rigid_backing_thickness = 1e-3;

% Solutions Poly
Poly_width = 30e-3;
Poly_depth = 30e-3;
Poly_cavities_width = 28e-3; % bords externes : 30 mm
Poly_cavities_depth = 28e-3; % bords externes : 30 mm
Poly_cavities_input_section = Poly_cavities_width * Poly_cavities_depth; 
Poly_input_surface = Poly_width * Poly_depth;

% Solutions HR
yc_width = 12e-3;
yc_depth = 30e-3;
yellow_cavities_thickness_ETS = total_thickness_ETS - top_plate_thickness - air_gap_thickness - rigid_backing_thickness;
yellow_cavities_thickness_Poly = total_thickness_Poly - top_plate_thickness - air_gap_thickness - rigid_backing_thickness;
yellow_cavities_width = 10e-3; % bords externes : 12 mm
yellow_cavities_depth = 28e-3; % bords externes : 30 mm
yellow_cavities_input_section = yellow_cavities_width * yellow_cavities_depth;
yc_input_surface = yc_width * yc_depth;

%% Structure des variables optimisées

NTP = 3; % (rayon, nombre de perf par ligne (width), nombre de perfs par colonne (depth))
NS = 8; % Nombre de MPPSBH optimisés
NV = 3; % Nombre de variables pour chaque solution (rayon des perforations, nombre de perfs en largeur, espacement des perfs en largeur)
N = 5; % Nombre de plaques optimisées indépendantes pour chaque solution

% NP = 500; % Nombre de points de départ
% NP = 100;
% NP = 50;
NP = 10;

ETS_cavities_total_thickness = total_thickness_ETS - top_plate_thickness - air_gap_thickness - N * plates_thickness;
ETS_cavities_thickness = round((total_thickness_ETS - top_plate_thickness - air_gap_thickness - N * plates_thickness) / (N+1), 4);

% Récupération des parties du vecteur d'optimisation
x_TP_ETS = @(x) x(:, 1 : NTP); % Plaque couvrante ETS
x_TP_Poly = @(x) x(:, NTP+1 : 2*NTP); % Plaque couvrante Poly
x_TP_ETS_yc = @(x) x(:, 2*NTP+1 : 3*NTP); % Plaque couvrante ETS cavités jaunes
x_TP_Poly_yc = @(x) x(:, 3*NTP+1 : 4*NTP); % Plaque couvrante Poly cavités jaunes
x_ETS = @(x) permute(reshape(x(:, 4*NTP+1 : 4*NTP + N*NV*NS), [], NS, N, NV), [2, 3, 4, 1]); % Solutions ETS
x_SPLX = @(x) x(:, 4*NTP + N*NV*NS + 1 : end); % Epaisseur des cavités ETS

% x_TP_ETS = @(x) x(1 : NTP);
% x_TP_Poly = @(x) x(NTP+1 : 2*NTP);
% x_ETS = @(x) reshape(x(2*NTP+1 : 2*NTP + N*NV*NS), NS, N, NV);
% x_SPLX = @(x) x(2*NTP + N*NV*NS + 1 : end);

%% Valeurs minimales en fonction du type de variable

% Plaque couvrante
tp_phi_min = 0.01;
tp_r_min = 1;
tp_whn_min = 2;
tp_dhn_min = 4;
tp_whn_yc_min = 1;
tp_dhn_yc_min = 4;


% Solution ETS
dw_min = 3 * radius_mm(1)*1e-3;
pw_min = 1;
r_min = 1;

theta_min = 1;

lb_TP = repmat([tp_r_min, tp_whn_min, tp_dhn_min], 1, 2); % Optimisation de 4 plaques
lb_TP_yc = repmat([tp_r_min, tp_whn_yc_min, tp_dhn_yc_min], 1, 2); % Optimisation de 4 plaques
lb = horzcat(lb_TP, lb_TP_yc, repmat(r_min, 1, N * NS), repmat(dw_min, 1, N * NS), ones(1, N * NS), repmat(theta_min, 1, N));

%% Valeurs maximales en fonction du type de variable

% Plaque couvrante
tp_phi_max = 0.3;
tp_r_max = 12;
tp_whn_max = 20;
tp_dhn_max = 40;
tp_whn_yc_max = 10;
tp_dhn_yc_max = 40;

% Solution ETS
dw_max = 9 * radius_mm(1)*1e-3;
pw_max = 8;
r_max = 5;

theta_max = 5;

ub_TP = repmat([tp_r_max, tp_whn_max, tp_dhn_max], 1, 2); 
ub_TP_yc = repmat([tp_r_max, tp_whn_yc_max, tp_dhn_yc_max], 1, 2); 
ub = horzcat(ub_TP, ub_TP_yc, repmat(r_max, 1, N * NS), repmat(dw_max, 1, N * NS), repmat(pw_max, 1, N * NS), repmat(theta_max, 1, N));

%% Valeurs initiales en fonction du types de variable

% Plaque supérieure 
tp_r_init = randi([tp_r_min, tp_r_max], NP, 2);
tp_whn_init = randi([tp_whn_min, tp_whn_max], NP, 2);
tp_dhn_init = randi([tp_dhn_min, tp_dhn_max], NP, 2);
tp_whn_yc_init = randi([tp_whn_yc_min, tp_whn_yc_max], NP, 2);
tp_dhn_yc_init = randi([tp_dhn_yc_min, tp_dhn_yc_max], NP, 2);

% Rayon des perforations
r_init = randi([r_min, r_max], NP, N * NS);

% Distance inter-perforation en largeur
dw_init = dw_min + (dw_max - dw_min) * rand(NP, N * NS);
% dw_init_sorted = sort(dw_init, 2, "descend");

% Nombre de perforation en largeur
pw_init = randi([pw_min, pw_max], NP, N * NS);
% pw_init_sorted = sort(pw_init, 2, "descend"); 

% Paramètres de répartition de l'épaisseur
theta_init = theta_min + (theta_max - theta_min) * rand(NP, N);

x0_TP_ETS = horzcat(tp_r_init(:, 1), tp_whn_init(:, 1), tp_dhn_init(:, 1));
x0_TP_Poly = horzcat(tp_r_init(:, 2), tp_whn_init(:, 2), tp_dhn_init(:, 2));
x0_TP_yc_ETS = horzcat(tp_r_init(:, 1), tp_whn_yc_init(:, 1), tp_dhn_yc_init(:, 1));
x0_TP_yc_Poly = horzcat(tp_r_init(:, 2), tp_whn_yc_init(:, 2), tp_dhn_yc_init(:, 2));
x0 = horzcat(x0_TP_ETS, x0_TP_Poly, x0_TP_yc_ETS, x0_TP_yc_Poly, r_init, dw_init, pw_init, theta_init);
% x0 = horzcat(x0_TP_ETS, x0_TP_Poly, dw_init_sorted, pw_init_sorted);

% % Debog : Largeur des fentes crées
% sw = 2 * radius_mm(r_init)*1e-3 + dw_init .* (pw_init - 1);
% histogram(sw, 20);

% % Debog : Porosité (apparente) des plaques crées
% phi = (pi * (radius_mm(r_init)*1e-3).^2 * 8 .* pw_init) / (ETS_cavities_width * ETS_cavities_depth);
% histogram(phi, 20);

%% Contrainte sur les variables entières

intcon = find(horzcat(ones(1, 4*NTP), ones(1, N*NS), zeros(1, N*NS), ones(1, N*NS), zeros(1, N)));

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
        frequency_support, surface_impedance, Poly_cavities_width, Poly_cavities_depth)).surface_impedance(env);

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
% imported_Poly_element.plot_alpha(env, 'Element importé');
% Tube_Poly = ImpedanceTube2D(ImpedanceTube2D.create_config({numerical_Poly_element}));
% Tube_Poly = Tube_Poly.lauch_tube_measurement(env);
% Tube_Poly.plot_alpha(env, 'Element simulé');

%% Création dynamique des objets de classe et des assemblages

Objets = struct();

% Construction du ième MPPSBH à partir d'une découpe du vecteur d'optimisation
Objets.MPPSBH_i = @(x_ETS, x_SPLX, i) classMPPSBH_Rectangular( ...
    classMPPSBH_Rectangular.create_explicit_slit_pattern_config( ...
        ETS_input_surface, N, ETS_cavities_depth, ETS_cavities_width, ...
        {radius_mm(x_ETS(i, :, 1))*1e-3}, ... {eval_r(x0(:, 1, i))}, ... % rayon des perforations
        {x_ETS(i, :, 2)}, ... % distance entre perforations (width)
        {ETS_cavities_depth/8}, ... % distance entre perforations (depth)
        {8}, ... {transpose(x0(:, 3, i))}, ... % nombre de perforations en profondeur
        {x_ETS(i, :, 3)}, ... % nombre de perforations en largeur
        {plates_thickness}, ... % épaisseur des plaques (supérieure + internes)
        {round(ETS_cavities_total_thickness/N+1, 4)})); % {perso_simplex_map(x_SPLX, ETS_cavities_total_thickness)}));  % épaisseur de cavité

% Debog (OK)
% figure()
% Objets.MPPSBH_i(x_ETS(x0(1, :)), x_SPLX(x0(1, :)), 1).plot_alpha(env, 'modèle linéaire');
% close();

Objets.MPPSBH_HL_i = @(x_ETS, x_SPLX, i) classMPPSBH_Rectangular_HL( ...
    classMPPSBH_Rectangular.create_explicit_slit_pattern_config( ...
        ETS_input_surface, N, ETS_cavities_depth, ETS_cavities_width, ...
        {radius_mm(x_ETS(i, :, 1))*1e-3}, ... {eval_r(x0(:, 1, i))}, ... % rayon des perforations
        {x_ETS(i, :, 2)}, ... % distance entre perforations (width)
        {ETS_cavities_depth/6}, ... % distance entre perforations (depth)
        {8}, ... {transpose(x0(:, 3, i))}, ... % nombre de perforations en profondeur
        {x_ETS(i, :, 3)}, ... % nombre de perforations en largeur
        {plates_thickness}, ... % épaisseur des plaques (supérieure + internes)
        {round(ETS_cavities_total_thickness/N+1, 4)})); % {perso_simplex_map(x_SPLX, ETS_cavities_total_thickness)}));  % épaisseur de cavité 

% % Debog (OK)
% figure()
% Objets.MPPSBH_HL_i(x_ETS(x0(1, :)), x_SPLX(x0(1, :)), 1).plot_alpha(handle_env(dB), 'HL, dB spec');
% Objets.MPPSBH_HL_i(x_ETS(x0(1, :)), x_SPLX(x0(1, :)), 1).plot_alpha(handle_env(dB), 'HL, dB rms');
% Objets.MPPSBH_HL_i(x_ETS(x0(1, :)), x_SPLX(x0(1, :)), 1).plot_alpha(handle_env(dB), 'HL, dB max');
% close();

Objets.MPPSBH_HL_fp_i = @(x_ETS, x_SPLX, i) classMPPSBH_Rectangular_HL_first_plate( ...
    classMPPSBH_Rectangular.create_explicit_slit_pattern_config( ...
        ETS_input_surface, N, ETS_cavities_depth, ETS_cavities_width, ...
        {radius_mm(x_ETS(i, :, 1))*1e-3}, ... {eval_r(x0(:, 1, i))}, ... % rayon des perforations
        {x_ETS(i, :, 2)}, ... % distance entre perforations (width)
        {ETS_cavities_depth/6}, ... % distance entre perforations (depth)
        {8}, ... {transpose(x0(:, 3, i))}, ... % nombre de perforations en profondeur
        {x_ETS(i, :, 3)}, ... % nombre de perforations en largeur
        {plates_thickness}, ... % épaisseur des plaques (supérieure + internes)
        {round(ETS_cavities_total_thickness/N+1, 4)})); % {perso_simplex_map(x_SPLX, ETS_cavities_total_thickness)}));  % épaisseur de cavité 

% Debog (OK)
% figure()
% Objets.MPPSBH_HL_fp_i(x_ETS(x0(1, :)), x_SPLX(x0(1, :)), 1).plot_alpha(handle_env(dB), 'HL fp, dB spec');
% Objets.MPPSBH_HL_fp_i(x_ETS(x0(1, :)), x_SPLX(x0(1, :)), 1).plot_alpha(handle_env(dB), 'HL fp, dB rms');
% Objets.MPPSBH_HL_fp_i(x_ETS(x0(1, :)), x_SPLX(x0(1, :)), 1).plot_alpha(handle_env(dB), 'HL fp, dB max');
% perso_configure_alpha_figure(2000);
% close();

% Construction d'une solution en rajoutant une cavité au dessus de la solution MPPSBH
Objets.MPPSBH_element_i = @(x, i) classelement( ...
    classelement.create_config({ ...
    classcavity(classcavity.create_config(ETS_cavities_thickness, ETS_cavities_width, ETS_cavities_depth)) ...
    Objets.MPPSBH_i(x_ETS(x), x_SPLX(x), i)}, 'closed', ETS_input_surface));

Objets.MPPSBH_HL_element_i = @(x, i) classelement( ...
    classelement.create_config({ ...
    classcavity(classcavity.create_config(ETS_cavities_thickness, ETS_cavities_width, ETS_cavities_depth)) ...
    Objets.MPPSBH_HL_i(x_ETS(x), x_SPLX(x), i)}, 'closed', ETS_input_surface));

Objets.MPPSBH_HL_fp_element_i = @(x, i) classelement( ...
    classelement.create_config({ ...
    classcavity(classcavity.create_config(ETS_cavities_thickness, ETS_cavities_width, ETS_cavities_depth)) ...
    Objets.MPPSBH_HL_fp_i(x_ETS(x), x_SPLX(x), i)}, 'closed', ETS_input_surface));

% % Debog : MPPSBH_element_i
% figure();
% Objets.MPPSBH_element_i(x_ETS(x0(1, :)), 1).plot_alpha(env, 'MPPSBH element 1');

% Construction d'un cell array contenant les objets de classe MPPSBH
Objets.cell_of_MPPSBH_elements = @(x) arrayfun(@(i) ...
    Objets.MPPSBH_element_i(x, i), 1:NS ,'UniformOutput', false);

Objets.cell_of_MPPSBH_HL_elements = @(x) arrayfun(@(i) ...
    Objets.MPPSBH_HL_element_i(x, i), 1:NS ,'UniformOutput', false);

Objets.cell_of_MPPSBH_HL_fp_elements = @(x) arrayfun(@(i) ...
    Objets.MPPSBH_HL_fp_element_i(x, i), 1:NS ,'UniformOutput', false);

% Plaque supérieure (optimisée)
top_plate_ETS = @(x_TP_ETS) classMPP_Circular(classMPP_Circular.create_explicit_rectangular_plate_config( ...
top_plate_thickness, radius_mm(x_TP_ETS(1))*1e-3, ETS_width, ETS_depth * 4, x_TP_ETS(2), x_TP_ETS(3)));

top_plate_ETS_contrib = @(x_TP_ETS) classMPP_Circular(classMPP_Circular.create_config( ...
    ETS_input_surface, top_plate_thickness, radius_mm(x_TP_ETS(1))*1e-3, top_plate_ETS(x_TP_ETS).Configuration.Porosity, ETS_cavities_width, ETS_cavities_depth));

top_plate_ETS_HL = @(x_TP_ETS) classMPP_Circular_HL(classMPP_Circular.create_explicit_rectangular_plate_config( ...
top_plate_thickness, radius_mm(x_TP_ETS(1))*1e-3, ETS_width, ETS_depth * 4, x_TP_ETS(2), x_TP_ETS(3)));

top_plate_ETS_HL_contrib = @(x_TP_ETS) classMPP_Circular_HL(classMPP_Circular.create_config( ...
    ETS_input_surface, top_plate_thickness, radius_mm(x_TP_ETS(1))*1e-3, top_plate_ETS_HL(x_TP_ETS).Configuration.Porosity, ETS_cavities_width, ETS_cavities_depth));

top_plate_Poly = @(x_TP_Poly) classMPP_Circular(classMPP_Circular.create_explicit_rectangular_plate_config( ...
top_plate_thickness, radius_mm(x_TP_Poly(1))*1e-3, Poly_width, Poly_depth * 4, x_TP_Poly(2), x_TP_Poly(3)));

top_plate_Poly_contrib = @(x_TP_Poly) classMPP_Circular(classMPP_Circular.create_config( ...
    Poly_input_surface, top_plate_thickness, radius_mm(x_TP_Poly(1))*1e-3, top_plate_Poly(x_TP_Poly).Configuration.Porosity, Poly_cavities_width, Poly_cavities_depth));

top_plate_Poly_HL = @(x_TP_Poly) classMPP_Circular_HL(classMPP_Circular.create_explicit_rectangular_plate_config( ...
top_plate_thickness, radius_mm(x_TP_Poly(1))*1e-3, Poly_width, Poly_depth * 4, x_TP_Poly(2), x_TP_Poly(3)));

top_plate_Poly_HL_contrib = @(x_TP_Poly) classMPP_Circular_HL(classMPP_Circular.create_config( ...
    Poly_input_surface, top_plate_thickness, radius_mm(x_TP_Poly(1))*1e-3, top_plate_Poly_HL(x_TP_Poly).Configuration.Porosity, Poly_cavities_width, Poly_cavities_depth));

top_plate_yc = @(x_TP_yc) classMPP_Circular(classMPP_Circular.create_explicit_rectangular_plate_config( ...
top_plate_thickness, radius_mm(x_TP_yc(1))*1e-3, yellow_cavities_width, yellow_cavities_depth * 4, x_TP_yc(2), x_TP_yc(3)));

top_plate_yc_contrib = @(x_TP_yc) classMPP_Circular(classMPP_Circular.create_config( ...
    yc_input_surface, top_plate_thickness, radius_mm(x_TP_yc(1))*1e-3, top_plate_yc(x_TP_yc).Configuration.Porosity, yellow_cavities_width, yellow_cavities_depth));

top_plate_yc_HL = @(x_TP_yc) classMPP_Circular_HL(classMPP_Circular.create_explicit_rectangular_plate_config( ...
top_plate_thickness, radius_mm(x_TP_yc(1))*1e-3, yellow_cavities_width, yellow_cavities_depth * 4, x_TP_yc(2), x_TP_yc(3)));

top_plate_yc_HL_contrib = @(x_TP_yc) classMPP_Circular_HL(classMPP_Circular.create_config( ...
    yc_input_surface, top_plate_thickness, radius_mm(x_TP_yc(1))*1e-3, top_plate_yc_HL(x_TP_yc).Configuration.Porosity, yellow_cavities_width, yellow_cavities_depth));

% Distance Plaque - Solutions
air_gap = classcavity(classcavity.create_config(air_gap_thickness, total_width, total_depth));

air_gap_ETS = classcavity(classcavity.create_config(air_gap_thickness, ETS_cavities_width, ETS_cavities_depth));

air_gap_Poly = classcavity(classcavity.create_config(air_gap_thickness, Poly_cavities_width, Poly_cavities_depth));

air_gap_yc = classcavity(classcavity.create_config(air_gap_thickness, yellow_cavities_width, yellow_cavities_depth));

% Cavité Jaune
yellow_cavity_ETS = classcavity(classcavity.create_config(yellow_cavities_thickness_ETS, yellow_cavities_width, yellow_cavities_depth));
yellow_cavity_Poly = classcavity(classcavity.create_config(yellow_cavities_thickness_Poly, yellow_cavities_width, yellow_cavities_depth));
% yellow_cavity = classQWL_Slit(classQWL_Slit.create_config(yellow_cavities_thickness, yellow_cavities_width, yellow_cavities_depth));
yellow_cavity_element_ETS = classelement(classelement.create_config({yellow_cavity_ETS}, 'closed', yc_input_surface));
yellow_cavity_element_Poly = classelement(classelement.create_config({yellow_cavity_Poly}, 'closed', yc_input_surface));
% % Debog :  Affichage des performance de la cavité jaune
% figure();
% perso_plot_surface_impedance(env.w/(2*pi), yellow_cavity_element.surface_impedance(env), env);

%% Création dynamique des contributions des solutions individuelles

Contributions = struct();

Contributions.contribution_MPPSBH_element_i = @(x, i) classelement(classelement.create_config( ...
    {top_plate_ETS(x_TP_ETS(x)), ...
     air_gap_ETS, ...
     classcavity(classcavity.create_config(ETS_cavities_thickness, ETS_cavities_width, ETS_cavities_depth)), ...
     Objets.MPPSBH_i(x_ETS(x), x_SPLX(x), i)}, 'closed', ETS_input_surface));

% % Debog (OK)
% figure()
% Contributions.contribution_MPPSBH_element_i(x0(1, :), 1).plot_alpha(env, 'Contribution MPPSBH élement 1');
% close();

Contributions.contribution_MPPSBH_element_HL_i = @(x, i) classelement(classelement.create_config( ...
    {top_plate_ETS_HL(x_TP_ETS(x)), ...
     air_gap_ETS, ...
     classcavity(classcavity.create_config(ETS_cavities_thickness, ETS_cavities_width, ETS_cavities_depth)), ...
     Objets.MPPSBH_HL_i(x_ETS(x), x_SPLX(x), i)}, 'closed', ETS_input_surface));

Contributions.contribution_MPPSBH_element_HL_fp_i = @(x, i) classelement(classelement.create_config( ...
    {top_plate_ETS_HL(x_TP_ETS(x)), ...
     air_gap_ETS, ...
     classcavity(classcavity.create_config(ETS_cavities_thickness, ETS_cavities_width, ETS_cavities_depth)), ...
     Objets.MPPSBH_HL_fp_i(x_ETS(x), x_SPLX(x), i)}, 'closed', ETS_input_surface));

Contributions.contribution_cell_of_MPPSBH_element = @(x) arrayfun(@(i) ...
    Contributions.contribution_MPPSBH_element_i(x, i), 1:NS ,'UniformOutput', false);

Contributions.contribution_cell_of_MPPSBH_HL_element = @(x) arrayfun(@(i) ...
    Contributions.contribution_MPPSBH_element_HL_i(x, i), 1:NS ,'UniformOutput', false);

Contributions.contribution_cell_of_MPPSBH_HL_fp_element = @(x) arrayfun(@(i) ...
    Contributions.contribution_MPPSBH_element_HL_fp_i(x, i), 1:NS ,'UniformOutput', false);

Contributions.contribution_Poly_element = @(x) classelement(classelement.create_config( ...
    {top_plate_Poly(x_TP_Poly(x)), ...
     air_gap_Poly, ...
     imported_Poly_subelement}, 'closed', Poly_input_surface));

Contributions.contribution_Poly_HL_element = @(x) classelement(classelement.create_config( ...
    {top_plate_Poly_HL(x_TP_Poly(x)), ...
     air_gap_Poly, ...
     imported_Poly_subelement}, 'closed', Poly_input_surface));

Contributions.contribution_Poly_numerical_element = @(x) classelement(classelement.create_config( ...
    {top_plate_Poly(x_TP_Poly(x)), ...
     air_gap_Poly, ...
     numerical_Poly_subelement}, 'closed', Poly_input_surface));

Contributions.contribution_Poly_HL_numerical_element = @(x) classelement(classelement.create_config( ...
    {top_plate_Poly_HL(x_TP_Poly(x)), ...
     air_gap_Poly, ...
     numerical_Poly_subelement}, 'closed', Poly_input_surface));

Contributions.cell_of_Poly_element_contribution = @(x) arrayfun(@(i) ...
    Contributions.contribution_Poly_element(x), 1:NS ,'UniformOutput', false);

Contributions.cell_of_Poly_HL_element_contribution = @(x) arrayfun(@(i) ...
    Contributions.contribution_Poly_HL_element(x), 1:NS ,'UniformOutput', false);

Contributions.contribution_ETS_yellow_cavity = @(x) classelement(classelement.create_config( ...
    {top_plate_yc(x_TP_ETS(x)), ...
     air_gap_yc, ...
     yellow_cavity_ETS}, 'closed', yc_input_surface));

Contributions.contribution_ETS_HL_yellow_cavity = @(x) classelement(classelement.create_config( ...
    {top_plate_yc_HL(x_TP_ETS(x)), ...
     air_gap_yc, ...
     yellow_cavity_ETS}, 'closed', yc_input_surface));

Contributions.cell_of_ETS_yellow_cavity_contributions = @(x) arrayfun(@(i) ...
    Contributions.contribution_ETS_yellow_cavity(x), 1:4 ,'UniformOutput', false);

Contributions.cell_of_ETS_HL_yellow_cavity_contributions = @(x) arrayfun(@(i) ...
    Contributions.contribution_ETS_yellow_cavity(x), 1:4 ,'UniformOutput', false);

Contributions.contribution_Poly_yellow_cavity = @(x) classelement(classelement.create_config( ...
    {top_plate_yc(x_TP_Poly(x)), ...
     air_gap_yc, ...
     yellow_cavity_Poly}, 'closed', yc_input_surface));

Contributions.contribution_Poly_HL_yellow_cavity = @(x) classelement(classelement.create_config( ...
    {top_plate_yc_HL(x_TP_Poly(x)), ...
     air_gap_yc, ...
     yellow_cavity_Poly}, 'closed', yc_input_surface));

Contributions.cell_of_Poly_yellow_cavity_contributions = @(x) arrayfun(@(i) ...
    Contributions.contribution_Poly_yellow_cavity(x), 1:4 ,'UniformOutput', false);

Contributions.cell_of_Poly_HL_yellow_cavity_contributions = @(x) arrayfun(@(i) ...
    Contributions.contribution_Poly_HL_yellow_cavity(x), 1:4 ,'UniformOutput', false);

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

Modules.module_ETS_HL = @(x) classelementassembly(classelementassembly.create_config( ...
        [Objets.cell_of_MPPSBH_HL_elements(x), ... % Solutions ETS
            repmat({yellow_cavity_element_ETS}, 1, 4)])); % Solutions HR 

Modules.module_ETS_HL_fp = @(x) classelementassembly(classelementassembly.create_config( ...
        [Objets.cell_of_MPPSBH_HL_fp_elements(x), ... % Solutions ETS
            repmat({yellow_cavity_element_ETS}, 1, 4)])); % Solutions HR 

% Modules.module_ETS_sans_HR = @(x) classelementassembly(classelementassembly.create_config(Objets.cell_of_MPPSBH_elements(x))); 

Modules.module_Poly = @(x) classelementassembly(classelementassembly.create_config( ...
                [repmat({imported_Poly_element}, 1, NS), ... % Solutions Poly
                    repmat({yellow_cavity_element_Poly}, 1, 4)])); % Solutions HR 

% Modules.module_Poly_sans_HR = @(x) classelementassembly(classelementassembly.create_config(repmat({imported_Poly_element}, 1, NS)));

%% Création dynamique des cartouches

Cartouches = struct();

Cartouches.cartouche_ETS = @(x) classelement(classelement.create_config( ...
    {top_plate(x_TP_ETS(x)), air_gap, Modules.module_ETS(x)}, 'closed', total_input_surface));

Cartouches.cartouche_ETS_HL = @(x) classelement(classelement.create_config( ...
    {top_plate_HL(x_TP_ETS(x)), air_gap, Modules.module_ETS_HL(x)}, 'closed', total_input_surface));

Cartouches.cartouche_ETS_HL_fp = @(x) classelement(classelement.create_config( ...
    {top_plate_HL(x_TP_ETS(x)), air_gap, Modules.module_ETS_HL_fp(x)}, 'closed', total_input_surface));

% Cartouches.cartouche_ETS_sans_HR = @(x) classelement(classelement.create_config( ...
    % {top_plate(x_TP_ETS(x)), air_gap, Modules.module_ETS_sans_HR(x)}, 'closed', total_input_surface));

Cartouches.cartouche_ETS_contributions = @(x) classelementassembly(classelementassembly.create_config( ...
    [Contributions.contribution_cell_of_MPPSBH_element(x), Contributions.cell_of_ETS_yellow_cavity_contributions(x)]));

Cartouches.cartouche_ETS_HL_contributions = @(x) classelementassembly(classelementassembly.create_config( ...
    [Contributions.contribution_cell_of_MPPSBH_HL_element(x), Contributions.cell_of_ETS_HL_yellow_cavity_contributions(x)]));

Cartouches.cartouche_ETS_HL_fp_contributions = @(x) classelement(classelement.create_config( ...
    {classelementassembly(classelementassembly.create_config( ...
    [Contributions.contribution_cell_of_MPPSBH_HL_fp_element(x), Contributions.cell_of_ETS_HL_yellow_cavity_contributions(x)]))}, 'closed', total_input_surface));

% Cartouches.cartouche_ETS_sans_HR_contributions = @(x) classelementassembly(classelementassembly.create_config( ...
%     Contributions.contribution_cell_of_MPPSBH_element(x)));

Cartouches.cartouche_Poly = @(x) classelement(classelement.create_config( ...
    {top_plate(x_TP_Poly(x)), air_gap, Modules.module_Poly(x)}, 'closed', total_input_surface));

Cartouches.cartouche_Poly_HL = @(x) classelement(classelement.create_config( ...
    {top_plate_HL(x_TP_Poly(x)), air_gap, Modules.module_Poly(x)}, 'closed', total_input_surface));

% Cartouches.cartouche_Poly_sans_HR = @(x) classelement(classelement.create_config( ...
%     {top_plate(x_TP_Poly(x)), air_gap, Modules.module_Poly_sans_HR(x)}, 'closed', total_input_surface));

Cartouches.cartouche_Poly_contributions = @(x) classelementassembly(classelementassembly.create_config( ...
    [Contributions.cell_of_Poly_element_contribution(x), Contributions.cell_of_Poly_yellow_cavity_contributions(x)]));

Cartouches.cartouche_Poly_HL_contributions = @(x) classelement(classelement.create_config( ...
    {classelementassembly(classelementassembly.create_config( ...
    [Contributions.cell_of_Poly_HL_element_contribution(x), Contributions.cell_of_Poly_HL_yellow_cavity_contributions(x)]))}, 'closed', total_input_surface));

% Cartouches.cartouche_Poly_sans_HR_contributions = @(x) classelementassembly(classelementassembly.create_config( ...
%     Contributions.cell_of_Poly_element_contribution(x)));

Cartouches.cartouche_globale = @(x) classelementassembly(classelementassembly.create_config({Cartouches.cartouche_ETS(x), Cartouches.cartouche_Poly(x)}));

Cartouches.cartouche_globale_HL = @(x) classelementassembly(classelementassembly.create_config({Cartouches.cartouche_ETS_HL(x), Cartouches.cartouche_Poly_HL(x)}));

Cartouches.cartouche_globale_HL_fp = @(x) classelementassembly(classelementassembly.create_config({Cartouches.cartouche_ETS_HL_fp(x), Cartouches.cartouche_Poly_HL(x)}));

Cartouches.cartouche_globale_contributions = @(x) classelementassembly(classelementassembly.create_config({Cartouches.cartouche_ETS_contributions(x), Cartouches.cartouche_Poly_contributions(x)}));

Cartouches.cartouche_globale_HL_contributions = @(x) classelementassembly(classelementassembly.create_config({Cartouches.cartouche_ETS_HL_contributions(x), Cartouches.cartouche_Poly_HL_contributions(x)}));

Cartouches.cartouche_globale_HL_fp_contributions = @(x) classelementassembly(classelementassembly.create_config({Cartouches.cartouche_ETS_HL_fp_contributions(x), Cartouches.cartouche_Poly_HL_contributions(x)}));


%% Fonction de définitions de la matrice de contraintes non linéaires  

% Définition du handle avec paramètres capturés
handle_nonlconf = @(x) perso_nonlconf(x_ETS(x), N, NS, top_plate_ETS(x_TP_ETS(x)), top_plate_Poly(x_TP_Poly(x)), top_plate_yc(x_TP_ETS_yc(x)), top_plate_yc(x_TP_Poly_yc(x)), ...
    ETS_cavities_width, ETS_cavities_depth, tp_phi_min, tp_phi_max, radius_mm);

% % Debog : Test des contraintes non-linéaires sur les configurations initiales
% [c, ceq] = handle_nonlconf(x0);
% ratio = sum(~any(c > 0, 2))/NP * 100;
% sprintf('%f pourcents de configurations respectant les contraintes non-linéaires', ratio)

%% Affichage des porosités simulées

% figure()
% p = [];
% for i = 1:size(x0, 1)
%     p(end+1) = top_plate((x0(i, :))).Configuration.Porosity;
% end
% histogram(p, 20);
% title('Porosités simulées');

%% Fonctions coût

% Définition de la cartouche sur laquelle l'optimisation à lieu
% handle_alpha = @(x, env, g_obj) subsref(Cartouches.cartouche_Poly(x).alpha(env), substruct('()', {g_obj(env)}));
% handle_alpha = @(x, env, g_obj) subsref(Cartouches.cartouche_Poly_HL(x).alpha(env), substruct('()', {g_obj(env)}));
% handle_alpha = @(x, env, g_obj) subsref(Cartouches.cartouche_globale(x).alpha(env), substruct('()', {g_obj(env)}));
% handle_alpha = @(x, env, g_obj) subsref(Cartouches.cartouche_globale_HL(x).alpha(env), substruct('()', {g_obj(env)}));
% handle_alpha = @(x, env, g_obj) subsref(Cartouches.cartouche_globale_HL_fp(x).alpha(env), substruct('()', {g_obj(env)}));
handle_alpha = @(x, env, g_obj) subsref(Cartouches.cartouche_globale_HL_fp_contributions(x).alpha(env), substruct('()', {g_obj(env)}));

handle_cost_function = @(x, env, g_obj) sum(1 - handle_alpha(x, env, g_obj)).^2;
handle_objective = @(x, env, g_obj_cell) arrayfun(@(i) handle_cost_function(x, env, g_obj_cell{i}), 1:length(g_obj_cell) ,'UniformOutput', false);

% objective = @(x) cell2mat(handle_objective(x, handle_env(dB), {g_obj_h1, g_obj_h3, g_obj_4, g_obj_lb})); % Objectif Cartouche ETS

% objective = @(x) cell2mat(handle_objective(x, handle_env(dB), {g_obj_h1})); % Objectif Cartouche Poly
% objective = @(x) cell2mat(handle_objective(x, handle_env(dB), {g_obj_h2})); % Objectif Cartouche Poly
% objective = @(x) cell2mat(handle_objective(x, handle_env(dB), {g_obj_h3, g_obj_h4})); % Objectif Cartouche Poly
% objective = @(x) cell2mat(handle_objective(x, handle_env(dB), {g_obj_h2, g_obj_lb})); % Objectif Cartouche Poly

objective = @(x) cell2mat(handle_objective(x, handle_env(dB), {g_obj_h1, g_obj_h2, g_obj_h3, g_obj_h4, g_obj_lb})); % Objectif Cartouche globale

% objective(x0(1, :))

%% Fonction d'affichage des résultats temporaires

% temp_plot_MPPSBH_results = @(x, i) plot_MPPSBH_results(x, i, x_ETS, Objets, Contributions, env);

% temp_plot_module_ETS = @(x) plot_module_ETS(x, x_ETS, Objets, Modules, env);

temp_plot_cartouche_ETS = @(x) plot_cartouche_ETS(x, Contributions, Cartouches, handle_env(dB));  

temp_plot_cartouches = @(x) plot_cartouches(x, Cartouches, handle_env(dB));

% temp_plot_contributions = @(x) plot_contributions(x, x_ETS, MPPSBH_i, contribution_MPPSBH_element_i, ...
%     contribution_ETS_yellow_cavities, contribution_Poly_yellow_cavity, ...
%     contribution_Poly_element, module_ETS, module_Poly, ...
%     cartouche_ETS, cartouche_Poly, cartouche_globale, handle_env(dB), NS);

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

%% Conditionnement du vecteur d'optimisation

% xopti_to_cell_array_of_alpha = @(x, env) arrayfun(@(i) Cartouches.cartouche_Poly(x(i, :)).alpha(env), 1:size(x, 1), 'UniformOutput', false);
% xopti_to_cell_array_of_alpha = @(x, env) arrayfun(@(i) Cartouches.cartouche_Poly_HL(x(i, :)).alpha(env), 1:size(x, 1), 'UniformOutput', false);
% xopti_to_cell_array_of_alpha = @(x, env) arrayfun(@(i) Cartouches.cartouche_globale(x(i, :)).alpha(env), 1:size(x, 1), 'UniformOutput', false);
% xopti_to_cell_array_of_alpha = @(x, env) arrayfun(@(i) Cartouches.cartouche_globale_HL(x(i, :)).alpha(env), 1:size(x, 1), 'UniformOutput', false);
% xopti_to_cell_array_of_alpha = @(x, env) arrayfun(@(i) Cartouches.cartouche_globale_HL_fp(x(i, :)).alpha(env), 1:size(x, 1), 'UniformOutput', false);
% xopti_to_cell_array_of_alpha = @(x, env) arrayfun(@(i) Cartouches.cartouche_globale_HL_fp_contributions(x(i, :)).alpha(env), 1:size(x, 1), 'UniformOutput', false);

cell_of_MPPSBH_assembly_alpha_to_mean_alpha = @(alpha_cell_array, gabarit) arrayfun(@(i) mean(alpha_cell_array{i}(gabarit)), 1:size(alpha_cell_array, 2), 'UniformOutput', false);

% On récupère les vecteurs d'absorption des meilleures configurations
[sorted_scores_opti, sorted_index_opti] = sort(fval);
sorted_xopti = xopti(sorted_index_opti(:, 1), :);
filtered_alpha = xopti_to_cell_array_of_alpha(sorted_xopti, handle_env(dB));

% Tracé interractif des meilleurs résultats de l'optimisation multi objectif
perso_interactive_multi_plot(handle_env(dB).w/(2*pi), filtered_alpha, 2000);

% % On rajoute des barres pour représenter les bandes d'optimisation
patch([f_min_h1, f_min_h1, f_max_h1, f_max_h1], [0, 1, 1, 0], 'red', ...
      'FaceAlpha', 0.2, 'EdgeColor','none', 'DisplayName', 'Bande d''optimisation 1');
patch([f_min_h2, f_min_h2, f_max_h2, f_max_h2], [0, 1, 1, 0], 'red', ...
      'FaceAlpha', 0.2, 'EdgeColor','none', 'DisplayName', 'Bande d''optimisation 2');
patch([f_min_h3, f_min_h3, f_max_h3, f_max_h3], [0, 1, 1, 0], 'red', ...
      'FaceAlpha', 0.2, 'EdgeColor','none', 'DisplayName', 'Bande d''optimisation 3');
patch([f_min_h4, f_min_h4, f_max_h4, f_max_h4], [0, 1, 1, 0], 'red', ...
      'FaceAlpha', 0.2, 'EdgeColor','none', 'DisplayName', 'Bande d''optimisation 4');
patch([f_min_lb, f_min_lb, f_max_lb, f_max_lb], [0, 1, 1, 0], 'green', ...
      'FaceAlpha', 0.2, 'EdgeColor','none', 'DisplayName', 'Bande d''optimisation élargie');

%% Résultats et sélection de la solution 

chosed_index = input('Veuillez entrer le numéro de la configuration choisie : ');
x_opti = sorted_xopti(chosed_index, :);

%% Sauvergarde

% env_saved = input('Sauvegarder l''environnement d''optimisation : ');

if env_saved == 1
    currentTime = char(datetime('now', 'Format', 'yyyy_MM_dd_HH_mm_ss'));
    mkdir([folderName, '\optimisation_ETS_Poly_', currentTime]);
    mkdir([folderName, '\optimisation_ETS_Poly_', currentTime, '\Figures']);
    save([folderName, '\optimisation_ETS_Poly_', currentTime '\environnement matlab.mat']);
else
    return
end

%% Affichage des performances et des contributions

% temp_plot_MPPSBH_results(x_opti, 1);
% temp_plot_module_ETS(x_opti);
temp_plot_cartouche_ETS(x_opti);
temp_plot_cartouches(x_opti);

x_TP_ETS(x_opti);
x_TP_Poly(x_opti);
top_plate(x_TP_ETS(x_opti)).Configuration % Plaque ETS
top_plate(x_TP_Poly(x_opti)).Configuration % Plaque Poly

figure()
hold on
Cartouches.cartouche_globale(x_opti).plot_alpha(handle_env(dB), 'Cartouche globale');
Cartouches.cartouche_globale_HL(x_opti).plot_alpha(handle_env(dB), 'Cartouche globale HL');
Cartouches.cartouche_globale_HL_fp(x_opti).plot_alpha(handle_env(dB), 'Cartouche globale_HL fp');
perso_configure_alpha_figure(2000);
saveas(gcf, [folderName, '\optimisation_ETS_Poly_', currentTime, '\Figures\Prédiction des performances de la configuration optimale.fig']);

%% Indicateurs

% alpha_mean_lb_hf_in_band = assembly_lb_hf_opti.alpha_mean(env, f_min_obj1, f_max_obj1);
% alpha_mean_lb_hf_out_band = assembly_lb_hf_opti.alpha_mean(env, f_min_obj2, f_max_hf);
% alpha_mean = assembly_lb_hf_opti.alpha_mean(env, f_min_obj1, f_max_hf);

%% Validation numérique des objects individuels

% Validation des MPPSBHs

% i = 1;
% 
% Tube_MPPSBH = ImpedanceTube2D(ImpedanceTube2D.create_config({Objets.MPPSBH_element_i(x_ETS(x_opti), i)}));
% Tube_MPPSBH = Tube_MPPSBH.launch_tube_measurement(env);
% Tube_MPPSBH.plot_alpha(env, ['MPPSBH ' num2str(i)]);
% figure();
% mphgeom(Tube_MPPSBH.Configuration.ComsolModel);
% MPPSBH = Objets.MPPSBH_i(x_ETS(x_opti), i);
% MPPSBH_config = MPPSBH.Configuration;
% Objets.MPPSBH_i(x_ETS(x_opti), i).plot_alpha(env, 'analytique');
% mphsave(Tube_MPPSBH.Configuration.ComsolModel, [folderName, '\optimisation_', currentTime, '\validation_2D_MPPSBH_', num2str(i), '.mph']);
% mphgeom(Tube_MPPSBH.Configuration.ComsolModel)

% % Validation des cavités HR
% 
% Tube = ImpedanceTube2D(ImpedanceTube2D.create_config({}));
% Tube = Tube.lauch_tube_measurement();
% Tube.plot_alpha(env, 'MPPSBH 1');
% figure();
% mphgeom(Tube.Configuration.ComsolModel);
% Objets.MPPSBH_i(x_ETS(x0(1, :)), 1).plot_alpha(env, 'analytique');
% mphsave(Tube.Configuration.ComsolModel, [folderName, '\optimisation_', currentTime, '\validation_2D_MPPSBH_1.mph']);

% %  Validation des solutions de Poly
% 
% Tube_Poly = ImpedanceTube2D(ImpedanceTube2D.create_config({numerical_Poly_subelement}));
% Tube_Poly = Tube_Poly.lauch_tube_measurement();
% 
% figure();
% hold on
% alpha_COMSOL_Poly_subelement = perso_plot_alpha_from_COMSOL_model(Tube_Poly.Configuration.ComsolModel, 'sous-élement Poly numérique');
% imported_Poly_subelement.plot_alpha(env, 'sous-élement importé');
% 
% mphgeom(Tube_Poly.Configuration.ComsolModel);
% mphsave(Tube_Poly.Configuration.ComsolModel, [folderName, '\optimisation_', currentTime, '\validation_2D_solution_Poly.mph']);

%% Validation des contributions individuelles

validation_env = handle_env(dB);

% Contributions des élements MPPSBHs
for i = 1:NS
    figure()
    % Tube_MPPSBH_element_contrib = ImpedanceTube2D(ImpedanceTube2D.create_config({Contributions.contribution_MPPSBH_element_i(x_opti, i)}));
    % Tube_MPPSBH_element_contrib = Tube_MPPSBH_element_contrib.launch_tube_measurement(validation_env);
    % Tube_MPPSBH_element_contrib.plot_alpha(validation_env, ['Contribution MPPSBH' num2str(i)]);
    Contributions.contribution_MPPSBH_element_i(x_opti, i).plot_alpha(validation_env, 'modèle linéaire');
    Contributions.contribution_MPPSBH_element_HL_i(x_opti, i).plot_alpha(validation_env, 'modèle HL');
    Contributions.contribution_MPPSBH_element_HL_fp_i(x_opti, i).plot_alpha(validation_env, 'modèle HL appliqué à la première plaque seulement');
    perso_configure_alpha_figure(2000);
    saveas(gcf, [folderName, '\optimisation_ETS_Poly_', currentTime, '\Figures\Validation de la contribution de MPPSBH' num2str(i) '.fig']);

    % figure()
    % mphgeom(Tube_MPPSBH_element_contrib.Configuration.ComsolModel);
    % saveas(gcf, [folderName, '\optimisation_ETS_Poly_', currentTime, '\Figures\Géométrie de l''élement MPPSBH' num2str(i) '.fig']);
    % mphsave(Tube_MPPSBH_element_contrib.Configuration.ComsolModel, [folderName, '\optimisation_ETS_Poly_', currentTime, '\validation_2D_MPPSBH_', num2str(i), '.mph']);
end

% Contribution de la cavité jaune dans la cartouche ETS
% Tube_ETS_yc_contrib = ImpedanceTube2D(ImpedanceTube2D.create_config({Contributions.contribution_ETS_yellow_cavity(x_opti)}));
% Tube_ETS_yc_contrib = Tube_ETS_yc_contrib.launch_tube_measurement(validation_env);
figure();
% Tube_ETS_yc_contrib.plot_alpha(validation_env, 'Contribution ETS cavité jaune');
Contributions.contribution_ETS_yellow_cavity(x_opti).plot_alpha(validation_env, 'modèle linéaire');
Contributions.contribution_ETS_HL_yellow_cavity(x_opti).plot_alpha(validation_env, 'modèle HL');
perso_configure_alpha_figure(2000);
saveas(gcf, [folderName, '\optimisation_ETS_Poly_', currentTime, '\Figures\Validation de la contribution de la cavité jaune de la cartouche ETS.fig']);
% mphsave(Tube_ETS_yc_contrib.Configuration.ComsolModel, [folderName, '\optimisation_ETS_Poly_', currentTime, '\validation_2D_ETS_yellow_cavity.mph']);

% Contribution de la solution Poly
Tube_Poly_element_contrib = ImpedanceTube2D(ImpedanceTube2D.create_config({Contributions.contribution_Poly_numerical_element(x_opti)}));
Tube_Poly_element_contrib = Tube_Poly_element_contrib.launch_tube_measurement(validation_env);
figure();
imported_Poly_element.plot_alpha(validation_env,'élement importé seul');
Tube_Poly_element_contrib.plot_alpha(validation_env, 'Contribution Poly élement numérique');
Contributions.contribution_Poly_element(x_opti).plot_alpha(validation_env, 'Contribution Poly élement numérique - modèle linéaire');
Contributions.contribution_Poly_HL_element(x_opti).plot_alpha(validation_env, 'modèle HL');
patch([f_min_h1, f_min_h1, f_max_h1, f_max_h1], [0, 1, 1, 0], 'red', ...
      'FaceAlpha', 0.2, 'EdgeColor','none', 'DisplayName', 'Bande d''optimisation pour la fréquence de passage des pales');

perso_configure_alpha_figure(2000);
saveas(gcf, [folderName, '\optimisation_ETS_Poly_', currentTime, '\Figures\Validation de la contribution de la solution de Poly.fig']);
% mphsave(Tube_Poly_element_contrib.Configuration.ComsolModel, [folderName, '\optimisation_ETS_Poly_', currentTime, '\validation_2D_Poly_numerical_element.mph']);

% Contribution de la cavité jaune dans la cartouche ETS
Tube_Poly_yc_contrib = ImpedanceTube2D(ImpedanceTube2D.create_config({Contributions.contribution_Poly_yellow_cavity(x_opti)}));
Tube_Poly_yc_contrib = Tube_Poly_yc_contrib.launch_tube_measurement(validation_env);
figure();
% Tube_Poly_yc_contrib.plot_alpha(validation_env, 'Contribution Poly cavité jaune');
Contributions.contribution_Poly_yellow_cavity(x_opti).plot_alpha(validation_env, 'modèle linéaire');
Contributions.contribution_Poly_HL_yellow_cavity(x_opti).plot_alpha(validation_env, 'modèle HL');
patch([f_min_h2, f_min_h2, f_max_h2, f_max_h2], [0, 1, 1, 0], 'red', ...
      'FaceAlpha', 0.2, 'EdgeColor','none', 'DisplayName', 'Bande d''optimisation de la première harmonique');
perso_configure_alpha_figure(2000);
saveas(gcf, [folderName, '\optimisation_ETS_Poly_', currentTime, '\Figures\Validation de la contribution de la cavité jaune de la cartouche Poly.fig']);
% mphsave(Tube_Poly_yc_contrib.Configuration.ComsolModel, [folderName, '\optimisation_ETS_Poly_', currentTime, '\validation_2D_Poly_yellow_cavity.mph']);

%% Validation numérique des cartouches

% Cartouche_ETS_numerical_2D_validation = ...
%     @(x, i, name) Cartouche_ETS_numerical_2D_validation( ...
%     Cartouches.cartouche_ETS(x), env, folderName, name);
% 
% model = contribution_MPPSBH_element_i_numerical_2D_validation(x0(1, :), 1, 'validation_MPPSBH_element_1');
% mphsave(model, [folderName, '\validation_MPPSBH_element_1.mph']);
% perso_plot_alpha_from_COMSOL_model(model, 'MPPSBH_element_1');

% handle_Cartouche_Poly_numerical_2D_validation = @(x, solN, name) Cartouche_Poly_numerical_2D_validation( ...
%     Cartouches.cartouche_Poly(x), solN, env, folderName, name);
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

