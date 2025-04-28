function [x_fill, y_fill] = perso_colorAboveThreshold(x, y, seuil)
    % Trouver les indices où y est au-dessus de la valeur seuil
    indices_above_threshold = find(y > seuil);

    % Extraire les points de la courbe qui sont au-dessus de la valeur seuil
    x_above_threshold = x(indices_above_threshold);
    y_above_threshold = y(indices_above_threshold);

    % Créer les données pour la région à colorier
    x_fill = [x_above_threshold, fliplr(x_above_threshold)];
    y_fill = [y_above_threshold, seuil * ones(size(y_above_threshold))];
end
