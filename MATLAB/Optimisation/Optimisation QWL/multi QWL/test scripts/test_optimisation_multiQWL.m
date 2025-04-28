close all;

addpath ("C:\Users\Utilisateur\OneDrive - ETS\CRIAQ-REAR\Maitrise LB\Classes") 
addpath ("C:\Users\Utilisateur\OneDrive - ETS\CRIAQ-REAR\Maitrise LB\Classes\QWL_classes")
addpath ("C:\Users\Utilisateur\OneDrive - ETS\CRIAQ-REAR\Maitrise LB\Functions")
addpath ("C:\Users\Utilisateur\OneDrive - ETS\CRIAQ-REAR\Maitrise LB\Optimisation\Optimisation QWL\multi QWL")
addpath ("C:\Users\Utilisateur\OneDrive - ETS\CRIAQ-REAR\Maitrise LB\Functions\Gestion des types")

%% Environnement

% Propriétés de l'air
To = 23;
Po = 100800;
Hr = 50;
air = classair(To, Po, Hr);
param = air.parameters;

% Fréquence
f = 1:1000;
w = 2 * pi * f;

%% Initialisation de l'objet

main_radius = 50e-3;
main_surface = pi*main_radius^2;
r_init = 5e-3;
shape = 'circle';
f_peak = 400;
bandwidth = 200;

multiQWL = init_multiQWL(2, main_surface, r_init, shape, f_peak, bandwidth, air);
%% Création du gabarit

gabarit = classgabarit({@classgabarit.band_pass, f_peak, bandwidth, 15, 1}).build_gabarit(w);

%% Création des variables muettes et des bornes inf et sup

params = {};
params.a = [0.0040 2e-3 1e-2]; % Radius 1
params.b = [0.0040 2e-3 1e-2]; % Radius 2
params.c = [0.5764 0.2 1]; % Length 1
params.d = [0.3459 0.2 1]; % Length 2

%% Attribution des variables dans la configuration

config = vectors2cells(multiQWL.Configuration);
config.Radius(1) = {'a'};
config.Radius(2) = {'b'};
config.Length(1) = {'c'};
config.Length(2) = {'d'};

%% Calcul de la réponse optimisée 

% Réponse optimisée 

num_starts = 20; 
multiQWL_opti = optimise_multiQWL(config, params, gabarit, air, w, num_starts);

%% Résultats de la configuration optimisée et de la configuration initiale

% Configuration initiale

TM = multiQWL.transfermatrix(air, w);
Z0 = param.rho * param.c0;
Zs = TM.T11 ./ TM.T21;
alpha_model = 1 - abs((Zs - Z0)./(Zs + Z0)).^2;

% configuration optimisée

TM_opti = multiQWL_opti.transfermatrix(air, w);
Z0 = param.rho * param.c0;
Zs_opti = TM_opti.T11 ./ TM_opti.T21;
alpha_model_opti = 1 - abs((Zs_opti - Z0)./(Zs_opti + Z0)).^2;

% Tracé du modèle obtenu et du gabarit sur la même figure

figure()
hold on 
plot(f, alpha_model,"-", 'Color', 'g', 'LineWidth', 1.5, 'DisplayName', 'Configuration initiale');
plot(f, alpha_model_opti,"-", 'Color', 'r', 'LineWidth', 1.5, 'DisplayName', 'Configuration optimisée');
plot(f, gabarit,"--", 'Color', 'b', 'LineWidth', 1.5, 'DisplayName', 'Gabarit');
title("Optimisation des solutions multi 1/4 d'onde");
xlabel('Fréquence (Hz)');
ylabel('Coefficient d''absorption');
grid on;

% Table des paramètres de la configuration optimisée et de la configuration optimale

% Définir les deux structures à comparer
config1 = multiQWL.Configuration;
config2 = multiQWL_opti.Configuration;

% Créer une table pour la première configuration
tableData1 = struct2table(config1);

% Créer une table pour la deuxième configuration
tableData2 = struct2table(config2);

% Afficher les tables
disp('Configuration initale :');
disp(tableData1);

disp('Configuration optimisée :');
disp(tableData2);


