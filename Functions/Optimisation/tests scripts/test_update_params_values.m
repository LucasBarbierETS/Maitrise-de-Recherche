addpath ("C:\Users\Utilisateur\OneDrive - ETS\CRIAQ-REAR\Maitrise LB\Functions\Optimisation")

% Définition de la structure params
params.a = [0.2, 0.1, 1];
params.b = [0.5, 0.3, 2];
params.c = [1, 0.5, 5];

% Affichage de la structure params avant la mise à jour
disp('Params avant la mise à jour :');
disp(params);

% Définition des nouvelles valeurs
new_values = [0.3, 0.7, 2.5];

% Appel de la fonction pour mettre à jour les valeurs dans params
params = update_params_values(params, new_values);

% Affichage de la structure params après la mise à jour
disp('Params après la mise à jour :');
disp(params);
