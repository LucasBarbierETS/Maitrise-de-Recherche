%% Exploitation des données expérimentales en tube à incidence normale Echantillon 3

%%  Gestion des adresses et des répértoires
folder_path = [env.Root, '\Répertoire GitHub\Mesures expérimentales\Echantillons Hutchinson 1ère itération\Echantillon 1.3 Hutchinson'];

%% Importation des données

data3 = perso_load_mecanum_files([folder_path, '\Export_Data']);

% Coefficient d'absorption
SPL3 = data3.SoundPressureLevelAtMaterialSurface_dB_;
alpha3 = data3.AbsorptionCoefficientOnCavity;
f = alpha3.Sample1_Frequency_Hz_;
alpha3_100 = alpha3.AbsorptionCoefficientOnCavity;
SPL3_100 = SPL3.SoundPressureLevelAtMaterialSurface_dB_;
alpha3_110 = alpha3.AbsorptionCoefficientOnCavity_1;
SPL3_110 = SPL3.SoundPressureLevelAtMaterialSurface_dB__1;
alpha3_120 = alpha3.AbsorptionCoefficientOnCavity_2;
SPL3_120 = SPL3.SoundPressureLevelAtMaterialSurface_dB__2;
alpha3_130 = alpha3.AbsorptionCoefficientOnCavity_3;
SPL3_130 = SPL3.SoundPressureLevelAtMaterialSurface_dB__3;
alpha3_140 = alpha3.AbsorptionCoefficientOnCavity_4;
SPL3_140 = SPL3.SoundPressureLevelAtMaterialSurface_dB__4;
alpha3_145 = alpha3.AbsorptionCoefficientOnCavity_5;
SPL3_145 = SPL3.SoundPressureLevelAtMaterialSurface_dB__5;
alpha3_150 = alpha3.AbsorptionCoefficientOnCavity_6;
SPL3_150 = SPL3.SoundPressureLevelAtMaterialSurface_dB__6;

%% Définition de la configuration géométrique

% Configuration analytique
config3 = classMPPSBH_Rectangular.create_explicit_rectangular_pattern_config(30e-3^2, 6, 28e-3, 28e-3, ...
    {[0.475 0.475 0.475 0.45 0.45 0.475] *  1e-3}, ...
    {[1.425 1.425 2.692 1.35 1.35 1.35] *  1e-3}, ...
    {[3.111 2.154 2.333 2.333 3.111 3.111] *  1e-3}, ...
    {[10 6 8 4 2 1]}, ...
    {[8 12 11 11 8 8]}, ...
    {[1 2 2 2 2 2] *  1e-3}, ...
    {14.83e-3});

%% %%%%%%%%%%%%%%%%%%%%%%%%%% 100 dB %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Résultats expérimentaux

perso_figure('Validation expérimentale - Echantillons Hutchinson - 100 dB');

subplot(2, 2, 3)
title('Echantillon 1.3')
hold on

plot(f, alpha3_100, 'DisplayName', 'Résultat expérimental');

% Modèle linéaire
MPPSBH = classMPPSBH_Rectangular(config3);
alpha_model = MPPSBH.alpha(handle_env(100, 0));
plot(env.w/(2*pi), alpha_model, 'DisplayName', 'Modèle analytique');

%% Validation numérique 3D

% Si c'est la première fois
%
% points_FEM = 500;
% env_FEM = handle_env_FEM(points_FEM);
% 
% Tube3D_ap = ImpedanceTube3D(ImpedanceTube3D.create_config({MPPSBH}));
% Tube3D_ap = Tube3D_ap.launch_tube_measurement_ap(env_FEM);
% mphsave(Tube3D_ap.Configuration.ComsolModel, [env_FEM.Root, '\Répertoire GitHub\Mesures expérimentales\Echantillons Hutchinson 1ère itération\Echantillon 1.3 Hutchinson\modèle numérique 3D-AP']);
% Tube3D_ap.plot_alpha('Modélisation numérique 3D - AP')
% 
% Tube3D = ImpedanceTube3D(ImpedanceTube3D.create_config({MPPSBH}));
% Tube3D.launch_tube_measurement_ap(env_FEM);
% mphsave(Tube3D_ap.Configuration.ComsolModel, [env_FEM.Root, '\Répertoire GitHub\Mesures expérimentales\Echantillons Hutchinson 1ère itération\Echantillon 1.3 Hutchinson\modèle numérique 3D-TV'])
% Tube3D_ap.plot_alpha('Modélisation numérique 3D - AP')

Tube3D_ap = ImpedanceTube3D(ImpedanceTube3D.create_config({}));
Tube3D_ap.Configuration.ComsolModel = mphload([folder_path, '\modèle numérique 3D-AP.mph']);
Tube3D_ap.plot_alpha('Modélisation numérique 3D - AP');
xlim([f_min, f_max])
legend('Location','best')

% %%%%%%%%%%%%%%%%%%%%%%%%%%%% 145 dB %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% subplot(2, 1, 2)
% hold on
% title('Echantillon 3 - 145 dB')
% 
% plot(f, alpha3_145, 'DisplayName', 'Mesures expérimentales');
% 
% % % Modèle linéaire
% % alpha_model = classMPPSBH_Rectangular(config3).alpha(env(145));
% % plot(env(145).w/(2*pi), alpha_model, 'DisplayName', 'Modèle analytique linéaire');
% % legend()
% 
% % % Validation 2D
% Tube_MPPSBH = ImpedanceTube2D(ImpedanceTube2D.create_config({classelement(classelement.create_config ...
%     ({classMPPSBH_Rectangular(config2)}, 'closed', 30e-3^2))}));
% Tube_MPPSBH = Tube_MPPSBH.launch_tube_measurement(env);
% Tube_MPPSBH.plot_alpha(env, 'Echantillon 3 - validation numérique en régime linéaire');
% 
% % % Modèle non-linéaire appliqué à toutes les plaques 
% % alpha_model_HL = classMPPSBH_Rectangular_HL(config3).alpha(env(145));
% % plot(env(145).w/(2*pi), alpha_model_HL, 'DisplayName', 'Modèle analytique non-linéaire (toutes les plaques)');
% % legend()
% 
% % Modèle non-linéaire itératif
% % SPL3_145_interpolated = interp1(f, SPL3_145, env([]).w / (2*pi));
% % alpha_model_HL_first_plate = classMPPSBH_Rectangular_HL_iter(config3).alpha(env(SPL3_145_interpolated), 'iter');
% alpha_model_HL_iter = classMPPSBH_Rectangular_HL_iter(config3).alpha(env(145), 'iter', 1e-8);
% plot(env(145).w/(2*pi), alpha_model_HL_iter, 'DisplayName', 'Modèle analytique non-linéaire (itératif)');
% 
% % % Modèle non-linéaire avec seulement la première plaque concernée
% % alpha_model_HL_first_plate = classMPPSBH_Rectangular_HL_first_plate(config3).alpha(env(145));
% % plot(env(145).w/(2*pi), alpha_model_HL_first_plate, 'DisplayName', 'Modèle analytique non-linéaire première plaque');
% legend()