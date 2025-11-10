%% ========================================================================
%  Étude de l'influence de l'ordre des plaques sur une configuration donnée
%  Auteur : Lucas Barbier
%  Version : 1.0
%  Date : [à compléter]
% ========================================================================

%% ------------------------------
%  PARAMÈTRES GÉNÉRAUX
% -------------------------------

N_plates = 10;          % Nombre total de plaques
N_permutations = 100;   % Nombre de permutations aléatoires à générer

%% ------------------------------
%  PARAMÈTRES GÉOMÉTRIQUES DU LINER
% -------------------------------

% Paramètres de la configuration
W = 28e-3;
L = 100e-3;
N = 10;
wc = 10e-3;
wend = 4e-3;
d = 0.5e-3;
t = 1e-3;
phi = 0.1;

%% ------------------------------
%  DÉFINITION DU PROFIL DE RÉFÉRENCE (côtés perforés)
% -------------------------------

% Loi linéaire entre largeur initiale (wc) et largeur finale (wend)
% pour N_plates plaques
side_ref = linspace(W, wend, N_plates)';  

% % Visualisation optionnelle du profil
% figure('Name', 'Profil de référence');
% plot(1:N_plates, side_ref * 1e3, '-o', 'LineWidth', 1.2);
% xlabel('Indice de plaque');
% ylabel('Largeur de la zone perforée (mm)');
% title('Profil linéaire de la largeur des zones perforées');
% grid on;

%% ------------------------------
%  PARAMÈTRES FRÉQUENTIELS
% -------------------------------

f_min_bf = 150;  f_max_bf = 400;   % Basses fréquences
f_min_mf = 400;  f_max_mf = 600;   % Moyennes fréquences
f_min_hf = 600;  f_max_hf = 1500;  % Hautes fréquences

%% ------------------------------
%  GÉNÉRATION DES PERMUTATIONS
% -------------------------------

side_permuted = zeros(N_plates, N_permutations);
for k = 1:N_permutations
    side_permuted(:, k) = side_ref(randperm(N_plates));
end
% Exemple de visualisation du profil d'une permutation
perso_plot_profil_shape(side_permuted(:, 1));

%% ------------------------------
%  MÉTRIQUES D'ÉVALUATION
% -------------------------------

% Critères d'entrée (propriétés géométriques)
barycenter_criterium = @(side_list) perso_barycenter_criterium(side_list, wend, wc);
disorder_criterium = @(side_list) perso_distance_to_order_criterium(side_list);

% Fonctions de construction de configuration et d’évaluation acoustique
side_to_MPPSBH = @(side_list) classMPPSBH_Rectangular( ...
    classMPPSBH_Rectangular.create_config( ...
        W^2, N_plates, ...
        W, W, {side_list'}, {side_list'}, ...
        {d/2}, {phi}, {t}, ...
        {round((L - t * N_plates) / N_plates, 4)}));

handle_alpha = @(list_pw) side_to_MPPSBH(list_pw).absorption_coefficient(handle_env(100, 0));

% Fonctions d’évaluation acoustique (moyennes par bandes)
mean_alpha_bf    = @(alpha) perso_alpha_mean(alpha, handle_env(100, 0), f_min_bf, f_max_bf);
mean_alpha_mf    = @(alpha) perso_alpha_mean(alpha, handle_env(100, 0), f_min_mf, f_max_mf);
mean_alpha_hf    = @(alpha) perso_alpha_mean(alpha, handle_env(100, 0), f_min_hf, f_max_hf);
mean_alpha_bf_mf = @(alpha) perso_alpha_mean(alpha, handle_env(100, 0), f_min_bf, f_max_mf);
mean_alpha_mf_hf = @(alpha) perso_alpha_mean(alpha, handle_env(100, 0), f_min_mf, f_max_hf);
mean_alpha_bf_hf = @(alpha) perso_alpha_mean(alpha, handle_env(100, 0), f_min_bf, f_max_hf);

%% ------------------------------
%  BOUCLE D'ÉVALUATION
% -------------------------------

input_matrix  = zeros(2, N_permutations);
output_matrix = zeros(2, N_permutations);

for k = 1:N_permutations
    side_list = side_permuted(:, k);
    alpha = handle_alpha(side_list);
    
    % Critères d’entrée
    input_matrix(:, k) = [ ...
        barycenter_criterium(side_list), ...
        disorder_criterium(side_list)];
    
    % Critères de sortie (performances acoustiques)
    output_matrix(:, k) = [ ...
        mean_alpha_bf(alpha), ...
        ... mean_alpha_mf(alpha),
        ... mean_alpha_hf(alpha),
        ...) mean_alpha_bf_mf(alpha),
        mean_alpha_mf_hf(alpha) ...
        % mean_alpha_bf_hf(alpha),...
        ];
end

%% ------------------------------
%  ANALYSE DE CORRÉLATION ENTRE MÉTRIQUES
% -------------------------------

figure('Name','Corrélations entrées/sorties','Color','w');
tl = tiledlayout(2, 2, 'Padding', 'compact', 'TileSpacing', 'compact');

for i = 1:2
    for j = 1:2
        nexttile
        x = input_matrix(i, :);
        y = output_matrix(j, :);
        scatter(x, y, 30, 'filled');
        [rho, pval] = corr(x', y');
        title(['\rho = ', num2str(round(rho, 2)), ', p = ', num2str(round(pval, 3))]);
        xlabel(['Entrée ', num2str(i)]);
        ylabel(['Sortie ', num2str(j)]);
        grid on;
    end
end

title(tl, 'Corrélation entre propriétés géométriques et performances acoustiques');