function perso_ouvrir_lien_Zotero(zoteroLink)
     % Crée un fichier HTML temporaire avec un lien cliquable pour ouvrir un lien Zotero.
    %
    % Syntaxe :
    %   ouvrirLienZoteroHTML(zoteroLink)
    %
    % Entrée :
    %   zoteroLink : Chaîne de caractères contenant le lien Zotero (ex : 'zotero://open-pdf/library/items/UF5M6PI2').
    %
    % Exemple d'utilisation :
    %   ouvrirLienZoteroHTML('zotero://open-pdf/library/items/UF5M6PI2');

    % Vérifier que l'entrée est une chaîne de caractères
    if ~ischar(zoteroLink)
        error('L''entrée doit être une chaîne de caractères.');
    end

    % Vérifier que le lien commence par 'zotero://'
    if ~startsWith(zoteroLink, 'zotero://')
        error('Le lien doit commencer par ''zotero://''.');
    end

    % Créer le contenu HTML avec un lien cliquable
    htmlContent = sprintf('<html><body><a href="%s">Ouvrir le PDF dans Zotero</a></body></html>', zoteroLink);

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
    disp(['Ouverture du lien Zotero : ', zoteroLink]);
end