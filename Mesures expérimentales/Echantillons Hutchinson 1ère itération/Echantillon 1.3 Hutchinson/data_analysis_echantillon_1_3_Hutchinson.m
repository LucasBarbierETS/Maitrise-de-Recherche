% Exploitation des données expérimentales en tube à incidence normale
% Echantillon 3

data3 = perso_load_mecanum_files([env.Root, '\Mesures expérimentales\Echantillons Hutchinson 1ère itération\Echantillon 1.3 Hutchinson\Export_Data']);

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

% Configuration analytique
config3 = classMPPSBH_Rectangular.create_explicit_slit_pattern_config(6, 28e-3, 28e-3, ...
    {[0.475 0.475 0.475 0.45 0.45 0.475] *  1e-3}, ...
    {[1.425 1.425 2.692 1.35 1.35 1.35] *  1e-3}, ...
    {[3.111 2.154 2.333 2.333 3.111 3.111] *  1e-3}, ...
    {[10 6 8 4 2 1]}, ...
    {[8 12 11 11 8 8]}, ...
    {[1 2 2 2 2 2] *  1e-3}, ...
    {14.83e-3});

%%%%%%%%%%%%%%%%%%%%%%%%%%%% 100 dB %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

figure()
subplot(2, 1, 1)
hold on
title('Echantillon 3 - 100 dB')

plot(f, alpha3_100, 'DisplayName', 'Résultat expérimental');

% Modèle linéaire
alpha_model = classMPPSBH_Rectangular(config3).alpha(env);
plot(env.w/(2*pi), alpha_model, 'DisplayName', 'Modèle analytique linéaire');

% % Modèle non-linéaire appliqué à toutes les plaques
% alpha_model_HL = classMPPSBH_Rectangular_HL(config3).alpha(env(100));
% plot(env.w/(2*pi), alpha_model_HL, 'DisplayName', 'Modèle analytique non-linéaire (toutes les plaques)');

% % Modèle non-linéaire avec seulement la première plaque concernée
% alpha_model_HL_first_plate = classMPPSBH_Rectangular_HL_first_plate(config3).alpha(env(100));
% plot(env.w/(2*pi), alpha_model_HL_first_plate, 'DisplayName', 'Modèle analytique non-linéaire première plaque');
legend()

%%%%%%%%%%%%%%%%%%%%%%%%%%%% 145 dB %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

subplot(2, 1, 2)
hold on
title('Echantillon 3 - 145 dB')

plot(f, alpha3_145, 'DisplayName', 'Mesures expérimentales');

% % Modèle linéaire
% alpha_model = classMPPSBH_Rectangular(config3).alpha(env(145));
% plot(env(145).w/(2*pi), alpha_model, 'DisplayName', 'Modèle analytique linéaire');
% legend()

% % Validation 2D
Tube_MPPSBH = ImpedanceTube2D(ImpedanceTube2D.create_config({classelement(classelement.create_config ...
    ({classMPPSBH_Rectangular(config2)}, 'closed', 30e-3^2))}));
Tube_MPPSBH = Tube_MPPSBH.launch_tube_measurement(env);
Tube_MPPSBH.plot_alpha(env, 'Echantillon 3 - validation numérique en régime linéaire');

% % Modèle non-linéaire appliqué à toutes les plaques 
% alpha_model_HL = classMPPSBH_Rectangular_HL(config3).alpha(env(145));
% plot(env(145).w/(2*pi), alpha_model_HL, 'DisplayName', 'Modèle analytique non-linéaire (toutes les plaques)');
% legend()

% Modèle non-linéaire itératif
% SPL3_145_interpolated = interp1(f, SPL3_145, env([]).w / (2*pi));
% alpha_model_HL_first_plate = classMPPSBH_Rectangular_HL_iter(config3).alpha(env(SPL3_145_interpolated), 'iter');
alpha_model_HL_iter = classMPPSBH_Rectangular_HL_iter(config3).alpha(env(145), 'iter', 1e-8);
plot(env(145).w/(2*pi), alpha_model_HL_iter, 'DisplayName', 'Modèle analytique non-linéaire (itératif)');

% % Modèle non-linéaire avec seulement la première plaque concernée
% alpha_model_HL_first_plate = classMPPSBH_Rectangular_HL_first_plate(config3).alpha(env(145));
% plot(env(145).w/(2*pi), alpha_model_HL_first_plate, 'DisplayName', 'Modèle analytique non-linéaire première plaque');
legend()