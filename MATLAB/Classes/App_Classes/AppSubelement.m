classdef AppSubelement < AppObject

    methods
        function obj = AppSubelement(app, varargin)
            
            % varargin = {type, app_config, ...

            obj@AppObject(app);
            
            % Si le type de sous-élement est donné
            if nargin > 1
                obj.TypeName = varargin{1};

                % Si la configuration d'application est donnée
                if nargin > 2
                    obj.AppConfig = varargin{2};
                end
            end
        end

        function class_obj = app_to_class(obj, app)
        % Cette méthode retourne l'objet de classe associé
        % au sous-élement d'application

        % On remplace les champs de la configuration d'application
        % correspondant à des variables muettes
        class_config = app.Types.(obj.TypeName).HandleClassConfig( ...
        replace_fields(obj.AppConfig, app.HandleVariables));
        class_obj = app.Types.(obj.TypeName).HandleClassObject(class_config);
        end
    end

    methods (Static)

        function app_sblm = class_to_app(app, class_sblm)
        % Cette méthode permet de construire un élement d'application
        % à partir d'un objet de classe

            type_name_sblm = class(class_sblm);
            app_config_sblm = app.Types.(type_name_sblm).HandleAppConfig(class_sblm.Configuration);
            app_sblm = AppSubelement(app, type_name_sblm, app_config_sblm);
        end   
    end
end