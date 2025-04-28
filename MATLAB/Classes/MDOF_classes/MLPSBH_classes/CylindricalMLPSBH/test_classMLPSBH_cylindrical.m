close all
clc

% Importation de tous les chemins
addpath ('C:\Users\Utilisateur\OneDrive - ETS\CRIAQ-REAR\Maitrise LB\Functions') 
add_all_paths('C:\Users\Utilisateur\OneDrive - ETS\CRIAQ-REAR\Maitrise LB');

% Création de l'environnement
[air, w] = create_environnement(23, 100800, 50, 1, 2000, 200);

% configuration initiale (validation)

Rext = 30e-3;           % Radius of the sample 
Rint = 30e-3;           % First perforated area radiuslucas
T = 100e-3;             % Total length
N = 4;                  % Number of feature units
rend = 3e-3;            % End radius
r = 0.1e-3;             % Holes radius
t = 0.2e-3;             % MPPs thickness
phi = 1;                % Perforation ratio
n = 1;                  % Radius profil function's order

ct = (T - (N * t)) / N;   % cavity thickness

lambda_QWL = T * 4;
freq_QWL = air.parameters.c0 / lambda_QWL;

MLPSBH = classMLPSBH_Cylindrical(classMLPSBH_Cylindrical.create_config(Rext, Rint, {Rint, rend, n}, phi, r, t, ct, 'Hankel', 'Bezançon', true, N));

%% Absorption

figure()
plot(w / (2*pi), MLPSBH.alpha(air, w))
xline(freq_QWL);
legend("classMPP Cylindrical", "fréquence 1/4 d'onde")
xlabel("frequence (Hz)")
ylabel("absorption")
ylim([0,1])
title("Modèle Cylindrical MLPSBH Configuration C.1")