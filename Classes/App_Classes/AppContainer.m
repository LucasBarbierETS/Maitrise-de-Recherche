classdef AppContainer < handle

    properties

        Content  % Cell array pour contenir les sous-éléments (AppElement, AppSubelement, AppJunction) (enfants)
        Container % Objet de classe AppElement ou AppJunction (parent)       
    end

    events

        ContentChanged
    end
    
    methods
       
        function obj = AppContainer(varargin)

            % varargin = {content, ...

            % On créer un listener qui réagit lorsque le contenu change
            addlistener(obj, 'ContentChanged', @(~, ~) obj.reindex_content());

            if nargin > 0
                
                obj.Content = varargin{1}; 

                % On définit de l'extérieur le contenant du contenu
                for i = 1:length(obj.Content)
                    obj.Content{i}.Container = obj;
                end

                % On réindexe le contenu
                obj.reindex_content();
            end
        end
        
        function add_content(obj, content, varargin)
        % Cette fonction permet d'insérer un objet de classe dans le contenant courant 
        % à une position donnée. Le contenu qui suit est alors déplacé et
        % réindexé.

        % varargin = {position, ...

            % On définie l'emplacement de réception du contenu
            if nargin > 2
                index = varargin{1};
            else
                index = length(obj.Content) + 1;
            end

            % On vérifie si la position est valide
            if index < 1 || index > length(obj.Content) + 1
                error('Position invalide.');
            end

            % On créer un lien rétroactif
            content.Container = obj;
            
            % On ajoute le contenu à la position souhaitée
            obj.Content = [obj.Content(1:index-1), {content}, obj.Content(index:end)];
        end
        
        function add_periodic_content(obj, content, period_number, varargin)
        % Cette méthode permet d'ajouter un objet de type AppPeriodic
        % contenant un objet de classe (a priori élement ouvert ou
        % sous-élement)

            % On définie l'emplacement de réception du contenu
            if nargin > 2
                index = varargin{1};
            else
                index = length(obj.Content) + 1;
            end

            % On vérifie si la position est valide
            if index < 1 || index > length(obj.Content) + 1
                error('Position invalide.');
            end

            % On crée un objet périodique
            periodic_content = AppPeriodic(content, period_number);

            % On créer un lien rétroactif
            periodic_content.Container = obj;
            
            % On ajoute le contenu à la position souhaitée
            obj.Content = [obj.Content(1:index-1), {periodic_content}, obj.Content(index:end)];
        end
        
        function remove_content(obj, index)
        % Cette méthode permet de supprimer un objet de son contenant.
        % Le handle de l'objet de classe à été effacé au préalable.
        
            % On vérifie si la position est valide
            if index < 1 || index > length(obj.Content) + 1
                error('Position invalide.');
            end

            % On supprime le contenu souhaité
            obj.Content{index}.delete();
            obj.Content = [obj.Content(1:index-1), obj.Content(index+1:end)];
        end

        function hide_content(obj)
    
            for i = 1:length(obj.Content)
                obj.Content{i}.hide()
            end
        end

        function scatter_with_call(obj, app, component)
        % Cette méthode est appelée lorsque on souhaite afficher le
        % contenu d'un objet de class AppContainer avec un point d'appel au
        % bout

            obj.scatter(app, component)
            
            % On crée un sous-élement vide au bout de l'élement. On créer
            % un lien depuis l'objet de type None vers son contenant sans créer le
            % lien direct (le sous-élement n'appartient pas à son contenant. 
            % Lorsque l'objet est cliqué, on appelle un callback qui ajoute un 
            % objet de classe Undefined dans le contenant auquel il est rattaché.
            call_scatter = AppObject(app, 'None');
            call_scatter.Index = length(obj.Content) + 1;
            call_scatter.scatter(app, component);

            % On modifie le callback qui a été défini lors de l'affichage
            % de l'objet
            call_scatter.Scatter.ButtonDownFcn = @(~, ~) obj.undefined_object_created(app);    
        
            component.resize()  
        end
        
        function scatter(obj, app, component)
        % Cette méthode consiste à afficher les marqueurs des sous-élements
        % contenus dans obj.Content

            cla(component.UIObject);

            % On indique que la superposition de tracé est possible
            component.UIObject.NextPlot = 'add';

            % On réindexe le contenu
            obj.reindex_content()
            
            % On affiche les marqueurs un par un 
            for i = 1:length(obj.Content)
                obj.Content{i}.scatter(app, component);
            end

            component.resize();
        end
        
        function class_container = app_to_class(obj)
        % Cette méthode permet de convertir le contenu d'un object AppContainer
        % en un cell array contenant les objects de classe associé.
        % Le contenu peut se situer à différent niveau (AppElement,
        % Appsubelement) la méthode est donc récursive.

        % On crée le cell array contenant les objects de classe
        class_container = {};
            for i = 1:length(obj.Content)
               
                % Si le champ dispose d'un contenu (AppElment ou Appjunction)
                if isfield(obj, 'Content')
                    list{end+1} = app_to_class(obj.Content.Content); % Récursion sur un autre AppContainer
                else % (AppSubelement)
                    list{end+1} = obj.Content{i}.app_to_class();
                end
            end
        
        % On appelle le constructeur de classe du type d'objet considéré (AppElement ou AppJunction) 
        class_obj = obj.Type.HandleClassObject(class_container, obj.Type.HandleClassConfig(obj.Appconfig));

        end

        function reindex_content(obj)
        % Cette fonction permet de réindexer les objects de classe enfant
        % relativement à la structure de l'objet courant

            for i = 1:length(obj.Content)
                % On met à jour l'index du contenu 
                obj.Content{i}.Index = i;
            end
        end
        
    end

    methods

        function set.Content(obj, value)
            obj.Content = value;
            notify(obj, 'ContentChanged');
        end
    end

    methods % Callbacks

        function undefined_object_created(obj, app)

            % On ajoute le contenu à l'objet
            obj.add_content(AppObject(app, 'Undefined'));

            % On sélectionne virtuellement le dernier objet ajouté
            obj.Content{end}.object_selected(app);
        end

    end
end


