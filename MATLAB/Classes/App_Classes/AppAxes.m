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

        function resize(obj)
        % Cette méthode ajuste les dimensions et les limites du panneau (obj.UIObject)
        % en fonction des objets graphiques visibles contenus dans le graphe (uiaxes),
        % en laissant une marge de 1 unité sur chaque côté.
    
            % Vérifier si obj.UIObject est de type uiaxes
            if isa(obj.UIObject, 'matlab.ui.control.UIAxes') && ~isempty(obj.UIObject.Children)
                % Obtenir les enfants visibles de l'axes
                visibleChildren = obj.UIObject.Children(strcmp({obj.UIObject.Children.Visible}, 'on'));
                
                % Calculer les nouvelles limites en fonction des enfants visibles
                xData = [];
                yData = [];
    
                for i = 1:length(visibleChildren)
                    child = visibleChildren(i);
                    if isprop(child, 'XData')
                        xData = [xData; child.XData(:)];
                    end
                    if isprop(child, 'YData')
                        yData = [yData; child.YData(:)];
                    end
                end
    
                margin = 1; % Marge de 1 unité
    
                if ~isempty(xData)
                    xMin = min(xData) - margin;
                    xMax = max(xData) + margin;
                    xlim(obj.UIObject, [xMin xMax]);
                end
                if ~isempty(yData)
                    yMin = min(yData) - margin;
                    yMax = max(yData) + margin;
                    ylim(obj.UIObject, [yMin yMax]);
                end
            end
        end
    end
end