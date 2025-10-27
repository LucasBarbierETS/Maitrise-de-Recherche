function newStruct = perso_struct_str2double(inputStruct)
    % Cette fonction prend une structure en entrée et tente de convertir tous 
    % ses champs de strings ou char arrays en doubles, avec une vérification
    % pour s'assurer que la conversion est possible.
    % Si un champ est lui-même une structure, elle est traitée récursivement.
    
    newStruct = struct();
    fieldNames = fieldnames(inputStruct);
    
    for i = 1:numel(fieldNames)
        fieldName = fieldNames{i};
        value = inputStruct.(fieldName);
        
        if isstruct(value)
            % Cas récursif : structure imbriquée
            newStruct.(fieldName) = perso_struct_str2double(value);
            
        elseif isstring(value) || ischar(value)
            % Cas : string ou char
            if ischar(value) && size(value,1) > 1
                % Cas particulier : char array multi-ligne
                % On convertit chaque ligne en nombre
                cellLines = cellstr(value);              % Chaque ligne devient une cellule
                convertedValues = str2double(cellLines); % Conversion en nombres
                if all(~isnan(convertedValues))
                    newStruct.(fieldName) = convertedValues(:); % Vecteur colonne
                else
                    newStruct.(fieldName) = value;
                end
            else
                % Cas standard : chaîne unique
                convertedValue = str2double(value);
                if ~isnan(convertedValue)
                    newStruct.(fieldName) = convertedValue;
                else
                    newStruct.(fieldName) = value;
                end
            end
            
        else
            % Autres types (numériques, logiques, cellules, etc.)
            newStruct.(fieldName) = value;
        end
    end
end
