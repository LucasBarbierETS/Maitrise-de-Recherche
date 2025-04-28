function perso_load(dossier)
    % Liste tous les fichiers dans le dossier
    files = dir(fullfile(dossier, '*.mat'));
    
    % Parcours de chaque fichier
    for i = 1:length(files)
        % Charge le fichier
        fileName = files(i).name;
        filePath = fullfile(dossier, fileName);
        
        % Charge la variable à partir du fichier .mat
        loadedData = load(filePath);
        
        % Récupère le nom de la variable dans le fichier
        [~, varName, ~] = fileparts(fileName);
        
        % Attribue la variable à l'espace de travail
        if isfield(loadedData, 'varValue')
            assignin('base', varName, loadedData.varValue);
            fprintf('Variable "%s" chargée depuis "%s".\n', varName, fileName);
        else
            assignin('base', varName, loadedData);
            fprintf('Variable "%s" chargée depuis "%s".\n', varName, fileName);
        end
    end
end
