% Exploitation des données expérimentales en tube à incidence normale
% Echantillon 4

data4 = perso_load_mecanum_files('C:\Users\lucas.barbier\Documents\Maitrise dossier secondaire\Mesures expérimentales\Echantillons Hutchinson 1ère itération\Echantillon 4 Hutchinson\Export_Data');

% Coefficient d'absorption
alpha4 = data4.AbsorptionCoefficientOnCavity;
f = alpha4.Sample1_Frequency_Hz_;
alpha4_100 = alpha4.AbsorptionCoefficientOnCavity;
alpha4_110 = alpha4.AbsorptionCoefficientOnCavity_1;
alpha4_120 = alpha4.AbsorptionCoefficientOnCavity_2;
alpha4_130 = alpha4.AbsorptionCoefficientOnCavity_3;
alpha4_140 = alpha4.AbsorptionCoefficientOnCavity_4;
alpha4_145 = alpha4.AbsorptionCoefficientOnCavity_5;
alpha4_150 = alpha4.AbsorptionCoefficientOnCavity_6;

% Configuration analytique
config4 = classMPPSBH_Rectangular.create_explicit_slit_pattern_config(6, 28e-3, 28e-3, ...
    {[0.475 0.475 0.475 0.45 0.45 0.45] *  1e-3}, ...
    {[1.425 1.425 1.425 2.03 1.35 1.35] *  1e-3}, ...
    {[2.154 2.333 2.545 2.8 2.8 3.111] *  1e-3}, ...
    {[11 9 8 7 6 2]}, ...
    {[12 11 10 9 9 8]}, ...
    {[1 2 2 2 2 2] *  1e-3}, ...
    {14.83e-3});

%%%%%%%%%%%%%%%%%%%%%%%%%%%% 100 dB %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

figure()
subplot(2, 1, 1)
hold on
title('Echantillon 4 - 100 dB')

plot(f, alpha4_100, 'DisplayName', 'Résultat expérimental');


% Modèle linéaire
alpha_model = classMPPSBH_Rectangular(config4).alpha(env(100));
plot(env(100).w/(2*pi), alpha_model, 'DisplayName', 'Modèle analytique linéaire');
legend()

% % Modèle non-linéaire appliqué à toutes les plaques
% alpha_model_HL = classMPPSBH_Rectangular_HL(config4).alpha(env(100));
% plot(env(100).w/(2*pi), alpha_model_HL, 'DisplayName', 'Modèle analytique non-linéaire (toutes les plaques)');

% % Modèle non-linéaire avec seulement la première plaque concernée
% alpha_model_HL_first_plate = classMPPSBH_Rectangular_HL_first_plate(config4).alpha(env(100));
% plot(env(100).w/(2*pi), alpha_model_HL_first_plate, 'DisplayName', 'Modèle analytique non-linéaire première plaque');
legend()

%%%%%%%%%%%%%%%%%%%%%%%%%%%% 145 dB %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

subplot(2, 1, 2)
hold on
title('Echantillon 4 - 145 dB')

plot(f, alpha4_145, 'DisplayName', 'Mesures expérimentales');

% % Modèle linéaire
% alpha_model = classMPPSBH_Rectangular(config4).alpha(env(145));
% plot(env(145).w/(2*pi), alpha_model, 'DisplayName', 'Modèle analytique linéaire');
% legend()

% Modèle non-linéaire appliqué à toutes les plaques 
alpha_model_HL = classMPPSBH_Rectangular_HL(config4).alpha(env(145));
plot(env(145).w/(2*pi), alpha_model_HL, 'DisplayName', 'Modèle analytique non-linéaire (toutes les plaques)');
legend()

% Modèle non-linéaire itératif
% SPL4_145_interpolated = interp1(f, SPL4_145, env([]).w / (2*pi));
% alpha_model_HL_first_plate = classMPPSBH_Rectangular_HL_iter(config4).alpha(env(SPL4_145_interpolated), 'iter');
alpha_model_HL_iter = classMPPSBH_Rectangular_HL_iter(config4).alpha(env(135), 'iter', 1e-8);
plot(env(145).w/(2*pi), alpha_model_HL_iter, 'DisplayName', 'Modèle analytique non-linéaire (itératif)');

% % Modèle non-linéaire avec seulement la première plaque concernée
% alpha_model_HL_first_plate = classMPPSBH_Rectangular_HL_first_plate(config4).alpha(env(145));
% plot(env(145).w/(2*pi), alpha_model_HL_first_plate, 'DisplayName', 'Modèle analytique non-linéaire première plaque');
legend()