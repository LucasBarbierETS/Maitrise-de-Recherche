close all

addpath ("C:\Users\Utilisateur\OneDrive - ETS\CRIAQ-REAR\Maitrise LB\Functions\Optimisation")

% Définition de la configuration avec des variables muettes
config = struct(...
    'Radius', {{'a', 0.5, 1.0}}, ...
    'Length', {{'b', 'b', 'b'}}, ...
    'Shape', {{'circle', 'circle', 'circle'}}, ...
    'TotalSurface', 10 ...
);

% Définition des valeurs des paramètres
params = struct('a', 0.2, 'b', 0.5);

% Évaluation de la configuration en remplaçant les variables muettes par leurs valeurs
config_evaluated = replace_fields(config, params);

% Affichage de la configuration évaluée
disp(params);
disp(config);
disp(config_evaluated);

