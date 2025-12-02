%% ========================================================================
%  MODULE D'OPTIMISATION: CONSTRUCTION DYNAMIQUE DES MULTI-MPPSBH
% =========================================================================


%% Paramètres géométriques invariants

% Solution ETS
ETS_total_thickness = 117e-3;
ETS_width = 30e-3;
ETS_depth = 30e-3;
ETS_cavities_width = 28e-3; 
ETS_cavities_depth = 28e-3; 
ETS_input_surface = ETS_width * ETS_depth;
ETS_plates_thickness = 2e-3;
rigid_backing_thickness = 1e-3;
depth_holes_number = 10;
depth_holes_distance = ETS_cavities_depth / (depth_holes_number + 1);

%% Structure des variables optimisées

NS = 4; % Nombre de MPPSBH optimisés
NV = 4; % Nombre de variables pour chaque solution (rayon des perforations, nombre de perfs en largeur, espacement des perfs en largeur, theta)
N = 4; % Nombre de plaques optimisées indépendantes pour chaque solution

cavities_total_thickness = ETS_total_thickness - N * ETS_plates_thickness;

NP = 10; %nombre de points de départ (parents)

% Récupération des parties du vecteur d'optimisation
config = @(x) permute(reshape(x, [], NS, N, NV), [2, 3, 4, 1]); % Solutions ETS

%% Valeurs minimales en fonction du type de variable

% Solution ETS
r_min = 0.1e-3;
dw_min = 3 * r_min;
pw_min = 1;

theta_min = 1;

lb = horzcat(repmat(r_min, 1, N * NS), repmat(dw_min, 1, N * NS), repmat(pw_min, 1, N * NS), repmat(theta_min, 1, N * NS));

%% Valeurs maximales en fonction du type de variable

% Solution ETS
r_max = 0.3e-3;
dw_max =  3*r_max;
pw_max = depth_holes_number;

theta_max = 5;

ub = horzcat(repmat(r_max, 1, N * NS), repmat(dw_max, 1, N * NS), repmat(pw_max, 1, N * NS), repmat(theta_max, 1, N * NS));

% Debog : Porosité max et min
% phi_min = pi * radius(1)^2 / tp_dw_max^2; % < 1 %
% phi_max = pi * radius(4)^2 / tp_dw_min^2; % > 30 %

%% Valeurs initiales en fonction du type de variable

% Rayon des perforations
r_init = r_min + (r_max - r_min) * rand(NP, N * NS);

% Distance inter-perforation en largeur
dw_init = dw_min + (dw_max - dw_min) * rand(NP, N * NS);
% dw_init_sorted = sort(dw_init, 2, "descend");

% Nombre de perforation en largeur
pw_init = randi([pw_min, pw_max], NP, N * NS);
% pw_init_sorted = sort(pw_init, 2, "descend"); 

% Paramètres de répartition de l'épaisseur
theta_init = theta_min + (theta_max - theta_min) * rand(NP, N * NS);

x0 = horzcat(r_init, dw_init, pw_init, theta_init);


% % Debog : Largeur des fentes crées
% figure();
% sw_init = repmat(2 * radius(r_init), 1, NS) + dw_init .* (pw_init - 1);
% histogram(sw_init, 20);
% title('Largeur des fentes dans les MPPSBHs')

% % Debog : Porosité des plaques crées
% figure();
% hold on
% phi_init_app = (pi * (repmat(radius(r_init), 1, NS)).^2 * depth_holes_number .* pw_init) / (ETS_cavities_width * ETS_cavities_depth);
% phi_init = (pi * (repmat(radius_mm(r_init), 1, NS)).^2 * depth_holes_number .* pw_init) ./ (sw_init * ETS_cavities_depth);
% histogram(phi_init_app, 20, 'DisplayName', 'Porosité apparente de la plaque');
% histogram(phi_init, 20, 'DisplayName', 'Porosité effective de la zone perforée');
% title('Porosités des plaques dans les MPPSBHs');
% legend()

%% Contrainte sur les variables entières

intcon = find([zeros(1, N*NS), zeros(1, N*NS), ones(1, N*NS), zeros(1, N*NS)]);

%% Création dynamique des MPPSBHs

Objets = struct();

% Construction du ième MPPSBH à partir d'une découpe du vecteur d'optimisation
Objets.MPPSBH_i = @(config, i) classMPPSBH_Rectangular( ...
    classMPPSBH_Rectangular.create_explicit_rectangular_pattern_config( ...
        ETS_input_surface, N, ETS_cavities_depth, ETS_cavities_width, ...
        {config(i, :, 1)}, ... % rayon des perforations
        {config(i, :, 2)}, ... % distance entre perforations (width)
        {ETS_cavities_depth / depth_holes_number}, ... % distance entre perforations (depth)
        {depth_holes_number}, ... % nombre de perforations en profondeur
        {config(i, :, 3)}, ... % nombre de perforations en largeur
        {ETS_plates_thickness}, ... % épaisseur des plaques (supérieure + internes)
        {perso_simplex_map(config(i, :, 4), cavities_total_thickness)})); %;  % épaisseur de cavité

% Debog (OK)
% figure()
% Objets.MPPSBH_i(x_ETS(x0(1, :)), x_SPLX(x0(1, :)), 1).plot_alpha(env, 'modèle linéaire');
% close();

Objets.cell_of_MPPSBH = @(x) arrayfun(@(i) Objets.MPPSBH_i(config(x), i), 1:NS ,'UniformOutput', false);
Objects.assembly = @(x) classelementassembly(classelementassembly.create_config(Objets.cell_of_MPPSBH(x)));

%% Fonction de définitions de la matrice de contraintes non linéaires  

% Définition du handle avec paramètres capturés
handle_nonlconf = @(x) perso_nonlconf_1_solution(config(x), depth_holes_number, ETS_cavities_width, ETS_cavities_depth);

% % Debog : Test des contraintes non-linéaires sur les configurations initiales
% [c, ceq] = handle_nonlconf(x0);
% ratio = sum(~any(c > 0, 2))/NP * 100;
% sprintf('%f pourcents de configurations respectant les contraintes non-linéaires', ratio)

%% Affichage des porosités simulées

% figure()
% hold on
% p_ETS = zeros(1, NP);
% p_Poly = zeros(1, NP);
% for i = 1:NP
%     p_ETS(i) = top_plate(x_TP_ETS(x0(i, :))).Configuration.Porosity;
%     p_Poly(i) = top_plate(x_TP_Poly(x0(i, :))).Configuration.Porosity;
% end
% 
% histogram(p_ETS, 20, 'DisplayName', 'Cartouche ETS');
% histogram(p_Poly, 20, 'DisplayName', 'Cartouche Poly');
% title('Porosités des plaques couvrantes simulées');
% legend()

%% Fonctions coût

% Définition de la cartouche sur laquelle l'optimisation à lieu
handle_alpha = @(x, env, g_obj) subsref(Objects.assembly(x).absorption_coefficient(env, struct('HL_method', 'linear')), substruct('()', {g_obj(env)}));
handle_cost_function = @(x, env, g_obj) mean(1 - handle_alpha(x, env, g_obj));
handle_objective = @(x, env, g_obj_cell) arrayfun(@(i) handle_cost_function(x, env, g_obj_cell{i}), 1:length(g_obj_cell) ,'UniformOutput', false);


objective = @(x) cell2mat(handle_objective(x, env, {g_obj_h1, g_obj_h2, g_obj_h3, g_obj_h4, g_obj_lb})); % Objectif Cartouche globale