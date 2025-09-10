
% Ce script permet de construire une solution constituée d'une plaque
% perforée suivie par une succession de cavités et de fentes.

%% Construction de la solution

% Paramètres globaux
input_section = 30e-3^2;
solution_depth = 30e-3; % profondeur (solution projetée en 2D)

% Paramètres de la couche poreuse
layer_width = 30e-3;
layer_thickness = 2e-3;
layer_porosity = 0.824;
layer_tortuosity = 1.1;
layer_resistivity = 9.4e4;
viscous_length = 29.22e-6;
thermal_length = 61.18e-6;

% Paramètres des cavités 
cavities_thickness = 14.5e-3;
cavities_width = 30e-3;

% Paramètres des fentes
slits_number = 6;
slits_thickness = 0.1e-3;
first_slit_width = 3e-3;
last_slit_width = 3e-3;

% DPS = classDoublePorousSlits(classDoublePorousSlits.create_config( ...
% input_section, solution_depth, slits_thickness, slits_number, ...
% first_slit_width, last_slit_width, layer_width, layer_porosity, ...
% layer_tortuosity, layer_resistivity, viscous_length, thermal_length, ...
% layer_thickness, cavities_thickness, cavities_width));

%% Optimisation géométrique de la solution

%% valeurs initiales en fonction du types de variable

init_value = struct();
init_value.first_slit_width = 5e-3;
init_value.last_slit_width = 5e-3;

%% bornes inf et sup en fonction des types de variable

bound = struct();
bound.first_slit_width = [1e-3 29e-3];
bound.last_slit_width = [1e-3 29e-3];

%% répertoire des "variables muettes"

variables = struct();

variables.w1 = [init_value.first_slit_width, bound.first_slit_width(1), bound.first_slit_width(2)];
variables.w2 = [init_value.last_slit_width, bound.last_slit_width(1), bound.last_slit_width(2)];

%% données du problèmes

[x0, lb, ub] = variables_to_x0_lb_ub(variables);

%% gabarit

% On veut un maximum d'absorption entre 200 et 400 Hz
g = @(env) (env.w / (2*pi) > 180 & env.w / (2*pi) < 420);

%% Paramètres de l'optimisation

new_config = @(params) feval(@(variables) classDoublePorousSlits.create_config( ...
    input_section, solution_depth, slits_thickness, slits_number, variables.w1(1), variables.w2(2), layer_width, layer_porosity, ...
    layer_tortuosity, layer_resistivity, viscous_length, thermal_length, ...
    layer_thickness, cavities_thickness, cavities_width), x0_to_variables(params, variables));

buildDPS = @(params) classDoublePorousSlits(new_config(params));
cost_function = @(params, env) sum(((buildDPS(params).alpha(env) - g(env)) .* (g(env) > 0.1)).^2);
objective = @(params) cost_function(params, env);

% Options d'optimisation

n_starts = 2; % Nombre de points de départ pour algo multiStart
optionsmultistart = optimset('Algorithm', 'interior-point', 'Disp', 'iter');  % algorithme adapté aux problèmes de programmation non linéaire

% Création du problème pour Global Search, MultiStart et Genetic algoryhtm

problem = createOptimProblem('fmincon', 'objective', objective, 'x0', x0, ...
'lb', lb, 'ub', ub, 'options', optionsmultistart);

%% Algorythmes d'optimisation

% Variables de sortie :  - xopti : valeurs des paramètres optimisées
%                        - fval : évaluation de la fonction coût
%                        - eflag : état de convergence de la méthode d'optimisation

% MultiStart

rng; % For reproducibility
tic;
[xoptiMs, fvalMs, eflagMs, ouputMs, solutionsMs] = run(MultiStart, problem, n_starts);
timeMs = toc;

%% Résultats

% Evaluation des solutions obtenues avec les différents algorythmes

Ms_config = new_config(xoptiMs);
Ms_sol = classDoublePorousSlits(Ms_config);

% Tracé des solutions obtenus

figure()
plot(env.w/(2*pi), g(env) ,"--", env.w/(2*pi), Ms_sol.alpha(env));
legend('gabarit', 'MultiStart');

