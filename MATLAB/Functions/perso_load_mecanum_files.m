function dataStruct = perso_load_mecanum_files(folderPath)
    files = dir(fullfile(folderPath, '*.txt'));  % Trouver tous les fichiers .txt
    dataStruct = struct();  % Initialisation de la structure
    
    for i = 1:length(files)
        filePath = fullfile(files(i).folder, files(i).name);
        
        % Déterminer le nom de la variable à partir du nom du fichier
        tokens = split(files(i).name, '_');
        if length(tokens) < 3
            continue; % S'assurer qu'il y a au moins deux underscores
        end
        varName = matlab.lang.makeValidName(tokens{2}); % Nettoyer le nom
        
        % Lire le fichier en remplaçant les virgules par des points
        fileContent = fileread(filePath);
        fileContent = strrep(fileContent, ',', '.'); % Corriger la notation scientifique
        
        % Écrire temporairement un fichier avec le format corrigé
        tempFile = fullfile(folderPath, 'temp_file.txt');
        fid = fopen(tempFile, 'w');
        fwrite(fid, fileContent);
        fclose(fid);
        
        % Lire les données
        opts = detectImportOptions(tempFile, 'Delimiter', '\t', 'DecimalSeparator', '.', 'HeaderLines', 0, 'ReadVariableNames', true, 'VariableNamingRule', 'preserve');
        dataTable = readtable(tempFile, opts);
        
        for col = 1:width(dataTable)
            fieldName = matlab.lang.makeValidName(dataTable.Properties.VariableNames{col});
            dataStruct.(varName).(fieldName) = dataTable{:, col};
        end
        
        % Supprimer le fichier temporaire
        delete(tempFile);
    end
end