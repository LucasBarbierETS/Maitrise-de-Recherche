%% Exploitation des données expérimentales en tube à incidence normale Echantillon 42

%%  Gestion des adresses et des répértoires
folder_path = [env.Root, '\Répertoire GitHub\Mesures expérimentales\Echantillons Hutchinson 1ère itération\Echantillon 1.4 Hutchinson'];

%% Importation des données

data4 = perso_load_mecanum_files([folder_path, '\Export_Data']);

% Coefficient d'absorption
alpha4 = data4.alpha;
f = data4.f;
alpha4_100 = alpha4.Sample1;
alpha4_110 = alpha4.Sample2;
alpha4_120 = alpha4.Sample3;
alpha4_130 = alpha4.Sample4;
alpha4_140 = alpha4.Sample5;
alpha4_145 = alpha4.Sample6;
alpha4_150 = alpha4.Sample7;

%% Définition de la configuration géométrique

% Configuration analytique
config4 = classMPPSBH_Rectangular.create_explicit_rectangular_pattern_config(30e-3^2, 6, 28e-3, 28e-3, ...
    {[0.475 0.475 0.475 0.45 0.45 0.45] *  1e-3}, ...
    {[1.425 1.425 1.425 2.03 1.35 1.35] *  1e-3}, ...
    {[2.154 2.333 2.545 2.8 2.8 3.111] *  1e-3}, ...
    {[11 9 8 7 6 2]}, ...
    {[12 11 10 9 9 8]}, ...
    {[1 2 2 2 2 2] *  1e-3}, ...
    {14.83e-3});

%% %%%%%%%%%%%%%%%%%%%%%%%%%% 100 dB %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Résultats expérimentaux

perso_figure('Validation expérimentale - Echantillons Hutchinson - 100 dB');

subplot(2, 2, 4)
title('Echantillon 1.4')
hold on

plot(f, alpha4_100, 'DisplayName', 'Résultat expérimental');

% Modèle linéaire
MPPSBH = classMPPSBH_Rectangular(config4);
alpha_model = MPPSBH.alpha(handle_env(100, 0));
plot(env.w/(2*pi), alpha_model, 'DisplayName', 'Modèle analytique');

%% Validation numérique 3D

% Si c'est la première fois

points_FEM = 500;
env_FEM = handle_env_FEM(points_FEM);

% Tube3D_ap = ImpedanceTube3D(ImpedanceTube3D.create_config({MPPSBH}));
% Tube3D_ap = Tube3D_ap.launch_tube_measurement_ap(env_FEM);
% mphsave(Tube3D_ap.Configuration.ComsolModel, [env_FEM.Root, '\Répertoire GitHub\Mesures expérimentales\Echantillons Hutchinson 1ère itération\Echantillon 1.4 Hutchinson\modèle numérique 3D-AP']);
% Tube3D_ap.plot_alpha('Modélisation numérique 3D - AP');

% Tube3D = ImpedanceTube3D(ImpedanceTube3D.create_config({MPPSBH}));
% Tube3D.launch_tube_measurement_ap(env_FEM);
% mphsave(Tube3D_ap.Configuration.ComsolModel, [env_FEM.Root, '\Répertoire GitHub\Mesures expérimentales\Echantillons Hutchinson 1ère itération\Echantillon 1.4 Hutchinson\modèle numérique 3D-TV'])
% Tube3D_ap.plot_alpha(env_FEM, 'Modélisation numérique 3D - TV')

Tube3D_ap = ImpedanceTube3D(ImpedanceTube3D.create_config({}));
Tube3D_ap = Tube3D_ap.load_model(mphload([folder_path, '\modèle numérique 3D-AP.mph']));
Tube3D_ap.plot_alpha('Modélisation numérique 3D - AP');

xlim([f_min, f_max])
legend('Location','best')

% %%%%%%%%%%%%%%%%%%%%%%%%%%%% 145 dB %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% subplot(2, 1, 2)
% hold on
% title('Echantillon 4 - 145 dB')
% 
% plot(f, alpha4_145, 'DisplayName', 'Mesures expérimentales');
% 
% % % Modèle linéaire
% % alpha_model = classMPPSBH_Rectangular(config4).alpha(env(145));
% % plot(env(145).w/(2*pi), alpha_model, 'DisplayName', 'Modèle analytique linéaire');
% % legend()
% 
% % Modèle non-linéaire appliqué à toutes les plaques 
% alpha_model_HL = classMPPSBH_Rectangular_HL(config4).alpha(env(145));
% plot(env(145).w/(2*pi), alpha_model_HL, 'DisplayName', 'Modèle analytique non-linéaire (toutes les plaques)');
% legend()
% 
% % Modèle non-linéaire itératif
% % SPL4_145_interpolated = interp1(f, SPL4_145, env([]).w / (2*pi));
% % alpha_model_HL_first_plate = classMPPSBH_Rectangular_HL_iter(config4).alpha(env(SPL4_145_interpolated), 'iter');
% alpha_model_HL_iter = classMPPSBH_Rectangular_HL_iter(config4).alpha(env(135), 'iter', 1e-8);
% plot(env(145).w/(2*pi), alpha_model_HL_iter, 'DisplayName', 'Modèle analytique non-linéaire (itératif)');
% 
% % % Modèle non-linéaire avec seulement la première plaque concernée
% % alpha_model_HL_first_plate = classMPPSBH_Rectangular_HL_first_plate(config4).alpha(env(145));
% % plot(env(145).w/(2*pi), alpha_model_HL_first_plate, 'DisplayName', 'Modèle analytique non-linéaire première plaque');
% legend()