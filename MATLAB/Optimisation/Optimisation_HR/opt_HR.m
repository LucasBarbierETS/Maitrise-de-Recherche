%% Valeurs initiales en fonction du types de variable

iv = struct();
iv.neck_radius = 5e-3;
iv.neck_length = 0.1;

%% Bornes inf et sup en fonction des types de variable

bnd = struct();
bnd.neck_radius = [5e-4 3e-3];
bnd.neck_length = [2e-3 20e-3];

%% Répertoire des "variables muettes"

var = struct();
var.nr = [iv.neck_radius, bnd.neck_radius(1), bnd.neck_radius(2)];
var.nl = [iv.neck_length, bnd.neck_length(1), bnd.neck_length(2)];

%% Données du problèmes

[x0, lb, ub] = variables_to_x0_lb_ub(var);

%% Gabarit

% On veut un maximum d'absorption entre 200 et 300 Hz
g = @(env) (env.w / (2*pi) > 200 & env.w / (2*pi) < 300);


%% Paramètres de l'optimisation

new_config = @(params) feval(@(var) classHelmholtz_Resonator.create_config(var.nr(1), var.nl(1), 10e-3, 30e-3, 116e-3 - var.nl(1) , 10e-3*30e-3), ...
                                       x0_to_variables(params, var));

buildHR = @(params) classHelmholtz_Resonator(new_config(params));
cost_function = @(params, env) sum(((buildHR(params).alpha(env) - g(env)) .* (g(env) > 0.1)).^2);
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
[xopti, fval, eflag, output, population, scores] = ga(objective, length(x0), [], [], [], [], lb, ub, [], [], options);
timeGa = toc;


%% Résultats

% Solutions et configurations optimisée
hr_opti_config = new_config(xopti);
hr_opti = classHelmholtz_Resonator(hr_opti_config);

figure()
plot(env.w/(2*pi), g(env) ,"--", env.w/(2*pi), hr_opti.alpha(env));
xlim([0 2000]);
