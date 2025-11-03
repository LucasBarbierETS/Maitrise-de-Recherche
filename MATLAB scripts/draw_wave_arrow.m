function h = draw_wave_arrow(app, ax, direction)
    % Affiche une flèche PNG dans un UIAxes
    % direction : 'vertical' ou 'horizontal'

    % === 1. Limites actuelles de l'axe ===
    xlimOrig = ax.XLim;
    ylimOrig = ax.YLim;
    width  = diff(xlimOrig);
    height = diff(ylimOrig);

    % === 2. Chemin du PNG ===
    imgPath = fullfile(app.EnvApp.Root, 'Functions', 'App', ...
        'Fonctions d''affichages des sous élements', ...
        'Pictogrammes', 'fleche_front_d''onde.png');

    % === 3. Lecture de l'image et canal alpha ===
    [img, ~, alpha] = imread(imgPath);
    img = im2double(img);
    if isempty(alpha)
        alpha = ones(size(img,1), size(img,2));
    else
        alpha = im2double(alpha);
    end

    % === 4. Rotation selon direction ===
    switch lower(direction)
        case 'vertical'
            img = rot90(img, 1); % 90° antihoraire
            alpha = rot90(alpha, 1);
        case 'horizontal'
            % inchangé
    end

    % === 5. Dimensions de l'image ===
    [imgH, imgW, ~] = size(img);
    aspect = imgH / imgW;

    % === 6. Recherche des groupes existants ===
    allChildren = ax.Children;
    groups = allChildren(strcmp({allChildren.Type}, 'hggroup'));

    % Filtrer les groupes selon leur Tag
    validGroups = groups(~contains({groups.Tag}, 'picto_None'));

    hold(ax, 'on');

    switch lower(direction)
        case 'horizontal'
            % Flèche à gauche basée sur le premier groupe
            if isempty(validGroups)
                % Aucun groupe existant, position par défaut
                yCenter = mean(ylimOrig);
                h = height / 5;
                w = h / aspect;
                xRight = xlimOrig(1) + w;  % À gauche
                xRange = [xRight - w, xRight];
                yRange = [yCenter - h/2, yCenter + h/2];
            else
                firstGroup = validGroups(end); % En haut de la pile
                grpChildren = firstGroup.Children;
                refGraphic = grpChildren(1); % Premier graphique du groupe
                xData = refGraphic.XData;
                yData = refGraphic.YData;
                w_ref = diff(xData);
                h_ref = diff(yData);

                % Taille de la flèche = largeur du premier graphique
                w = w_ref;
                h = w * aspect;

                % Position = à gauche du premier graphique
                xRight = xData(1) - 2 * w_ref;  % 1× la taille du graphique + 1× la taille de la flèche
                yCenter = mean(yData);
                xRange = [xRight, xRight + w];
                yRange = [yCenter - h/2, yCenter + h/2];
            end

            % Affichage
            hImg = image(ax, 'CData', img, 'AlphaData', alpha, ...
                'XData', xRange, 'YData', yRange, 'HitTest', 'off');
            h = hggroup('Parent', ax, 'Tag', 'wave_arrow_horizontal');
            set(hImg, 'Parent', h);
            h.UserData.Image = hImg;

        case 'vertical'
            % Flèche au-dessus de chaque groupe
            h = gobjects(numel(validGroups), 1);
            for k = 1:numel(validGroups)
                grp = validGroups(k);
                grpChildren = grp.Children;
                refGraphic = grpChildren(1);
                xData = refGraphic.XData;
                yData = refGraphic.YData;
                w_ref = diff(xData);
                h_ref = diff(yData);

                % Taille de la flèche = hauteur du premier graphique
                hArrow = h_ref;
                wArrow = hArrow / aspect;

                % Position = au-dessus du graphique
                xCenter = mean(xData);
                yTop = max(yData) + h_ref; % distance = hauteur du graphique
                xRange = [xCenter - wArrow/2, xCenter + wArrow/2];
                yRange = [yTop, yTop + hArrow];

                % Affichage
                hImg = image(ax, 'CData', img, 'AlphaData', alpha, ...
                    'XData', xRange, 'YData', yRange, 'HitTest', 'off');
                h(k) = hggroup('Parent', ax, 'Tag', ['wave_arrow_vertical_' num2str(k)]);
                set(hImg, 'Parent', h(k));
                h(k).UserData.Image = hImg;
            end
    end

    % === 7. Orientation Y correcte ===
    if isprop(ax, 'YDir') && ~strcmpi(ax.YDir, 'normal')
        ax.YDir = 'normal';
    end
end
