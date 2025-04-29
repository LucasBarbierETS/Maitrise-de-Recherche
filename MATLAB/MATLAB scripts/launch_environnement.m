%% Chemins d'accès

% addpath 'C:\Users\Utilisateur\OneDrive - ETS\CRIAQ-REAR\Maitrise LB\MATLAB' 
% add_all_paths('C:\Users\Utilisateur\OneDrive - ETS\CRIAQ-REAR\Maitrise LB\MATLAB');

addpath 'E:\Montréal 2023 - 2025\Maitrise LB\MATLAB\Functions' 
perso_add_all_paths('E:\Montréal 2023 - 2025\Maitrise LB\MATLAB');

% addpath 'C:\Users\AQ99270\ETS\GRAM - TD - GTO365 - CRIAQ-REAR - CRIAQ-REAR\Maitrise LB\MATLAB'
% add_all_paths('C:\Users\AQ99270\ETS\GRAM - TD - GTO365 - CRIAQ-REAR - CRIAQ-REAR\Maitrise LB\MATLAB')

%% Importation des mises à jour depuis GitHub
system('git pull');

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
dB = 130;
env = create_environnement(t, sp, hum, fmin, fmax, points, dB);