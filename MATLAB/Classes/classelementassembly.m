 classdef classelementassembly

    % References :
    
    %         [1] Transfer Matrix Method Applied to the Parallel Assembly 
    %             of Sound Absorbing Materials
    %         [2] Comparison between parallel transfer matrix method and 
    %             admittance sum method

    % Par besoin de formulation d'une condition de fin, les éléments ouverts d'un objet de classe classelementassembly débouchent tous sur un même plan
    % dans la direction de propagation de l'onde
    
    properties

        Configuration
    end
    
    methods
        function obj = classelementassembly(config)

            obj.Configuration = config;
        end
        
        function r = input_ratios(obj)

            % On récupère la liste des ratios de surfaces
            r = zeros(1, length(obj.Configuration.ListOfElements));
            for i = 1:length(obj.Configuration.ListOfElements)
                r(i) = obj.Configuration.ListOfElements{i}.Configuration.Surface;
            end

            r = r./obj.Configuration.Surface;
        end
        
        function TM = transfer_matrix(obj, env, varargin)

            opened_elements = [];
            closed_elements = [];
            TM_list = cell(1, length(obj.Configuration.ListOfElements));
            Y_list = cell(1, length(obj.Configuration.ListOfElements));

            r = input_ratios(obj);

            for i = 1:length(obj.Configuration.ListOfElements)

                % fprintf('\nclass(obj) : %s\n',class(obj))
                % fprintf('\nclass(obj.ListOfElements) : %s\n',class(obj.ListOfElements))
                % fprintf('\nclass(obj.ListOfElements{%d}) : %s\n', i, class(obj.ListOfElements{i}))

                if strcmp(obj.Configuration.ListOfElements{i}.Configuration.EndStatus, 'opened')
                    opened_elements = [opened_elements, i]; % list of the indexes of open elements
                else
                    closed_elements = [closed_elements, i]; % list of indexes of closed elements
                end

                % Dans le code actuel, les matrices de transfert sont
                % formulées en pression - débit. On fait la transformation
                % inverse pour revenir en pression - vitesse.

                if nargin > 2 && isstring(varargin{1}) && strcmp(varargin{1}, "iter")
                    TM = obj.Configuration.ListOfElements{i}.transfer_matrix_iter(env);
                else
                    TM = obj.Configuration.ListOfElements{i}.transfer_matrix(env);
                end

                % % Debog
                % figure();
                % perso_plot_transfer_matrix(TM, env);

                TM.T12 = TM.T12 * obj.Configuration.ListOfElements{i}.Configuration.Surface;
                TM.T21 = TM.T21 / obj.Configuration.ListOfElements{i}.Configuration.Surface;
                % TM.T12 = TM.T12 * obj.Configuration.ListOfElements{i}.Configuration.Section;
                % TM.T21 = TM.T21 / obj.Configuration.ListOfElements{i}.Configuration.Section;
                TM_list{i} = TM;
                Y_list{i} = perso_TM_to_YM(TM_list{i}); % admittance ([2] eq. 5)

                % % Debog
                % figure();
                % perso_plot_admittance_matrix(Y_list{i}, env);

            end

            % Calculate all the sums needed in the final matrix (because they are used several times) 
            % i all the elements
            % j open elements
            % k closed elements

            rjyj12 = 0;
            rjyj21 = 0;
            rjyj22 = 0;
            riyi11 = 0;
            bigsumk = 0;

            % opened and closed cells

            for i = 1:length(obj.Configuration.ListOfElements)
                riyi11 = riyi11 + r(i) .* Y_list{i}.Y11;
            end

            % opened cells

            for j = 1:length(opened_elements)
                rjyj21 = rjyj21 + r(opened_elements(j)) .* Y_list{opened_elements(j)}.Y21;
                rjyj22 = rjyj22 + r(opened_elements(j)) .* Y_list{opened_elements(j)}.Y22;
                rjyj12 = rjyj12 + r(opened_elements(j)) .* Y_list{opened_elements(j)}.Y12;
            end

            % closed cells

            for k = 1:length(closed_elements)
                bigsumk = bigsumk + r(closed_elements(k)) .* Y_list{closed_elements(k)}.Y12 .* Y_list{closed_elements(k)}.Y21 ./ Y_list{closed_elements(k)}.Y22;
            end

            % Final matrix (opened and closed cells) ([2] eq. 3)

            TM = struct();
            TM.T11 = -rjyj22 ./ rjyj21;
            TM.T12 =  1 ./ rjyj21;
            TM.T21 = -1 ./ rjyj21 .* (rjyj22 .* (riyi11-bigsumk)-rjyj12 .* rjyj21);
            TM.T22 = -1 ./ rjyj21 .* (bigsumk-riyi11);

            % Debog
            % figure();
            % perso_plot_transfer_matrix(TM, env)
        end 

        function [TM, p_in, u_in] =  transfer_matrix_iter(obj, env, p_in, u_in)

            config = obj.Configuration;

            % % debog : Tracé de la pression acoustique RMS au niveau de chaque sous-élement
            % perso_figure('p_rms');
            % plot(abs(p_in));

            for i = 1:length(config.ListOfElements)
                elem = config.ListOfElements{i};
                if isa(elem, 'function_handle')
                    elem = elem(abs(u_in));
                end
                
                [sblm_TM, p_in, u_in] = elem.transfer_matrix_iter(env, p_in, u_in);
                
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
        
        function TM_sb = side_branch_transfer_matrix(obj, env, Lx, M)
            
            config = obj.Configuration;

            TM_sb = config.ListOfSubelements{1}.side_branch_transfer_matrix(env, Lx, M);

            for i = 2:length(config.ListOfSubelements)

                TM_sb = matprod(Tm_sb, config.ListOfSubelements{i}.side_branch_transfer_matrix(env, Lx, M));
            end
        end
        
        function Zs = surface_impedance(obj, env, varargin)
                
            Ysum = zeros(1, length(env.w));
            r = obj.input_ratios();
            elem_list = obj.Configuration.ListOfElements;

            for i = 1:length(elem_list)
                elem = elem_list{i};
                TM = elem.transfer_matrix(env);

                % % Debog : Matrices de transfert des élements
                % perso_figure('Matrices de transfert des élements dans classelementassembly\surface_impedance');
                % perso_plot_transfer_matrix(TM, env, ['Element', num2str(i)]);

                Ysum = Ysum + r(i) * TM.T21 ./ TM.T11 / elem.Configuration.Surface;

                % % Debog : Contribution des admittances de surface
                % perso_figure('Admittance de surface des élements dans classelementassembly\surface_impedance');
                % perso_plot_surface_admittance(r(i) * TM.T21 ./ TM.T11 / elem.Configuration.Surface, env, ['Contribution de l''élement', num2str(i)]);
                % % legend()
            end

            Zs = 1 ./ Ysum;

            % else
                % TM = obj.transfer_matrix(env);
                % Zs = TM.T11 ./ TM.T21; % rigid wall
            % end
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
            Zs_iter = 0;
            distance = 0;

            % % debog : Tracé de la pression acoustique RMS à l'entrée
            % perso_figure('p_rms');
            % plot(env.p_rms)

            % Paramètre de la procédure itérative
            
            % Tolérance pour la convergence
            if nargin > 2
                tol = varargin{1};
            else
                tol = 1e-3; 
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

            r = obj.input_ratios();
            elem_list = obj.Configuration.ListOfElements;

            while ~converged && iter < max_iter
                iter = iter + 1;

                Ysum = zeros(1, length(env.w));

                for i = 1:length(elem_list)
                    elem = elem_list{i};
                    TM = elem.transfer_matrix_iter(env, p_rms, u_rms);

                    % % Debog : TM des élements
                    % perso_figure('TM des élements dans classelementassembly\surface_impedance_iter');
                    % perso_plot_transfer_matrix(TM, env, ['TM élement ', num2str(i)]);
                    
                    Ysum = Ysum + r(i) * TM.T21 ./ TM.T11 / elem.Configuration.Surface;

                    % % Debog : Contribution des admittances de surface
                    % perso_figure('Admittance de surface des élements dans classelementassembly\surface_impedance_iter');
                    % perso_plot_surface_admittance(r(i) * TM.T21 ./ TM.T11 / elem.Configuration.Surface, env, ['Contribution de l''élement', num2str(i)]);
                    % % legend()
                end

                % % Debog : Contribution des admittances de surface
                % perso_figure('Admittance de surface de l''assemblage dans classelementassembly\surface_impedance_iter');
                % perso_plot_surface_admittance(Ysum, env, ['Itération ', num2str(iter)]);
                % % legend()

                Zs = 1 ./ Ysum;

                % % Debog : Tracé de l'impédance de surface
                % perso_figure('Impédance de surface de l''assemblage dans classelementassembly\surface_impedance_iter');
                % perso_plot_surface_impedance(Zs, env, ['Itération ', num2str(iter)]);

                % % Debog : Partie réelle négatve
                % find(real(Zs) < 0);

                new_u_rms = abs(p_rms) ./ abs(Zs) * obj.Configuration.Surface;
                % new_u_rms = abs(p_rms) ./ abs(Zs);

                % % Debog (suite)
                % perso_figure('u_rms');
                % plot(new_u_rms);
                
                convergence_criterium = max(abs(new_u_rms - u_rms));

                % % Debog : Critère de convergence
                % perso_figure('Convergence');
                % scatter(iter, convergence_criterium, 'Color', 'b', 'HandleVisibility', 'off');
                % % ylim([-1e-2 1e-2]);

                if convergence_criterium < tol
                    converged = true;
                    Zs_iter = Zs;
                else
                    u_rms = new_u_rms;
                end
            end
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

            % % Debog : alpha négatif
            % find(alpha < 0);
        end

        function [f_max, alpha_max] = alpha_peak(obj, env, f_min, f_max) 
            % Retourne les fréquences et les amplitudes des pics d'absorption (y compris les maximums locaux)
            
            % Calculer la fonction alpha à partir de l'objet et de l'environnement
            a = obj.alpha(env);
            m = (env.w / (2*pi) > f_min) & (env.w / (2*pi) < f_max);

            % Identifier les maximums locaux dans la fonction alpha
            % On compare chaque valeur avec ses voisins gauche et droit
            local_maxs = (a(2:end-1) > a(1:end-2)) & (a(2:end-1) > a(3:end)); % Conditions pour des maximums locaux
            
            % Inclure les bords si nécessaire (maximum global ou bords)
            local_maxs = [a(1) > a(2), local_maxs, a(end) > a(end-1)]; 

            % On masque les parties non-désirées du spectre
            local_maxs_m = local_maxs .* m ;

            % Récupérer les indices des maximums locaux
            max_indices = find(local_maxs_m);
            
            % Calculer les fréquences correspondantes à ces maximums
            f_max = env.w(max_indices) / (2 * pi);
            alpha_max = a(max_indices);
        end

        function obj = plot_alpha(obj, env, name, varargin)

            alpha = obj.alpha(env, varargin{:});
            f = env.w / (2 * pi);
            plot(f, alpha, 'DisplayName', name);
            perso_configure_alpha_figure(3000);
        end
    
        function mean_alpha = alpha_mean(obj, env, f_min, f_max)
            mask = @(env) (env.w / (2*pi) > f_min & env.w / (2*pi) < f_max);
            alpha = obj.alpha(env);
            mean_alpha = mean(alpha(mask(env)));
        end
    end 

    methods (Static, Access = public)

        function config = create_config(list_of_elements)

            config = struct();
            config.ListOfElements = list_of_elements;

            % Parcours la liste des élements. Si l'un d'entre eux est
            % ouvert, on ferme les autres. Si aucun n'est ouvert on ouvre
            % le premier

            have_opened = 0;
            for i = 1:length(config.ListOfElements)
                % Si l'élement est ouvert et que c'est le premier
                try  
                    end_status = config.ListOfElements{i}.Configuration.EndStatus;
                catch ME
                    warning(ME.identifier, "Erreur capturée: %s", ME.message);
                    pause; % stoppe l’exécution jusqu’à une touche
                end

                if (strcmp(config.ListOfElements{i}.Configuration.EndStatus, 'opened'))
                    if (have_opened == 0)
                       have_opened = 1;
                    else
                        config.ListOfElements{i}.Configuration.EndStatus = 'closed';
                    end
                end
            end

            if have_opened == 0
                config.ListOfElements{i}.Configuration.EndStatus = 'opened';
            
            end

            % On récupère la liste des ratios de surfaces
            sum_surface = 0;
            % r = zeros(1, length(config.ListOfElements));
            
            for i = 1:length(config.ListOfElements)
                sum_surface = sum_surface + config.ListOfElements{i}.Configuration.Surface;
            end

            config.Surface = sum_surface;
        end
    end
end

