classdef classobject
   
    properties

        HandleAppBuilder = @(app, class_sblm) AppSubelement.class_to_app(app, class_sblm);
        HandleAppConfig
        Configuration   
    end

    methods % Constructeur

        function obj = classobject(config)

             if nargin > 0
                obj.Configuration = config;
            end
        end
    end

    methods % Matrices
        
        function [TM_inv, options] = inverse_transfer_matrix(obj, env, options, varargin)

            if nargin < 3 || isempty(options)
                 options = struct(); % ou ton options par défaut
            end

            if nargin >= 4
                TM = varargin{1};
            else
                TM = obj.transfer_matrix(env, options);
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
            
            % Optionnel : Avertissement si certaines valeurs sont NaN
            if any(mask_outside, 'all')
                warning('Certaines valeurs du déterminant sont hors de l''intervalle [1 - 1e-3, 1 + 1e-3] et ont été remplacées par NaN.');
            end

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
        
            options = perso_propagate(TM_inv, options);
        end
    
        function YM = admittance_matrix(env, options)

            TM = elem.transfer_matrix(env, options);
            YM.Y11 = 1 ./ TM.T12 .* TM.T22;
            YM.Y12 = 1 ./ TM.T12 .* (TM.T21 .* TM.T12 - TM.T22 .* TM.T11);
            YM.Y21 = 1 ./ TM.T12;
            YM.Y22 = -1 ./ TM.T12 .* (TM.T11);
        end 
    end

    methods % Méthodes d'affichage des configurations
        
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
    
        function obj = plot_alpha(obj, env, options) % f_min, f_max 
                
                % Résultats analytiques
                alpha = obj.absorption_coefficient(env, options);
    
                f = env.w / (2 * pi);
                color = perso_random_color_rgb_triplet();
    
                hold on
    
                plot(f, alpha, 'color', color, 'DisplayName', options.plot_name);
                % ...
                % y_line_anal = yline(obj.alpha_mean(env, f_min, f_max), '--b', ...
                % ['alpha moyen an. ', num2str(f_min), ' - ', num2str(f_max), ' Hz : ', num2str(obj.alpha_mean(env, f_min, f_max), 2)], ...
                % 'LabelHorizontalAlignment', 'left', ...
                % 'LabelVerticalAlignment', 'top', ...
                % 'HandleVisibility', 'off');
                
                % Résultats numériques
                if isfield(obj.Configuration, 'ComsolModel')
                    data = mphtable(obj.Configuration.ComsolModel, 'tbl1').data;
                    obj.Configuration.Alpha2D = data;
                    color = perso_random_color_rgb_triplet();
                    plot(data(:, 1), data(:, 2), 'LineStyle', 'o--','Color', color, 'DisplayName', [name ' - Résultat FEM'])
                    % m = (data(:, 1) > f_min & data(:, 1) < f_max);
                    % yline(mean(data(m, 2)), '--r', ...
                    %       ['alpha moyen FEM ', num2str(f_min), ' - ', num2str(f_max), ' Hz : ', num2str(obj.alpha_mean(env, f_min, f_max), 2)], ...
                    %       'LabelHorizontalAlignment', 'right', ...
                    %       'LabelVerticalAlignment', 'top', ...
                    %       'HandleVisibility', 'off');
                end
    
                % Résultats numériques 3D
                if isfield(obj.Configuration, 'Comsol3DModel')
                    data = mphtable(obj.Configuration.Comsol3DModel, 'tbl1').data;
                    obj.Configuration.Alpha3D = data;
                    plot(data(:, 1), data(:, 2), 'LineStyle', '--', 'DisplayName', [name ' - Résultat FEM 3D'])
                end
            end
    end


end



