
close all
addpath("C:\Users\Utilisateur\Documents\Maitrise_ETS\code_calcul_clément\Bell_EPC_App\Files\Classes")

% Propriétés de l'air
To = 23;
Po = 100800;
Hr = 50;
air = classair(To, Po, Hr);
param = air.parameters;

% Fréquence
f = 1:1000;
w = 2*pi*f;

% Paramètres du résonateur
radius = 0e-3;  
main_radius = 50e-3;
phi = radius^2/main_radius^2;
f_peak = 600; % Hz
bandwidth = 50;
alpha_max = 1;
f_min = f_peak - bandwidth/2;
f_max = f_peak + bandwidth/2;

% Tracé du gabarit
alpha_g = gabarit_QWL(w, f_peak, bandwidth, alpha_max);

% Optimisation des paramètres
[r_opti, L_opti] = optimised_QWL(main_radius, radius, 'circle', f_peak, bandwidth, alpha_max, air, w);

% Création de l'objet QWL avec les paramètres optimisés
QWL_opti = classQWL(main_radius, r_opti, L_opti, 'circle');

% Calcul de la matrice de transfert
TM = QWL_opti.transferMatrix(air, w);

% Calcul de l'impédance caractéristique et du coefficient d'absorption
Z0 = param.rho * param.c0;
Zs = TM.T11./TM.T21;
phi = r_opti^2/main_radius^2;
alpha_model = 1 - abs((Zs/phi - Z0)./(Zs/phi + Z0)).^2;

% Tracé du modèle obtenu et du gabarit sur la même figure
figure;
plot(f, alpha_model, 'LineWidth', 1.5, 'DisplayName', 'Modèle Obtenu');
hold on;
plot(f, alpha_g, 'LineWidth', 1, 'DisplayName', 'Gabarit', 'Color', [0.8, 0.2, 0.2], 'LineStyle', '--');
title("Résonateur quart d'onde optimisé");
xlabel('Fréquence (Hz)');
ylabel('Coefficient d''absorption');
ylim([0, 1]);
legend('Location', 'Best');
grid on;
