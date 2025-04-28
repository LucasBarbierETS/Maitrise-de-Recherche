function perso_add_all_paths(rootFolder)
    % Fonction pour ajouter tous les chemins de sous-dossiers dans le répertoire racine
    % en évitant d'ajouter des chemins déjà présents.

    % Vérifiez si l'argument rootFolder est un dossier valide
    if ~isfolder(rootFolder)
        error('Le dossier spécifié n''existe pas.');
    end
    
    % Ajouter le dossier racine au chemin, s'il n'est pas déjà ajouté
    if ~isInPath(rootFolder)
        addpath(rootFolder);
    end
    
    % Obtenez une liste de tous les fichiers et dossiers dans le dossier racine
    files = dir(rootFolder);
    
    % Parcourir chaque élément dans le dossier
    for i = 1:length(files)
        % Ignorer les dossiers '.' et '..'
        if strcmp(files(i).name, '.') || strcmp(files(i).name, '..')
            continue;
        end
        
        % Construire le chemin complet de l'élément actuel
        currentPath = fullfile(rootFolder, files(i).name);
        
        % Si l'élément est un dossier, l'ajouter au chemin et appeler récursivement
        if isfolder(currentPath)
            if ~isInPath(currentPath)
                addpath(currentPath);
            end
            % Appel récursif pour parcourir les sous-dossiers
            perso_add_all_paths(currentPath);
        end
    end
end
