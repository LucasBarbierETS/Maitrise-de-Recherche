function S_out = replace_fields(S_in, params)

    % Variables d'entrée : 
    % - S_in (struct) : la structure associée à la configuration S_in.radius = "a"
    % - params (struct) la structure contenant les valeurs associées au variables muettes : params.a(1) = 0.1

    % Cette fonction remplace les variables muettes dans la structure S_in par leurs valeurs réelles
    % en utilisant les paramètres fournis dans la structure params.

    S_out = recursiveReplace(S_in, params);
end

function S_out = recursiveReplace(S_in, params)

    % Fonction récursive pour remplacer les variables muettes dans la structure

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
            S_out.(currentField) = recursiveReplace(S_in.(currentField), params);
        
        % Vérifier si le champ est un cell array
        elseif iscell(S_in.(currentField))
            % Initialiser une cellule temporaire pour stocker les valeurs converties
            tempCell = S_in.(currentField);
            
            % Parcourir les éléments du cell array
            for j = 1:numel(S_in.(currentField))
                % Si l'élément est une chaîne de caractères et correspond à une clé dans 'params', remplacer la valeur
                if ischar(S_in.(currentField){j}) && isfield(params, S_in.(currentField){j})
                    tempCell{j} = params.(S_in.(currentField){j}){1};
                else
                    % Conserver l'élément original s'il ne correspond pas à une variable muette
                    tempCell{j} = S_in.(currentField){j};
                end
            end
            
            % Convertir le cell array en vecteur si tous les éléments sont des numériques
            if all(cellfun(@isnumeric, tempCell))
                S_out.(currentField) = cell2mat(tempCell);
            else
                S_out.(currentField) = tempCell;
            end
        
        % Vérifier si le champ est une chaîne de caractères et correspond à une clé dans 'params'
        elseif ischar(S_in.(currentField)) && isfield(params, S_in.(currentField))
            % Remplacer la valeur de la chaîne de caractères par la valeur correspondante dans 'params'
            S_out.(currentField) = params.(S_in.(currentField)).Value;
        
        % Conserver les champs qui sont des vecteurs ou des scalaires
        elseif isnumeric(S_in.(currentField)) && (isscalar(S_in.(currentField)) || isvector(S_in.(currentField)))
            S_out.(currentField) = S_in.(currentField);

        % Sinon, conserver la valeur initiale
        else
            S_out.(currentField) = S_in.(currentField);
        end
    end
end
