addpath 'C:\Users\Utilisateur\OneDrive - ETS\CRIAQ-REAR\Maitrise LB\Classes'

%% environnement

% Propriétés de l'air
To = 23;
Po = 100800;
Hr = 50;
air = classair(To, Po, Hr);
param = air.parameters;

% Définir la gamme de fréquences (en rad/s)
w = linspace(0, 2000 * 2 * pi, 2000);

%% configuration

config = struct();

% Dimensions des cavités (par exemple, longueur et largeur pour les cavités rectangulaires)
config.cavities_dimensions = [0.05 0.05; 0.1 0.1]; % Exemple de deux cavités

% Longueurs des cavités
config.cavities_length = [0.15; 0.25]; % Longueurs en mètres

% Forme des cavités (par exemple, 'rectangle', 'circle', etc.)
config.cavities_shape = ["rectangle"; "rectangle"];

% Forme des perforations des plaques (par exemple, 'circle', 'square', etc.)
config.plates_perforations_shape = ["circle"; "circle"];

% Porosité des plaques
config.plates_porosity = [0.05; 0.08]; % Porosité en pourcentage (0 à 1)

% Épaisseur des plaques
config.plates_thickness = [0.001; 0.002]; % Épaisseur en mètres

% Correction de longueur des plaques
config.plates_correction_length = [0; 0]; % Correction en mètres

% Dimensions des perforations des plaques
config.plates_perforations_dimensions = [0.001; 0.001]; % Dimensions en mètres

disp(config);

% Créer l'objet MDOF
MDOF = classMDOF(config);

%% résultats

% Calculer les matrices de transfert et l'impédance de surface
TM = MDOF.transfermatrix(air, w);
Zs = MDOF.surfaceImpedance(air, w);
alpha = MDOF.alpha(air, w);
fpeak = MDOF.alpha_peak(air, w);

% Afffielicher les paramètres de la configuration
disp('Paramètres de la configuration :');
parametres_table = table(config.cavities_dimensions, config.cavities_length, config.cavities_shape, ...
    config.plates_perforations_shape, config.plates_porosity, config.plates_thickness, ...
    config.plates_correction_length, config.plates_perforations_dimensions);
parametres_table.Properties.VariableNames = {'cavities dimensions', 'cavities length', ...
    'cavities shape', 'plates perforations shape', 'plates porosity', ...
    'plates thickness', 'plates_correction_length', 'plates_perforations_dimensions'};
parametres_table.Properties.RowNames = {'Cavité 1', 'Cavité 2'};
disp(parametres_table);

% Tracer les résultats
figure;
subplot(3,1,1);
plot(w / (2 * pi), abs(Zs));
title('Impédance de surface');
xlabel('Fréquence (Hz)');
ylabel('Impédance (Ohms)');

subplot(3,1,2);
plot(w / (2 * pi), alpha);
title("Coefficient d'absorption");
xlabel('Fréquence (Hz)');
ylabel('\alpha');

subplot(3,1,3);
plot(w / (2 * pi), TM.T11, 'DisplayName', 'T11');
hold on;
plot(w / (2 * pi), TM.T12, 'DisplayName', 'T12');
plot(w / (2 * pi), TM.T21, 'DisplayName', 'T21');
plot(w / (2 * pi), TM.T22, 'DisplayName', 'T22');
title('Matrice de transfert');
xlabel('Fréquence (Hz)');
ylabel('Coefficient');

