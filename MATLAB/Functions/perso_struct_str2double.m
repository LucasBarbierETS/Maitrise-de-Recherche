function newStruct = perso_struct_str2double(inputStruct)
    % Cette fonction prend une structure en entrée et tente de convertir tous 
    % ses champs de strings en doubles, avec une vérification pour s'assurer que la conversion est possible.
    % Si un champ est lui-même une structure, elle est traitée récursivement.
    
    % Initialiser la nouvelle structure vide
    newStruct = struct();
    
    % Obtenir les noms des champs de la structure
    fieldNames = fieldnames(inputStruct);
    
    % Parcourir chaque champ de la structure
    for i = 1:numel(fieldNames)
        fieldName = fieldNames{i};
        
        % Vérifier si le champ est une structure
        if isstruct(inputStruct.(fieldName))
            % Appel récursif pour convertir les champs de la structure imbriquée
            newStruct.(fieldName) = perso_struct_str2double(inputStruct.(fieldName));
        elseif ischar(inputStruct.(fieldName)) || isstring(inputStruct.(fieldName))
            % Tenter de convertir le champ en double
            convertedValue = str2double(inputStruct.(fieldName));
            
            % Vérifier si la conversion a réussi (str2double retourne NaN en cas d'échec)
            if ~isnan(convertedValue)
                newStruct.(fieldName) = convertedValue;
            else
                % Garder le champ tel quel si la conversion échoue
                newStruct.(fieldName) = inputStruct.(fieldName);
            end
        else
            % Si ce n'est pas une chaîne de caractères, garder le champ tel quel
            newStruct.(fieldName) = inputStruct.(fieldName);
        end
    end
end
