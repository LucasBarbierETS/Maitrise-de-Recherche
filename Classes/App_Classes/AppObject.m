classdef AppObject < handle 
   
    % Contruit : AppElement, AppSubelement, AppJunction
   
    properties

       Container
       Index
       Scatter
       TypeName
       AppConfig
       Path
   end

    events

        TypeNameChanged
        ContentChanged
    end

    methods

        function obj = AppObject(app, varargin)

            % On définit une instance vide de chemin d'accès
            obj.Path = AppPath();

            % On créer un listener qui réagit à la modification du type de l'objet
            addlistener(obj, 'TypeNameChanged', @(~, ~) obj.type_name_changed(app));

            % varargin = {type, app_config}
            
            % Si le type de sous-élement est donné
            if nargin > 1
                obj.TypeName = varargin{1}; % n'active pas encore le listener

                % Si la configuration d'application est donnée
                if nargin > 2
                    obj.AppConfig = varargin{2};
                end
            end
        end

        function scatter(obj, app, component)
        % Cette méthode consiste à afficher le marqueur de l'objet courant
        % dans le composant graphique donné en argument

            % On affiche le marqueur dans le composant graphique, à sa place attitrée
            obj.Scatter = scatter(component.UIObject, obj.Index, 1, "Marker", app.Types.(obj.TypeName).Marker, ...
                                                                    "MarkerEdgeColor", app.Types.(obj.TypeName).Color);
    
            % On crée un Callback qui s'active lorsque le marqueur est cliqué
            % dans l'interface graphique
            obj.Scatter.ButtonDownFcn = @(~, ~) obj.object_selected(app);
        end
    
        function show(obj, app)

            % Si l'objet n'a pas de contenu, ou que son contenu n'a pas été
            % défini (AppObjet, AppSubelement en général) et qu'il existe
            % un objet qui le contient, on affiche cet objet.
            if (~isprop(obj, 'Content') || isempty(obj.Content)) && ~isempty(obj.Container.Container)
                obj.Container.Container.show(app)
            
            % dans le cas contraire, on affiche si ils existent, le contenu
            % dans la vue du bas et le contenu du contenant dans la vue du
            % haut
            else   
                cla(app.Graph.Components.SubelementsGraph.UIObject)
                cla(app.Graph.Components.ElementsGraph.UIObject)
                
                if isprop(obj, 'Container') && ~isempty(obj.Container)
                    obj.Container.scatter_with_call(app, app.Graph.Components.ElementsGraph);
                end

                if isprop(obj, 'Content') && ~isempty(obj.Content)
                    obj.Content.scatter_with_call(app, app.Graph.Components.SubelementsGraph);
                end       
            end  

            cla(app.Graph.Components.Navigator.UIObject)
            obj.get_path(app)
            obj.Path.scatter(app);
        end
         
        function get_path(obj, app)

            % On réinitialise le chemin
            obj.Path = AppPath();
          
            % Si l'objet est contenu dans un objet, on récupère le chemin
            % de son contenant
            if isprop(obj.Container, 'Container') && ~isempty(obj.Container.Container)
                obj.Container.Container.get_path(app);
                
                % A la sortie de la boucle, on ajoute le contenant de
                % l'objet au chemin, si celui n'est pas affiché
                obj.Path = obj.Container.Container.Path;
                
                if ~((isprop(obj.Container, 'Container') && ~isempty(obj.Container.Container)) && ...
                    (isvalid(obj.Container.Container.Scatter) && (strcmp(obj.Container.Container.Scatter.Visible, 'on'))))
                    obj.Path.add_to_path(obj.Container.Container);
                end
            end
        end
        
        function disp_app_config(obj, app) 
        % Cette méthode gère l'affichage du panneau des paramètres du
        % sous-élement courant. 

            % On remplit le sous-panneau avec les données de la
            % configuration d'application 
            struct = app.Types.(obj.TypeName).ParametersPanelStruct;
            app_config = obj.AppConfig;
            
            for i = 1:length(struct.ParametersEditFields)
                if isfield(app_config, supprimerEspaces(struct.ParametersLabels{i}.Text))
                    struct.ParametersEditFields{i}.Value = ...
                    app_config.(supprimerEspaces(struct.ParametersLabels{i}.Text));
                end
            end
        end
        
        function update_app_config(obj, app)
        % Cette méthode permet de mettre à jour la configuration d'un
        % objet à partir des valeurs inscrites dans le panneau des
        % paramètres

            struct = app.Types.(obj.TypeName).ParametersPanelStruct;
            
            for i = 1:length(struct.ParametersEditFields)
                obj.AppConfig.(supprimerEspaces(struct.ParametersLabels{i}.Text)) = ...
                struct.ParametersEditFields{i}.Value;
            end
        end
    
    end
    
    methods % Callbacks
        
        function object_selected(obj, app)
        % Ce callback s'active lorsque'un object est sélectionné.  
        
            %% Gestion de l'affichage
            obj.show(app); 

            obj.Scatter.MarkerEdgeColor = 'r';

            % Si le contenant existe et est affiché, on l'affiche en rouge également
            if (isprop(obj.Container, 'Container') && ~isempty(obj.Container.Container)) && ...
               (isvalid(obj.Container.Container.Scatter) && (strcmp(obj.Container.Container.Scatter.Visible, 'on')))
                obj.Container.Container.Scatter.MarkerEdgeColor = 'r';
            end
        
            %% Gestion des objets graphiques

            % On affiche la configuration de l'objet dans le panneau prévu a cet effet 
            app_panel = app.Types.(obj.TypeName).ParametersPanelStruct.Container.Components.(obj.TypeName);

            % On affiche le sous panneau (AppComponent) associé au type d'élement courant
            app_panel.show_only(); 

            % On efface le contenu affiché dans le panneau
            app_panel.clean();

            %% Gestion de la configuration d'application
            
            % On affiche la configuration
            obj.disp_app_config(app);
            
            % On redirige le callback du bouton Update Configuration vers l'objet actuel
            app.UpdateConfigurationButton.ButtonPushedFcn = @(~, ~) obj.update_app_config(app);

            % On redirige le callback du menu déroulant Type vers l'objet
            % actuel. En changeant le type on déclenche par la suite la
            % modification de l'objet.
            app.TypeDropDown.ValueChangedFcn = @(~, ~) set_type_name(obj, app.TypeDropDown.Value);
            
            % On met à jour le menu déroulant. Comme le type est le même
            % que celui déclaré dans la vérification, le listener n'est pas
            % déclenché.
            app.TypeDropDown.Value = obj.TypeName;

            % On réactualise l'affichage de l'arbre
            perso_visualizeContentTree(app.Elements, app.Tree);
        end

        function type_name_changed(obj, app)
        % Cette méthode est appelée lorsque le type d'un objet est modifié.
        % Lorsque c'est le cas, on redéfinit l'objet en appelant le constructeur 
        % associé au nouveau type et en transférant les autres propriétés
        % au nouvel objet
        
            % On construit l'objet correspondant au type donné
            new_obj = app.Types.(obj.TypeName).HandleAppObject(app);
            
            % On transfère les propriétés vers le nouvel objet
            new_obj.TypeName = obj.TypeName;
            obj.Container.Content{obj.Index} = new_obj;
            new_obj.Container = obj.Container;
            
            % On montre l'objet modifié
            new_obj.object_selected(app);
        end
    end

    methods % Méthodes d'assignation d'attribut
         
        function set.TypeName(obj, value)

            % On ne notifie le changement que si le type était déjà défini
            % avant l'assignation.

            if ~isempty(obj.TypeName)
                obj.TypeName = value;
                notify(obj, 'TypeNameChanged');
            else
                obj.TypeName = value;
            end
        end
   
        function set_type_name(obj, type_name)

            % Si le type assigné est différent du type actuel
            if ~strcmp(obj.TypeName, type_name)
                obj.TypeName = type_name;
            end
        end
    end
end

