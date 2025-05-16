function perso_ouvrir_lien_Obsidian(obsidianLink)
    % Crée un fichier HTML temporaire avec un lien cliquable pour ouvrir une note Obsidian.
    %
    % Syntaxe :
    %   perso_ouvrir_lien_Obsidian(obsidianLink)
    %
    % Entrée :
    %   obsidianLink : Chaîne de caractères contenant le lien Obsidian (ex : 'obsidian://open?vault=MonVault&file=MaNote').
    %
    % Exemple d'utilisation :
    %   perso_ouvrir_lien_Obsidian('obsidian://open?vault=MonVault&file=MaNote');

    % Vérifier que l'entrée est une chaîne de caractères
    if ~ischar(obsidianLink)
        error('L''entrée doit être une chaîne de caractères.');
    end

    % Vérifier que le lien commence par 'obsidian://'
    if ~startsWith(obsidianLink, 'obsidian://')
        error('Le lien doit commencer par ''obsidian://''.');
    end

    % Créer le contenu HTML avec un lien cliquable
    htmlContent = sprintf('<html><body><a href="%s">Ouvrir la note dans Obsidian</a></body></html>', obsidianLink);

    % Créer un fichier HTML temporaire
    tempFile = [tempname, '.html']; % Génère un nom de fichier temporaire
    fid = fopen(tempFile, 'w'); % Ouvre le fichier en mode écriture
    if fid == -1
        error('Impossible de créer le fichier HTML temporaire.');
    end
    fprintf(fid, '%s', htmlContent); % Écrit le contenu HTML dans le fichier
    fclose(fid); % Ferme le fichier

    % Ouvrir le fichier HTML dans le navigateur par défaut
    web(tempFile, '-browser');

    % Afficher un message de confirmation
    disp(['Fichier HTML temporaire créé : ', tempFile]);
    disp(['Ouverture de la note Obsidian : ', obsidianLink]);
end
