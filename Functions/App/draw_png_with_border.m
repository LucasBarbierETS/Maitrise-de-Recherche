function h = draw_png_with_border(ax, x, y, imgPath, tag, varargin)
% DESSINE UN PICTOGRAMME PNG AVEC BORDURE CARRÉE
%
% Syntaxe :
%   h = draw_png_with_border(ax, x, y, imgPath, tag)
%   h = draw_png_with_border(ax, x, y, imgPath, tag, 'Size', 0.5, 'EdgeColor', 'k')
%
% Entrées :
%   ax      : axe cible (uiaxes ou axes)
%   x, y    : position du centre du pictogramme
%   imgPath : chemin complet du fichier PNG
%   tag     : étiquette du groupe (ex. 'picto_none')
%
% Paramètres optionnels :
%   'Size'      : taille nominale du pictogramme (défaut = 0.5)
%   'EdgeColor' : couleur du contour (défaut = 'k')
%   'LineWidth' : épaisseur du contour (défaut = 1.5)

    % === Analyse des paramètres ===
    p = inputParser;
    addParameter(p, 'Size', 0.5, @(v) isnumeric(v) && isscalar(v) && v > 0);
    addParameter(p, 'EdgeColor', 'k', @(v) (ischar(v) || isnumeric(v)));
    addParameter(p, 'LineWidth', 1.5, @(v) isnumeric(v) && isscalar(v) && v > 0);
    parse(p, varargin{:});

    s = p.Results.Size;
    edgeColor = p.Results.EdgeColor;
    lw = p.Results.LineWidth;

    hold(ax, 'on');

    % === Vérifie l'existence du fichier ===
    if ~isfile(imgPath)
        warning('Image non trouvée : %s', imgPath);
        h = [];
        return;
    end

    % === Lecture du PNG ===
    img = flipud(imread(imgPath));

    % === Définition des coordonnées d’affichage ===
    xRange = [x - s/2, x + s/2];
    yRange = [y - s/2, y + s/2];

    % === Affichage du PNG ===
    hImg = image(ax, ...
        'CData', img, ...
        'XData', xRange, ...
        'YData', yRange, ...
        'HitTest', 'off');

    % Corrige l’orientation verticale si nécessaire
    set(ax, 'YDir', 'normal');

    % === Création du contour carré ===
    borderSize = s * 1.05;
    hBorder = rectangle(ax, ...
        'Position', [x - borderSize/2, y - borderSize/2, borderSize, borderSize], ...
        'EdgeColor', edgeColor, ...
        'LineWidth', lw, ...
        'FaceColor', 'none', ...
        'HitTest', 'off');

    % Place le contour derrière l’image
    uistack(hBorder, 'bottom');

    % === Crée le groupe graphique cliquable ===
    h = hggroup('Parent', ax, 'Tag', tag);
    set([hBorder hImg], 'Parent', h);

    % === Stocke les métadonnées utiles ===
    h.UserData.Border = hBorder;
    h.UserData.Image  = hImg;
    h.UserData.BaseSize = s;

    % === Active le clic sur le groupe ===
    set(h, 'HitTest', 'on', 'PickableParts', 'all');
end