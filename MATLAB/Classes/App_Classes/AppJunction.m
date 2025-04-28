classdef AppJunction < AppObject
       

    properties

        Content
    end
    methods

        function obj = AppJunction(app, varargin)

            % varargin = {content, type, app_config, ...
            
            obj@AppObject(app);
            
            % Si le contenu de l'élement est donnée
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
            end 
        end


        function class_jcn = app_to_class(obj, app)
            % Cette méthode permet de passer d'un objet d'application
            % à un objet de classe. La méthode suppose que la jonction
            % ne contient qu'un seul élement.

            % On appelle l'élement présent dans la jonction
            jcn_element = obj.Content.Content{1}.app_to_class(app);
            class_config = app.Types.(obj.TypeName).HandleClassConfig( ...
            replace_fields(obj.AppConfig, app.HandleVariables));
            class_jcn = app.Types.(obj.TypeName).HandleClassObject(jcn_element, class_config);
        end
    end

    methods (Static, Access = public)

        function app_jcn = class_to_app(app, class_jcn)
        % Cette méthode permet de créer un objet d'application de classe AppJunction 
        % Pour l'instant, on fait l'hypothèse que la jonction seulement un
        % sous_élement.
       
            class_config_jcn = class_jcn.Configuration;
     
            % On convertit le contenu en objet d'application
            class_jcn_elm = class_config_jcn.JunctionElement;
            app_jcn_elm = class_jcn_elm.HandleAppBuilder(app, class_jcn_elm);

            % On construit la jonction
            type_name_jcn = class(class_jcn);
            app_config_jcn = app.Types.(type_name_jcn).HandleAppConfig(class_config_jcn);
            app_jcn = AppJunction(app, AppContainer({app_jcn_elm}), type_name_jcn, app_config_jcn);  
        end
    end
end
