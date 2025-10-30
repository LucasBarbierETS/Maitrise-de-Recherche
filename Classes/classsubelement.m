classdef classsubelement
   
    properties

        HandleAppBuilder = @(app, class_sblm) AppSubelement.class_to_app(app, class_sblm)
        HandleAppConfig
        Configuration   
    end

    methods

        function obj = classsubelement(config)

             if nargin > 0
                obj.Configuration = config;
            end
        end

        function [TM_inv, pt_out, u_out] = inverse_transfer_matrix(obj, env, options)

            arguments
                obj
                env
                options.pt_in = NaN
                options.u_in = NaN
                options.TM = NaN
                options.IndexPosition = []
            end
            
            try
                if all(structfun(@(x) all(isnan(x), 'all'), options.TM))
                    args = perso_namedargs(options);
                    TM = obj.transfer_matrix(env, args{:});
                else
                    TM = options.TM;
                end

                % % Debog : Matrice de transfert inverse
                % perso_figure('TM d''un sous-élement dans classsubelement/inverse_transfer_matrix')
                % clf;
                % sgtitle(class(obj))
                % perso_plot_transfer_matrix(TM, env, 'TM'); 
            
                % Calcul du déterminant
                det_TM = TM.T11 .* TM.T22 - TM.T12 .* TM.T21;
                
                % Mise à NaN des valeurs hors de l'intervalle [1 - 1e-3, 1 + 1e-3]
                mask_outside = abs(det_TM - 1) > 1e-3;
                det_TM(mask_outside) = NaN;
                
                % % Optionnel : Avertissement si certaines valeurs sont NaN
                % if any(mask_outside, 'all')
                %     warning('Certaines valeurs du déterminant sont hors de l''intervalle [1 - 1e-3, 1 + 1e-3] et ont été remplacées par NaN.');
                % end

                % % Debog : Affichage du déterminant
                % perso_figure('Déterminant de la matrice de transfert d''un sous-élement dans classsubelement/inverse_transfer_matrix')
                % clf;
                % plot(env.w/(2*pi), det_TM)

                % Calcul de l'inverse de la matrice
                TM_inv.T11 = TM.T22 ./ det_TM;
                TM_inv.T12 = -TM.T12 ./ det_TM;
                TM_inv.T21 = -TM.T21 ./ det_TM;
                TM_inv.T22 = TM.T11 ./ det_TM;
        
                % % Debog : Matrice de transfert inverse
                % perso_figure('TM d''un sous-élement dans classsubelement/inverse_transfer_matrix')
                % perso_plot_transfer_matrix(TM_inv, env, 'TM inv'); 

            catch ME
                % 🔥 En cas d'erreur imprévue (ex. NaN, taille incohérente, etc.)
                error('Erreur lors de l''inversion de la matrice de transfert'); 
            end

            pt_in = options.pt_in; u_in = options.u_in;

            if ~all(isnan(pt_in)) && ~all(isnan(u_in))
                pt_out = TM_inv.T11 .* pt_in + TM_inv.T12 .* u_in;
                u_out = TM_inv.T21 .* pt_in + TM_inv.T22 .* u_in;
            else
                pt_out = NaN;
                u_out = NaN;
            end
        end

        function Zs = surface_impedance(obj, env, options)

            arguments
                obj
                env
                options.pt_in = NaN
                options.u_in = NaN
                options.TM = NaN
                options.IndexPosition = []
            end
               
            args = perso_namedargs(options);
            TM = obj.transfer_matrix(env, args{:});
            if ~any(~cellfun(@(x) all(isnan(real(x(:))) & isnan(imag(x(:)))), struct2cell(TM)))
                error('Matrice NaN dans classsublement/surface_impedance')
            end

            Zs = obj.Configuration.Surface * TM.T11 ./ TM.T21;
        end
        
        function alpha = alpha(obj, env) 

            Zs = obj.surface_impedance(env);
            param = env.air.parameters;
            Z0 = param.rho * param.c0;
            alpha = 1 - abs((Zs - Z0) ./ (Zs + Z0)).^2;
        end

        function plot_alpha(obj, env, name)
            
            hold on
            alpha = obj.alpha(env);
            f = env.w / (2 * pi);
            plot(f, alpha, 'DisplayName', name);
            perso_configure_alpha_figure(f(end));
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
    end
end



