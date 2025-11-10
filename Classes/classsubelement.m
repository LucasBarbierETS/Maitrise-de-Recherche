classdef classsubelement
   
    properties

        HandleAppBuilder
        HandleAppConfig
        Configuration   
    end

    methods % Constructeur

        function obj = classsubelement(config)

             if nargin > 0
                obj.Configuration = config;
            end
        end

    end

    methods % Matrices
        
        function [TM, TM_inv, pt_out, u_out] = inverse_transfer_matrix(obj, env, options)

            arguments
                obj
                env
                options.pt_in = NaN
                options.u_in = NaN
                options.TM = NaN
                options.IndexPosition = []
            end
            
            try
                isValidTM = isstruct(options.TM) && ...            % TM doit être une structure
                all(isfield(options.TM, {'T11','T12','T21','T22'})) && ... % avec champs requis
                any(~isnan([options.TM.T11, options.TM.T12, options.TM.T21, options.TM.T22]), 'all'); % AU MOINS une valeur non-NaN

                if isValidTM
                   TM = options.TM; 
                else  
                    args = perso_namedargs(options);
                    TM = obj.transfer_matrix(env, args{:});
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
    end

    methods % Indicateurs acoustiques

        function Zs = surface_impedance(obj, env, options)

            arguments
                obj
                env
                options.tolerance = 1e-3
                options.max_iter = 500;
                options.HL_method {mustBeMember(options.HL_method, ['linear', 'all', "first", 'retropropagation'])} = "linear"
                options.Id = 1
            end
               

            % Initialisation
            u = zeros(1, length(env.w));
            pt = env.pt;
            iter = 0;
            converged = false;
            S = obj.Configuration.Surface;

            while ~converged && iter < options.max_iter
                iter = iter + 1;

                TM = obj.transfer_matrix(env, options);
                Zs = S * TM.T11 ./ TM.T12;
                new_u = pt ./ Zs * S;

                % % Debog : Tracé de l'impédance de surface
                % perso_figure('Impédance de surface dans classsubelement/surface_impedance');
                % perso_plot_surface_impedance(env.w/(2*pi), Zs, env, ['Itération ', num2str(iter)]);

                % % Debog : Partie réelle négative
                % find(real(Zs) < 0);

                % Debog : Vitesse RMS à l'entrée de l'assemblage
                perso_figure('u dans classsubelement/surface_impedance');
                plot(env.w/(2*pi), new_u);
                
                convergence_criterium = max(abs(u - new_u));

                % % Debog : Critère de convergence
                % perso_figure('Convergence dans classsubelement/surface_impedance');
                % scatter(iter, convergence_criterium, 'Color', 'b', 'HandleVisibility', 'off');
                % % ylim([-1e-2 1e-2]);

                if convergence_criterium < options.tolerance
                    converged = true;
                else
                    u = new_u;
                end   
            end
        end
        
        function R = reflexion_coefficient(obj, env, varargin)

            Z0 = env.air.parameters.Z0;
            if nargin > 2
                Zs = varargin{1};
            else
                Zs = obj.surface_impedance(env);
            end

            R = (Zs - Z0) ./ (Zs + Z0);
        end

        function alpha = alpha(obj, env) 

            alpha = 1 - abs(obj.reflexion_coefficient(obj, env)).^2;
        end
   
        function mean_alpha = alpha_mean(obj, env, f_min, f_max)
            mask = @(env) (env.w / (2*pi) > f_min & env.w / (2*pi) < f_max);
            alpha = obj.alpha(env);
            mean_alpha = mean(alpha(mask(env)));
        end

        function [peak_frequencies, peak_alpha] = alpha_peak(obj, env, varargin) 
            % Retourne les fréquences et les amplitudes des pics d'absorption (y compris les maximums locaux)

            if nargin > 2
                a = varargin{1};
            else
                % Calculer la fonction alpha à partir de l'objet et de l'environnement
                a = obj.alpha(env);
            end
            
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

        function error = alpha_error(obj, env, alpha_comp)

            error = 1/length(env.w)*sum(abs(obj.alpha(env) - alpha_comp)./alpha_comp);
            % perso_ouvrir_lien_Zotero('zotero://open-pdf/library/items/233HZ8GN?page=8&annotation=62TL63NL');
        end  
        
        
        function TL = transmission_loss(obj, env, varargin)

            % Si la TM est donnée en entrée (ex : TM en parallèle)
            if nargin > 2
                TM = varargin{1};
            else
                TM = obj.transfer_matrix(env);
            end

            S = obj.Configuration.Surface;
            param = env.air.parameters;
            Z0 = param.Z0;
            
            % % Convention Pression - Vitesse
            % TL = 20 * log10(abs(0.5 * (TM.T11 + TM.T12/Z0 + Z0*TM.T21 + TM.T22)));

            % Convention Pression - Débit
            TL = 20 * log10(abs(0.5 * (TM.T11 + TM.T12 * S/Z0 + Z0/S * TM.T21 + TM.T22)));
        end 
    end

    methods % Méthodes d'affichage
        function plot_alpha(obj, env, options)

            % Gestion des options
            default = struct('name', 'test');
            options = parse_options(options, default, {});
            
            hold on
            alpha = obj.absorption_coefficient(env, options);
            plot(env.f, alpha, 'DisplayName', options.name);
            perso_configure_alpha_figure(env.f(end));
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



