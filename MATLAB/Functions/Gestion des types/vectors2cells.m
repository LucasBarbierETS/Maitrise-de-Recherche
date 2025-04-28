function S_out = vectors2cells(S_in)
    % Fonction pour convertir récursivement les vecteurs numériques dans une structure en cellules de cell arrays
    % Les chaînes de caractères et autres types de données sont laissés intacts.

    % Initialiser la structure de sortie comme une copie de la structure d'entrée
    S_out = S_in;

    % Obtenir les noms des champs de la structure d'entrée
    fields = fieldnames(S_in);

    % Parcourir tous les champs de la structure
    for i = 1:numel(fields)
        currentField = fields{i};

        % Vérifier si le champ est une structure
        if isstruct(S_in.(currentField))
            % Appeler récursivement la fonction pour traiter la sous-structure
            S_out.(currentField) = vectors2cells(S_in.(currentField));
        
        % Vérifier si le champ est un vecteur numérique
        elseif isnumeric(S_in.(currentField)) && isvector(S_in.(currentField))
            % Convertir le vecteur numérique en cellules de cell array
            S_out.(currentField) = num2cell(S_in.(currentField));
        
        % Conserver les chaînes de caractères et les cell arrays de chaînes de caractères tels quels
        elseif iscell(S_in.(currentField))
            % Parcourir les éléments du cell array
            for j = 1:numel(S_in.(currentField))
                % Si l'élément est une structure, appeler récursivement la fonction
                if isstruct(S_in.(currentField){j})
                    S_out.(currentField){j} = vectors2cells(S_in.(currentField){j});
                end
            end
        end
    end
end
