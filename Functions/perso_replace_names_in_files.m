function perso_replace_names_in_files(directory, search_pattern, replacement)
    % Remplace toutes les occurrences d'un motif de recherche par un remplacement
    % dans tous les fichiers .m d'un répertoire donné.
    
    % Liste tous les fichiers .m dans le répertoire spécifié
    files = dir(fullfile(directory, '*.m'));
    
    % Parcourt chaque fichier et effectue le remplacement
    for k = 1:length(files)
        file_path = fullfile(files(k).folder, files(k).name);
        replace_in_file(file_path, search_pattern, replacement);
    end
end

function replace_in_file(file_path, search_pattern, replacement)
    % Ouvre le fichier et lit son contenu
    fid = fopen(file_path, 'r', 'n', 'UTF-8');
    if fid == -1
        error('Cannot open file %s for reading.', file_path);
    end
    file_contents = fread(fid, '*char')';
    fclose(fid);
    
    % Effectue le remplacement des motifs
    new_contents = regexprep(file_contents, search_pattern, replacement);
    
    % Écrit le nouveau contenu dans le fichier
    fid = fopen(file_path, 'w', 'n', 'UTF-8');
    if fid == -1
        error('Cannot open file %s for writing.', file_path);
    end
    fwrite(fid, new_contents, 'char');
    fclose(fid);
end
