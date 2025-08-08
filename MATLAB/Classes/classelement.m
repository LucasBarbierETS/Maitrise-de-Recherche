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

        function TM = transfer_matrix(obj, env) % (p1, u1) = TM * (p2, u2)

            % On vérifie que l'élement ne contient pas un sous-élement
            % importé. Sinon on calcule la matrice de transfert des blocs
            % placés en amont du sous-élement importé et on calcule les
            % coefficient T11 et T22 de la matrice globale en utilisant
            % l'impédance de surface du bloc importé directement

            config = obj.Configuration;
            TM = perso_empty_TM(env.w);

            for i = 1:length(config.ListOfSubelements)
                sblm = config.ListOfSubelements{i};
                if isa(sblm, 'classsubelement_imported') || isa(sblm, 'classelementassembly')
                    
                    % exlications
                    % perso_ouvrir_lien_Obsidian('obsidian://open?vault=Maitrise%20REAR&file=Notes%20atomiques%2FNote%20Matlab%20-%20Imp%C3%A9dance%20de%20surface%20compos%C3%A9e')
                    S = config.ListOfSubelements{i}.Configuration.Surface;
                    % Debug
                    try
                        TM.T11 = TM.T11 .* config.ListOfSubelements{i}.surface_impedance(env)/S + TM.T12;
                    catch
                        sprinf('pause!');
                    end
                    TM.T21 = TM.T21 .* config.ListOfSubelements{i}.surface_impedance(env)/S + TM.T22;
                    return

                else
                    % % Debog
                    % if isa(sblm, 'classannularcavity')
                    %     sprintf('Blabla');
                    % end

                    TM = matprod(TM, sblm.transfer_matrix(env));
                end
            end
        end

        function [TM, p_in, u_in] =  transfer_matrix_iter(obj, env, p_in, u_in)

            config = obj.Configuration;

            % % debog : Tracé de la pression acoustique RMS au niveau de chaque sous-élement
            % perso_figure('p_rms');
            % plot(abs(p_in));

            for i = 1:length(config.ListOfSubelements)
                sblm = config.ListOfSubelements{i};
                if isa(sblm, 'function_handle')
                    sblm = sblm(abs(u_in));
                end
                
                [sblm_TM, p_in, u_in] = sblm.transfer_matrix_iter(env, p_in, u_in);
                
                % % debog (suite)
                % perso_figure('p_rms');
                % plot(abs(p_in));
                
                if exist('TM', 'var')
                    TM = matprod(TM, sblm_TM);
                else
                    TM = sblm_TM;
                end

                % % debog : Tracé des termes complexes de la matrice de transfert du sous-élement
                % perso_figure('TM')
                % perso_plot_transfer_matrix(sblm_TM, env);  
                % clf
            end 

            % % debog : Tracé des termes complexes de la matrice de transfert de l'élement
            % perso_figure('TM')
            % clf
            % perso_plot_transfer_matrix(TM, env);  

        end
        
        function TM_inv = inverse_transfer_matrix(obj, env) % (p2, u2) = TM_inv * (p1, u1)

            config = obj.Configuration;

            TM_inv = config.ListOfSubelements{end}.inverse_transfer_matrix(env);

            if length(config.ListOfSubelements) > 1
                for i = length(config.ListOfSubelements)-1:-1:1
                    TM_inv = matprod(TM_inv, config.ListOfSubelements{i}.inverse_transfer_matrix(env));
                end
            end
        end
  
        function TM_sb = side_branch_transfer_matrix(obj, env, Lx, M)

            TM_sb = struct();

            % perso_ouvrir_lien_Obsidian('obsidian://open?vault=Maitrise%20REAR&file=Notes%20atomiques%2FDescription%20du%20mod%C3%A8le%20approch%C3%A9%20utilis%C3%A9%20%C3%A0%20partir%20du%20nombre%20de%20Mach%20moyen')
            Z = obj.surface_impedance_iter(env);
            Lz = obj.Configuration.ElementWidth;
            param = env.air.parameters;
            rho0 = param.rho;
            c0 = param.c0;
            Z0 = param.Z0;
            w = env.w;
            k0 = w/c0;

            % Si le nombre de Mach de l'écoulement n'est pas donné
            if nargin < 4

                % Cas sans écoulement
                f = @(u) u.^2 + (1/3) .* u.^4 + (2/15) .* u.^6 - (1j .* rho0 .* Lx .* w) ./ Z;
                kx = fsolve(1, f)/Lx;
                kz = sqrt((w/c0).^2 - kx.^2);

                TM_sb.T11 = exp(-1j .* Lz .* kz);
                TM_sb.T12 = zeros(1, length(w));
                TM_sb.T21 = exp(1j .* Lz .* kz);
                TM_sb.T22 = zeros(1, length(w));
            
            % Si il est donné    
            else 

                % Cas avec écoulement
                fM_frwrd = @(y) (1j / (1 + M).^2) + (1j .* M ./ ((w/c0).^2 .* Lx.^2 .* (1 + M)) - Z ./ (rho0 .* w .* Lx)) .* y.^2 ...
                + (1j .* M ./ (4 .* k0.^4 .* Lx.^4) - Z ./ (3 .* rho0 .* w .* Lx)) .* y.^4 ...
                + (1j .* M .* (1 - M.^2) ./ (8 .* k0.^6 .* Lx.^6) - 2 .* Z ./ (15 .* rho0 .* w .* Lx)) .* y.^6;
                kx_frwrd = fsolve(fM_frwrd, ones(1, length(w)))/Lx;
                kz_frwrd = (-M .* k0 + sqrt(k0.^2 - (1 - M.^2) .* kx_frwrd.^2)) / (1 - M.^2);
    
                fM_bckwrd = @(w) (-1j / (1 - M).^2) + (1j .* M ./ (k0.^2 .* Lx.^2 .* (1 - M)) + Z ./ (rho0 .* w .* Lx)) .* w.^2 ...
                + (1j .* M ./ (4 .* k0.^4 .* Lx.^4) + Z ./ (3 .* rho0 .* w .* Lx)) .* w.^4 ...
                + (1j .* M .* (1 - M.^2) ./ (8 .* k0.^6 .* Lx.^6) + 2 .* Z ./ (15 .* rho0 .* w .* Lx)) .* w.^6;
                kx_bckwrd = fsolve(fM_bckwrd, ones(1, length(w)))/Lx;
                kz_bckwrd = (M .* k0 + sqrt(k0.^2 - (1 - M.^2) .* kx_bckwrd.^2)) ./ (1 - M.^2);

                
                % Calcul des éléments de la matrice
                Y_frwrd = Z0 .* (k0 - M .* kz_frwrd) ./ kz_frwrd;
                Y_bckwrd = Z0 .* (k0 + M .* kz_bckwrd) ./ kz_bckwrd;
                exp_term = exp(1j .* (kz_frwrd - kz_bckwrd) .* Lz)./(Y_frwrd + Y_bckwrd);
              
                TM_sb.T11 = exp_term.*(Y_bckwrd .* exp(-1j .* Lz .* kz_frwrd) + Y_frwrd .* exp(1j .* Lz .* kz_bckwrd));
                TM_sb.T12 = exp_term.*(Y_frwrd .* Y_bckwrd .* (exp(1j .* Lz .* kz_bckwrd) - exp(-1j .* Lz .* kz_frwrd)));
                TM_sb.T21 = exp_term.*(exp(1j .* Lz .* kz_bckwrd) - exp(-1j .* Lz .* kz_frwrd));
                TM_sb.T22 = exp_term.*(Y_frwrd .* exp(-1j .* Lz .* kz_frwrd) + Y_bckwrd .* exp(1j .* Lz .* kz_bckwrd));
            end



        end

        function Zs = surface_impedance(obj, env, varargin)

            if nargin > 2
                TM = varargin{1};
            else
                TM = obj.transfer_matrix(env);
            end

            S = obj.Configuration.Surface;
            % On revient en convention pression - vitesse
            Zs = S * TM.T11 ./ TM.T21; % rigid wall
        end

        function Zs_iter = surface_impedance_iter(obj, env, varargin)

            % Explications
            % perso_ouvrir_lien_Obsidian('obsidian://open?vault=Maitrise%20REAR&file=Notes%20atomiques%2FProc%C3%A9dure%20it%C3%A9rative%20pour%20obtenir%20l''imp%C3%A9dance%20de%20surface%20non-lin%C3%A9aire%20d''une%20solution%20multi-plaques')

            % Algorithme
            % Initialisation
            % u_rms(1, :) = zeros(1, length(env.w)) (vecteur des débits RMS à l'entrée des sous-élements, lignes par lignes)
            % p_rms(1, :) = P_rms_top (matrices des pression RMS à l'entrée des sous-élements, lignes par lignes)
            %
            % Pour le i_ème sous-élement : 
            % - on regarde si c'est un handle, si oui on appelle l'objet avec le veteur u_rms(i, :) donné en argument
            % - on ajoute la matrice de transfert à la liste en cours
            % - on calcule la matrice inverse
            % - on définit u_rms(i+1, :) et p_rms(i+1, :) à partir de la matrice inverse et de u_rms(i, :) et p_rms(i, :)
            % 
            % Evaluation itérative
            % - on calcule la surface d'impedance obtenue à partir de la matrice de transfert composée
            % - on calcule la nouvelle vitesse rms de surface new_u_rms à partir de p_rms(1, :) et de la surface d'impédance obtenue 
            % - condition de convergence : max(u_rms(1, :) - new_u_rms) < seuil

            % Initialisation
            u_rms = zeros(1, length(env.w));
            p_rms = env.p_rms;

            % % debog : Tracé de la pression acoustique RMS à l'entrée
            % perso_figure('p_rms');
            % plot(env.p_rms)

            % Paramètre de la procédure itérative
            
            % Tolérance pour la convergence
            if nargin > 2
                tol = varargin{1};
            else
                tol = 1e-4; 
            end

            max_iter = 500;  % Nombre maximum d'itérations
            iter = 0;
            converged = false;

            % % debog : Tracé des débits acoustiques RMS successives au cours de la procédure itérative
            % perso_figure('u_rms');
            % clf
            % title('Débit acoustique RMS à l''entrée de l''élement')
            % legend();
            % plot(env.w/(2*pi), u_rms, 'DisplayName', 'Itération 0')

            while ~converged && iter < max_iter
                iter = iter + 1;

                TM = obj.transfer_matrix_iter(env, p_rms, u_rms);

                % Vérification du critère de convergence
                Zs = obj.surface_impedance(env, TM);

                % % debog : Tracé de l'impédance de surface
                % perso_figure('Zs');
                % perso_plot_surface_impedance(Zs, env)

                new_u_rms = abs(p_rms) ./ abs(Zs) * obj.input_section();
                % new_u_rms = abs(p_rms) ./ abs(Zs);

                % % debog (suite)
                % perso_figure('u_rms');
                % plot(new_u_rms)
                
                convergence_criterium = max(abs(new_u_rms - u_rms));
                if convergence_criterium < tol
                    converged = true;
                    Zs_iter = Zs;
                else
                    u_rms = new_u_rms;
                end
            end
        end
    
        function TL = transmission_loss(obj, env, varargin)

            % Si la TM est donnée en entrée (ex : TM en parallèle)
            if nargin > 2
                TM = varargin{1};
            else
                TM = obj.transfer_matrix(env);
            end

            S = obj.Configuration.InputSection;
            param = env.air.parameters;
            Z0 = param.Z0;
            
            % % Convention Pression - Vitesse
            % TL = 20 * log10(abs(0.5 * (TM.T11 + TM.T12/Z0 + Z0*TM.T21 + TM.T22)));

            % Convention Pression - Débit
            TL = 20 * log10(abs(0.5 * (TM.T11 + TM.T12 * S/Z0 + Z0/S * TM.T21 + TM.T22)));
        end 

        function alpha = alpha(obj, env, varargin) % retourne le vecteur coefficient d'absorption

            if nargin > 2 && strcmp(varargin{1}, "iter")
                if nargin > 3
                    Zs = obj.surface_impedance_iter(env, varargin{2}); % tol
                else   
                    Zs = obj.surface_impedance_iter(env);
                end
            else
                Zs = obj.surface_impedance(env);
            end

            param = env.air.parameters;
            Z0 = param.rho * param.c0;
            alpha = 1 - abs((Zs - Z0) ./ (Zs + Z0)).^2;
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

        function obj = plot_alpha(obj, env, name) % f_min, f_max 

            % figure()
            hold on
            
            % Résultats analytiques
            alpha = obj.alpha(env);
            f = env.w / (2 * pi);
            color = perso_random_color_rgb_triplet();
            plot_anal = plot(f, alpha, 'color', color, 'DisplayName', name);
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
            perso_configure_alpha_figure(3000);
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

        function config = create_config(list_of_subelements, end_status, surface)

            config = {};
            config.ListOfSubelements = list_of_subelements;
            config.EndStatus = end_status;
            config.Surface = surface;
        end
    end
end
