function distance_matrix = perso_distance_metric(x, lb, ub)

    % On calcule la distance normalisée min-max entre deux points du domaine. 

    % On effectue une normalisation uniforme des deux points de
    % fonctionnement comparés
    x_norm = (x - lb) ./ (ub - lb);
   
    N_points = size(x, 4);

    % On initialise la matrice des distances des points
    distance_matrix = zeros(N_points, N_points);

    % On calcule la distance euclidenne sur les points normalisés
    for i = 1:N_points
        for p = 1:i
            % Extraction du point normalisé courant
            xi = x_norm(:, :, :, i);
            xp = x_norm(:, :, :, p);
    
            % Calcul des distances par rapport à tous les autres points
            dist = sqrt(sum((xi - xp).^2, "all"));
            % Calcul de la distance euclidienne pour chaque paire
            distance_matrix(i, p) = dist;
            distance_matrix(p, i) = dist;
        end
    end
end

