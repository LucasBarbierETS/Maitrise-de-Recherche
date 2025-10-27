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

        function [TM, TM_inv] = inverse_transfer_matrix(obj, env, options)

            arguments
                obj
                env
                options.pt_in = NaN
                options.u_in = NaN
            end
            
            try
                % On récupère la matrice de transfert
                args = namedargs2cell(options);
                TM = obj.transfer_matrix(env, args{:});

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
        end

        function [TM, p2, u2] = transfer_matrix_iter(obj, env, p1, u1) 

            [TM, TM_inv] = obj.inverse_transfer_matrix(env, p1, u1);

            % % debog : Tracé des termes complexes de la matrice de transfert du sous-élement
            % perso_figure('TM')
            % clf
            % perso_plot_transfer_matrix(TM, env, ['type d''objet : ', class(obj)]);  
            % close();

            % % debog : Tracé des termes complexes de la matrice de transfert inverse du sous-élement
            % perso_figure('TM')
            % clf
            % perso_plot_transfer_matrix(TM_inv, env, ['type d''objet : ', class(obj)]);  
            % close();

            p2 = TM_inv.T11 .* p1 + TM_inv.T12 .* u1;
            u2 = TM_inv.T21 .* p1 + TM_inv.T22 .* u1;
        end

        function Zs = surface_impedance(obj, env, options)

            arguments
                obj
                env
                options.pt_in = NaN
                options.u_in = NaN
                options.IndexPosition = []
            end
                
            args = namedargs2cell(options);
            TM = obj.transfer_matrix(env, args{:});
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
            plot(f, alpha, 'Color', "g", 'DisplayName', name);
            perso_configure_alpha_figure(f(end));
        end
    end
end



