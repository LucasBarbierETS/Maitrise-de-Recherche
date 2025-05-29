function perso_plot_profil_shape(lengths)
    % Vérifier que les longueurs sont un vecteur non vide
    if isempty(lengths)
        error('Le vecteur de longueurs ne peut pas être vide');
    end

    % Initialiser la figure
    figure;
    hold on; % Maintenir tous les dessins sur la même figure

    % Calcul de la largeur maximale
    max_length = max(lengths);

    % Normaliser les longueurs par rapport à la largeur maximale
    normalized_lengths = lengths / max_length;

    % Nombre de blocs
    n = length(normalized_lengths);

    % Espacement entre les blocs
    spacing = 1;

    % Dessiner chaque bloc
    for i = 1:n
        % La longueur normalisée du bloc
        len = normalized_lengths(i);

        % Calcul des coordonnées x et y pour le bloc
        x = [-len/2, len/2, len/2, -len/2];  % Les coins du bloc
        y = [spacing*i - spacing/2, spacing*i - spacing/2, spacing*i + spacing/2, spacing*i + spacing/2];  % Position verticale

        % Tracer le bloc
        fill(x, y, 'b', 'EdgeColor', 'k');  % 'b' pour bleu, 'k' pour bordure noire
    end

    % Ajuster les axes
    xlim([-1, 1]);  % Limites x normalisées entre -1 et 1
    ylim([0, (n + 1) * spacing]);  % Limites y en fonction du nombre de blocs
end