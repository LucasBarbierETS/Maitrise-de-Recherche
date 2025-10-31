function perso_replace_string(folder, oldStr, newStr)
% REMPLACE une chaîne de caractères dans tous les fichiers .m d'un dossier
%
% Syntaxe :
%   perso_replace_string(folder, oldStr, newStr)
%
% Exemple :
%   perso_replace_string('C:\MonProjet', 'app.Types', 'app.TypeDefs')

    % Recherche récursive de tous les fichiers .m
    files = dir(fullfile(folder, '**', '*.m'));
    nbChanges = 0;

    for i = 1:length(files)
        filePath = fullfile(files(i).folder, files(i).name);

        % Lire le contenu du fichier
        fid = fopen(filePath, 'rt');
        if fid == -1
            warning('Impossible d’ouvrir : %s', filePath);
            continue;
        end
        content = fread(fid, '*char')';
        fclose(fid);

        % Remplacer la chaîne
        if contains(content, oldStr)
            newContent = strrep(content, oldStr, newStr);

            % Sauvegarder le fichier seulement si le contenu change
            if ~strcmp(content, newContent)
                fid = fopen(filePath, 'wt');
                fwrite(fid, newContent);
                fclose(fid);

                nbChanges = nbChanges + 1;
                fprintf('🔁 Modifié : %s\n', filePath);
            end
        end
    end

    fprintf('\n✅ %d fichier(s) modifié(s).\n', nbChanges);
end
