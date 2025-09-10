%% Valeurs initiales en fonction du types de variable

iv = struct();
iv.slits_width_in = 25e-3;
iv.slits_width_out = 5e-3;
iv.plates_porosity = 0.05;
% iv.plates_thickness = 0.001;
iv.plates_perforations_dimensions = 25e-5;
iv.number_of_plates = 1;

%% bornes inf et sup en fonction des types de variable

bnd = struct();
bnd.slits_width_in = [20e-3 29e-3];
bnd.slits_width_out = [2e-3 29e-3];
bnd.plates_porosity = [0.014 0.053];
bnd.plates_perforations_dimensions = [5e-5 1.5e-3];
bnd.number_of_plates = [1 20];

%% Répertoire des "variables muettes"

var = struct();
var.N = [iv.number_of_plates, bnd.number_of_plates(1), bnd.number_of_plates(2)];
var.win = [iv.slits_width_in, bnd.slits_width_in(1), bnd.slits_width_in(2)];
var.wend = [iv.slits_width_out, bnd.slits_width_out(1), bnd.slits_width_out(2)];
var.pin = [iv.plates_porosity, bnd.plates_porosity(1), bnd.plates_porosity(2)];
var.pend = [iv.plates_porosity, bnd.plates_porosity(1), bnd.plates_porosity(2)];
var.r1 = [iv.plates_perforations_dimensions, bnd.plates_perforations_dimensions(1), bnd.plates_perforations_dimensions(2)];
% var.r2 = [iv.plates_perforations_dimensions, bnd.plates_perforations_dimensions(1), bnd.plates_perforations_dimensions(2)];
% var.rend = [iv.plates_perforations_dimensions, bnd.plates_perforations_dimensions(1), bnd.plates_perforations_dimensions(2)];


%% Données du problèmes

[x0, lb, ub] = variables_to_x0_lb_ub(var);

%% Gabarit

% On veut un maximum d'absorption entre 300 et 600 Hz
g = @(env) (env.w / (2*pi) > 400 & env.w / (2*pi) < 2000);

%% Paramètres de l'optimisation

new_config = @(params) feval(@(var) classMPPSBH_Rectangular.create_config(var.N(1), 30e-3, 29e-3, ...
                                       {{var.win(1), var.wend(1), var.N(1)+1, 1}}, ... % largeur des fentes
                                       {{var.pin(1), var.pend(1), var.N(1), 1}}, ... % porosité des plaques
                                       {var.r1(1)}, ... % {var.r1(1), {var.r2(1), var.rend(1), var.N(1)-1, 1}}, ... % rayon des perforations
                                       {2e-3}, ... épaisseur des plaques
                                       {round((116e-3 - 2e-3*var.N(1)) / var.N(1), 4)}), ... % épaisseur des cavités
                                       x0_to_variables(params, var));

buildMPPSBH = @(params) classMPPSBH_Rectangular(new_config(params));
cost_function = @(params, env) sum(((buildMPPSBH(params).alpha(env) - g(env)) .* (g(env) > 0.1)).^2);
objective = @(params) cost_function(params, env);



%% Algorythmes d'optimisation

% Variables de sortie :  - xopti : valeurs des paramètres optimisées
%                        - fval : évaluation de la fonction coût
%                        - eflag : état de convergence de la méthode d'optimisation

% %% MultiStart
% 
% % Options d'optimisation
% 
% n_starts = 5; % Nombre de points de départ pour algo multiStart
% optionsmultistart = optimset('Algorithm', 'interior-point', 'Disp', 'iter');  % algorithme adapté aux problèmes de programmation non linéaire
% 
% % Création du problème pour Global Search, MultiStart et Genetic algoryhtm
% 
% problem = createOptimProblem('fmincon', 'objective', objective, 'x0', x0, ...
% 'lb', lb, 'ub', ub, 'options', optionsmultistart);
% 
% rng; % For reproducibility
% tic;
% [xoptiMs, fvalMs, eflagMs, ouputMs, solutionsMs] = run(MultiStart, problem, n_starts);
% timeMs = toc;

% % GlobalSearch
% 
% gs = GlobalSearch('Display', 'iter'); % Crée un objet GlobalSearch avec affichage des itérations
% rng; % For reproducibility
% tic;
% [xoptiGs, fvalGs, eflagGs, outputGs] = run(gs, problem); % Exécute l'optimisation GlobalSearch
% timeGs = toc;
% 
%% Genetic Algorithm

options = optimoptions('ga', 'Display', 'iter', 'MaxGenerations', 30);

rng; % For reproducibility
tic;
[xopti, fval, eflag, output, population, scores] = ga(objective, length(x0), [], [], [], [], lb, ub, [], 1, options);
timeGa = toc;


%% Résultats

% Solutions et configurations optimisée
sol_lb_mf_opti_config = new_config(xopti);
sol_lb_mf_opti = classMPPSBH_Rectangular(sol_lb_mf_opti_config);


figure()
plot(env.w/(2*pi), g(env) ,"--", env.w/ (2*pi), sol_lb_mf_opti.alpha(env));
xlim([0 2000]);

