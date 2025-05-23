classdef classsubelement_imported < classsubelement

    methods
        function obj = classsubelement_imported(config)
            
            obj@classsubelement(config)
        end

        function Zs = surface_impedance(obj, env)
            
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
            Zs = nan(size(freq_env));
        
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
    end

    methods (Static, Access = public)

        function config = create_config(frequency_support, surface_impedance, input_section)
            
            config = struct();
            config.FrequencySupport = frequency_support;
            config.SurfaceImpedance = surface_impedance;
            config.InputSection = input_section;
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

