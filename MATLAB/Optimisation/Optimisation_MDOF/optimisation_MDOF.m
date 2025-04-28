%% Optimisation d'un MDOF composé de 4 cavités 1/4 d'onde, chacune recouverte par une MPP

close all

addpath 'C:\Users\Utilisateur\OneDrive - ETS\CRIAQ-REAR\Maitrise LB\Classes' % classair
addpath 'C:\Users\Utilisateur\OneDrive - ETS\CRIAQ-REAR\Maitrise LB\Classes\MLPSBH_classes'
addpath 'C:\Users\Utilisateur\OneDrive - ETS\CRIAQ-REAR\Maitrise LB\Classes\Annular_classes'
addpath 'C:\Users\Utilisateur\OneDrive - ETS\CRIAQ-REAR\Maitrise LB\Functions\Gabarits\Elementary function'
addpath 'C:\Users\Utilisateur\OneDrive - ETS\CRIAQ-REAR\Maitrise LB\Functions' % matprod
addpath 'C:\Users\Utilisateur\OneDrive - ETS\CRIAQ-REAR\Maitrise LB\Functions\Draw' % drawMLPSBH
addpath 'C:\Users\Utilisateur\OneDrive - ETS\CRIAQ-REAR\Maitrise LB\Functions\Optimisation\x0_to_variables'
addpath 'C:\Users\Utilisateur\OneDrive - ETS\CRIAQ-REAR\Maitrise LB\Functions\Optimisation\replace_fields'
addpath 'C:\Users\Utilisateur\OneDrive - ETS\CRIAQ-REAR\Maitrise LB\Classes\MDOF_classes'

%% environnement

% Propriétés de l'air

To = 23;
Po = 100800;
Hr = 50;
air = classair(To, Po, Hr);
param = air.parameters;

% Support fréquenciel

f = 1:3000;
w = 2 * pi * f;


%% valeurs initiales en fonction du types de variable

init_value = struct();
init_value.cavities_length = 0.1;
init_value.plates_porosity = 0.05;
init_value.plates_thickness = 0.001;
init_value.plates_perforations_dimensions = 0.001;

%% bornes inf et sup en fonction des types de variable

bound = struct();
bound.cavities_length = [0.01 0.5];
bound.plates_porosity = [0 1];
bound.plates_thickness = [0.0001 0.005];
bound.plates_perforations_dimensions = [0.0001 0.003];

%% repertoire des "variables muettes

variables = struct();

variables.l1 = [init_value.cavities_length, bound.cavities_length(1), bound.cavities_length(2)];
variables.l2 = [init_value.cavities_length, bound.cavities_length(1), bound.cavities_length(2)];
variables.l3 = [init_value.cavities_length, bound.cavities_length(1), bound.cavities_length(2)];
variables.l4 = [init_value.cavities_length, bound.cavities_length(1), bound.cavities_length(2)];

variables.p1 = [init_value.plates_porosity, bound.plates_porosity(1), bound.plates_porosity(2)];
variables.p2 = [init_value.plates_porosity, bound.plates_porosity(1), bound.plates_porosity(2)];
variables.p3 = [init_value.plates_porosity, bound.plates_porosity(1), bound.plates_porosity(2)];
variables.p4 = [init_value.plates_porosity, bound.plates_porosity(1), bound.plates_porosity(2)];

variables.t1 = [init_value.plates_thickness, bound.plates_thickness(1), bound.plates_thickness(2)];
variables.t2 = [init_value.plates_thickness, bound.plates_thickness(1), bound.plates_thickness(2)];
variables.t3 = [init_value.plates_thickness, bound.plates_thickness(1), bound.plates_thickness(2)];
variables.t4 = [init_value.plates_thickness, bound.plates_thickness(1), bound.plates_thickness(2)];

variables.r1 = [init_value.plates_perforations_dimensions, bound.plates_perforations_dimensions(1), bound.plates_perforations_dimensions(2)];
variables.r2 = [init_value.plates_perforations_dimensions, bound.plates_perforations_dimensions(1), bound.plates_perforations_dimensions(2)];
variables.r3 = [init_value.plates_perforations_dimensions, bound.plates_perforations_dimensions(1), bound.plates_perforations_dimensions(2)];
variables.r4 = [init_value.plates_perforations_dimensions, bound.plates_perforations_dimensions(1), bound.plates_perforations_dimensions(2)];

%% données du problèmes

[x0, lb, ub] = variables_to_x0_lb_ub(variables);


%% gabarit

fm3dB = 300; % (Hz)
Q = 15;
alpha_max = 1;

% fonction handle pour le gabarit

% gabarit = classgabarit({@classgabarit.band_pass, f_peak, bandwidth, 15, 1}).build_gabarit(w);
alpha_g = @(w) high_pass(w, fm3dB, Q, alpha_max);
% plot(w/(2*pi), alpha_g(w), "--");

%% configuration pour l'optimisation

config = struct();
config.cavities_dimensions = [[0.05; 0.05], [0.05; 0.05], [0.05; 0.05], [0.05; 0.05]];
config.cavities_length = {'l1', 'l2', 'l3', 'l4'};
config.cavities_shape = {'rectangle', 'rectangle', 'rectangle', 'rectangle'};
config.plates_perforations_shape = {'circle','circle','circle','circle'};
config.plates_porosity = {'p1', 'p2', 'p3', 'p4'};
config.plates_thickness = {'t1', 't2', 't3', 't4'};
config.plates_correction_length = [0, 0, 0, 0]; 
config.plates_perforations_dimensions = {'r1', 'r2', 'r3', 'r4'};

%% Paramètres de l'optimisation

new_config = @(params) replace_fields(config, x0_to_variables(params, variables));
build_MDOF = @(params) classMDOF(new_config(params));
cost_function = @(params, air, w) sum(build_MDOF(params).alpha(air, w) - alpha_g(w).^2);
objective = @(params) cost_function(params, air, w);

% Options d'optimisation

n_starts = 1; % Nombre de points de départ pour algo multiStart
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

% % GlobalSearch
% 
% gs = GlobalSearch('Display', 'iter'); % Crée un objet GlobalSearch avec affichage des itérations
% rng; % For reproducibility
% tic;
% [xoptiGs, fvalGs, eflagGs, outputGs] = run(gs, problem); % Exécute l'optimisation GlobalSearch
% timeGs = toc;
% 
% % Genetic Algorithm 
% 
% rng; % For reproducibility
% tic;
% [xoptiGa, fvalGa, eflagGa, outputGa, populationGa, scoresGa] = ga(objective, length(x0), [], [], [], [], lb, ub, [], [], []);
% timeGa = toc;


%% Résultats

% Evaluation des solutions obtenues avec les différents algorythmes

Ms_config = new_config(xoptiMs);
Ms_sol = build_MDOF(xoptiMs);

% Gs_sol = buildMLPSBH(R, {R, rend, xoptiGs(4)}, xoptiGs(3), xoptiGs(1), xoptiGs(2), ct(xoptiGs(2)), true, N);
% Ga_sol = buildMLPSBH(R, {R, rend, xoptiGa(4)}, xoptiGa(3), xoptiGa(1), xoptiGa(2), ct(xoptiGa(2)), true, N);

% Tracé des solutions obtenus

% figure()
% plot(f, alpha_g(w) ,"--", f, Ms_sol.alpha(air, w));
% legend('gabarit', 'MultiStart');

% figure()
% plot(f, alpha_g(w) ,"--", f, Ms_sol.alpha(air, w), f, Gs_sol.alpha(air, w), f, Ga_sol.alpha(air, w));
% legend('gabarit', 'MultiStart', 'GlobalSearch', 'Genetic algorythm');


% Créer une table à double entrée pour afficher les paramètres
param_table = table (transpose(Ms_config.cavities_length), transpose(Ms_config.plates_porosity), transpose(Ms_config.plates_thickness), transpose(Ms_config.plates_perforations_dimensions));
param_table.Properties.VariableNames = {'Cavities length', 'Plates porosity', 'Plates thickness','Plates perforations dimensions'};
param_table.Properties.RowNames = {'Cavité 1', 'Cavité 2', 'Cavité 3', 'Cavité 4'};

% Afficher la table
disp(param_table)

% Performance des algorythmes
perf = table("MultiStart", timeMs, fvalMs, eflagMs);
% perf = table(["MultiStart"; "GlobalSearch";"Genetic algorythm"], [timeMs; timeGs; timeGa], [fvalMs; fvalGs; fvalGa], [eflagMs; eflagGs; eflagGa]);
perf.Properties.VariableNames = ["Algoryhtm" "Duration" "Cost Value" "Flag"];
display(perf);