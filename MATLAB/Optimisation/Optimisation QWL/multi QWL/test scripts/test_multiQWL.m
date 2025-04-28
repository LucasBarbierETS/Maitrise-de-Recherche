close all;

addpath ("C:\Users\Utilisateur\OneDrive - ETS\CRIAQ-REAR\Maitrise LB\Classes") 
addpath ("C:\Users\Utilisateur\OneDrive - ETS\CRIAQ-REAR\Maitrise LB\Classes\QWL_classes")
addpath ("C:\Users\Utilisateur\OneDrive - ETS\CRIAQ-REAR\Maitrise LB\Functions")

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

%% Initialisation de la l'objet

main_radius = 50e-3;
main_surface = pi*main_radius^2;
r_init = 5e-3;
shape = 'circle';
f_peak = 200;
bandwidth = 100;

multiQWL = init_multiQWL(2, main_surface, r_init, shape, f_peak, bandwidth, air);

% Calcul de la matrice de transfert
TM = multiQWL.transfermatrix(air, w);

% Calcul de l'impédance caractéristique et du coefficient d'absorption
Z0 = param.rho * param.c0;
Zs = TM.T11./TM.T21;
phi = sum(multiQWL.Configuration.Radius.^2)/main_radius^2;
alpha_model = 1 - abs((Zs - Z0)./(Zs + Z0)).^2; 


figure(1);
subplot(1,2,1);
plot(f,real(Zs./Z0));
xlabel("frequence (Hz)");
ylabel("Résistance normalisée");
% ylim([0 3]);
xlim([100 3000]);
grid();

subplot(1,2,2);
plot(f,imag(Zs./Z0));
xlabel("frequence (Hz)");
ylabel("Réactance normalisée");
% ylim([-20 10]);
xlim([100 3000]);
grid()

% Tracé du modèle obtenu et du gabarit sur la même figure
figure(2);
plot(f, alpha_model, 'LineWidth', 1.5, 'DisplayName', 'Modèle Obtenu');
title("Résonateur quart d'onde optimisé");
xlabel('Fréquence (Hz)');
ylabel('Coefficient d''absorption');
% ylim([0, 1]);
legend('Location', 'Best');
grid on;