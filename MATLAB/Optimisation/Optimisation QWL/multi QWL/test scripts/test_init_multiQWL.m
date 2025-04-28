close all

addpath ("C:\Users\Utilisateur\OneDrive - ETS\CRIAQ-REAR\Maitrise LB\Classes") 
addpath ("C:\Users\Utilisateur\OneDrive - ETS\CRIAQ-REAR\Maitrise LB\Classes\QWL_classes")
addpath ("C:\Users\Utilisateur\OneDrive - ETS\CRIAQ-REAR\Maitrise LB\Functions")
addpath ("C:\Users\Utilisateur\OneDrive - ETS\CRIAQ-REAR\Maitrise LB\Optimisation\Optimisation QWL\multi QWL")

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

n = 4;
main_radius = 50e-3;
main_surface = pi*main_radius^2;
r_init = 5e-3;
shape = 'circle';
f_peak = 400;
bandwidth = 200;

% Appel de la fonction pour créer un objet multiQWL initialisé
QWL_init = init_multiQWL(n, main_surface, r_init, shape, f_peak, bandwidth, air);

%% Resultats

TM = QWL_init.transfermatrix(air, w);
Z0 = param.rho * param.c0;
Zs = TM.T11 ./ TM.T21;
alpha_model = 1 - abs((Zs - Z0)./(Zs + Z0)).^2;

%% Affichage 

figure()
plot(f, alpha_model,"-", 'Color', 'g', 'LineWidth', 1.5, 'DisplayName', 'Configuration initiale');
title("Résonateurs multi-quart d'onde initialisés");
xlabel('Fréquence (Hz)');
ylabel('Coefficient d''absorption');
grid on;

config = QWL_init.Configuration;
tableData = struct2table(config);

disp('Configuration  :');
disp(tableData);