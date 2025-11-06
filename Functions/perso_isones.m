function tf = perso_isones(x)
    
    % Le cas vide -> faux automatiquement
    if isempty(x)
        tf = false;
        return;
    end

    % Vérification que c'est un vecteur (ligne ou colonne)
    if ~isvector(x)
        tf = false;
        return;
    end

    % Vérification que tous les éléments valent 1
    tf = all(x == 1);
end
