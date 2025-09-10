function export_struct_to_CSV(myStruct, filename)
    % Convertir la structure en cell array
    data = structToCellArray(myStruct);
    
    % Convertir le cell array en un tableau avec deux colonnes
    tableData = cell2table(data, 'VariableNames', {'Field', 'Value'});
    
    % Écrire le tableau dans un fichier CSV
    writetable(tableData, filename, 'Delimiter', ',');
end

function data = structToCellArray(myStruct)
    % Extraire les champs de la structure
    fields = fieldnames(myStruct);
    numFields = numel(fields);
    
    % Initialiser un cell array avec les données structurées
    data = cell(numFields, 2);
    for i = 1:numFields
        fieldName = fields{i};
        fieldValue = myStruct.(fieldName);
        data{i, 1} = fieldName;
        data{i, 2} = fieldValue;
    end
end
