% Exploitation des données expérimentales en tube à incidence normale Echantillon 1.1

data1 = perso_load_mecanum_files([env.Root, '\Mesures expérimentales\Echantillons Hutchinson 1ère itération\Echantillon 1.1 Hutchinson\Export_Data']);

% Coefficient d'absorption
alpha1 = data1.AbsorptionCoefficientOnCavity;
SPL1 = data1.SoundPressureLevelAtMaterialSurface_dB_;
f = alpha1.Sample1_Frequency_Hz_;
alpha1_100 = alpha1.AbsorptionCoefficientOnCavity;
alpha1_110 = alpha1.AbsorptionCoefficientOnCavity_1;
alpha1_120 = alpha1.AbsorptionCoefficientOnCavity_2;
alpha1_130 = alpha1.AbsorptionCoefficientOnCavity_3;
alpha1_140 = alpha1.AbsorptionCoefficientOnCavity_4;
alpha1_145 = alpha1.AbsorptionCoefficientOnCavity_5;
SPL1_145 = SPL1.SoundPressureLevelAtMaterialSurface_dB__5;
alpha1_150 = alpha1.AbsorptionCoefficientOnCavity_6;

% Configuration analytique
config1 = classMPPSBH_Rectangular.create_explicit_rectangular_pattern_config(30e-3^2, 6, 28e-3, 28e-3, ...
    {[0.475 0.475 0.45 0.45 0.45 0.45] *  1e-3}, ...
    {[1.372 1.424 1.377 1.35 1.35 1.35] *  1e-3}, ...
    {[3.25 2.8 3.11 0 2.8 3.11] *  1e-3}, ...
    {[9 9 2 1 3 4]}, ...
    {[6 9 8 10 9 8]}, ...
    {[1 2 2 2 2 2] *  1e-3}, ...
    {14.83e-3});

%%%%%%%%%%%%%%%%%%%%%%%%%%%% 100 dB %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

perso_figure('Validation expérimentale - Echantillon Hutchinson 1.1 - 100 dB')

% Coefficient d'absorption en incidence normale
subplot(2, 1, 1)
hold on

plot(f, alpha1_100, 'DisplayName', 'Résultat expérimental');

% Modèle linéaire
MPPSBH = classMPPSBH_Rectangular(config1);
alpha_model = MPPSBH.alpha(handle_env(100, 0));
plot(env.w/(2*pi), alpha_model, 'DisplayName', 'Modèle analytique linéaire');

% % Modèle non-linéaire appliqué à toutes les plaques
% alpha_model_HL = classMPPSBH_Rectangular_HL(config1).alpha(handle_env(100, 0));
% plot(env.w/(2*pi), alpha_model_HL, 'DisplayName', 'Modèle analytique non-linéaire (toutes les plaques)');

% % Modèle non-linéaire avec seulement la première plaque concernée
% alpha_model_HL_first_plate = classMPPSBH_Rectangular_HL_first_plate(config1).alpha(handle_env(100, 0));
% plot(env.w/(2*pi), alpha_model_HL_first_plate, 'DisplayName', 'Modèle analytique non-linéaire première plaque');
legend()

% % Validation numérique
% Tube3D = ImpedanceTube3D(ImpedanceTube3D.create_config({MPPSBH}));
% Tube3D.launch_tube_measurement();

% Transmission Loss en incidence rasante
subplot(2, 1, 2)
hold on

TM_sb = MPPSBH.side_branch_transfer_matrix(handle_env(100, 0), 38.1e-3, 0);
MPPSBH.transmission_loss(handle_env(100, 0), TM_sb);
plot(env.w/(2*pi), MPPSBH.transmission_loss(handle_env(100, 0), TM_sb), 'DisplayName', 'Modèle')
legend()


%%%%%%%%%%%%%%%%%%%%%%%%%%%% 145 dB %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

perso_figure('Validation expérimentale - Echantillon Hutchinson 1.1 - 145 dB')
subplot(2, 1, 1)
hold on

plot(f, alpha1_145, 'DisplayName', 'Mesures expérimentales');

% % Modèle linéaire
% alpha_model = classMPPSBH_Rectangular(config1).alpha(handle_env(145, 0));
% plot(env.w/(2*pi), alpha_model, 'DisplayName', 'Modèle analytique linéaire');
% legend()

% Modèle non-linéaire appliqué à toutes les plaques 
alpha_model_HL = classMPPSBH_Rectangular_HL(config1).alpha(handle_env(145, 0));
plot(env.w/(2*pi), alpha_model_HL, 'DisplayName', 'Modèle analytique non-linéaire (toutes les plaques)');
legend()

% Modèle non-linéaire itératif
SPL1_145_interpolated = interp1(f, SPL1_145, env.w / (2*pi));

% % Debug : Niveau sonore mesuré
% perso_figure('Niveau sonore mesuré')
% plot(env.w/(2*pi), SPL1_145_interpolated)
% % close();

alpha_model_HL_first_plate = classMPPSBH_Rectangular_HL_iter(config3).alpha(env(SPL1_145_interpolated), 'iter');
alpha_model_HL_iter = classMPPSBH_Rectangular_HL_iter(config1).alpha(handle_env(145, 0), 'iter', 1e-8);
plot(env.w/(2*pi), alpha_model_HL_iter, 'DisplayName', 'Modèle analytique non-linéaire (itératif)');

% % Modèle non-linéaire avec seulement la première plaque concernée
% alpha_model_HL_first_plate = classMPPSBH_Rectangular_HL_first_plate(config1).alpha(handle_env(145, 0));
% env145, 0).w/(2*pi), alpha_model_HL_first_plate, 'DisplayName', 'Modèle analytique non-linéaire première plaque');
legend()

% Transmission Loss en incidence rasante
subplot(2, 1, 2)
hold on

TM_sb = MPPSBH.side_branch_transfer_matrix(handle_env(145, 0), 38.1e-3, 0);
MPPSBH.transmission_loss(handle_env(145, 0), TM_sb);
plot(env, MPPSBH.transmission_loss(handle_env(145, 0), TM_sb), 'DisplayName', 'Modèle')
legend()