folder_path = [env.Root, '\Mesures expérimentales\Echantillons Hutchinson 2ème itération\Incidence normale\Echantillon 2.4'];

% Configuration C2_4

config_2_4_PW = classMPPSBH_Rectangular.create_explicit_slit_pattern_config(28e-3^2, 5, 28e-3, 28e-3, ...
    {5.9531e-04}, ...
    {[0.0024 0.0025 0.0025 0.0024 0.0025]}, ...
    {[0.0028 0.0028 0.0028 0.0028 0.0028]}, ...
    {10}, ...
    {[1 2 5 7 1]}, ...
    {[1 2 2 2 2 2] *  1e-3}, ...
    {17.17e-3}, 'Plane Wave');

config_2_4_LV = classMPPSBH_Rectangular.create_explicit_slit_pattern_config(28e-3^2, 5, 28e-3, 28e-3, ...
    {5.9531e-04}, ...
    {[0.0024 0.0025 0.0025 0.0024 0.0025]}, ...
    {[0.0028 0.0028 0.0028 0.0028 0.0028]}, ...
    {10}, ...
    {[1 2 5 7 1]}, ...
    {[1 2 2 2 2 2] *  1e-3}, ...
    {17.17e-3}, 'Lumped Volume');

%% Modèles analytiques

MPPSBH_PW = classMPPSBH_Rectangular_iter2(config_2_4_PW);
MPPSBH_LV = classMPPSBH_Rectangular_iter2(config_2_4_LV);

perso_figure('Validation expérimentale - C2.4 - 100 dB'); hold on 
plot(env.w/(2*pi), MPPSBH_PW.alpha(env), 'DisplayName', 'Modèle analytique linéaire - PW');
plot(env.w/(2*pi), MPPSBH_LV.alpha(env), 'DisplayName', 'Modèle analytique linéaire - LV');

%% Modèle 2D-TV

env_FEM = handle_env_FEM(100);

if exist([folder_path, '\modèle numérique 2D-TV.mph'], 'file')
    Tube2D_tv = ImpedanceTube2D.load_model(mphload([folder_path, '\modèle numérique 2D-TV.mph']));
else
    Tube2D_tv = ImpedanceTube2D(ImpedanceTube2D.create_config({classelement(classelement.create_config({MPPSBH_PW}, 'closed', 28e-3^2))}));
    Tube2D_tv = Tube2D_tv.launch_tube_measurement(env_FEM);
    mphsave(Tube2D_tv.Configuration.ComsolModel, [folder_path, '\modèle numérique 2D-TV.mph']);
end

Tube2D_tv.plot_alpha('Modélisation numérique 2D - TV')

%% Modèle 3D-AP

if exist([folder_path, '\modèle numérique 3D-AP.mph'], 'file')
    Tube3D_ap = ImpedanceTube3D.load_model(mphload([folder_path, '\modèle numérique 3D-AP.mph']));
else
    Tube3D_ap = ImpedanceTube3D(ImpedanceTube3D.create_config({MPPSBH_PW}));
    Tube3D_ap = Tube3D_ap.launch_tube_measurement_ap(env_FEM);
    mphsave(Tube3D_ap.Configuration.ComsolModel, [folder_path, '\modèle numérique 3D-AP.mph']);
end

Tube3D_ap.plot_alpha('Modélisation numérique 3D - AP')

%% Mesure expérimentale à incidence normale

data = perso_load_mecanum_files([env.Root, '\Mesures expérimentales\Echantillons Hutchinson 2ème itération\' ...
                                           'Incidence normale\Echantillon 2.3\Export_Data_3']);

plot(data.f, data.alpha.Sample1, 'DisplayName', 'Mesure expérimentale');

%% Incidence

% Element en parallèle
% E = classelement(classelement.create_config());