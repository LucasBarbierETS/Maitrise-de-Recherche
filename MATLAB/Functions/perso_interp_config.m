function output = perso_interp_config(input, n)
    % Cette fonction interprète ce qui est donné en entrée à une fonction de création de
    % configuration et retourne en sortie le bon vecteur, ajusté à n.
    
    total_values = 0; % Compteur pour vérifier le nombre total de valeurs générées
    output = []; % Vecteur de sortie initialisé
    
    % Parcours des éléments d'input
    for i = 1:numel(input)
        current_elem = input{i}; % Élément actuel de l'entrée
        
        if iscell(current_elem)
            % Si l'élément est une cellule, on utilise perso_powerspace pour générer les valeurs
            if numel(current_elem) == 4
                petit = current_elem{1};
                grand = current_elem{2};
                n_val = current_elem{3};
                p = current_elem{4};
                generated_values = perso_powerspace(petit, grand, n_val, p);
                output = [output, generated_values]; % Ajout des valeurs générées au vecteur de sortie
                total_values = total_values + n_val; % Met à jour le total des valeurs générées
            else
                error('Chaque cellule doit contenir 4 éléments : [petit, grand, n, p].');
            end
        else
            % Si l'élément n'est pas une cellule, on l'ajoute directement au vecteur
            output = [output, current_elem];
            total_values = total_values + numel(current_elem); % Met à jour le total des valeurs
        end
    end
    
    % Ajuster le nombre total de valeurs pour qu'il corresponde à n
    if total_values < n
        % Si le nombre de valeurs est insuffisant, on répète la dernière valeur jusqu'à atteindre n
        last_value = output(end); % Récupère la dernière valeur
        output = [output, repmat(last_value, 1, n - total_values)]; % Complète avec la dernière valeur
    elseif total_values > n
        % Si le nombre de valeurs est trop élevé, on coupe l'excédent
        output = output(1:n); % Ne garde que les n premières valeurs
    end
end
