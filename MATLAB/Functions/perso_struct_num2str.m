function newStruct = perso_struct_num2str(inputStruct)
    % Cette fonction prend une structure en entrée et convertit tous ses champs 
    % de doubles en strings, avec une vérification pour s'assurer que la conversion est possible.
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
            newStruct.(fieldName) = perso_struct_num2str(inputStruct.(fieldName));
        elseif isa(inputStruct.(fieldName), 'double')
            % Convertir le champ en string
            newStruct.(fieldName) = num2str(inputStruct.(fieldName));
        else
            % Si ce n'est pas un double, garder le champ tel quel
            newStruct.(fieldName) = inputStruct.(fieldName);
        end
    end
end
