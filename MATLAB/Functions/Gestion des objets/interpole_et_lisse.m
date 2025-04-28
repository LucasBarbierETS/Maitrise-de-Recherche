function [x_smooth, y_smooth] = interpole_et_lisse(x, y, numPoints, smoothingSpan)
    % Interpole et lisse des données de coordonnées
    %
    % Arguments:
    % x            : Vecteur des coordonnées x
    % y            : Vecteur des coordonnées y
    % numPoints    : Nombre de points pour l'interpolation régulière
    % smoothingSpan: Fenêtre de lissage (span) pour la méthode de lissage
    %
    % Sorties:
    % x_smooth     : Coordonnées x lissées
    % y_smooth     : Coordonnées y lissées

    % Vérifier que x et y ont la même longueur
    if length(x) ~= length(y)
        error('Les vecteurs x et y doivent avoir la même longueur.');
    end

    % Gérer les valeurs dupliquées dans x
    [x_unique, idx] = unique(x);
    y_unique = y(idx);

    % Générer une grille x régulière pour l'interpolation
    xq = linspace(min(x_unique), max(x_unique), numPoints);

    % Interpoler les données y en fonction de x sur la grille xq
    yq = interp1(x_unique, y_unique, xq, 'pchip');  % 'pchip' conserve mieux les formes

    % Lissage des données interpolées
    y_smooth = smooth(yq, smoothingSpan, 'loess');  % 'loess' pour un lissage local
    x_smooth = xq;  % x reste régulier après interpolation
end
