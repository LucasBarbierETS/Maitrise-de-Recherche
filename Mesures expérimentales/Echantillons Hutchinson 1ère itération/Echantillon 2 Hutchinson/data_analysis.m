% Exploitation des données expérimentales en tube à incidence normale
% Echantillon 2

data2 = perso_load_mecanum_files('C:\Users\lucas.barbier\Documents\Maitrise dossier secondaire\Mesures expérimentales\Echantillons Hutchinson 1ère itération\Echantillon 2 Hutchinson\Export_Data');

% Coefficient d'absorption
alpha2 = data2.AbsorptionCoefficientOnCavity;
f = alpha2.Sample1_Frequency_Hz_;
alpha2_100 = alpha2.AbsorptionCoefficientOnCavity;
alpha2_110 = alpha2.AbsorptionCoefficientOnCavity_1;
alpha2_120 = alpha2.AbsorptionCoefficientOnCavity_2;
alpha2_130 = alpha2.AbsorptionCoefficientOnCavity_3;
alpha2_140 = alpha2.AbsorptionCoefficientOnCavity_4;
alpha2_145 = alpha2.AbsorptionCoefficientOnCavity_5;
alpha2_150 = alpha2.AbsorptionCoefficientOnCavity_6;

% Configuration analytique
config2 = classMPPSBH_Rectangular.create_explicit_slit_pattern_config(30e-3^2, 6, 28e-3, 28e-3, ...
    {[0.475 0.475 0.475 0.475 0.45 0.475] *  1e-3}, ...
    {[1.425 1.425 1.425 2.464 1.406 1.35] *  1e-3}, ...
    {[2.33 2.15 2.55 2.6 2.83 4] *  1e-3}, ...
    {[11 11 7 11 11 7]}, ...
    {[11 12 10 9 10 6]}, ...
    {[1 2 2 2 2 2] *  1e-3}, ...
    {14.83e-3});

%%%%%%%%%%%%%%%%%%%%%%%%%%%% 100 dB %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

figure()
subplot(2, 1, 1)
hold on
title('Echantillon 2 - 100 dB')

plot(f, alpha2_100, 'DisplayName', 'Résultat expérimental');

% Modèle linéaire
alpha_model = classMPPSBH_Rectangular(config2).alpha(env(100));
plot(env(100).w/(2*pi), alpha_model, 'DisplayName', 'Modèle analytique linéaire');

% % Modèle non-linéaire appliqué à toutes les plaques
% alpha_model_HL = classMPPSBH_Rectangular_HL(config2).alpha(env(100));
% plot(env(100).w/(2*pi), alpha_model_HL, 'DisplayName', 'Modèle analytique non-linéaire (toutes les plaques)');

% % Modèle non-linéaire avec seulement la première plaque concernée
% alpha_model_HL_first_plate = classMPPSBH_Rectangular_HL_first_plate(config2).alpha(env(100));
% plot(env(100).w/(2*pi), alpha_model_HL_first_plate, 'DisplayName', 'Modèle analytique non-linéaire première plaque');
legend()


Tube_MPPSBH = ImpedanceTube2D(ImpedanceTube2D.create_config({classMPPSBH_Rectangular(config2)}));
Tube_MPPSBH = Tube_MPPSBH.lauch_tube_measurement(env(100));
Tube_MPPSBH.plot_alpha(env(dB), 'Echantillon 2 - 100 dB');

%%%%%%%%%%%%%%%%%%%%%%%%%%%% 145 dB %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

subplot(2, 1, 2)
hold on
title('Echantillon 2 - 145 dB')

plot(f, alpha2_145, 'DisplayName', 'Mesures expérimentales');

% % Modèle linéaire
% alpha_model = classMPPSBH_Rectangular(config2).alpha(env(145));
% plot(env(145).w/(2*pi), alpha_model, 'DisplayName', 'Modèle analytique linéaire');
% legend()

% Modèle non-linéaire appliqué à toutes les plaques 
alpha_model_HL = classMPPSBH_Rectangular_HL(config2).alpha(env(145));
plot(env(145).w/(2*pi), alpha_model_HL, 'DisplayName', 'Modèle analytique non-linéaire (toutes les plaques)');
legend()

% Modèle non-linéaire itératif
% SPL2_145_interpolated = interp1(f, SPL2_145, env([]).w / (2*pi));
% alpha_model_HL_first_plate = classMPPSBH_Rectangular_HL_iter(config2).alpha(env(SPL2_145_interpolated), 'iter');
alpha_model_HL_iter = classMPPSBH_Rectangular_HL_iter(config2).alpha(env(145), 'iter', 1e-8);
plot(env(145).w/(2*pi), alpha_model_HL_iter, 'DisplayName', 'Modèle analytique non-linéaire (itératif)');

% % Modèle non-linéaire avec seulement la première plaque concernée
% alpha_model_HL_first_plate = classMPPSBH_Rectangular_HL_first_plate(config2).alpha(env(145));
% plot(env(145).w/(2*pi), alpha_model_HL_first_plate, 'DisplayName', 'Modèle analytique non-linéaire première plaque');
legend()