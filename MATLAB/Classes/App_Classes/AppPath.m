classdef AppPath < handle

    properties

        Content  % Cell array pour contenir les sous-éléments (AppElement, AppSubelement, AppJunction)
    end

    methods
       
        function obj = AppPath(varargin)

            % varargin = {content, ...

            if nargin > 1
                
                obj.Content = varargin{1}; 
            end
        end
        
        function add_to_path(obj, content, varargin)
        % Cette fonction permet d'insérer un objet de classe dans le contenant courant 
            
            % On ajoute le contenu à la position souhaitée
            obj.Content = [obj.Content(1:end), {content}];
        end
          
        function scatter(obj, app)
        % Cette méthode consiste à afficher les marqueurs des sous-élements
        % contenus dans obj.Content

            navigator = app.Graph.Components.Navigator;
            cla(navigator.UIObject);

            % On indique que la superposition de tracé est possible
            navigator.UIObject.NextPlot = 'add';
            
            % On affiche les marqueurs un par un 
            for i = 1:length(obj.Content)
                sct = scatter(navigator.UIObject, i, 1, 'Marker', app.Types.(obj.Content{i}.TypeName).Marker, ...
                                                       'MarkerEdgeColor', app.Types.(obj.Content{i}.TypeName).Color);  
                
                sct.ButtonDownFcn = @(~, ~) obj.Content{i}.object_selected(app);
            end

            navigator.resize();
        end
    end
end


