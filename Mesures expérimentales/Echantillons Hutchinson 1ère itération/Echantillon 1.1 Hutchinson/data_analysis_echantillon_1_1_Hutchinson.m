%% Exploitation des données expérimentales en tube à incidence normale Echantillon 1.1

%%  Gestion des adresses et des répértoires
folder_path = [env.Root, '\Répertoire GitHub\Mesures expérimentales\Echantillons Hutchinson 1ère itération\Echantillon 1.1 Hutchinson'];

%% Importation des données

data1 = perso_load_mecanum_files([folder_path, '\Export_Data']);

% Coefficient d'absorption
alpha1 = data1.alpha;
SPL1 = data1.SPL;
f = data1.f; f_min = f(1); f_max = f(end);
alpha1_100 = data1.alpha.Sample1;
alpha1_110 = data1.alpha.Sample2;
alpha1_120 = data1.alpha.Sample3;
alpha1_130 = data1.alpha.Sample4;
alpha1_140 = data1.alpha.Sample5;
alpha1_145 = data1.alpha.Sample6;
alpha1_150 = data1.alpha.Sample7;

%% Définition de la configuration géométrique

% Configuration analytique
config1 = classMPPSBH_Rectangular.create_explicit_rectangular_pattern_config(30e-3^2, 6, 28e-3, 28e-3, ...
    {[0.475 0.475 0.45 0.45 0.45 0.45] *  1e-3}, ...
    {[1.372 1.424 1.377 1.35 1.35 1.35] *  1e-3}, ...
    {[3.25 2.8 3.11 0 2.8 3.11] *  1e-3}, ...
    {[9 9 2 1 3 4]}, ...
    {[6 9 8 10 9 8]}, ...
    {[1 2 2 2 2 2] *  1e-3}, ...
    {14.83e-3});

%% %%%%%%%%%%%%%%%%%%%%%%%%%% 100 dB %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Résultats expérimentaux

perso_figure('Validation expérimentale - Echantillons Hutchinson - 100 dB');
% perso_figure('alpha');

subplot(2, 1, 1)
title('Echantillon 1.1')
hold on

plot(f, alpha1_100, 'DisplayName', 'Résultat expérimental');

% Modèle linéaire
% MPPSBH = classMPPSBH_Rectangular(config1);
MPPSBH_frustum = classMPPSBH_Rectangular_frustum(config1);
% MPPSBH_sbdv = classMPPSBH_Rectangular_subdiv(config1);
% alpha_model = MPPSBH.alpha(handle_env(100, 0));
alpha_model_frustum = MPPSBH_frustum.alpha(handle_env(100, 0));

% alpha_model_sbdv = MPPSBH_sbdv.alpha(handle_env(100, 0));
% plot(env.w/(2*pi), alpha_model, 'DisplayName', 'Modèle analytique - approx. p');
plot(env.w/(2*pi), alpha_model_frustum, 'DisplayName', 'Modèle analytique - approx. c');
% plot(env.w/(2*pi), alpha_model_sbdv, 'DisplayName', 'Modèle analytiques subdiv');

%% Validation numérique 2D

% points_FEM = 100;
% env_FEM = handle_env_FEM(points_FEM);
% 
% Tube2D_tv = ImpedanceTube2D(ImpedanceTube2D.create_csonfig({classelement(classelement.create_config( ...
% {MPPSBH}, 'closed', 30e-3^2))}));
% Tube2D_tv = Tube2D_tv.launch_tube_measurement(env_FEM);
% Tube2D_tv.plot_alpha('Modélisation numérique 2D - TV');
% mphsave(Tube2D_tv.Configuration.ComsolModel, [folder_path, '\modèle numérique 2D_TV']);

%% Validation numérique 3D

% Si c'est la première fois
%
% points_FEM = 500;
% env_FEM = handle_env_FEM(points_FEM);
% 
% Tube3D_ap = ImpedanceTube3D(ImpedanceTube3D.create_config({MPPSBH}));
% Tube3D_ap = Tube3D_ap.launch_tube_measurement_ap(env_FEM);
% mphsave(Tube3D_ap.Configuration.ComsolModel, [folderpath, '\modèle numérique 3D-AP']);
% Tube3D_ap.plot_alpha('Modélisation numérique 3D - AP');
%
% Tube3D = ImpedanceTube3D(ImpedanceTube3D.create_config({MPPSBH}));
% Tube3D.launch_tube_measurement_ap(env_FEM);
% mphsave(Tube3D_ap.Configuration.ComsolModel, [folder_path, '\modèle numérique 3D-TV'])
% Tube3D_ap.plot_alpha('Modélisation numérique 3D - TV')

Tube3D_ap = ImpedanceTube3D(ImpedanceTube3D.create_config({}));
Tube3D_ap = Tube3D_ap.load_model(mphload([folder_path, '\modèle numérique 3D-AP.mph']));
Tube3D_ap.plot_alpha('Modélisation numérique 3D - AP');

xlim([f_min, f_max])
legend('Location','best')

% % Transmission Loss en incidence rasante
% subplot(2, 1, 2)
% hold on
% 
% TM_sb = MPPSBH.side_branch_transfer_matrix(handle_env(100, 0), 38.1e-3, 0);
% MPPSBH.transmission_loss(handle_env(100, 0), TM_sb);
% plot(env.w/(2*pi), MPPSBH.transmission_loss(handle_env(100, 0), TM_sb), 'DisplayName', 'Modèle')
% legend()

%%%%%%%%%%%%%%%%%%%%%%%%%%%% 140 dB %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

perso_figure('Validation expérimentale - Echantillon Hutchinson 1.1 - Forts niveaux')
subplot(2, 1, 1)
title('140 dB')
hold on

plot(f, alpha1_140, 'DisplayName', 'Mesures expérimentales');

% % Modèle linéaire
% alpha_model = classMPPSBH_Rectangular(config1).alpha(handle_env(145, 0));
% plot(env.w/(2*pi), alpha_model, 'DisplayName', 'Modèle analytique linéaire');
% legend()

% Modèle non-linéaire appliqué à toutes les plaques 
Zs_NL = classMPPSBH_Rectangular_HL(config1).alpha(handle_env(140, 0), 'iter');
plot(env.w/(2*pi), Zs_NL, 'DisplayName', 'Modèle analytique non-linéaire itératif');
legend()

%%%%%%%%%%%%%%%%%%%%%%%%%%%% 150 dB %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

subplot(2, 1, 2)
title('150 dB')
hold on

plot(f, alpha1_150, 'DisplayName', 'Mesures expérimentales');

% % Modèle linéaire
% alpha_model = classMPPSBH_Rectangular(config1).alpha(handle_env(145, 0));
% plot(env.w/(2*pi), alpha_model, 'DisplayName', 'Modèle analytique linéaire');
% legend()

% Modèle non-linéaire appliqué à toutes les plaques 
Zs_NL = classMPPSBH_Rectangular_HL(config1).alpha(handle_env(150, 0), 'iter');
plot(env.w/(2*pi), Zs_NL, 'DisplayName', 'Modèle analytique non-linéaire itératif');
legend()

perso_figure('Validation expérimentale - Echantillon Hutchinson 1.1 - 145 dB -  Surface d''impédance')
hold on

perso_plot_surface_impedance(f, data1.Zs.Sample6, 'DisplayName', 'Mesures expérimentales - 145 dB');

% % Modèle linéaire
% alpha_model = classMPPSBH_Rectangular(config1).alpha(handle_env(145, 0));
% plot(env.w/(2*pi), alpha_model, 'DisplayName', 'Modèle analytique linéaire');
% legend()

% Modèle non-linéaire appliqué à toutes les plaques 
Zs_NL = classMPPSBH_Rectangular_HL(config1).alpha(handle_env(145, 0), 'iter');
perso_plot_surface_impedance(env.w/(2*pi), Zs_NL/env.air.parameters.Z0, 'DisplayName', 'Modèle analytique non-linéaire itératif');
legend();

% % Modèle non-linéaire itératif
% SPL1_145_interpolated = interp1(f, SPL1_145, env.w / (2*pi));

% % Debug : Niveau sonore mesuré
% perso_figure('Niveau sonore mesuré')
% plot(env.w/(2*pi), SPL1_145_interpolated)
% % close();

% % % Modèle non-linéaire avec seulement la première plaque concernée
% alpha_model_HL_first_plate = classMPPSBH_Rectangular_HL_first_plate(config1).alpha(handle_env(145, 0));
% plot(env145, 0).w/(2*pi), alpha_model_HL_first_plate, 'DisplayName', 'Modèle analytique non-linéaire première plaque');
% legend()

% % Transmission Loss en incidence rasante
% subplot(2, 1, 2)
% hold on
% 
% TM_sb = MPPSBH.side_branch_transfer_matrix(handle_env(145, 0), 38.1e-3, 0);
% MPPSBH.transmission_loss(handle_env(145, 0), TM_sb);
% plot(env, MPPSBH.transmission_loss(handle_env(145, 0), TM_sb), 'DisplayName', 'Modèle')
% legend()