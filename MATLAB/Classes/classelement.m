classdef classelement
    
    properties
        
        HandleAppBuilder = @(app, class_elm) AppElement.class_to_app(app, class_elm)
        HandleAppConfig = @(class_config) struct('InputSection', class_config.InputSection)
        Configuration
        % Contenu 
        % ListOfSubelements % (cell) la seul requête des subelements est d'avoir une méthode transfermatrix(env)
        % EndStatus % (string) 'opened' (default mode) or 'closed'
        % InputSection % (double) uitle seulement pour la méthode surface_impedance(env)
        % ...
    end
    
    methods
        function obj = classelement(config)
            
            obj.Configuration = config;
        end
        
        function TM = transfer_matrix(obj, env)
                
            config = obj.Configuration;
            
            TM = config.ListOfSubelements{1}.transfer_matrix(env);
            if length(config.ListOfSubelements) > 1
                for i = 2:length(config.ListOfSubelements)
                    TM = matprod(TM, config.ListOfSubelements{i}.transfer_matrix(env));
                end
            end
        end

        function Zs = surface_impedance(obj, env)
            
            TM = obj.transfer_matrix(env);
            S = obj.Configuration.InputSection;
            % On revient en convention pression - vitesse
            Zs = S * TM.T11 ./ TM.T21; % rigid wall
        end

        function TL = transmission_loss(obj, env)
            TM = obj.transfer_matrix(env);
            S = obj.Configuration.InputSection;
            param = env.air.parameters;
            Z0 = param.Z0;
            
            % % Convention Pression - Vitesse
            % TL = 20 * log10(abs(0.5 * (TM.T11 + TM.T12/Z0 + Z0*TM.T21 + TM.T22)));

            % Convention Pression - Débit
            TL = 20 * log10(abs(0.5 * (TM.T11 + TM.T12 * S/Z0 + Z0/S * TM.T21 + TM.T22)));
        end 

        function alpha = alpha(obj, env) % retourne le vecteur coefficient d'absorption
            Zs = obj.surface_impedance(env);
            param = env.air.parameters;
            Z0 = param.rho * param.c0;
            alpha = 1 - abs((Zs - Z0) ./ (Zs + Z0)).^2;
        end

        function mean_alpha = alpha_mean(obj, env, f_min, f_max)
            mask = @(env) (env.w / (2*pi) > f_min & env.w / (2*pi) < f_max);
            alpha = obj.alpha(env);
            mean_alpha = mean(alpha(mask));
        end

        function [peak_frequencies, peak_alpha] = alpha_peak(obj, env) 
            % Retourne les fréquences et les amplitudes des pics d'absorption (y compris les maximums locaux)
            
            % Calculer la fonction alpha à partir de l'objet et de l'environnement
            a = obj.alpha(env);
            
            % Identifier les maximums locaux dans la fonction alpha
            % On compare chaque valeur avec ses voisins gauche et droit
            local_maxs = (a(2:end-1) > a(1:end-2)) & (a(2:end-1) > a(3:end)); % Conditions pour des maximums locaux
            
            % Inclure les bords si nécessaire (maximum global ou bords)
            local_maxs = [a(1) > a(2), local_maxs, a(end) > a(end-1)]; 
            
            % Récupérer les indices des maximums locaux
            max_indices = find(local_maxs);
            
            % Calculer les fréquences correspondantes à ces maximums
            peak_frequencies = env.w(max_indices) / (2 * pi);
            peak_alpha = a(max_indices);
        end

        function disp_subelements_parameters_table(obj, env)

            obj.disp_parameters_table(env);
            config = obj.Configuration;
            for i = 1: length(config.ListOfSubelements)
                % Si le sous-élement est un objet de classe 'classelement', on appelle la fonction de manière récursive
                if isfield(config.ListOfSubelements{i}.Configuration, 'ListOfSubelements')
                    config.ListOfSubelements{i}.disp_subelements_parameters_table(env);
                else
                    config.ListOfSubelements{i}.disp_parameters_table(env)
                end
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
            
            % Filtrer pour ne garder que les sections InputSection et OutputSection
            filterIdx = contains(Parameters, 'InputSection') | contains(Parameters, 'OutputSection');
            Parameters = Parameters(filterIdx);
            Values = Values(filterIdx);
            Units = Units(filterIdx);
            
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
                else
                    valueStr = sprintf('%.2f', value);
                end
        
                % Affichage formaté sans crochets, guillemets ni accolades
                fprintf('%-35s %-15s %-10s\n', param, valueStr, unit);
            end
        end

        function obj = plot_alpha(obj, env, f_min, f_max, name)

            % figure()
            hold on
            
            % Résultats analytiques
            alpha = obj.alpha(env);
            f = env.w / (2 * pi);
            plot(f, alpha, 'color', 'b', 'DisplayName', [name ' - Résultat Analytique'])
            yline(obj.alpha_mean(env, f_min, f_max), '--b', ...
                  sprintf('Valeur : %.2f', obj.alpha_mean(env, f_min, f_max)), 'LabelHorizontalAlignment', 'left', 'LabelVerticalAlignment', 'top');
            
            % Résultats numériques
            if isfield(obj.Configuration, 'ComsolModel')
                data = mphtable(obj.Configuration.ComsolModel, 'tbl1').data;
                obj.Configuration.Alpha2D = data;
                plot(data(:, 1), data(:, 2), 'LineStyle', 'o--r', 'DisplayName', [name ' - Résultat FEM'])
                m = (data(:, 1) > f_min & data(:, 1) < f_max);
                yline(mean(data(m, 2)), '--r', ...
                      sprintf('Valeur : %.2f', mean(data(m, 2))), 'LabelHorizontalAlignment', 'right', 'LabelVerticalAlignment', 'top');

            end

            % Résultats numériques 3D
            if isfield(obj.Configuration, 'Comsol3DModel')
                data = mphtable(obj.Configuration.Comsol3DModel, 'tbl1').data;
                obj.Configuration.Alpha3D = data;
                plot(data(:, 1), data(:, 2), 'LineStyle', '--', 'DisplayName', [name ' - Résultat FEM 3D'])
            end
         
            xlabel("Fréquence (Hz)")
            ylabel("Coefficient d'Absorption")
            xlim([0 2000])
            ylim([0 1])
            legend()
        end

        function obj = plot_surface_impedance(obj, env)

            figure()
            hold on
            
            title('Impédance acoustique')
            f = env.w / (2 * pi);

            subplot(2, 1, 1)
            xlabel("Fréquence (Hz)")
            ylabel("Re(Zs)")
            xlim([0 3000])

            subplot(2, 1, 2)
            xlabel("Fréquence (Hz)")
            ylabel("Im(Zs)")
            
            % xlim([0 f(end)])
            xlim([0 3000])

            % Résultats analytiques
            
            Zs_anal = obj.surface_impedance(env);

            subplot(2, 1, 1)
            yyaxis left
            plot(f, real(Zs_anal), 'DisplayName', 'Résultat Analytique');

            subplot(2, 1, 2)
            yyaxis left
            plot(f, imag(Zs_anal), 'DisplayName', 'Résultat Analytique');

            % Résultats numériques
            if isfield(obj.Configuration, 'ComsolModel')
                Zs_FEM = mphtable(obj.Configuration.ComsolModel, 'tbl1').data;

                subplot(2, 1, 1)
                yyaxis right
                plot(Zs_FEM(:, 1), Zs_FEM(:, 5), 'DisplayName', 'Résultats numériques')
    
                subplot(2, 1, 2)
                yyaxis right
                plot(Zs_FEM(:, 1), Zs_FEM(:, 6), 'DisplayName', 'Résultat numérique')
            end

            legend()
         end
        
        function save_class_object(obj, filename)

            path = 'E:\OneDrive - ETS\CRIAQ-REAR\Maitrise LB\MATLAB\Apps\Configurations\';
            fullpath = fullfile(path, filename);
            save(fullpath, 'obj');
        end

        function scatter_config(obj, propname, label)

            figure();
            scatter(linspace(1, length(obj.Configuration.(propname)), length(obj.Configuration.(propname))), obj.Configuration.(propname), 'red', 'filled', 'o');
            xlabel('Numéro de plaque');
            ylabel(label);
        end
    end

    methods (Static, Access = public)

        function config = create_config(list_of_subelements, end_status, varargin)

            config = {};
            config.ListOfSubelements = list_of_subelements;
            config.EndStatus = end_status;
            if nargin > 2
                config.InputSection = varargin{1};
            end
        end
    end
end
