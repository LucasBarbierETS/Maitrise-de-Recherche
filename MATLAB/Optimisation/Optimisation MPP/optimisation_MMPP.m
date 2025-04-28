%% Optimisation d'un système MMPP

clear
launch_environnement;

%% Valeurs initiales en fonction du types de variable

init_value = struct();
init_value.cavities_length = 0.01;
init_value.plates_porosity = 0.05;
init_value.plates_thickness = 0.001;
init_value.plates_perforations_dimensions = 0.001;

%% Bornes inf et sup en fonction des types de variable

bound = struct();
bound.cavities_length = [0.005 0.03];
bound.plates_porosity = [0 0.1];
bound.plates_thickness = [0.0001 0.003];
bound.plates_perforations_dimensions = [0.0001 0.003];

%% Répertoire des "variables muettes

variables = struct();

variables.ct1 = [init_value.cavities_length, bound.cavities_length(1), bound.cavities_length(2)];
variables.ct2 = [init_value.cavities_length, bound.cavities_length(1), bound.cavities_length(2)];
variables.ct3 = [init_value.cavities_length, bound.cavities_length(1), bound.cavities_length(2)];

variables.pp1 = [init_value.plates_porosity, bound.plates_porosity(1), bound.plates_porosity(2)];
variables.pp2 = [init_value.plates_porosity, bound.plates_porosity(1), bound.plates_porosity(2)];
variables.pp3 = [init_value.plates_porosity, bound.plates_porosity(1), bound.plates_porosity(2)];

variables.pt1 = [init_value.plates_thickness, bound.plates_thickness(1), bound.plates_thickness(2)];
variables.pt2 = [init_value.plates_thickness, bound.plates_thickness(1), bound.plates_thickness(2)];
variables.pt3 = [init_value.plates_thickness, bound.plates_thickness(1), bound.plates_thickness(2)];

variables.pr1 = [init_value.plates_perforations_dimensions, bound.plates_perforations_dimensions(1), bound.plates_perforations_dimensions(2)];
variables.pr2 = [init_value.plates_perforations_dimensions, bound.plates_perforations_dimensions(1), bound.plates_perforations_dimensions(2)];
variables.pr3 = [init_value.plates_perforations_dimensions, bound.plates_perforations_dimensions(1), bound.plates_perforations_dimensions(2)];

%% données du problèmes

[x0, lb, ub] = variables_to_x0_lb_ub(variables);


%% fonction handle pour le gabarit

alpha_g = @(env) (env.w > 2*pi*200) & (env.w < 2*pi*500);

%% configuration pour l'optimisation

config = struct();
config.pp1 = 'pp1';
config.pt1 = 'pt1';
config.pr1 = 'pr1';
config.ct1 = 'ct1';
config.pp2 = 'pp2';
config.pt2 = 'pt2';
config.pr2 = 'pr2';
config.ct2 = 'ct2';
config.pp3 = 'pp3';
config.pt3 = 'pt3';
config.pr3 = 'pr3';
config.ct3 = 'ct3';

function MMPP_HL = build_2MPP_HL(config)

    list = {}; 
    list{end + 1} = classsectionchange(1, config.pp1);
    list{end + 1} = classMPP_Circular_HL(classMPP_Circular_HL.create_config(config.pp1, config.pt1, config.pr1));
    list{end + 1} = classsectionchange(config.pp1, 1);
    list{end + 1} = classcavity(config.ct1);
    list{end + 1} = classsectionchange(1, config.pp2);
    list{end + 1} = classMPP_Circular_HL(classMPP_Circular_HL.create_config(config.pp2, config.pt2, config.pr2));
    list{end + 1} = classsectionchange(config.pp2, 1);
    list{end + 1} = classcavity(config.ct2);
    MMPP_HL = classelement(list, 'closed');
end

function MMPP_HL = build_3MPP_HL(config)

    list = {}; 
    list{end + 1} = classsectionchange(1, config.pp1);
    list{end + 1} = classMPP_Circular_HL(classMPP_Circular_HL.create_config(config.pp1, config.pt1, config.pr1));
    list{end + 1} = classsectionchange(config.pp1, 1);
    list{end + 1} = classcavity(config.ct1);
    list{end + 1} = classsectionchange(1, config.pp2);
    list{end + 1} = classMPP_Circular_HL(classMPP_Circular_HL.create_config(config.pp2, config.pt2, config.pr2));
    list{end + 1} = classsectionchange(config.pp2, 1);
    list{end + 1} = classcavity(config.ct2);
    list{end + 1} = classsectionchange(1, config.pp3);
    list{end + 1} = classMPP_Circular_HL(classMPP_Circular_HL.create_config(config.pp3, config.pt3, config.pr3));
    list{end + 1} = classsectionchange(config.pp3, 1);
    list{end + 1} = classcavity(config.ct3);
    MMPP_HL = classelement(list, 'closed');
end

function MMPP = build_2MPP(config)

    list = {}; 
    list{end + 1} = classsectionchange(1, config.pp1);
    list{end + 1} = classMPP_Circular(classMPP_Circular.create_config(config.pp1, config.pt1, config.pr1));
    list{end + 1} = classsectionchange(config.pp1, 1);
    list{end + 1} = classcavity(config.ct1);
    list{end + 1} = classsectionchange(1, config.pp2);
    list{end + 1} = classMPP_Circular(classMPP_Circular.create_config(config.pp2, config.pt2, config.pr2));
    list{end + 1} = classsectionchange(config.pp2, 1);
    list{end + 1} = classcavity(config.ct2);
    
    MMPP = classelement(list, 'closed');
end

function MMPP = build_3MPP(config)

    list = {}; 
    list{end + 1} = classsectionchange(1, config.pp1);
    list{end + 1} = classMPP_Circular(classMPP_Circular.create_config(config.pp1, config.pt1, config.pr1));
    list{end + 1} = classsectionchange(config.pp1, 1);
    list{end + 1} = classcavity(config.ct1);
    list{end + 1} = classsectionchange(1, config.pp2);
    list{end + 1} = classMPP_Circular(classMPP_Circular.create_config(config.pp2, config.pt2, config.pr2));
    list{end + 1} = classsectionchange(config.pp2, 1);
    list{end + 1} = classcavity(config.ct2);
    list{end + 1} = classsectionchange(1, config.pp3);
    list{end + 1} = classMPP_Circular(classMPP_Circular.create_config(config.pp3, config.pt3, config.pr3));
    list{end + 1} = classsectionchange(config.pp3, 1);
    list{end + 1} = classcavity(config.ct3);
    
    MMPP = classelement(list, 'closed');
end

%% Paramètres de l'optimisation

new_config = @(params) replace_fields(config, x0_to_variables(params, variables));
build_element = @(params) build_3MPP_HL(new_config(params));
cost_function = @(params, env) ...
    sum(((build_element(params).alpha(env) - alpha_g(env)).^2) .* (alpha_g(env) ~= 0));
objective = @(params) cost_function(params, env);

% Options d'optimisation

n_starts = 30; % Nombre de points de départ pour algo multiStart
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

% GlobalSearch

% gs = GlobalSearch('Display', 'iter'); % Crée un objet GlobalSearch avec affichage des itérations
% rng; % For reproducibility
% tic;
% [xoptiGs, fvalGs, eflagGs, outputGs] = run(gs, problem); % Exécute l'optimisation GlobalSearch
% timeGs = toc;
% 
% Genetic Algorithm 

% rng; % For reproducibility
% tic;
% [xoptiGa, fvalGa, eflagGa, outputGa, populationGa, scoresGa] = ga(objective, length(x0), [], [], [], [], lb, ub, [], [], []);
% timeGa = toc;


%% Résultats

% Evaluation des solutions obtenues avec les différents algorythmes

Ms_config = new_config(xoptiMs);
Ms_sol_HL = build_3MPP_HL(Ms_config);
Ms_sol = build_3MPP(Ms_config);


% Gs_sol = buildMLPSBH(R, {R, rend, xoptiGs(4)}, xoptiGs(3), xoptiGs(1), xoptiGs(2), ct(xoptiGs(2)), true, N);
% Ga_sol = buildMLPSBH(R, {R, rend, xoptiGa(4)}, xoptiGa(3), xoptiGa(1), xoptiGa(2), ct(xoptiGa(2)), true, N);

% Tracé des solutions obtenus

figure()
hold on
xlabel('Fréquence (Hz)');
ylabel('Coefficient d''absorption')
plot(env.w/(2*pi), alpha_g(env), 'DisplayName', 'Gabarit');
plot(env.w/(2*pi), Ms_sol.alpha(env), 'DisplayName', 'Modèle linéaire');
plot(env.w/(2*pi), Ms_sol_HL.alpha(env), 'DisplayName', 'Modèle Fort Niveaux (Laly)');

legend();

% % figure()
% plot(env.w/(2*pi), alpha_g(env) ,"--", env.w/(2*pi), Ms_sol.alpha(env));
% legend('gabarit', 'MultiStart', 'GlobalSearch', 'Genetic algorythm');


% Créer une table à double entrée pour afficher les paramètres
% param_table = table (transpose(Ms_config.cavities_length), transpose(Ms_config.plates_porosity), transpose(Ms_config.plates_thickness), transpose(Ms_config.plates_perforations_dimensions));
% param_table.Properties.VariableNames = {'Cavities length', 'Plates porosity', 'Plates thickness','Plates perforations dimensions'};
% param_table.Properties.RowNames = {'Cavité 1', 'Cavité 2', 'Cavité 3', 'Cavité 4'};

% Afficher la table
% disp(param_table)

% Performance des algorythmes
% perf = table("MultiStart", timeMs, fvalMs, eflagMs);
% % perf = table(["MultiStart"; "GlobalSearch";"Genetic algorythm"], [timeMs; timeGs; timeGa], [fvalMs; fvalGs; fvalGa], [eflagMs; eflagGs; eflagGa]);
% perf.Properties.VariableNames = ["Algoryhtm" "Duration" "Cost Value" "Flag"];
% display(perf);