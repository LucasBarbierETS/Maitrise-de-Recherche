function h = draw_wave_arrow(app, ax, direction)
    % Affiche une flèche PNG dans un UIAxes
    % direction : 'vertical' ou 'horizontal'

    % === 1. Limites actuelles de l'axes ===
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

    % === 5. Proportions de l'image ===
    [imgH, imgW, ~] = size(img);
    aspect = imgH / imgW;

    % === 6. Placement automatique à l'intérieur de l'UIAxes ===
    hold(ax, 'on');

    % Détecter les pictogrammes existants pour placer la flèche juste à côté
    pictos = findobj(ax, 'Type', 'hggroup');
    if ~isempty(pictos)
        % prendre les XData/YData des images déjà tracées
        xMaxPic = -Inf; xMinPic = Inf;
        yMaxPic = -Inf; yMinPic = Inf;
        for i = 1:numel(pictos)
            if isfield(pictos(i).UserData, 'Image') && isgraphics(pictos(i).UserData.Image)
                imgData = pictos(i).UserData.Image;
                xMaxPic = max([xMaxPic, max(imgData.XData)]);
                xMinPic = min([xMinPic, min(imgData.XData)]);
                yMaxPic = max([yMaxPic, max(imgData.YData)]);
                yMinPic = min([yMinPic, min(imgData.YData)]);
            end
        end
    else
        xMinPic = xlimOrig(1);
        xMaxPic = xlimOrig(2);
        yMinPic = ylimOrig(1);
        yMaxPic = ylimOrig(2);
    end

    switch lower(direction)
        case 'vertical'
            % flèche au-dessus des pictos existants
            xCenter = mean(xlimOrig);
            w = width/5;
            h = w * aspect;
            yBottom = min(yMaxPic + 0.01*height, ylimOrig(2) - h); % toujours visible
            xRange = [xCenter - w/2, xCenter + w/2];
            yRange = [yBottom, yBottom + h];

        case 'horizontal'
            % flèche à gauche des pictos existants
            yCenter = mean(ylimOrig);
            h = height/5;
            w = h / aspect;
            xRight = max(xMinPic - 0.01*width, xlimOrig(1)); % toujours visible
            xRange = [xRight - w, xRight];
            yRange = [yCenter - h/2, yCenter + h/2];
    end

    % === 7. Affichage avec transparence ===
    hImg = image(ax, ...
        'CData', img, ...
        'AlphaData', alpha, ...
        'XData', xRange, ...
        'YData', yRange, ...
        'HitTest', 'off');

    % === 8. Groupe hggroup pour facilité de manipulation ===
    h = hggroup('Parent', ax, 'Tag', ['wave_arrow_' direction]);
    set(hImg, 'Parent', h);
    h.UserData.Image = hImg;

    % === 9. Orientation Y correcte ===
    if isprop(ax, 'YDir') && ~strcmpi(ax.YDir, 'normal')
        ax.YDir = 'normal';
    end
end