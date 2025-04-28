%% Valeurs initiales en fonction du types de variable

iv = struct();
iv.slits_width = 5e-3;
iv.plates_porosity = 0.1;
iv.plates_perforations_dimensions = 0.0025;
iv.cavities_thickness = 116e-3/3;
iv.number_of_plates = 1;

%% Bornes inf et sup en fonction des types de variable

bnd = struct();
bnd.slits_width = [1e-3 29e-3];
bnd.first_slit_width = [20e-3 29e-3];
bnd.plates_porosity = [0.014 0.053];
bnd.plates_perforations_dimensions = [2.5e-4 1.5e-3];
bnd.cavities_thickness = [2e-3 98e-3];
bnd.number_of_plates = [2 2];

%% Répertoire des "variables muettes"

var = struct();
var.N = [iv.number_of_plates, bnd.number_of_plates(1), bnd.number_of_plates(2)];
var.w1 = [iv.slits_width, bnd.first_slit_width(1), bnd.first_slit_width(2)];
var.w2 = [iv.slits_width, bnd.slits_width(1), bnd.slits_width(2)];
var.wend = [iv.slits_width, bnd.slits_width(1), bnd.slits_width(2)];
% var.t1 = [iv.cavities_thickness, bnd.cavities_thickness(1), bnd.cavities_thickness(2)];
% var.t2 = [iv.cavities_thickness, bnd.cavities_thickness(1), bnd.cavities_thickness(2)];
% var.t3 = [iv.cavities_thickness, bnd.cavities_thickness(1), bnd.cavities_thickness(2)];
var.p1 = [iv.plates_porosity, bnd.plates_porosity(1), bnd.plates_porosity(2)];
var.r1 = [iv.plates_perforations_dimensions, bnd.plates_perforations_dimensions(1), bnd.plates_perforations_dimensions(2)];

%% Données du problèmes

[x0, lb, ub] = variables_to_x0_lb_ub(var);

%% Gabarit

% On veut un maximum d'absorption entre 300 et 600 Hz
g = @(env) (env.w / (2*pi) > 300 & env.w / (2*pi) < 600);


%% Paramètres de l'optimisation

new_config = @(params) feval(@(var) classSDOF.create_config(var.p1(1), var.r1(1), 2e-3, 56e-3, 30e-3, 30e-3, 'false'), ...
                                       x0_to_variables(params, var));

buildSDOF = @(params) classSDOF(new_config(params));
cost_function = @(params, env) sum(((buildSDOF(params).alpha(env) - g(env)) .* (g(env) > 0.1)).^2);
objective = @(params) cost_function(params, env);

%% Fonction handle pour les contraintes

% function [c, ceq] = contraintes(params)
%     c = [];
%     ceq = []; 
%     % ceq = params(3) + params(4) - 96e-3;
%     % ceq = params(4) + params(5) + params (6) - 97e-3;
% end


%% Algorythmes d'optimisation

% variables de sortie :  - xopti : valeurs des paramètres optimisées
%                        - fval : évaluation de la fonction coût
%                        - eflag : état de convergence de la méthode d'optimisation

%% MultiStart

% % Options d'optimisation
% 
% n_starts = 1; % Nombre de points de départ pour algo multiStart
% optionsmultistart = optimset('Algorithm', 'interior-point', 'Disp', 'iter');  % algorithme adapté aux problèmes de programmation non linéaire
% 
% % Création du problème pour Global Search, MultiStart et Genetic algoryhtm
% 
% problem = createOptimProblem('fmincon', 'objective', objective, ...
%     'x0', x0,'lb', lb, 'ub', ub, ... % limites et valeurs initiales
%     'nonlcon', @contraintes, ...
%     'options', optionsmultistart);

% rng; % For reproducibility
% tic;
% [xopti, fval, eflag, ouput, solutions] = run(MultiStart, problem, n_starts);
% timeMs = toc;

%% GlobalSearch
% 
% gs = GlobalSearch('Display', 'iter'); % Crée un objet GlobalSearch avec affichage des itérations
% rng; % For reproducibility
% tic;
% [xopti, fval, eflag, output] = run(gs, problem); % Exécute l'optimisation GlobalSearch
% timeGs = toc;

%% Genetic Algorithm

options = optimoptions('ga', 'Display', 'iter', 'MaxGenerations', 30);

rng; % For reproducibility
tic;
[xopti, fval, eflag, output, population, scores] = ga(objective, length(x0), [], [], [], [], lb, ub, [], 1, options);
timeGa = toc;


%% Résultats

% Solutions et configurations optimisée
sol_bf_opti_config = new_config(xopti);
sol_bf_opti = sol_bf(sol_bf_opti_config);

figure()
plot(env.w/(2*pi), g(env) ,"--", env.w/(2*pi), sol_bf_opti.alpha(env));
xlim([0 2000]);
