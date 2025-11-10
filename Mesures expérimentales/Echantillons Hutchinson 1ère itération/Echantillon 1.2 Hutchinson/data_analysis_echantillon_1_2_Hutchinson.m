%% Exploitation des données expérimentales en tube à incidence normale Echantillon 2

%%  Gestion des adresses et des répértoires
folder_path = [env.Root, '\Mesures expérimentales\Echantillons Hutchinson 1ère itération\Echantillon 1.2 Hutchinson'];

%% Importation des données

data2 = perso_load_mecanum_files([folder_path, '\Export_Data']);

% Coefficient d'absorption
alpha2 = data2.alpha;
f = data2.f;
alpha2_100 = alpha2.Sample1;
alpha2_110 = alpha2.Sample2;
alpha2_120 = alpha2.Sample3;
alpha2_130 = alpha2.Sample4;
alpha2_140 = alpha2.Sample5;
alpha2_145 = alpha2.Sample6;
alpha2_150 = alpha2.Sample7;

% Coefficient d'absorption
Zs2 = data2.Zs;
f = data2.f;
Zs2_100 = Zs2.Sample1;
Zs2_110 = Zs2.Sample2;
Zs2_120 = Zs2.Sample3;
Zs2_130 = Zs2.Sample4;
Zs2_140 = Zs2.Sample5;
Zs2_145 = Zs2.Sample6;
Zs2_150 = Zs2.Sample7;

%% Affichage des résultats expérimentaux

perso_figure('Validation expérimentale - Echantillon 1.2 Hutchinson - 100-150 dB');
subplot(3, 1, 1)
title('Prototype 1.2')
hold on

plot(f, alpha2_110, 'DisplayName', '110 dB');
plot(f, alpha2_120, 'DisplayName', '120 dB');
plot(f, alpha2_130, 'DisplayName', '130 dB');
plot(f, alpha2_140, 'DisplayName', '140 dB');
plot(f, alpha2_145, 'DisplayName', '145 dB');
plot(f, alpha2_150, 'DisplayName', '150 dB');
perso_configure_alpha_figure(fmax);
xlim([f_min, 3500])
legend('Location', 'best');

subplot(3, 1, 2)
title('Résistance de surface normalisée')
hold on
xlabel('Fréquence (Hz)')
ylabel('Re(Zs/Z0)')
yline(1, '--k', 'HandleVisibility', 'off');
xlim([f_min, 3500])
legend('Location', 'best');

plot(f, real(Zs2_110), 'DisplayName', '110 dB');
plot(f, real(Zs2_120), 'DisplayName', '120 dB');
plot(f, real(Zs2_130), 'DisplayName', '130 dB');
plot(f, real(Zs2_140), 'DisplayName', '140 dB');
plot(f, real(Zs2_145), 'DisplayName', '145 dB');
plot(f, real(Zs2_150), 'DisplayName', '150 dB');

subplot(3, 1, 3)
title('Réactance de surface normalisée')
hold on
xlabel('Fréquence (Hz)')
ylabel('Im(Zs/Z0)')
yline(0, '--', 'HandleVisibility', 'off');
xlim([f_min, 3500])
ylim([-8 8])
legend('Location', 'best');

plot(f, imag(Zs2_110), 'DisplayName', '110 dB');
plot(f, imag(Zs2_120), 'DisplayName', '120 dB');
plot(f, imag(Zs2_130), 'DisplayName', '130 dB');
plot(f, imag(Zs2_140), 'DisplayName', '140 dB');
plot(f, imag(Zs2_145), 'DisplayName', '145 dB');
plot(f, imag(Zs2_150), 'DisplayName', '150 dB');

%% Définition de la configuration géométrique

% Configuration analytique
config2 = classMPPSBH_Rectangular.create_explicit_rectangular_pattern_config(30e-3^2, 6, 28e-3, 28e-3, ...
    {[0.475 0.475 0.475 0.475 0.45 0.475] *  1e-3}, ...
    {[1.425 1.425 1.425 2.464 1.406 1.35] *  1e-3}, ...
    {[2.33 2.15 2.55 2.6 2.83 4] *  1e-3}, ...
    {[11 11 7 11 11 7]}, ...
    {[11 12 10 9 10 6]}, ...
    {[1 2 2 2 2 2] *  1e-3}, ...
    {14.83e-3});

%% %%%%%%%%%%%%%%%%%%%%%%%%%% 100 dB %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Résultats expérimentaux

perso_figure('Validation expérimentale - Echantillons Hutchinson - 100 dB')

subplot(2, 1, 2)
title('Echantillon 1.2')
hold on

plot(f, alpha2_100, 'DisplayName', 'Mesure expérimentale');

% Modèle linéaire
MPPSBH = classMPPSBH_Rectangular_frustum(config2);
alpha_model = MPPSBH.absorption_coefficient(handle_env(100, 0));
plot(env.w/(2*pi), alpha_model, 'DisplayName', 'Modèle analytique régime linéaire');
perso_configure_alpha_figure(f_max)
xlim([f_min, f_max])

%% Validation numérique 3D

% Si c'est la première fois
%
% points_FEM = 500;
% env_FEM = handle_env_FEM(points_FEM);
% 
% Tube3D_ap = ImpedanceTube3D(ImpedanceTube3D.create_config({MPPSBH}));
% Tube3D_ap = Tube3D_ap.launch_tube_measurement_ap(env_FEM);
% mphsave(Tube3D_ap.Configuration.ComsolModel, [env_FEM.Root, '\Répertoire GitHub\Mesures expérimentales\Echantillons Hutchinson 1ère itération\Echantillon 1.2 Hutchinson\modèle numérique 3D-AP']);
% Tube3D_ap.plot_alpha('Modélisation numérique 3D - AP')
% 
% Tube3D = ImpedanceTube3D(ImpedanceTube3D.create_config({MPPSBH}));
% Tube3D.launch_tube_measurement_ap(env_FEM);
% mphsave(Tube3D_ap.Configuration.ComsolModel, [env_FEM.Root, '\Répertoire GitHub\Mesures expérimentales\Echantillons Hutchinson 1ère itération\Echantillon 1.2 Hutchinson\modèle numérique 3D-TV'])
% Tube3D_ap.plot_alpha('Modélisation numérique 3D - AP')

Tube3D_ap = ImpedanceTube3D(ImpedanceTube3D.create_config({}));
Tube3D_ap = Tube3D_ap.load_model(mphload([folder_path, '\modèle numérique 3D-AP.mph']));
Tube3D_ap.plot_alpha('Modélisation numérique');

xlim([f_min, f_max])
legend('Location','best')

% %%%%%%%%%%%%%%%%%%%%%%%%%%%% 145 dB %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% subplot(2, 1, 2)
% hold on
% title('Echantillon 2 - 145 dB')
% 
% plot(f, alpha2_145, 'DisplayName', 'Mesures expérimentales');
% 
% % % Modèle linéaire
% % alpha_model = classMPPSBH_Rectangular(config2).absorption_coefficient(env(145));
% % plot(env(145).w/(2*pi), alpha_model, 'DisplayName', 'Modèle analytique linéaire');
% % legend()
% 
% % Modèle non-linéaire appliqué à toutes les plaques 
% alpha_model_HL = classMPPSBH_Rectangular_HL(config2).absorption_coefficient(env(145));
% plot(env(145).w/(2*pi), alpha_model_HL, 'DisplayName', 'Modèle analytique non-linéaire (toutes les plaques)');
% legend()
% 
% % Modèle non-linéaire itératif
% % SPL2_145_interpolated = interp1(f, SPL2_145, env([]).w / (2*pi));
% % alpha_model_HL_first_plate = classMPPSBH_Rectangular_HL_iter(config2).absorption_coefficient(env(SPL2_145_interpolated), 'iter');
% alpha_model_HL_iter = classMPPSBH_Rectangular_HL_iter(config2).absorption_coefficient(env(145), 'iter', 1e-8);
% plot(env(145).w/(2*pi), alpha_model_HL_iter, 'DisplayName', 'Modèle analytique non-linéaire (itératif)');
% 
% % % Modèle non-linéaire avec seulement la première plaque concernée
% % alpha_model_HL_first_plate = classMPPSBH_Rectangular_HL_first_plate(config2).absorption_coefficient(env(145));
% % plot(env(145).w/(2*pi), alpha_model_HL_first_plate, 'DisplayName', 'Modèle analytique non-linéaire première plaque');
% legend()