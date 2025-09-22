%% Lancement du serveur COMSOL 

try
    v = mphversion;
catch
    try
        system('start comsolmphserver');
        addpath('C:\Program Files\COMSOL\COMSOL63\Multiphysics\mli');
        mphstart;
        import com.comsol.model.*
        import com.comsol.model.util.*
    catch
    end
end

%% Ajout des chemins d'accès

try
    addpath('C:\Users\paulf\Documents\GitHub\Maitrise-de-Recherche\Functions')
    root = 'C:\Users\paulf\Documents\GitHub\Maitrise-de-Recherche';
    perso_add_all_paths(root);
catch
end

try
    addpath('C:\Users\lucas.barbier\Documents\Maitrise ETS\Répertoire GitHub\Functions')
    root = 'C:\Users\lucas.barbier\Documents\Maitrise ETS';
    perso_add_all_paths([root, '\Répertoire GitHub']);
catch
end

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
% points = 100;

% Niveau sonore
env = create_environnement(root, t, sp, hum, fmin, fmax, points);
handle_env = @(SPL, M) create_environnement(root, t, sp, hum, fmin, fmax, points, SPL, M);
handle_env_FEM = @(points) create_environnement(root, t, sp, hum, fmin, fmax, points);

%% Fermeture du serveur COMSOL (si besoin)
% ModelUtil.disconnect