% Explications 
% Le but de cette étude est de mettre en évidence des corrélations entre
% la largeur moyenne des fentes (illustration de l'effet diaphramme) et
% certaines performances acoustiques : 
% - performances large bande
% - performances régulières (plateau)
% - performances basses fréquences

N_config = 10;
N_plates = 10;
N_variants = 10;

% Valeurs extrêmes 
pw_min = 1;
pw_max = 14;

%% Valeurs initiales en fonction du types de variable

D = 100e-3; % Epaisseur totale
trb = 1e-3; %  Epaisseur du fond rigide
cd = 29e-3; % profondeur des cavités
cw = 29e-3; % largeur des cavités
t = 2e-3; % Epaisseur des plaques
r = 5e-4; % rayon
pd = 14; % Nombre de perforations dans le sens de la profondeur
pw = randi([pw_min, pw_max], N_plates, N_config);

% Evaluation des solutions
f_min_bf = 150;
f_max_bf = 400;
f_min_mf = 400;
f_max_mf = 600;
f_min_hf = 600;
f_max_hf = 1500;

% Pour chaque ensemble de N_plates plaques (nombre de configurations) on définit
% N_plaques * N_permutations distance interperforations entre le max 
d_max = @(width_hole_number) cw / (width_hole_number + 1);
dw = @(d_max) unifrnd(3*r, d_max);

% Initialisation de la matrice de permutations
dw_variants = zeros(N_plates, N_config, N_variants);

% Génération des variants
for i = 1:N_plates
    for j = 1:N_config
        % On récupère la distance max permise pour la configuration j
        dmax = d_max(pw(i, j));
        for k = 1:N_variants
            % On définit une taille de fente dans l'intervale admis pour chaque variant
            dw_variants(i, j, k) = dw(dmax);
        end
    end
end

% perso_plot_profil_shape(dw_variants(:, 1, 12));

% Critères d'évaluation des configurations

% Critères d'entrée
mean_criterium = @(dw_matrix) mean(dw_matrix, 1);
normalized_mean_criterium = @(mean_criterium) (mean_criterium - (max(mean_criterium, [], 'all') + min(mean_criterium, [], 'all'))/2) / ((max(mean_criterium, [], 'all') - min(mean_criterium, [], 'all'))/2);
variance_criterium = @(dw_matrix) sum((dw_matrix - mean(dw_matrix, 1)).^2, 1) / size(dw_matrix, 1);
normalized_variance_critererium = @(variance_criterium) variance_criterium / max(variance_criterium, [], 'all');

% slit_barycentre_criterium = @(list_dw, list_pw) perso_slit_barycentre_criterium(list_pw, pw_min, pw_max);
input_criterium_matrix = cat(1, normalized_mean_criterium(mean_criterium(dw_variants)), normalized_variance_critererium(variance_criterium(dw_variants)));

% Critères de sortie
% Objet flottant construit à partir des variables d'une configuration
list_dw_and_list_pw_to_MPPSBH = @(list_dw, list_pw) classMPPSBH_Rectangular(classMPPSBH_Rectangular.create_explicit_config(N_plates, cd, cw, ...
                                                                                                {list_dw .* (list_pw - 1)}, ... % largeur des fentes
                                                                                                {r}, {list_dw'}, {pd}, ...
                                                                                                {list_pw'}, ... % nombre de perforations dans le sens de la largeur
                                                                                                {t}, {round((D - trb - t * N_plates) / N_plates, 4)}));

handle_alpha = @(list_dw, list_pw) list_dw_and_list_pw_to_MPPSBH(list_dw, list_pw).absorption_coefficient(env);

% Evaluations flottantes des configurations
mean_alpha_bf = @(alpha) perso_alpha_mean(alpha, env, f_min_bf, f_max_bf);
mean_alpha_mf = @(alpha) perso_alpha_mean(alpha, env, f_min_mf, f_max_mf);
mean_alpha_hf = @(alpha) perso_alpha_mean(alpha, env, f_min_hf, f_max_hf);
mean_alpha_bf_mf = @(alpha) perso_alpha_mean(alpha, env, f_min_bf, f_max_mf);
mean_alpha_mf_hf = @(alpha) perso_alpha_mean(alpha, env, f_min_mf, f_max_hf);
mean_alpha_bf_hf = @(alpha) perso_alpha_mean(alpha, env, f_min_bf, f_max_hf);

% Création des matrices d'évaluation des critères de sortie
output_criterium_matrix = zeros(6, N_config, N_variants);
color_matrix = zeros(N_config, 3);

for j = 1:N_config
    color_matrix(j, :) = perso_random_color_rgb_triplet();
    for k = 1:N_variants
        list_dw = dw_variants(:, j, k);
        list_pw = pw(:, j);
        alpha = handle_alpha(list_dw, list_pw);
        output_criterium_matrix(:, j, k) = [mean_alpha_bf(alpha), mean_alpha_mf(alpha), mean_alpha_hf(alpha), mean_alpha_bf_mf(alpha), mean_alpha_mf_hf(alpha), mean_alpha_bf_hf(alpha)];
    end
end

% Visualisation graphique

% Créer un layout de type grille 2x6
tl = tiledlayout(2, 6, 'Padding', 'compact', 'TileSpacing', 'compact');

% Boucles pour chaque combinaison de niveaux des deux matrices
for i = 1:2
    for j = 1:6
        % Récupérer les données pour la combinaison des niveaux i et j
        x = input_criterium_matrix(i, :, :);  % Flatten mat1
        x = x(:);  % Aplatir en vecteur
        y = output_criterium_matrix(j, :, :);  % Flatten mat2
        y = y(:);  % Aplatir en vecteur

        % Créer un subplot pour cette combinaison
        nexttile
        scatter(x, y, [], repmat(color_matrix, N_variants, 1));  % Tracer le scatter plot
        [rho, pval] = corr(x, y); % Corrélation
        title(['\rho : ', num2str(round(rho, 2)), ' - p.val : ', num2str(round(pval, 2))]);
    end
end

