function parametres_config_multiQWL(config, n, shape)

    % Affiche un tableau des parametres pour la solution associée à config
    
    % Vérifier que la longueur de config est un multiple de 3
    if mod(length(config), 3) ~= 0
        error('La longueur de config doit être un multiple de 3.');
    end

    % Réorganiser le vecteur config en une matrice 3xN
    config_matrice_nx3 = transpose(reshape(config, n, []));
    
    % Arrondir les valeurs au centième de millimètre
    config_matrice_rounded = round(config_matrice_nx3 * 1e3, 2) / 1e3;

    % Convertir les valeurs arrondies en chaînes de caractères avec format fixe
    config_strings = arrayfun(@(x) sprintf('%.3f', x), config_matrice_rounded, 'UniformOutput', false);

    % Afficher le nombre de résonateurs et la forme avec fprintf
    fprintf('\nParamètres de la configuration\n\n');
    fprintf('Nombre de résonateurs : %d\n', n);
    fprintf('Forme : %s\n\n', shape);

    % Afficher la matrice des paramètres des résonateurs en trois colonnes
    fprintf('Paramètres des résonateurs :\n\n');

    % Spécificateurs de format pour centrer les colonnes
    formatSpec = '%-23s%-23s%-23s\n';

    % Titres centrés
    fprintf(formatSpec, 'Rayon principal (mm)', 'Rayon interne (mm)', 'Longueur (mm)');

    % Ligne de séparation centrée
    fprintf('%s\n', repmat('-', 1, 23*3 + 2*2*23));

    % Paramètres centrés et non scientifiques
    fprintf(formatSpec, config_strings{:});

    fprintf('\n');
end
