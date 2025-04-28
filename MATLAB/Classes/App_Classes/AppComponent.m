classdef AppComponent  < handle
    
    properties

        Name
        Container % Object de classe AppComponentContainer (parent)
        UIObject % Objet graphique
    end
    
    methods
        function obj = AppComponent(ui_object, name)
            obj.UIObject = ui_object;
            obj.Name = name;
        end
        
        function show_only(obj)
        % Cette méthode permet de montrer l'objet graphique associé à
        % l'objet de classe graphique courant. Pour cela on accède à
        % l'objet graphique parent de l'objet graphique, on cache tous
        % composants qu'il contient puis on affiche le composant courant.

            % On cache les composants du contenant
            obj.Container.hide_components()

            % On affiche le composant courant
            obj.show()
        end

        function show(obj)
            obj.UIObject.Visible = 'on';
        end

        function hide(obj)       
            obj.UIObject.Visible = 'off';
        end

    end
end


