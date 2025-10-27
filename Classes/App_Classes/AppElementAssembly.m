classdef AppElementAssembly < AppObject

    properties

        Content % Object de class AppContainer
    end

    methods
        function obj = AppElementAssembly(app, varargin)
            
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

        class_obj = app.Types.(obj.TypeName).HandleClassObject(list);
        end
    end

    methods (Static)

        function app_element_assembly = class_to_app(app, class_element_assembly)
        % Cette méthode permet de construire un élement d'application 
        % à partir d'un objet de classe. Si l'élement contient des
        % jonctions ou des élements, la méthode pourra être récursive

            content = {};
            % On parcourt la liste des sous-élements et on construit les
            % sous-élements d'applications
            class_config_element_assembly = class_element_assembly.Configuration;
            for i = 1:length(class_config_element_assembly.ListOfElements)
                
                class_element = class_config_element_assembly.ListOfElements{i};
                content{i} = class_element.HandleAppBuilder(app, class_element);
            end
            
            % On construit l'assemblage d'élements
            % app_config_element_assembly = app.Types.classelementassembly.HandleAppConfig(class_config_element_assembly);
            app_element_assembly = AppElementAssembly(app, AppContainer(content), 'classelementassembly');         
        end

        
    end
end