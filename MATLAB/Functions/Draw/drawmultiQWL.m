function drawmultiQWL(params)

    n = length(params)/3;
    R = params(1:n);
    r = params(n+1:2*n);
    L = params(2*n+1:end);
    main_radius = sqrt(sum(R.^2));

    % Nombre de résonateurs
    n = length(r);

    % Diamètre principal
    main_diameter = main_radius * 2;

    % Espacement équitable entre les résonateurs
    total_space = main_diameter - sum(2 * r);
    interval = total_space / (n + 1);

    % Coordonnées des points de la vue en coupe
    x_points = zeros(4, n);
    y_points = zeros(4, n);

    % Coordonnées des coins de chaque résonateur
    current_x = interval; % Espacement à gauche du premier résonateur
    for i = 1:n
        x_points(:, i) = [current_x; current_x + 2*r(i); current_x + 2*r(i); current_x]; % Rectangles orientés verticalement
        y_points(:, i) = [max(L); max(L); max(L) - L(i); max(L) - L(i)]; % Aligner avec l'origine vertical et faire descendre les résonateurs

        current_x = current_x + 2*r(i) + interval;  % Mettre à jour la position x pour le prochain résonateur
    end

    % Dessiner la vue en coupe avec la fonction patch
    patch(x_points, y_points, 'b', 'EdgeColor', 'k', 'FaceAlpha', 0.7);
    xlabel('Diamètre principal');
    ylabel('Position verticale');
    title('Vue en Coupe des Résonateurs');
    ylim([0, max(L)]);  % Ajuster la hauteur du dessin en fonction de la longueur maximale
    xlim([0, main_diameter]);  % Ajuster les limites de l'axe horizontal
    grid on;
end