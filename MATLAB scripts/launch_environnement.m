%% Lancement du serveur COMSOL 

% try
%     v = mphversion;
% catch
%     try
%         addpath('C:\Program Files\COMSOL\COMSOL63\Multiphysics\mli');
%         system('start comsolmphserver');
%         mphstart;
%         import com.comsol.model.*
%         import com.comsol.model.util.*
%     catch
%     end
% end

%% Ajout des chemins d'accès

if isfolder('C:\Users\paulf\Documents\GitHub\Maitrise-de-Recherche\Functions')
    addpath('C:\Users\paulf\Documents\GitHub\Maitrise-de-Recherche\Functions')
    root = 'C:\Users\paulf\Documents\GitHub\Maitrise-de-Recherche';
elseif isfolder('C:\Users\lucas.barbier\Documents\Maitrise ETS\Répertoire GitHub')
    addpath('C:\Users\lucas.barbier\Documents\Maitrise ETS\Répertoire GitHub\Functions')
    root = 'C:\Users\lucas.barbier\Documents\Maitrise ETS\Répertoire GitHub';
end

perso_add_all_paths(root);

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
env = create_environnement(root, t, sp, hum, fmin, fmax, points, 100, 0);
handle_env = @(SPL, M) create_environnement(root, t, sp, hum, fmin, fmax, points, SPL, M);
handle_env_FEM = @(points) create_environnement(root, t, sp, hum, fmin, fmax, points, 100);

%% Fermeture du serveur COMSOL (si besoin)
% ModelUtil.disconnect