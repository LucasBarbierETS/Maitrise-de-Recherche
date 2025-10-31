classdef AppAxes < AppComponent

    properties

        % Name
        % Container % Object de classe AppComponentContainer (parent)
        % UIObject % Objet graphique
    end

    methods
        function obj = AppAxes(ui_object, name)
            obj@AppComponent(ui_object, name)
        end

        % function resize(obj)
        % % Cette méthode ajuste les dimensions et les limites du panneau (obj.UIObject)
        % % en fonction des objets graphiques visibles contenus dans le graphe (uiaxes),
        % % en laissant une marge de 1 unité sur chaque côté.
        % 
        %     % Vérifier si obj.UIObject est de type uiaxes
        %     if isa(obj.UIObject, 'matlab.ui.control.UIAxes') && ~isempty(obj.UIObject.Children)
        %         % Obtenir les enfants visibles de l'axes
        %         visibleChildren = obj.UIObject.Children(strcmp({obj.UIObject.Children.Visible}, 'on'));
        % 
        %         % Calculer les nouvelles limites en fonction des enfants visibles
        %         xData = [];
        %         yData = [];
        % 
        %         for i = 1:length(visibleChildren)
        %             child = visibleChildren(i);
        %             if isprop(child, 'XData')
        %                 xData = [xData; child.XData(:)];
        %             end
        %             if isprop(child, 'YData')
        %                 yData = [yData; child.YData(:)];
        %             end
        %         end
        % 
        %         margin = 1; % Marge de 1 unité
        % 
        %         if ~isempty(xData)
        %             xMin = min(xData) - margin;
        %             xMax = max(xData) + margin;
        %             xlim(obj.UIObject, [xMin xMax]);
        %         end
        %         if ~isempty(yData)
        %             yMin = min(yData) - margin;
        %             yMax = max(yData) + margin;
        %             ylim(obj.UIObject, [yMin yMax]);
        %         end
        %     end
        % end

        function resize(obj)
        % Ajuste les limites d'un UIAxes en fonction des objets visibles
        % en gérant rectangles, patchs, lignes, images, textes et hggroup.
        
            ax = obj.UIObject;
            if ~isa(ax, 'matlab.ui.control.UIAxes') || isempty(ax.Children)
                return;
            end
        
            % Récupérer uniquement les enfants visibles
            kids = ax.Children;
            visMask = arrayfun(@(h) strcmpi(h.Visible,'on'), kids);
            kids = kids(visMask);
        
            % Fonction utilitaire : renvoie [xmin xmax ymin ymax] ou [] si rien
            function bbox = get_bbox(h)
                bbox = [];
                if ~isgraphics(h) || ~strcmpi(h.Visible,'on')
                    return;
                end
        
                % Si c'est un groupe : union des bbox des enfants
                if strcmpi(h.Type,'hggroup') || strcmpi(class(h), 'matlab.graphics.primitive.Group')
                    ch = h.Children;
                    for k = 1:numel(ch)
                        bbk = get_bbox(ch(k));
                        if ~isempty(bbk)
                            bbox = merge_bbox(bbox, bbk);
                        end
                    end
                    return;
                end
        
                % Essayer les cas typiques par Type
                switch lower(h.Type)
                    case {'line'}
                        xd = h.XData; yd = h.YData;
                        bbox = minmax_bbox(xd, yd);
        
                    case {'patch'}
                        % Patch: XData/YData peuvent être cell/array
                        try
                            xd = h.XData; yd = h.YData;
                        catch
                            xd = []; yd = [];
                        end
                        bbox = minmax_bbox(xd, yd);
        
                    case {'image'}
                        % Image: XData/YData définissent l’emprise en données
                        xd = h.XData; yd = h.YData;
                        % Valeurs par défaut si vides
                        if isempty(xd)
                            w = size(h.CData,2);
                            xd = [1 w];
                        end
                        if isempty(yd)
                            hgt = size(h.CData,1);
                            yd = [1 hgt];
                        end
                        bbox = [min(xd) max(xd) min(yd) max(yd)];
        
                    case {'rectangle'}
                        % Rectangle.Position = [x y w h]
                        p = h.Position;
                        bbox = [p(1) p(1)+p(3) p(2) p(2)+p(4)];
        
                    case {'text'}
                        % Text.Position est en unités "data" sur des axes
                        pos = h.Position;
                        if numel(pos) >= 2
                            % On prend au moins le point, ça suffit pour étendre les limites
                            bbox = [pos(1) pos(1) pos(2) pos(2)];
                            % Variante (si tu veux tenir compte de la taille du texte) :
                            % ext = h.Extent; % [x y w h] en unités data
                            % bbox = [ext(1) ext(1)+ext(3) ext(2) ext(2)+ext(4)];
                        end
        
                    otherwise
                        % Fallback: si l’objet a XData/YData
                        if isprop(h,'XData') && isprop(h,'YData')
                            xd = h.XData; yd = h.YData;
                            bbox = minmax_bbox(xd, yd);
                        elseif isprop(h,'Position')
                            p = h.Position;
                            if numel(p) >= 4
                                bbox = [p(1) p(1)+p(3) p(2) p(2)+p(4)];
                            end
                        end
                end
            end
        
            % Union de deux bbox [xmin xmax ymin ymax]
            function out = merge_bbox(a, b)
                if isempty(a), out = b; return; end
                if isempty(b), out = a; return; end
                out = [min(a(1),b(1)) max(a(2),b(2)) min(a(3),b(3)) max(a(4),b(4))];
            end

            function [xall, yall] = flatten_xy(xd, yd)
            % Transforme XData et YData (cell ou array) en vecteurs simples
                if iscell(xd)
                    xall = cell2mat(cellfun(@(c) c(:), xd, 'UniformOutput', false));
                else
                    xall = xd(:);
                end
            
                if iscell(yd)
                    yall = cell2mat(cellfun(@(c) c(:), yd, 'UniformOutput', false));
                else
                    yall = yd(:);
                end
            end
        
            % Calcule bbox à partir de XData/YData (vecteurs ou matrices/cell)
            function bb = minmax_bbox(xd, yd)
                bb = [];
                if isempty(xd) || isempty(yd), return; end
                try
                    xall = xd(:); yall = yd(:);
                catch
                    % xd/yd peuvent être des cellules (polygones multiples)
                    try
                        [xall, yall] = flatten_xy(xd, yd);
                    catch
                        xall = []; yall = [];
                    end
                end
                if isempty(xall) || isempty(yall)
                    return;
                end
                xall = xall(~isnan(xall)); yall = yall(~isnan(yall));
                if isempty(xall) || isempty(yall), return; end
                bb = [min(xall) max(xall) min(yall) max(yall)];
            end
        
            % Parcours des enfants → bbox globale
            bbox = [];
            for i = 1:numel(kids)
                bbk = get_bbox(kids(i));
                if ~isempty(bbk)
                    bbox = merge_bbox(bbox, bbk);
                end
            end
        
            if isempty(bbox)
                return; % rien de visible avec emprise exploitable
            end
        
            % Marges
            margin = 1; % fixe (comme avant)
            xmin = bbox(1) - margin;
            xmax = bbox(2) + margin;
            ymin = bbox(3) - margin;
            ymax = bbox(4) + margin;
        
            % Sécurité si emprise dégénérée (un seul point/texte)
            if ~(isfinite(xmin) && isfinite(xmax) && xmin < xmax)
                cx = mean([bbox(1) bbox(2)]);
                xmin = cx - 1; xmax = cx + 1;
            end
            if ~(isfinite(ymin) && isfinite(ymax) && ymin < ymax)
                cy = mean([bbox(3) bbox(4)]);
                ymin = cy - 1; ymax = cy + 1;
            end
        
            xlim(ax, [xmin xmax]);
            ylim(ax, [ymin ymax]);
        end

        function adjust_pictogram_sizes(obj)
        % Ajuste les proportions des pictogrammes pour qu'ils restent carrés visuellement,
        % quelle que soit la taille ou le rapport d’aspect du UIAxes.
        
            ax = obj.UIObject;
            if ~isvalid(ax) || ~isa(ax, 'matlab.ui.control.UIAxes')
                return;
            end
        
            % === 1. Récupère les limites des axes (coordonnées réelles) ===
            xlimVals = xlim(ax);
            ylimVals = ylim(ax);
        
            % === 2. Taille en pixels du UIAxes ===
            pixelPos = getpixelposition(ax);
            width_px  = pixelPos(3);
            height_px = pixelPos(4);
        
            % === 3. Rapport d’échelle entre les unités X/Y et les pixels ===
            % aspectRatio > 1 → X étiré → il faut compenser
            x_units_per_px = diff(xlimVals) / width_px;
            y_units_per_px = diff(ylimVals) / height_px;
            aspectRatio = x_units_per_px / y_units_per_px;
        
            % === 4. Recherche tous les pictogrammes ===
            pictos = findobj(ax, 'Type', 'hggroup');
            if isempty(pictos)
                return;
            end
        
            % === 5. Ajustement de chaque pictogramme ===
            for i = 1:numel(pictos)
                h = pictos(i);
                if ~isfield(h.UserData, 'BaseSize') || isempty(h.UserData.BaseSize)
                    continue; % ignore si taille non définie
                end
                s = h.UserData.BaseSize;
        
                % --- Ajuste la bordure ---
                if isfield(h.UserData, 'Border') && isgraphics(h.UserData.Border)
                    border = h.UserData.Border;
                    pos = get(border, 'Position');
                    cx = pos(1) + pos(3)/2;
                    cy = pos(2) + pos(4)/2;
        
                    newW = s * aspectRatio;
                    newH = s;
        
                    set(border, 'Position', [cx - newW/2, cy - newH/2, newW, newH]);
                end
        
                % --- Ajuste l’image PNG ---
                if isfield(h.UserData, 'Image') && isgraphics(h.UserData.Image)
                    img = h.UserData.Image;
                    xCenter = mean(get(img, 'XData'));
                    yCenter = mean(get(img, 'YData'));
                    xWidth = s * aspectRatio;
                    yHeight = s;
        
                    set(img, 'XData', [xCenter - xWidth/2, xCenter + xWidth/2], ...
                             'YData', [yCenter - yHeight/2, yCenter + yHeight/2]);
                end
            end
        end
    end
end