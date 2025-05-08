function x_norm = perso_normalize_input_point(x, lb, ub)
    % Tout point x du domaine délimité pour l'optimisation est représenté par 
    % une matrice de taille N (nombre de plaques par solution) * NV (nb de variables
    % codant une plaque) * NS (nombre de solutions). 
    % Pour chaque colonne x(:, i, :), la distance doit être centrée et réduite à partir des limites
    % définies pour le type de variable.
    x_norm = (x - lb) ./ (ub - lb);
end