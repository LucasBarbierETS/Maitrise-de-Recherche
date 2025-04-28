classdef AppComponentContainer < handle

    % Cette classe construit un contenant graphique (UIAxes, UIPanel, ...) 
    
    properties

        Name 
        UIObject % Objet graphique associé au contenant graphique
        Components % Structure des composants contenant les objets de classe AppComponent (enfant)
        Container
    end
    
    methods

        function obj = AppComponentContainer(ui_objet, name)

            obj.Name = name;
            obj.UIObject = ui_objet;
            obj.UIObject.Tag = name;
        end


        function hide_components(obj)
        % Cette méthode permet de cacher tous les composants d'un conteneur graphique

            fnames = fieldnames(obj.Components);
            for i = 1:length(fnames)
                obj.Components.(fnames{i}).hide();
            end
        end

        function add_component(obj, component)
            obj.Components.(component.Name) = component; 
            component.Container = obj;
        end

        function ui_panel = add_empty_panel(obj, name)
        % Cette méthode permet de créer un graphe dans conteneur courant
            
            ui_panel = uipanel(obj.UIObject);
            ui_panel.Visible = 'off';
            ui_panel.Units = "normalized";
            ui_panel.Position = [0 0 1 1];
            component = AppPanel(ui_panel, name);
            obj.add_component(component);
        end
    end
end

