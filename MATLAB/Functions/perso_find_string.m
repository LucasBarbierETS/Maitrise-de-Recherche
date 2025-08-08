function perso_find_string(folder, str)

    files = dir(fullfile(folder, '**', '*.m')); % Recherche récursive dans tous les sous-dossiers
    
    for i = 1:length(files)
        filePath = fullfile(files(i).folder, files(i).name); % Récupère le chemin complet du fichier
        fid = fopen(filePath, 'rt');
        if fid ~= -1
            content = fread(fid, '*char')';
            fclose(fid);
            if contains(content, str)
                disp(['Trouvé dans : ', filePath]); % Affiche le fichier où l'expression est trouvée
            end
        end
    end
end