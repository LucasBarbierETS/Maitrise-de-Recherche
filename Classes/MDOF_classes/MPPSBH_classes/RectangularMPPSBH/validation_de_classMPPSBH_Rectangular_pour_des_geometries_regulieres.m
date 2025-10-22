%% Validation du modèle classMPPSBH_Rectangular Lumped Volume
folder_path = [env.Root, '\Classes\MDOF_classes\MPPSBH_classes\RectangularMPPSBH\Validation de classMPPSBH_Rectangular pour des géométries simples']
 perso_figure('Validation du modèle classMPPSBH_Rectangular - Lumped Volume - Géométries régulières');

%% Profil constant
          
subplot(1, 2, 1);
hold on
title('Validation Rectangular MPPSBH');

% Paramètres de la configuration
W = 28e-3;
L = 100e-3;
N = 1;
wc = 10e-3;
wend = 2e-3;
d = 0.5e-3;
t = 1e-3;
phi = 0.1;

%% Profil constant

config = classMPPSBH_Rectangular.create_config(W^2, N,...
    W, W, {wc}, {wc}, ...
    {d/2}, {phi}, {t}, {L/N - t});

% calcul de la réponse des modèles analytiques
alpha_model = classMPPSBH_Rectangular(config).alpha(env);

plot(env.w / (2*pi), alpha_model, 'Color', 'g', 'LineWidth', 1, 'DisplayName', 'Modèle linéaire');

% Modèle 3D-AP

if exist([folder_path, '\profil constant - modèle numérique 3D-AP.mph'], 'file')
    Tube3D_ap = ImpedanceTube3D.load_model(mphload([folder_path, '\profil constant - modèle numérique 3D-AP.mph']));
else
    Tube3D_ap = ImpedanceTube3D(ImpedanceTube3D.create_config({MPPSBH_PW}));
    Tube3D_ap = Tube3D_ap.launch_tube_measurement_ap(env_FEM);
    mphsave(Tube3D_ap.Configuration.ComsolModel, [folder_path, '\profil constant - modèle numérique 3D-AP.mph']);
end

Tube3D_ap.plot_alpha('Modèle numérique 3D - AP')

%% Profil quadratique

% % calcul de la réponse du modèle analytique
% alpha_model = classMPPSBH_Rectangular(classMPPSBH_Rectangular.create_config(N, R, R, {{R, rend, N+1, 0.5}}, {phi}, {d/2}, {t}, {L/N - t})).alpha(env);
% 
% plot(env.w / (2*pi), alpha_model, 'Color', 'b', 'LineWidth', 1, 'DisplayName', 'Profil quadratique - Modèle');
% 
% % affichage des résultats
% xlabel("Fréquence (Hz)");
% ylabel("Coefficient d'Absorption");
% ylim([0 1]);
% xlim([0 3000]);
% legend();