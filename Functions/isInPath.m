function status = isInPath(folder)
    % Vérifie si le dossier est déjà dans le chemin MATLAB.
    % Retourne true si le dossier est déjà dans le chemin, sinon false.
    
    % Obtenez tous les chemins actuels
    currentPaths = strsplit(path, pathsep);
    
    % Vérifiez si le dossier est dans la liste des chemins
    status = any(strcmp(folder, currentPaths));
end