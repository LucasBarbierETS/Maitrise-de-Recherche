%% Lancement du serveur COMSOL (si disponible)
% addpath('C:\Program Files\COMSOL\COMSOL63\Multiphysics\mli');
% mphstart;
% import com.comsol.model.*
% import com.comsol.model.util.*

%% Ajout des chemins d'accès
% root_A = 'E:\Montréal 2023 - 2025\Maitrise LB';
root_B = 'C:\Users\lucas.barbier\Documents\Maitrise ETS\Répertoire GitHub';

% addpath([root_A, '\MATLAB\Functions'])
addpath([root_B, '\Functions'])
% perso_add_all_paths([root_A, '\MATLAB']);
perso_add_all_paths(root_B);

%% Importation des mises à jour depuis GitHub
% system('git pull');

%% Création de l'environnement

% Milieu 
t = 23; % Température
sp = 100800; % Pression atmosphérique
hum = 50; % Humidité relative

% Support fréquentiel
fmin = 1;
fmax = 5000;
points = 5000;

% Niveau sonore
env = create_environnement(t, sp, hum, fmin, fmax, points);
handle_env = @(dB, M) create_environnement(t, sp, hum, fmin, fmax, points, dB, M);

%% Fermeture du serveur COMSOL (si besoin)
% ModelUtil.disconnect