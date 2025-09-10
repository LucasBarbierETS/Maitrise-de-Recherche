function search_string_in_files(string, path)
    % Vérifie si les chemins d'accès sont fournis
    if nargin < 2
        error('Veuillez fournir la chaîne de recherche et les chemins d''accès.');
    end

    % Ouvre un fichier HTML pour écrire les résultats
    resultsFile = 'search_results.html';
    fid = fopen(resultsFile, 'w');
    
    % Écrit l'en-tête HTML
    fprintf(fid, '<html><head><title>Résultats de Recherche</title></head><body>');
    fprintf(fid, '<h1>Résultats de la recherche pour "%s"</h1>', string);
    
    % Parcourt chaque chemin d'accès
    for i = 1:length(path)
        filePath = path(i);
        
        % Vérifie si le fichier existe
        if exist(filePath, 'file')
            % Ouvre le fichier en lecture
            fileID = fopen(filePath, 'r');
            lineNumber = 0;
            found = false; % Indique si la chaîne a été trouvée
            
            % Lit le fichier ligne par ligne
            while ~feof(fileID)
                lineNumber = lineNumber + 1;
                lineContent = fgetl(fileID);
                
                % Recherche la chaîne dans la ligne
                if contains(lineContent, string)
                    found = true;
                    % Écrit un lien hypertexte vers l'endroit où la chaîne est trouvée
                    fprintf(fid, '<p><a href="file://%s#L%d">Trouvé dans %s à la ligne %d</a></p>', ...
                            filePath, lineNumber, filePath, lineNumber);
                end
            end
            
            fclose(fileID);
            
            if found
                fprintf(fid, '<h2>Occurrences trouvées dans le fichier: %s</h2>', filePath);
            end
        else
            fprintf(fid, '<p>Le fichier %s n''existe pas.</p>', filePath);
        end
    end
    
    % Écrit la fin du document HTML
    fprintf(fid, '</body></html>');
    fclose(fid);
    
    % Ouvre le fichier HTML dans le navigateur par défaut
    web(resultsFile, '-browser');
end
