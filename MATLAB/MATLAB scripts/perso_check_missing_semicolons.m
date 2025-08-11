function perso_check_missing_semicolons(directory)
    
    % Récupérer tous les fichiers .m dans le répertoire et ses sous-répertoires
    files = get_m_files(directory);
    
    % Analyser chaque fichier avec checkcode
    for i = 1:length(files)
        checkcode(files{i});
    end

end

function files = get_m_files(directory)
    % Cette fonction récupère tous les fichiers .m dans le répertoire et sous-répertoires
    files = {};
    files_in_dir = dir(fullfile(directory, '**', '*.m'));
    
    for i = 1:length(files_in_dir)
        files{end+1} = fullfile(files_in_dir(i).folder, files_in_dir(i).name);
    end
end
