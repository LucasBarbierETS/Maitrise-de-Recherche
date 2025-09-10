addpath ("C:\Users\Utilisateur\OneDrive - ETS\CRIAQ-REAR\Maitrise LB\Functions\Gestion des types") 

% Exemple de configuration avec des vecteurs numériques, des chaînes de caractères et des sous-structures
config = struct();
config.Radius = [1, 2, 3];
config.Length = [4, 5, 6];
config.Shape = 'circle';
config.Colors = {'red', 'green', 'blue'};
config.OtherField = 10;
config.SubStruct = struct('SubRadius', [7, 8, 9], 'SubShape', 'square');

% Convertir les vecteurs numériques en cellules de cell arrays de manière récursive
config_converted = vectors2cells(config);

% Afficher la configuration mise à jour
disp(config);
disp(config.SubStruct);
disp(config_converted);
disp(config_converted.SubStruct);