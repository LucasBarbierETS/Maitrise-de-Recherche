classdef classsubelement
    
    properties

        HandleAppBuilder = @(app, class_sblm) AppSubelement.class_to_app(app, class_sblm)
        Configuration   
    end
    
    methods

        function obj = classsubelement(config)

            if nargin > 0
                obj.Configuration = config;
            end
        end
        
        function disp_parameters_table(obj, env)
            config = obj.Configuration;
            
            % Évaluer la configuration en cas de pointeurs de fonction
            config = eval_config(config, env);
            
            % Préparer les variables de la table
            VariableNames = {'Parameter', 'Value', 'Unit'};
            Parameters = {};
            Values = {};
            Units = {};
            
            % Appeler la fonction récursive pour remplir les paramètres, valeurs et unités
            [Parameters, Values, Units] = parse_structure(config, class(obj), Parameters, Values, Units, env);
            
            % Afficher l'en-tête de la table
            fprintf('\n\n%-35s %-15s %-10s\n', VariableNames{:});
            fprintf('%s\n', repmat('-', 1, 65)); % Ligne de séparation
            
            % Afficher chaque ligne de la table
            for i = 1:length(Parameters)
                param = Parameters{i};
                value = Values{i};
                unit = Units{i};
        
                % Remplacer les NaN par une chaîne vide
                if isnan(value)
                    valueStr = '';  % Chaine vide pour NaN
                elseif ischar(value)
                    valueStr = value;
                else
                    valueStr = sprintf('%.4f', value);
                end
        
                % Affichage formaté sans crochets, guillemets ni accolades
                fprintf('%-35s %-15s %-10s\n', param, valueStr, unit);
            end
        end

        function Zs = surface_impedance(obj, env)

            % On suppose qu'il y a une terminaison rigide à l'extrémité du sous-élément
            TM = obj.transfer_matrix(env);
            S = obj.Configuration.InputSection;

            % Si TM est formulé avec la convention Pression - Vitesse
            % Zs = TM.T11 ./ TM.T21; 

            % Si TM est formulé avec la convention Pression - Débit
            Zs = S * TM.T11 ./ TM.T21; 
        end

        function alpha = alpha(obj, env) 

            Zs = obj.surface_impedance(env);
            param = env.air.parameters;
            Z0 = param.rho * param.c0;
            alpha = 1 - abs((Zs - Z0) ./ (Zs + Z0)).^2;
        end

        function plot_alpha(obj, env)

            figure()
            hold on
            alpha = obj.alpha(env);
            f = env.w / (2 * pi);
            plot(f, alpha)
            xlabel("Fréquence (Hz)")
            ylabel("Coefficient d'Absorption")
            ylim([0 1])
            xlim([0  f(end)])
        end
    end
end



