classdef perso_ManagedLayout < handle
    % ManagedLayout regroupe des tracés dans UNE seule fenêtre nommée,
    % avec layout auto, context menu (Détacher / Fermer), et absorption de figures.

    properties (SetAccess=private)
        Name            (1,1) string
        Fig             matlab.ui.Figure
        Tile            matlab.graphics.layout.TiledChartLayout
        AxesList        matlab.graphics.axis.Axes = matlab.graphics.axis.Axes.empty
    end

    properties (Constant, Access=private)
        TagPrefix = "ManagedLayout__";
    end

    methods
        function obj = perso_ManagedLayout(name)
            arguments
                name (1,1) string
            end
            obj.Name = name;

            % Réutiliser la fenêtre si elle existe déjà
            tag = obj.tagForName(name);
            old = findall(0,'Type','figure','Tag',tag);
            if ~isempty(old) && isvalid(old(1))
                obj.Fig = old(1);
                tl = findobj(obj.Fig,'Type','tiledlayout');
                if isempty(tl) || ~isvalid(tl(1))
                    clf(obj.Fig);
                    obj.Tile = tiledlayout(obj.Fig,1,1);
                else
                    obj.Tile = tl(1);
                end
                % Récup axes existants
                obj.AxesList = findobj(obj.Fig,'Type','axes')';
            else
                obj.Fig = figure('Name',char(name), 'NumberTitle','off', ...
                                 'Tag',char(tag), 'HandleVisibility','on', ...
                                 'IntegerHandle','off', 'WindowStyle','normal'); % undocked by default
                obj.Tile = tiledlayout(obj.Fig,1,1);
            end
        end

        function ax = nextAxes(obj, titleStr)
            if nargin < 2, titleStr = ""; end
            obj.ensureLayout();
        
            % Assainir la liste
            obj.AxesList = obj.AxesList(isvalid(obj.AxesList));
            n = numel(obj.AxesList);
            cap = obj.currentCapacity();
        
            if cap < n + 1
                % Pas assez de place : on fabrique un axes "placeholder" dans une figure cachée,
                % on l'ajoute à la liste puis on reflow -> la grille est agrandie à n+1.
                phFig = figure('Visible','off','IntegerHandle','off');
                phAx  = axes('Parent', phFig);                 
                obj.AxesList(end+1) = phAx;                    % on anticipe le +1
                obj.reflow();                                  % reconstruit layout pour n+1
                ax = obj.AxesList(end);                        % le nouvel axes dans la fenêtre gérée
                if strlength(titleStr) > 0, title(ax, titleStr); end
                return
            end
        
            % Il reste de la place : on peut utiliser nexttile
            ax = nexttile(obj.Tile);
            obj.decorateAxes(ax, titleStr);
            obj.AxesList(end+1) = ax;
        end

        function cap = currentCapacity(obj)
            if isempty(obj.Tile) || ~isvalid(obj.Tile)
                cap = 0; return;
            end
            gs = obj.Tile.GridSize; % [nrow ncol]
            cap = prod(gs);
        end

        function addPlot(obj, plotFcnHandle, titleStr)
            % Ajoute un panneau et exécute une fonction de tracé:
            % plotFcnHandle doit être un handle @(ax) ...
            arguments
                obj
                plotFcnHandle (1,1) function_handle
                titleStr string = ""
            end
            ax = obj.nextAxes(titleStr);
            plotFcnHandle(ax);
        end

        function addFromFigure(obj, f)
            % Absorbe une figure existante: copie les axes (enfants) dans un nouveau tile et ferme la figure source
            if nargin<2 || isempty(f), f = gcf; end
            if ~ishandle(f) || ~strcmp(get(f,'Type'),'figure')
                error('addFromFigure: input must be a figure handle');
            end
            srcAxes = findall(f,'Type','axes');
            if isempty(srcAxes)
                close(f); return;
            end
            % On crée un tile par axes trouvé (ordre visuel approximatif)
            for k = numel(srcAxes):-1:1
                axSrc = srcAxes(k);
                axDst = obj.nextAxes(string(axSrc.Title.String));
                % Copier les enfants (courbes, images, etc.)
                copyobj(allchild(axSrc), axDst);
                % Copier propriétés de base utiles
                axDst.XLim = axSrc.XLim; axDst.YLim = axSrc.YLim; axDst.ZLim = axSrc.ZLim;
                axDst.XScale = axSrc.XScale; axDst.YScale = axSrc.YScale; axDst.ZScale = axSrc.ZScale;
                axDst.Box = axSrc.Box;
                axDst.XLabel.String = axSrc.XLabel.String;
                axDst.YLabel.String = axSrc.YLabel.String;
                axDst.ZLabel.String = axSrc.ZLabel.String;
                axDst.Title.String  = axSrc.Title.String;
                try colormap(axDst, colormap(axSrc.Parent)); catch, end
                % Légendes: si présentes, les recréer
                lg = legend(axSrc);
                if ~isempty(lg) && isvalid(lg)
                    legend(axDst, 'show');
                end
            end
            close(f);
        end

        function popOut(obj, ax)
            % Détache un panneau -> nouvelle figure (déplacement)
            if nargin < 2 || isempty(ax), ax = gca; end
            validateattributes(ax, {'matlab.graphics.axis.Axes'}, {'scalar'});
            if ~isvalid(ax), return; end

            % Nouvelle figure
            fNew = figure('Name','Panneau détaché','NumberTitle','off','WindowStyle','normal');
            axNew = axes('Parent', fNew);
            % Déplacer le contenu (on peut aussi "copier" si on veut dupliquer)
            copyobj(allchild(ax), axNew);
            % Copier propriétés utiles
            axNew.XLim = ax.XLim; axNew.YLim = ax.YLim; axNew.ZLim = ax.ZLim;
            axNew.XScale = ax.XScale; axNew.YScale = ax.YScale; axNew.ZScale = ax.ZScale;
            axNew.Box = ax.Box;
            axNew.XLabel.String = ax.XLabel.String;
            axNew.YLabel.String = ax.YLabel.String;
            axNew.ZLabel.String = ax.ZLabel.String;
            axNew.Title.String  = ax.Title.String;
            try colormap(axNew, colormap(ax.Parent)); catch, end

            % Retirer du layout
            obj.closeAxes(ax, false); % false = ne pas supprimer enfants (déjà copiés)
        end

        function closeAxes(obj, ax, deleteChildren)
            % Ferme un panneau (tile) et refait le layout
            if nargin < 3, deleteChildren = true; end
            if nargin < 2 || isempty(ax), ax = gca; end
            validateattributes(ax, {'matlab.graphics.axis.Axes'}, {'scalar'});
            if ~isvalid(ax), return; end

            % Retirer de la liste
            obj.AxesList = obj.AxesList(isvalid(obj.AxesList));
            idx = find(obj.AxesList==ax, 1);
            if ~isempty(idx)
                obj.AxesList(idx) = [];
            end

            if deleteChildren
                delete(ax);
            else
                % Supprimer l'axes sans se soucier des enfants (déjà déplacés)
                if isvalid(ax); delete(ax); end
            end
            obj.reflow();
        end

        function closeAll(obj)
            if isvalid(obj.Fig); close(obj.Fig); end
            obj.AxesList = matlab.graphics.axis.Axes.empty;
        end

        function setDocked(obj, tf)
            % Dock / Undock la fenêtre principale (entière)
            if tf
                obj.Fig.WindowStyle = 'docked';
            else
                obj.Fig.WindowStyle = 'normal';
            end
        end
    end

    methods (Access=private)
        function ensureLayout(obj)
            if isempty(obj.Tile) || ~isvalid(obj.Tile)
                clf(obj.Fig);
                obj.Tile = tiledlayout(obj.Fig,1,1);
            end
        end

        function reflow(obj)
            % Conserver uniquement les axes valides
            obj.AxesList = obj.AxesList(isvalid(obj.AxesList));
            ax = obj.AxesList;
            n  = numel(ax);
        
            if n == 0
                clf(obj.Fig);
                obj.Tile = tiledlayout(obj.Fig, 1, 1);
                obj.AxesList = matlab.graphics.axis.Axes.empty;
                drawnow;
                return;
            end
        
            % Grille quasi carrée
            ncol = ceil(sqrt(n));
            nrow = ceil(n / ncol);
        
            % 1) BACKUP : copier chaque axes dans une figure temporaire invisible
            tmpFig  = figure('Visible','off','IntegerHandle','off');
            tmpAxes = gobjects(1,n);
            for k = 1:n
                tmpAxes(k) = copyobj(ax(k), tmpFig);  % copie l'axes + tous ses enfants/propriétés
            end
        
            % 2) Recréer le layout cible
            clf(obj.Fig);
            obj.Tile = tiledlayout(obj.Fig, nrow, ncol);
        
            % 3) Restituer : copier chaque axes backup dans le tiledlayout
            newList = gobjects(1,n);
            for k = 1:n
                % Parent = obj.Tile => MATLAB place l'axes dans le "next tile"
                newList(k) = copyobj(tmpAxes(k), obj.Tile);
        
                % Redéposer le menu contextuel (détacher/fermer)
                obj.decorateAxes(newList(k), string(newList(k).Title.String));
            end
        
            % 4) Nettoyage
            close(tmpFig);
            obj.AxesList = newList;
            drawnow;
        end

        function decorateAxes(obj, ax, titleStr)
            if strlength(titleStr)>0
                title(ax, titleStr);
            end
            % Menu contextuel: Pop-out & Close
            cm = uicontextmenu(obj.Fig);
            uimenu(cm,'Text','Détacher dans une nouvelle fenêtre', ...
                      'MenuSelectedFcn',@(s,e) obj.popOut(ax));
            uimenu(cm,'Separator','on','Text','Fermer ce panneau', ...
                      'MenuSelectedFcn',@(s,e) obj.closeAxes(ax,true));
            ax.UIContextMenu = cm;
        end
    end

    methods (Static, Access=private)
        function tag = tagForName(name)
            tag = perso_ManagedLayout.TagPrefix + name;
        end
    end
end
