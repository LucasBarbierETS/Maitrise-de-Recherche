% close all

addpath ("C:\Users\Utilisateur\OneDrive - ETS\CRIAQ-REAR\Maitrise LB\Classes")

% Définition des paramètres des gabarits
params_notch = {@classgabarit.notch, 1000, [], 10, 0.8};
params_low_pass = {@classgabarit.low_pass, 1500, [], 10, 0.6};
params_high_pass = {@classgabarit.high_pass, 2000, [], 10, 0.4};
params_band_pass = {@classgabarit.band_pass, 1200, 100, 10, 0.7};

% Vecteur de fréquences (en rad/s)
w_vect = linspace(0, 2 * pi * 3000, 1000);  % Fréquence de 0 à 3000 Hz convertie en rad/s

% Création d'un objet classgabarit
gabarit_obj = classgabarit([], w_vect);

% Ajout des différents types de gabarits
% gabarit_obj = gabarit_obj.add_gabarit(params_notch);
gabarit_obj = gabarit_obj.add_gabarit(params_low_pass);
gabarit_obj = gabarit_obj.add_gabarit(params_high_pass);
% gabarit_obj = gabarit_obj.add_gabarit(params_band_pass);

% Construction du gabarit global
gabarit_obj.Parametres_gabarits
gabarit = gabarit_obj.build_Gabarit();

% Affichage du gabarit global
figure;
plot(w_vect / (2 * pi), gabarit);  % Convertir les fréquences en Hz pour l'affichage
xlabel('Fréquence (Hz)');
ylabel('Coefficient d''absorption');
title('Gabarit Global');
grid on;

% Suppression d'un gabarit (par exemple, le deuxième gabarit ajouté)
gabarit_obj = gabarit_obj.delete_gabarit(2);

% Reconstruction du gabarit global après suppression
gabarit = gabarit_obj.build_Gabarit();

% Affichage du nouveau gabarit global après suppression
figure;
plot(w_vect / (2 * pi), gabarit);  % Convertir les fréquences en Hz pour l'affichage
xlabel('Fréquence (Hz)');
ylabel('Coefficient d''absorption');
title('Gabarit Global après Suppression');
grid on;
