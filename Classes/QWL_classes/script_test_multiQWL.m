% Script pour tester la classe classmultiQWL

% Nettoyer l'espace de travail
clc;

% Importation de tous les chemins d'accès
addpath ('C:\Users\Utilisateur\OneDrive - ETS\CRIAQ-REAR\Maitrise LB\Functions') 
add_all_paths('C:\Users\Utilisateur\OneDrive - ETS\CRIAQ-REAR\Maitrise LB');

% Création de l'environnement
[air, w] = create_environnement(23, 100800, 50, 1, 4000, 200);

% Définir la configuration pour un multiQWL
config.Dimensions = [0.05 0.05; 0.03 0.03; 0.04 0.04];
disp(config.Dimensions);
config.Lengths = [1.2, 0.8, 1.0];                               
config.Shapes = repmat("rectangle", 1, size((config.Lengths), 2));       

% Créer l'objet multiQWL
multiQWL = classmultiQWL(config);

% Propriétés de l'air
To = 23;
Po = 100800;
Hr = 50;
air = classair(To, Po, Hr);
param = air.parameters;

% Définir la gamme de fréquences (en rad/s)
w = linspace(0, 2000 * 2 * pi, 2000);

% Calculer les matrices de transfert et l'impédance de surface
TM = multiQWL.transfermatrix(air, w);
Zs = multiQWL.surfaceImpedance(air, w);
alpha = multiQWL.alpha(air, w);
fpeak = multiQWL.alpha_peak(air, w);

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
legend show;
