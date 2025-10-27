classdef classelement_imported < classelement

    methods
        function obj = classelement_imported(config)
            
            obj@classelement(config)
            obj.HandleAppBuilder = @(app, class_sblm) AppSubelement.class_to_app(app, class_sblm);
        end
  
        function [Zs, obj] = surface_impedance(obj, env, varargin)
            
            % Cette fonction récupère le vecteur support de l'environnement env.w /(2*pi), 
            % le compare au vecteur support importé obj.Configuration.FrequencySupport 
            % et interpole l'impédance de surface importée obj.Configuration.SurfaceImpedance 
            % sur celui-ci :
            % - si un point du support se situe entre deux points importés,
            %   on réalise une interpolation linéaire pour définir sa valeur (complexe)
            % - si le point du support est en dehors du support importé, 
            %   on attribue la valeur NaN à l'impédance de surface
        
                % Récupération du vecteur de fréquences de l'environnement
                freq_env = env.w / (2 * pi);
          
                % Récupération des données de la configuration
                freq_support = obj.Configuration.FrequencySupport;
                Zs_imported = obj.Configuration.SurfaceImpedance;
            
                % Initialisation du vecteur d'impédance de surface
                Zs = complex(nan(size(freq_env)));
            
                % Boucle sur chaque fréquence de l'environnement
                for i = 1:length(freq_env)
                    % Vérification si la fréquence est dans l'intervalle supporté
                    if freq_env(i) >= min(freq_support) && freq_env(i) <= max(freq_support)
                        % Interpolation linéaire de l'impédance complexe
                        Zs(i) = interp1(freq_support, Zs_imported, freq_env(i), 'linear', NaN);
                    else
                        % Fréquence en dehors du support, valeur NaN
                        Zs(i) = NaN;
                    end
                end
            end
    
        function TM =  transfer_matrix(obj, env, varargin)
            
            TM.T11 = obj.surface_impedance(env, varargin) / obj.Configuration.Surface;
            TM.T12 = zeros(1, length(env.w));
            TM.T21 = ones(1, length(env.w));
            TM.T22 = zeros(1, length(env.w));
        end
    end

    methods (Static, Access = public)

        function config = create_config(frequency_support, surface_impedance, surface, options)
            
            arguments
                frequency_support
                surface_impedance
                surface
                options.Width = NaN;
                options.Depth = NaN;
            end

            config = struct();
            config.FrequencySupport = frequency_support;
            config.SurfaceImpedance = surface_impedance;
            config.Width = options.Width;
            config.Depth = options.Depth;
            config.Surface = surface;
            config.EndStatus = 'closed';
        end

        function validate(env)
            
            analytical_element = classMPPSBH_Rectangular(classMPPSBH_Rectangular.create_config(10, 30e-3, 30e-3, {29e-3}, {1e-3}, {5e-2}, {1e-3}, {9e-3}));
            resistive_screen = classscreen(classscreen.create_config(1e5, 2e-3, analytical_element.Configuration.InputSection));
            imported_element = classelement(classelement.create_config({resistive_screen, ...
                                                                        classsubelement_imported(classsubelement_imported.create_config(env.w / (2*pi), ...
                                                                                                                                        analytical_element.surface_impedance(env), ...
                                                                                                                                        analytical_element.Configuration.InputSection))}, ...
                                                                        'closed', analytical_element.Configuration.InputSection)); 
            
            figure()
            hold on
            plot(env.w/(2*pi), analytical_element.alpha(env), 'DisplayName', 'Résultat direct')
            plot(env.w/(2*pi), imported_element.alpha(env), 'DisplayName', 'Résultat importé + écran résistif')
            legend()
            perso_configure_alpha_figure(2000);
        end
    end
end