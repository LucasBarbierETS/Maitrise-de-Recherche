% Ce script est un exemple d'optimisation pour 2 résonateurs d'Helmholtz
% Il se base sur des paramètres préalablement définis dans une table, que
% l'utilisateur nomme ces paramètres comme il souhaite, puis les attribue à
% des propriétés des résonateurs. Le programme minimise le coefficient de
% réflexion au carré sur une plage de fréquences donnée.

%% Path and clear
clc; clear; close all;

addpath 'C:\Users\AQ99270\Documents\Projet Bell\Acoustique_ML_2024_03_01\Classes'
addpath 'C:\Users\AQ99270\Documents\Projet Bell\Acoustique_ML_2024_03_01\Functions'

%% Air
T0 = 20; % Temperature in Celsius
P0 = 1e5; % Atmospheric pressure in Pascals
hr = 20; % Relative humidity in percentage

air = classair(T0, P0, hr);

clear T0 P0 hr

%% Optimisation frequency band

fmin = input("Bande de fréquences pour l'optimisation, borne inf [Hz] :");
fmax = input("Bande de fréquences pour l'optimisation, borne sup [Hz] :");
fstep = input("Bande de fréquences pour l'optimisation, pas [Hz] :");
f_opti = fmin:fstep:fmax;
w_opti = 2*pi*f_opti;

% Display frequency for plot/figure only
f = 1:f_opti(end) + 200;
w = 2*pi*f;

%% Geometric parameters


%% tableSilentVariables

% Table des variables muettes définies par l'utilisateur qui pourront être injectées dans l'optimisation
tableSilentVariables = table(["a";"b"], [1e-3; 1e-3], [1e-4; 1e-4], [1e-1; 1e-1], ["Rayon du col du 1er RH";"Rayon du col du 2ème RH"]);
tableSilentVariables.Properties.VariableNames = ["Name" "Value" "LowerBound" "UpperBound" "Description"];

% Ajout d'autres paramètres préalablement définis
tableSilentVariables(3, :) = {"c" 1.1e-3 1e-3 1e-1 "longueur du col du 1er RH"};
tableSilentVariables(4, :) = {"d" 1.1e-3 1e-3 1e-1 "longueur du col du 2ème RH"};

% tableSilentVariables =

% 4×5 table
% 
%   Name    Value     LowerBound    UpperBound            Description         
%   ____    ______    __________    __________    ____________________________
% 
%   "a"      0.001      0.0001         0.1        "Rayon du col du 1er RH"    
%   "b"      0.001      0.0001         0.1        "Rayon du col du 2ème RH"   
%   "c"     0.0011       0.001         0.1        "longueur du col du 1er RH" 
%   "d"     0.0011       0.001         0.1        "longueur du col du 2ème RH"


%% paramsSilentVariables

% Création d'une structure à partir de la table des paramètres sous forme de structure.variable_muettes = valeur
n_variables = height(tableSilentVariables);
for i = 1:n_variables
    paramsSilentVariables.(tableSilentVariables{i, 1}) = tableSilentVariables{i, 2};
end

% paramsSilentVariables = 
% 
%   struct with fields:
% 
%     a: 1.0000e-03
%     b: 1.0000e-03
%     c: 0.0011
%     d: 0.0011

%% Paramètres entrés dans l'interface

PUC_area = pi*(50e-3)^2; % periodic unity cell

r_col1 = "a"; % Paramètre prédéfini
l_col1 = "c";r
r_cav1 = "22.22e-3"; % Valeur
l_cav1 = "10e-3";

r_col2 = "b";
l_col2 = "d";
r_cav2 = "22.22e-3";
l_cav2 = "20e-3";

%% Handle functions and objects

% Création des objets en fonction des paramètres muets définis par l'utilisateur dans tablePreviouslyDeterminedParameters

HR_cells = cell(1, 2); % Cell contenant les handles objects
phi_cells = HR_cells;  % Cell contenant les handles surface ratio
elements_cells = HR_cells; % Cell contenant les objects de class 'Element'

% j : résonateurs
% i : paramètres

% params :     Tableau contenant les valeurs des paramètres entrées par l'utilisateur
%              Un paramètre de param_list peut-être associé à un scalaire ou à une variables muettes.

for j = 1:2 % Parcours des sous-éléments (similaire à l'application)

%% création de la chaine de caractères et de HR_cell

    create_object = "@(params) classHR2("; % Create a handle function
    switch j
        case 1
            params = [r_col1 l_col1 r_cav1 l_cav1];
        case 2
            params = [r_col2 l_col2 r_cav2 l_cav2];
    end
    for i = 1:4
        if ismember(params(i), fieldnames(paramsSilentVariables)) % Si la valeur entrée est l'une des variables muettes
            create_object = create_object + "params." + string(params(i));
        else
            create_object = create_object + string(double(params(i)));
        end
        if i < 4
            create_object = create_object + ", ";
        else
            create_object = create_object + ");";
        end
    end

    HR_cells{j} = str2func(create_object); % HR_cells{j} = @(params) classHR2(r_col1, l_col1, r_cav1, l_cav1)
    

% Create the handle porosity : si params(j,1) = a : phi_cells{j} = @(params) pi*params.a^2/PUC_area
%                              si params(j,1) = 0.5 : phicell{j} = @(params) pi

    if ismember(params(i,1), fieldnames(paramsSilentVariables))
        phi_cells{j} = str2func("@(params) pi*params." + string(params(j,1)) + "^2/" + string(PUC_area)); % Variable muette
    elseif not(ismember(params(i), fieldnames(paramsSilentVariables)))
        phi_cells{j} = str2func("@(params) pi*" + double(params(j,1)) + "^2/" + string(PUC_area)); % Valeur numérique
    end

    
    
    if j == 1
        elements_cells{j} = @(params) Element(phi_cells{j}(params), {HR_cells{j}(params)}, 'opened'); % Element
    else
        elements_cells{j} = @(params) Element(phi_cells{j}(params), {HR_cells{j}(params)}, 'closed'); % Element
    end
end


cellfunction2list = @(cell,para) cell(para);
elements = @(params) cellfun(@(x) cellfunction2list(x, params), elements_cells);
assembly = @(params) element_assembly(elements(params));

% Reflexion coefficient with handle parameters
Zs = @(params, assembly, fluid, w) assembly(params).transferMatrix(fluid, w).T11 ./ assembly(params).transferMatrix(fluid, w).T21; % Impédance de surface
R = @(params, assembly, fluid, w) ... % Coefficient de réflexion
(Zs(params, assembly, fluid, w) - fluid.parameters.rho * fluid.parameters.c0) ...
. / (Zs(params, assembly fluid, w) + fluid.parameters.rho * fluid.parameters.c0);

figure, hold on
plot(f, abs(R(paramsSilentVariables, assembly, air, w)), "DisplayName", "Initial values")
xlabel("Frequency (Hz)")
ylabel("|R| (1)")
title("User values")
ylim([0 1])

%% Optimisation

% Vecteur initial
x0 = tableSilentVariables{:, 2};

% Bornes sup et inf
lb = tableSilentVariables{:, 3}; % Borne inf
ub = tableSilentVariables{:, 4}; % Borne sup

% Contraintes
Aineq = zeros(length(x0));
bineq = zeros(length(x0), 1);
% Imposer : Rcol <= Rcav
Aineq(1) = 1;
bineq(1) = str2double(r_cav1);

% Alpha initial
alpha0 = 1 - abs(R(paramsSilentVariables, assembly, air, w)).^2;

% Initial sound absorption
figure;
hold on;
plot(f, alpha0, "-", 'linewidth', 2, "displayname", num2str(2) + "xRH : vecteur initial");
patch([f_opti(1) f_opti(end) f_opti(end) f_opti(1)], [0 0 1 1], "green", "facealpha", 0.1, "displayname", "study area")
pause(0.1)

% Options
n_starts = 2; % Nombre de points de départ pour algo multi-start

optionsmultistart = optimset('Algorithm', 'interior-point');  % algorithme adapté aux problèmes de programmation non linéaire.
optionsgraph = optimset('Disp', 'iter', 'PlotFcns', {'optimplotfval', 'optimplotx'}); 
% 'Disp' = 'iter' : des informations seront affichées à chaque itération de l'algorithme d'optimisation.
%  'PlotFcns' = {'optimplotfval', 'optimplotx'} : les valeurs de la fonction objectif et les variables d'optimisation seront tracées à chaque itération.
optionsmultistart = optimset(optionsmultistart, optionsgraph);

%% Optimisation

% Fonction objectif
costf = @(w, params, assembly, fluid) sum(abs(R(params, assembly, fluid, w)).^2);
objectif = @(x) build_obj(x, costf, w_opti, assembly, air, tableSilentVariables);

% Création du problème pour Global Search et Multi start
problem = createOptimProblem('fmincon', 'objective', objectif, 'x0', x0, 'Aineq', Aineq, 'bineq', bineq, ...
        'lb', lb, 'ub', ub, 'options', optionsmultistart);

%% Multi start
rng; % For reproducibility

tic;
[xoptiMs, fvalMs, eflagMs, ouputMs, solutionsMs] = run(MultiStart, problem, n_starts);
tempsMs = toc;

%% Genetic algorithm 

rng; % For reproducibility

tic;
[xoptiGa, fvalGa, exitflagGa, outputGa, populationGa, scoresGa] = ga(objectif, length(x0), Aineq, bineq, [], [], lb, ub, [], [], []);
timeGa = toc;

%% Absorption

fval0 = objectif(x0);

%% Résultats

vector_MS = struct;
vector_Ga = vector_MS;
for i = 1:n_variables
    vector_MS.(tableSilentVariables{i, 1}) = xoptiMs(i);
    vector_Ga.(tableSilentVariables{i, 1}) = xoptiGa(i);
end

alphaMs = 1 - abs(R(vector_MS, assembly, air, w)).^2;
alphaGa = 1 - abs(R(vector_Ga, assembly, air, w)).^2;
[~, fpics0] = findpeaks(alpha0, f);
[~, fpicsMs] = findpeaks(alphaMs, f);
[~, fpicsGa] = findpeaks(alphaGa, f);

%% Affichage

plot(f, alphaMs, "--", 'linewidth', 2, "displayname", num2str(2) + "xRH : opti Ms");
plot(f, alphaGa, "--", 'linewidth', 2, "displayname", num2str(2) + "xRH : opti Ga");

grid on;
legend;
xlabel('Frequences [Hz]');
ylabel("Coefficient d'absorption [1]");
ylim([0 1]);
title("Absorption générale");

function output = build_obj(x, cost_function, w, myassembly, air, tableParameters)
    % x: vector to optimize
    % cost_function whose parameters are (w, param, myassembly, air)
    % w: angular frequency
    % myassembly: the object of class Assembly to optimize
    % air: object of class Air
    
    for i = 1:length(tableParameters{:, 1}) % Pour chaque variable
        param.(tableParameters{i, 1}) = x(i); 
    end
    output = cost_function(w, param, myassembly, air);
end
costf = @(w, params, assembly, fluid) sum(abs(R(params, assembly, fluid, w)).^2);
objectif = @(x) build_obj(x, costf, w_opti, assembly, air, tableSilentVariables);
