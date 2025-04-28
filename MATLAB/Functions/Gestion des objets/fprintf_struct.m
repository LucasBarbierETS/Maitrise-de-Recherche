function fprintf_struct(s)
    % Cette fonction permet d'afficher le contenu d'un objet de type structure à l'aide de la fonction native fprintf

    % Vérifier si l'entrée est une structure
    if ~isstruct(s)
        error('L''entrée doit être une structure.');
    end
    
    % Récupérer les noms des champs de la structure
    fields = fieldnames(s);
    
    % Boucle à travers chaque champ pour afficher son contenu
    for i = 1:length(fields)
        fieldName = fields{i};
        fieldValue = s.(fieldName); % Récupérer la valeur du champ
        
        % Afficher le nom du champ
        fprintf('%s: ', fieldName);
        
        % Vérifier le type de données et formater l'affichage
        if isnumeric(fieldValue)
            fprintf('%.4f ', fieldValue); % Pour les valeurs numériques
        elseif ischar(fieldValue) || isstring(fieldValue)
            fprintf('"%s" ', fieldValue); % Pour les chaînes de caractères
        elseif iscell(fieldValue)
            % Pour les cellules, afficher chaque élément
            for j = 1:length(fieldValue)
                fprintf('"%s" ', fieldValue{j});
            end
        else
            fprintf('%s ', mat2str(fieldValue)); % Pour d'autres types, utiliser mat2str
        end
        
        fprintf('\n'); % Nouvelle ligne après chaque champ
    end
end
