function data = structToCellArray(myStruct)
    % Extraire les champs dse la structure
    fields = fieldnames(myStruct);
    numFields = numel(fields);
    
    % Initialiser un cell array avec les données structurées
    data = cell(numFields, 2);
    for i = 1:numFields
        fieldName = fields{i};
        fieldValue = myStruct.(fieldName);
        
        % Gérer les cas où fieldValue est un vecteur ou un tableau
        if isnumeric(fieldValue) && numel(fieldValue) > 1
            % Si fieldValue est un vecteur ou un tableau, le convertir en ligne de cellules
            data{i, 1} = fieldName;
            data{i, 2} = strjoin(arrayfun(@num2str, fieldValue, 'UniformOutput', false), ',');
        else
            data{i, 1} = fieldName;
            data{i, 2} = fieldValue;
        end
    end
end
