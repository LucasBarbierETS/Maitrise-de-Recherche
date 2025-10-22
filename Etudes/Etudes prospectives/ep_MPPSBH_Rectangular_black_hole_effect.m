% Explications 
% perso_ouvrir_lien_Obsidian('obsidian://open?vault=Maitrise%20REAR&file=Notes%20atomiques%2FEtude%20de%20l''effet%20trou-noir%20acoustique')

N_config = 1;
N_plates = 10;
N_permutations = 50;

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
dw = 1e-3; % distance entre deux perforations dans le sens de la largeur
pd = 14; % Nombre de perforations dans le sens de la profondeur
% pw = randi([pw_min, pw_max], N_plates, N_config, N_permutations);
pw = randi([pw_min, pw_max], N_plates, N_config);

% Evaluation des solutions
f_min_bf = 150;
f_max_bf = 400;
f_min_mf = 400;
f_max_mf = 600;
f_min_hf = 600;
f_max_hf = 1500;

% Lorsque on veut créer des jeux de permutations
% % Initialisation de la matrice de permutations
pw_permuted = zeros(N_plates, N_config, N_permutations);

% Génération des permutations
for j = 1:N_config
    for k = 1:N_permutations
        % Permutation aléatoire de chaque colonne
        pw_permuted(:, j, k) = pw(randperm(N_plates), j);
    end
end

perso_plot_profil_shape(pw_permuted(:, 1, 12));

% Critères d'évaluation des configurations
mean_criterium = @(list_pw) (mean(list_pw) - (pw_max - pw_min)/2) / ((pw_max - pw_min)/2);
variance_criterium = @(list_pw) sum((list_pw - mean(list_pw)).^2) / length(list_pw) / ((pw_max - pw_min)^2 / 4);
barycenter_criterium = @(list_pw) perso_barycenter_criterium(list_pw, pw_min, pw_max);


% Objet flottant construit à partir des variables d'une configuration
list_pw_to_MPPSBH = @(list_pw) classMPPSBH_Rectangular(classMPPSBH_Rectangular.create_explicit_square_pattern_config(cd*cw, N_plates, cd, cw, ...
                                                                                                {r}, {dw}, ...
                                                                                                {list_pw'}, ... % nombre de perforations dans le sens de la largeur
                                                                                                {t}, {round((D - trb - t * N_plates) / N_plates, 4)}));

handle_alpha = @(list_pw) list_pw_to_MPPSBH(list_pw).alpha(handle_env(100, 0));

% Evaluations flottantes des configurations
mean_alpha_bf = @(alpha) perso_alpha_mean(alpha,handle_env(100, 0), f_min_bf, f_max_bf);
mean_alpha_mf = @(alpha) perso_alpha_mean(alpha,handle_env(100, 0), f_min_mf, f_max_mf);
mean_alpha_hf = @(alpha) perso_alpha_mean(alpha,handle_env(100, 0), f_min_hf, f_max_hf);
mean_alpha_bf_mf = @(alpha) perso_alpha_mean(alpha,handle_env(100, 0), f_min_bf, f_max_mf);
mean_alpha_mf_hf = @(alpha) perso_alpha_mean(alpha,handle_env(100, 0), f_min_mf, f_max_hf);
mean_alpha_bf_hf = @(alpha) perso_alpha_mean(alpha,handle_env(100, 0), f_min_bf, f_max_hf);

color_matrix = zeros(N_config, 3);

% Création des matrices d'évaluation des critères d'entrée et de sortie
input_criterium_matrix = zeros(4, N_config, N_permutations);
output_criterium_matrix = zeros(6, N_config, N_permutations);

for j = 1:N_config
    color_matrix(j, :) = perso_random_color_rgb_triplet();
    for k = 1:N_permutations
        % list = pw(:, j, k);
        list = pw_permuted(:, j, k);
        alpha = handle_alpha(list);
        input_criterium_matrix(:, j, k) = [mean_criterium(list), variance_criterium(list), barycenter_criterium(list), perso_distance_to_order_criterium(list)];
        output_criterium_matrix(:, j, k) = [mean_alpha_bf(alpha), mean_alpha_mf(alpha), mean_alpha_hf(alpha), mean_alpha_bf_mf(alpha), mean_alpha_mf_hf(alpha), mean_alpha_bf_hf(alpha)];
    end
end

% Visualisation graphique

% Créer un layout de type grille 4x6
tl = tiledlayout(4, 6, 'Padding', 'compact', 'TileSpacing', 'compact');

% Boucles pour chaque combinaison de niveaux des deux matrices
for i = 1:4
    for j = 1:6
        % Récupérer les données pour la combinaison des niveaux i et j
        x = input_criterium_matrix(i, :, :);  % Flatten mat1
        x = x(:);  % Aplatir en vecteur
        y = output_criterium_matrix(j, :, :);  % Flatten mat2
        y = y(:);  % Aplatir en vecteur

        % Créer un subplot pour cette combinaison
        nexttile
        scatter(x, y, [], repmat(color_matrix, N_permutations, 1));  % Tracer le scatter plot
        [rho, pval] = corr(x, y); % Corrélation
        title(['\rho : ', num2str(round(rho, 2)), ' - p.val : ', num2str(round(pval, 2))]);
    end
end

