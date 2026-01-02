folder_path = [env.Root, '\Mesures expérimentales\Echantillons Hutchinson 2ème itération\Incidence normale\Echantillon 2.7'];

% Configuration C2_7

config_2_7_PW = classMPPSBH_Rectangular.create_explicit_slit_pattern_config(28e-3^2, 5, 28e-3, 28e-3, ...
    {5.9531e-04}, ...
    {[0.0025 0.0025 0.0025 0.0024 0.0025]}, ...
    {[0.0028 0.0028 0.0028 0.0028 0.0028]}, ...
    {10}, ...
    {[8 6 1 1 3]}, ...
    {[2.2 2.2 2.2 2.2 2.2] *  1e-3}, ...
    {17.5e-3}, 'Plane Wave');

config_2_7_PWC = classMPPSBH_Rectangular.create_explicit_slit_pattern_config(28e-3^2, 5, 28e-3, 28e-3, ...
    {5.9531e-04}, ...
    {[0.0025 0.0025 0.0025 0.0024 0.0025]}, ...
    {[0.0028 0.0028 0.0028 0.0028 0.0028]}, ...
    {10}, ...
    {[8 6 1 1 3]}, ...
    {[2.2 2.2 2.2 2.2 2.2] *  1e-3}, ...
    {17.5e-3}, 'Plane Wave Corrected');

config_2_7_LV = classMPPSBH_Rectangular.create_explicit_slit_pattern_config(28e-3^2, 5, 28e-3, 28e-3, ...
    {5.9531e-04}, ...
    {[0.0025 0.0025 0.0025 0.0024 0.0025]}, ...
    {[0.0028 0.0028 0.0028 0.0028 0.0028]}, ...
    {10}, ...
    {[8 6 1 1 3]}, ...
    {[2.2 2.2 2.2 2.2 2.2] *  1e-3}, ...
    {17.5e-3}, 'Lumped Volume');

%% Modèles analytiques

MPPSBH_PW = classMPPSBH_Rectangular_iter2(config_2_7_PW);
MPPSBH_PWC = classMPPSBH_Rectangular_iter2(config_2_7_PWC);
MPPSBH_LV = classMPPSBH_Rectangular_iter2(config_2_7_LV);

% perso_figure('Validation expérimentale - C2.7 - 100 dB'); hold on % Affichage individuel
perso_figure('Comparaison expérimental - numérique'); subplot(4, 2, 7); hold on % Affichage groupé
options_HL = struct('HL_method', 'all');
plot(env.w/(2*pi), MPPSBH_PW.absorption_coefficient(env, {}), 'DisplayName', 'Modèle analytique linéaire - PT');
plot(env.w/(2*pi), MPPSBH_PWC.absorption_coefficient(env, {}), 'DisplayName', 'Modèle analytique linéaire - PT corrigée');
plot(env.w/(2*pi), MPPSBH_LV.absorption_coefficient(env, {}), 'DisplayName', 'Modèle analytique linéaire - AV');
plot(env.w/(2*pi), MPPSBH_PW.absorption_coefficient(handle_env(140, 0), options_HL), 'DisplayName', 'Modèle analytique forts niveaux - PT');
plot(env.w/(2*pi), MPPSBH_PWC.absorption_coefficient(handle_env(140, 0), options_HL), 'DisplayName', 'Modèle analytique forts niveaux - PT corrigée');
plot(env.w/(2*pi), MPPSBH_LV.absorption_coefficient(handle_env(140, 0), options_HL), 'DisplayName', 'Modèle analytique forts niveaux - AV');

% %% Modèle 2D-TV
% 
% env_FEM = handle_env_FEM(100);
% 
% if exist([folder_path, '\modèle numérique 2D-TV.mph'], 'file')
%     Tube2D_tv = ImpedanceTube2D.load_model(mphload([folder_path, '\modèle numérique 2D-TV.mph']));
% else
%     Tube2D_tv = ImpedanceTube2D(ImpedanceTube2D.create_config({classelement(classelement.create_config({MPPSBH_PW}, 'closed', 28e-3^2))}));
%     Tube2D_tv = Tube2D_tv.launch_tube_measurement(env_FEM);
%     mphsave(Tube2D_tv.Configuration.ComsolModel, [folder_path, '\modèle numérique 2D-TV.mph']);
% end
% 
% Tube2D_tv.plot_alpha('C2.7 num. 2D');

%% Modèle 3D-AP

if exist([folder_path, '\modèle numérique 3D-AP.mph'], 'file')
    Tube3D_ap = ImpedanceTube3D.load_model(mphload([folder_path, '\modèle numérique 3D-AP.mph']));
else
    Tube3D_ap = ImpedanceTube3D(ImpedanceTube3D.create_config({MPPSBH_PW}));
    Tube3D_ap = Tube3D_ap.launch_tube_measurement_ap(env_FEM);
    mphsave(Tube3D_ap.Configuration.ComsolModel, [folder_path, '\modèle numérique 3D-AP.mph']);
end

Tube3D_ap.plot_alpha('C2.7 num. 3D');

%% Mesure expérimentale à incidence normale

% data = perso_load_mecanum_files([env.Root, '\Mesures expérimentales\Echantillons Hutchinson 2ème itération\' ...
%                                            'Incidence normale\Echantillon 2.7\Export_Data_7']);
% 
% plot(data.f, data.alpha.Sample1, 'DisplayName', 'Mesure expérimentale');

N = 7; % Mesure associée à l'échantillon 2.7

alpha1 = data.alpha.(['Sample', num2str((N-2)*3 + 1)]);
alpha2 = data.alpha.(['Sample', num2str((N-2)*3 + 2)]);
alpha3 = data.alpha.(['Sample', num2str((N-2)*3 + 3)]);

moy = mean([alpha1, alpha2, alpha3], 2);
ect = std([alpha1, alpha2, alpha3], 0, 2);

% Force en ligne
f = data.f(:).';         
m = moy(:).';            
s = ect(:).';

% Zone ± écart-type
fill([f fliplr(f)], [m+s fliplr(m-s)], ...
     [0.8 0.8 1], 'EdgeColor', 'none', 'FaceAlpha', 0.4, 'HandleVisibility', 'off');

% Courbe moyenne
plot(f, m, 'b', 'DisplayName', 'C2.7 exp.', 'LineWidth', 0.5);
xlim([data.f(1) data.f(end)])

%% Incidence

% Element en parallèle
% E = classelement(classelement.create_config());