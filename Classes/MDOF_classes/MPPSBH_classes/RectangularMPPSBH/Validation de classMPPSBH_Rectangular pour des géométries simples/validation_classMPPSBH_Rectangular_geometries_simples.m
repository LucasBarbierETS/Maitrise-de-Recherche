%%%%%%%%%%%%%%%%%%%%%%%% Validation du modèle classMPPSBH_Rectangular Lumped %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

folder_path = [env.Root, '\Classes\MDOF_classes\MPPSBH_classes\RectangularMPPSBH\Validation de classMPPSBH_Rectangular pour des géométries simples'];
% perso_figure('Validation du modèle classMPPSBH_Rectangular - Lumped Volume - Géométries régulières');

% Paramètres de la configuration
W = 28e-3;
L = 100e-3;
N = 10;
wc = 10e-3;
wend = 4e-3;
d = 0.5e-3;
t = 1e-3;
phi = 0.1;

% %% Profil constant
% 
% subplot(1, 2, 1);
% hold on
% title('Profil constant');
% 
% config = classMPPSBH_Rectangular.create_config(W^2, N,...
%     W, W, {wc}, {wc}, ...
%     {d/2}, {phi}, {t}, {L/N - t});
% 
% MPPSBH = classMPPSBH_Rectangular(config);
% MPPSBH_pd = classMPPSBH_Rectangular_pore_droit(config);
% 
% % calcul de la réponse des modèles analytiques
% alpha_model = MPPSBH.absorption_coefficient(env);
% alpha_model_pd = MPPSBH_pd.absorption_coefficient(env);
% 
% plot(env.w / (2*pi), alpha_model_pd, 'Color', 'b', 'LineWidth', 1, 'DisplayName', 'Modèle linéaire - Pore droit');
% plot(env.w / (2*pi), alpha_model, 'Color', 'g', 'LineWidth', 1, 'DisplayName', 'Modèle linéaire - Pore trapézoidal discrétisé');
% 
% % Modèle 3D-AP
% 
% env_FEM = handle_env_FEM(100);
% 
% if exist([folder_path, '\profil constant - modèle numérique 3D-AP.mph'], 'file')
%     Tube3D_ap = ImpedanceTube3D.load_model(mphload([folder_path, '\profil constant - modèle numérique 3D-AP.mph']));
% else
%     Tube3D_ap = ImpedanceTube3D(ImpedanceTube3D.create_config({MPPSBH}));
%     Tube3D_ap = Tube3D_ap.launch_tube_measurement_ap(env_FEM);
%     mphsave(Tube3D_ap.Configuration.ComsolModel, [folder_path, '\profil constant - modèle numérique 3D-AP.mph']);
% end
% 
% Tube3D_ap.plot_alpha('Modèle numérique 3D - AP');
% 
% %% Profil linéaire
% 
% subplot(1, 2, 2);
% hold on
% title('Profil Linéaire');
% 
% config = classMPPSBH_Rectangular.create_config(W^2, N,...
%     W, W, {{W, wend, N, 1}}, {{W, wend, N, 1}}, ...
%     {d/2}, {phi}, {t}, {L/N - t});
% 
% MPPSBH = classMPPSBH_Rectangular(config);
% MPPSBH_pd = classMPPSBH_Rectangular_pore_droit(config);
% 
% % calcul de la réponse des modèles analytiques
% alpha_model = MPPSBH.absorption_coefficient(env);
% alpha_model_pd = MPPSBH_pd.absorption_coefficient(env);
% 
% plot(env.w / (2*pi), alpha_model_pd, 'Color', 'b', 'LineWidth', 1, 'DisplayName', 'Modèle linéaire - Pore droit');
% plot(env.w / (2*pi), alpha_model, 'Color', 'g', 'LineWidth', 1, 'DisplayName', 'Modèle linéaire - Pore trapézoidal discrétisé');
% 
% % Modèle 3D-AP
% 
% env_FEM = handle_env_FEM(100);
% 
% if exist([folder_path, '\profil linéaire - modèle numérique 3D-AP.mph'], 'file')
%     Tube3D_ap = ImpedanceTube3D.load_model(mphload([folder_path, '\profil linéaire - modèle numérique 3D-AP.mph']));
% else
%     Tube3D_ap = ImpedanceTube3D(ImpedanceTube3D.create_config({MPPSBH_valid_cl}));
%     Tube3D_ap = Tube3D_ap.launch_tube_measurement_ap(env_FEM);
%     mphsave(Tube3D_ap.Configuration.ComsolModel, [folder_path, '\profil linéaire - modèle numérique 3D-AP.mph']);
% end
% 
% Tube3D_ap.plot_alpha('Modèle numérique 3D - AP');

% %%%%%%%%%%%%%%%%%%%%%%%% Etude de l'effet diaphragme %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% perso_figure('Etude de l''effet diaphragme');
% 
% %% Profil à porosité constante
% 
% subplot(1, 2, 1);
% hold on
% title('Profil à porosité constante');
% 
% real_phi = phi*wc^2/W^2;
% 
% % config_MMPP = classMMPP.create_config(W^2, N,...
% %     {d/2}, {phi}, {t}, {L/N - t});
% 
% config_MPPSBH_MMPP = classMPPSBH_Rectangular.create_config(W^2, N,...
%     W, W, {W}, {W}, ...
%     {d/2}, {real_phi}, {t}, {L/N - t});
% 
% config_Square = classMPPSBH_Rectangular.create_config(W^2, N,...
%     W, W, {wc}, {wc}, ...
%     {d/2}, {phi}, {t}, {L/N - t});
% 
% % MMPP = classMMPP(config_MMPP);
% MPPSBH_MMPP = classMPPSBH_Rectangular(config_MPPSBH_MMPP);
% MPPSBH_Square = classMPPSBH_Rectangular(config_Square);
% % MPPSBH_Slit = classMPPSBH_Rectangular(config_Slit);
% 
% % calcul de la réponse des modèles analytiques
% % alpha_model_MMPP = MMPP.absorption_coefficient(env);
% alpha_model_MPPSBH_MMPP = MPPSBH_MMPP.absorption_coefficient(env);
% alpha_model_MPPSBH_square = MPPSBH_Square.absorption_coefficient(env);
% % alpha_model_MPPSBH_slit = MPPSBH_Slit.absorption_coefficient(env);
% 
% % plot(env.w / (2*pi), alpha_model_MMPP, 'Color', 'b', 'LineWidth', 1, 'DisplayName', 'Modèle linéaire - classMMPP');
% plot(env.w / (2*pi), alpha_model_MPPSBH_MMPP, 'Color', 'b', 'LineWidth', 1, 'DisplayName', 'Modèle linéaire - répartition uniforme');
% plot(env.w / (2*pi), alpha_model_MPPSBH_square, 'Color', 'g', 'LineWidth', 1, 'DisplayName', 'Modèle linéaire - pattern carré');
% % plot(env.w / (2*pi), alpha_model_MPPSBH_slit, 'Color', 'r', 'LineWidth', 1, 'DisplayName', 'Modèle linéaire - fente');
% 
% % % Modèle 3D-AP 
% % 
% % env_FEM = handle_env_FEM(100);
% % 
% % % if exist([folder_path, '\profil constant - MMPP - modèle numérique 3D-AP.mph'], 'file')
% %     % Tube3D_ap = ImpedanceTube3D.load_model(mphload([folder_path, '\profil constant - MMPP - modèle numérique 3D-AP.mph']));
% % % else
% %     Tube3D_ap = ImpedanceTube3D(ImpedanceTube3D.create_config({MPPSBH_MMPP}));
% %     Tube3D_ap = Tube3D_ap.launch_tube_measurement_ap(env_FEM);
% %     mphsave(Tube3D_ap.Configuration.ComsolModel, [folder_path, '\profil constant - MMPP - modèle numérique 3D-AP.mph']);
% % % end
% % 
% % Tube3D_ap.plot_alpha('Modèle numérique 3D - AP - répartition uniforme');

% %% Profil à porosité décroissante (quadratique)
% 
% subplot(1, 2, 2);
% hold on
% title('Profil à porosité décroissante (quadratique)');
% 
% w = linspace(W, wend, N);
% real_phi = linspace(W, wend, N).^2/W^2 * phi;
% 
% % config_MMPP = classMMPP.create_config(W^2, N,...
% %     {d/2}, {phi}, {t}, {L/N - t});
% 
% config_MPPSBH_MMPP = classMPPSBH_Rectangular.create_config(W^2, N,...
%     W, W, {W}, {W}, ...
%     {d/2}, {real_phi}, {t}, {L/N - t});
% 
% config_Square = classMPPSBH_Rectangular.create_config(W^2, N,...
%     W, W, {{W, wend, N, 1}}, {{W, wend, N, 1}}, ...
%     {d/2}, {phi}, {t}, {L/N - t});
% 
% config_Slit = classMPPSBH_Rectangular.create_config(W^2, N,...
%     W, W, {w.^2/W}, {W}, ...
%     {d/2}, {phi}, {t}, {L/N - t});
% 
% % MMPP = classMMPP(config_MMPP);
% MPPSBH_MMPP = classMPPSBH_Rectangular(config_MPPSBH_MMPP);
% MPPSBH_Square = classMPPSBH_Rectangular(config_Square);
% MPPSBH_Slit = classMPPSBH_Rectangular(config_Slit);
% 
% % calcul de la réponse des modèles analytiques
% % alpha_model_MMPP = MMPP.absorption_coefficient(env);
% alpha_model_MPPSBH_MMPP = MPPSBH_MMPP.absorption_coefficient(env);
% alpha_model_MPPSBH_square = MPPSBH_Square.absorption_coefficient(env);
% alpha_model_MPPSBH_slit = MPPSBH_Slit.absorption_coefficient(env);
% 
% % plot(env.w / (2*pi), alpha_model_MMPP, 'Color', 'b', 'LineWidth', 1, 'DisplayName', 'Modèle linéaire - classMMPP');
% plot(env.w / (2*pi), alpha_model_MPPSBH_MMPP, 'Color', 'b', 'LineWidth', 1, 'DisplayName', 'Modèle linéaire - uniforme');
% plot(env.w / (2*pi), alpha_model_MPPSBH_square, '--g', 'LineWidth', 1, 'DisplayName', 'Modèle linéaire - carré');
% plot(env.w / (2*pi), alpha_model_MPPSBH_slit, '--r', 'LineWidth', 1, 'DisplayName', 'Modèle linéaire - fente');
% 
% % % Modèle 3D-AP 
% % 
% % env_FEM = handle_env_FEM(100);
% % 
% % if exist([folder_path, '\profil linéaire - MMPP - modèle numérique 3D-AP.mph'], 'file')
% %     Tube3D_ap = ImpedanceTube3D.load_model(mphload([folder_path, '\profil linéaire - MMPP - modèle numérique 3D-AP.mph']));
% % else
% %     Tube3D_ap = ImpedanceTube3D(ImpedanceTube3D.create_config({MPPSBH_MMPP}));
% %     Tube3D_ap = Tube3D_ap.launch_tube_measurement_ap(env_FEM);
% %     mphsave(Tube3D_ap.Configuration.ComsolModel, [folder_path, '\profil linéaire - MMPP - modèle numérique 3D-AP.mph']);
% % % end
% % 
% % Tube3D_ap.plot_alpha('Modèle numérique 3D - AP - répartition uniforme');

%%%%%%%%%%%%%%%%%%%%%%%% Etude de l'impact du nombre de plaques %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

perso_figure('Etude de l''impact du nombre de plaques - Coefficient d''absorption');

% %% Profil à porosité constante
% 
% % subplot(1, 2, 1);
% hold on
perso_figure('Profil constant');

config = @(N) classMPPSBH_Rectangular.create_config(W^2, N,...
    W, W, {wc}, {wc}, ...
    {d/2}, {phi}, {t}, {L/N - t});

N_var = [2, 4, 8, 16, 32];

for i= 1:length(N_var)

    MPPSBH = classMPPSBH_Rectangular_iter2(config(N_var(i)));
    alpha_model = MPPSBH.absorption_coefficient(env, {});
    subplot(2, 1, 1); hold on
    plot(env.w / (2*pi), alpha_model, 'LineWidth', 1, 'DisplayName', ['Modèle linéaire - ', num2str(N_var(i)), ' plaques']);
    subplot(2, 1, 2); hold on
    plot(env.w/(2*pi), real(MPPSBH.surface_impedance(env, {})/env.air.parameters.Z0), 'LineWidth', 1, 'DisplayName', [num2str(N_var(i)), ' plaques']);
end

%% Profil à décroissance linéaire

% subplot(1, 2, 2);

perso_figure('Profil à décroissance linéaire');
config = @(N) classMPPSBH_Rectangular.create_config(W^2, N,...
    W, W, {{W, wend, N, 1}}, {{W, wend, N, 1}}, ...
    {d/2}, {phi}, {t}, {L/N - t});

for i= 1:length(N_var)
   
    MPPSBH = classMPPSBH_Rectangular_iter2(config(N_var(i)));
    alpha_model = MPPSBH.absorption_coefficient(env, {});
    subplot(2, 1, 1); hold on
    plot(env.w / (2*pi), alpha_model, 'LineWidth', 1, 'DisplayName', ['Modèle linéaire - ', num2str(N_var(i)), ' plaques']);
    subplot(2, 1, 2); hold on
    plot(env.w/(2*pi), real(MPPSBH.surface_impedance(env, {})/env.air.parameters.Z0), 'LineWidth', 1, 'DisplayName', [num2str(N_var(i)), ' plaques']);
end

%%%%%%%%%%%%%%%%%%%%%%%% Etude de l'effet trou noir acoustique %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

perso_figure('Etude de l''effet trou noir acoustique'); hold on

Inv = [10, 9, 8, 7, 6, 5, 4, 3, 2, 1];
Alt = [1, 10, 2, 9, 3, 8, 4, 7, 5, 6];
Inv_Alt = [10, 1, 9, 2, 8, 3, 7, 4, 6, 5];
Autre = [6, 5, 7, 4, 8, 3, 9, 2, 10, 1];

config = classMPPSBH_Rectangular.create_config(W^2, N,...
    W, W, {w}, {w}, ...
    {d/2}, {phi}, {t}, {L/N - t}); 

config_Inv = classMPPSBH_Rectangular.create_config(W^2, N,...
    W, W, {w(Inv)}, {w(Inv)}, ...
    {d/2}, {phi}, {t}, {L/N - t}); 

config_Alt = classMPPSBH_Rectangular.create_config(W^2, N,...
    W, W, {w(Alt)}, {w(Alt)}, ...
    {d/2}, {phi}, {t}, {L/N - t}); 

config_Inv_Alt = classMPPSBH_Rectangular.create_config(W^2, N,...
    W, W, {w(Inv_Alt)}, {w(Inv_Alt)}, ...
    {d/2}, {phi}, {t}, {L/N - t}); 

config_Autre = classMPPSBH_Rectangular.create_config(W^2, N,...
    W, W, {w(Autre)}, {w(Autre)}, ...
    {d/2}, {phi}, {t}, {L/N - t}); 

MPPSBH = classMPPSBH_Rectangular(config);
MPPSBH_Inv = classMPPSBH_Rectangular(config_Inv);
MPPSBH_Alt = classMPPSBH_Rectangular(config_Alt);
MPPSBH_Inv_Alt = classMPPSBH_Rectangular(config_Inv_Alt);
MPPSBH_Autre = classMPPSBH_Rectangular(config_Autre);

alpha_model = MPPSBH.absorption_coefficient(env);
alpha_model_Inv = MPPSBH_Inv.absorption_coefficient(env);
alpha_model_Alt = MPPSBH_Alt.absorption_coefficient(env);
alpha_model_Inv_Alt = MPPSBH_Inv_Alt.absorption_coefficient(env);
alpha_model_Autre = MPPSBH_Autre.absorption_coefficient(env);

plot(env.w / (2*pi), alpha_model, 'Color', 'k', 'LineWidth', 1, 'DisplayName', 'Modèle linéaire');
plot(env.w / (2*pi), alpha_model_Inv, 'Color', 'b', 'LineWidth', 1, 'DisplayName', 'Modèle linéaire - disposition inversé');
plot(env.w / (2*pi), alpha_model_Alt, 'g', 'LineWidth', 1, 'DisplayName', 'Modèle linéaire - disposition alternée');
plot(env.w / (2*pi), alpha_model_Inv_Alt, 'r', 'LineWidth', 1, 'DisplayName', 'Modèle linéaire - dispoition alternée - inversée');
plot(env.w / (2*pi), alpha_model_Autre, 'c', 'LineWidth', 1, 'DisplayName', 'Modèle linéaire - dispoition autre');

perso_figure('Etude de l''effet trou noir acoustique - Surface d''impédance'); hold on

perso_plot_surface_impedance(env.w/(2*pi), MPPSBH.surface_impedance(env), env, 'C0.2');
perso_plot_surface_impedance(env.w/(2*pi), MPPSBH_Inv.surface_impedance(env), env, 'C0.2-I - disposition inversée');
perso_plot_surface_impedance(env.w/(2*pi), MPPSBH_Alt.surface_impedance(env), env, 'C0.2-A - disposition alternée');
perso_plot_surface_impedance(env.w/(2*pi), MPPSBH_Inv_Alt.surface_impedance(env), env, 'C0.2-I-A - disposition inversée-alternée');
perso_plot_surface_impedance(env.w/(2*pi), MPPSBH_Autre.surface_impedance(env), env, 'C0.2-Int-Ext - disposition interne-externe');
