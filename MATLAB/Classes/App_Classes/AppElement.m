classdef AppElement < AppObject
% Les élements sont à l'interface entre un contenant et un contenu.
% Comment les sous-élements on peut les afficher en tant que sous-élement,
% mais on peut aussi les sélectionner pour afficher à la fois leur
% contenant et leur contenu.

    properties

        Content % Object de class AppContainer
    end

    methods
        function obj = AppElement(app, varargin)
            
              % varargin = {content, type, app_config, ...

            obj@AppObject(app)
            
            % Si le contenu de l'élement est donné
            if nargin > 1
                obj.Content = varargin{1};
                obj.Content.Container = obj;

                % Si le type d'élement est donné
                if nargin > 2
                    obj.TypeName = varargin{2};

                    % Si la configuration d'application est donnée
                    if nargin > 3
                        obj.AppConfig = varargin{3};
                    end
                end

            else
                obj.Content = AppContainer();
                obj.Content.Container = obj;
            end                 
        end 
    
        function class_obj = app_to_class(obj, app)
        % Cette méthode permet de convertir le contenu d'un object
        % AppElement en un object classelement.
        % Le contenu peut se situer à différent niveau (AppElement,
        % Appsubelement) la méthode est donc récursive.

        list = {};
            for i = 1:length(obj.Content.Content)
                list{end+1} = obj.Content.Content{i}.app_to_class(app);
            end
        
        class_config = app.Types.(obj.TypeName).HandleClassConfig( ...
        replace_fields(obj.AppConfig, app.HandleVariables));
        class_obj = app.Types.(obj.TypeName).HandleClassObject(list, class_config);
        end
    end

    methods (Static)

        function app_elm = class_to_app(app, class_elm)
        % Cette méthode permet de construire un élement d'application 
        % à partir d'un objet de classe. Si l'élement contient des
        % jonctions ou des élements, la méthode pourra être récursive

            content = {};
            % On parcourt la liste des sous-élements et on construit les
            % sous-élements d'applications
            class_config_elm = class_elm.Configuration;
            for i = 1:length(class_config_elm.ListOfSubelements)
                
                class_sblm = class_config_elm.ListOfSubelements{i};
                content{i} = class_sblm.HandleAppBuilder(app, class_sblm);
            end
            
            % On construit l'élement
            app_config_elm = app.Types.Element.HandleAppConfig(class_config_elm);
            app_elm = AppElement(app, AppContainer(content), 'Element', app_config_elm);         
        end

        
    end
end