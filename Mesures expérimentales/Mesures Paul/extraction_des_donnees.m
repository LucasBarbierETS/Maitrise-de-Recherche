%% Choix de l'échantillon étudié

N = 1;

%% Récupération des données

exp_data_path = [env.Root, '\Répertoire GitHub\Mesures expérimentales\Mesures Paul'];
data  = perso_load_mecanum_files([exp_data_path, '\Export_Data_bloc', num2str(N)]);


%% Choix de la mesure étudiée

mes = 6;

%% Vérification de la mesure choisie pour l'échantillon choisi

perso_figure(['Vérification de la mesure ', num2str(mes), ' de l''échantillon ', num2str(N)]);

subplot(2, 2, 1);
hold on
plot(data.f, data.alpha.(['Sample', num2str(mes)]), 'DisplayName', 'Flat at Sample');
plot(data.f, data.alpha.(['Sample', num2str(mes + 6)]), 'DisplayName', 'Flat at Mic');
title('alpha'); legend('Location', 'best');

subplot(2, 2, 2);
hold on
plot(data.f, abs(data.Zs.(['Sample', num2str(mes)])), 'DisplayName', 'Flat at Sample');
plot(data.f, abs(data.Zs.(['Sample', num2str(mes)])), 'DisplayName', 'Flat at Mic');
title('abs(Zs)'); legend('Location', 'best');

subplot(2, 2, 3);
hold on
plot(data.f, abs(data.R.(['Sample', num2str(mes)])), 'DisplayName', 'Flat at Sample');
plot(data.f, abs(data.R.(['Sample', num2str(mes)])), 'DisplayName', 'Flat at Mic');
title('abs(R)'); legend('Location', 'best');
subplot(2, 2, 4);
hold on
plot(data.f, abs(data.SPL.(['Sample', num2str(mes)])), 'DisplayName', 'Flat at Sample');
plot(data.f, abs(data.SPL.(['Sample', num2str(mes)])), 'DisplayName', 'Flat at Mic');
title('SPL'); legend('Location', 'best');

%% Configurations des 4 échantillons

config1 = classMPPSBH_Rectangular.create_explicit_rectangular_pattern_config(30e-3^2, 6, 28e-3, 28e-3, ...
    {[0.475 0.475 0.45 0.45 0.45 0.45] *  1e-3}, ...
    {[1.372 1.424 1.377 1.35 1.35 1.35] *  1e-3}, ...
    {[3.25 2.8 3.11 0 2.8 3.11] *  1e-3}, ...
    {[9 9 2 1 3 4]}, ...
    {[6 9 8 10 9 8]}, ...
    {[1 2 2 2 2 2] *  1e-3}, ...
    {14.83e-3});

config2 = classMPPSBH_Rectangular.create_explicit_rectangular_pattern_config(30e-3^2, 6, 28e-3, 28e-3, ...
    {[0.475 0.475 0.475 0.475 0.45 0.475] *  1e-3}, ...
    {[1.425 1.425 1.425 2.464 1.406 1.35] *  1e-3}, ...
    {[2.33 2.15 2.55 2.6 2.83 4] *  1e-3}, ...
    {[11 11 7 11 11 7]}, ...
    {[11 12 10 9 10 6]}, ...
    {[1 2 2 2 2 2] *  1e-3}, ...
    {14.83e-3});

config3 = classMPPSBH_Rectangular.create_explicit_rectangular_pattern_config(30e-3^2, 6, 28e-3, 28e-3, ...
    {[0.475 0.475 0.475 0.45 0.45 0.475] *  1e-3}, ...
    {[1.425 1.425 2.692 1.35 1.35 1.35] *  1e-3}, ...
    {[3.111 2.154 2.333 2.333 3.111 3.111] *  1e-3}, ...
    {[10 6 8 4 2 1]}, ...
    {[8 12 11 11 8 8]}, ...
    {[1 2 2 2 2 2] *  1e-3}, ...
    {14.83e-3});

config4 = classMPPSBH_Rectangular.create_explicit_rectangular_pattern_config(30e-3^2, 6, 28e-3, 28e-3, ...
    {[0.475 0.475 0.475 0.45 0.45 0.45] *  1e-3}, ...
    {[1.425 1.425 1.425 2.03 1.35 1.35] *  1e-3}, ...
    {[2.154 2.333 2.545 2.8 2.8 3.111] *  1e-3}, ...
    {[11 9 8 7 6 2]}, ...
    {[12 11 10 9 9 8]}, ...
    {[1 2 2 2 2 2] *  1e-3}, ...
    {14.83e-3});

%% Validation numérique 3D

points_FEM = 50;
env_FEM = handle_env_FEM(points_FEM);

% Si jamais lancé
MPPSBH = classMPPSBH_Rectangular(eval(['config', num2str(N)]));
Tube3D_ap = ImpedanceTube3D(ImpedanceTube3D.create_config({MPPSBH}));
Tube3D_ap = Tube3D_ap.launch_tube_measurement_ap(env_FEM);
mphsave(Tube3D_ap.Configuration.ComsolModel, [exp_data_path, '\Modèles numériques 3D\Echantillon ', num2str(N), ' - modèle numérique 3D-AP']);

% Si déja lancé
% Tube3D_ap = ImpedanceTube3D(ImpedanceTube3D.create_config({}));
% Tube3D_ap.Configuration.ComsolModel = mphload([exp_data_path, '\Modèles numériques 3D\Echantillon ', num2str(N), ' - modèle numérique 3D-AP']);
% Tube3D_ap.plot_alpha('Modélisation numérique 3D - AP');

perso_figure('alpha');
title('alpha');
hold on
Tube3D_ap.plot_alpha('Modélisation numérique 3D - AP');
plot(data.f, data.alpha.Sample1, 'DisplayName', 'mesures expérimentales - 100 dB');

perso_figure('Zs');
title('Zs');
hold on
Tube3D_ap.plot_surface_impedance(env_FEM, 'Modélisation numérique 3D - AP');
perso_plot_surface_impedance(data.f, data.Zs.Sample1, 'DisplayName', 'mesures expérimentales - 100 dB');