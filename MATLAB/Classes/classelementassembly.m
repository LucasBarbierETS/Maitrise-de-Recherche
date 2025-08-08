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

        function s = input_section(obj)

            s = 0;
            loe = obj.Configuration.ListOfElements;
            for i = 1:length(loe)
                s = s + obj.Configuration.ListOfElements{i}.input_section();
            end
        end
        
        function r = input_ratios(obj)

            % On récupère la liste des ratios de surfaces
            r = zeros(1, length(obj.Configuration.ListOfElements));
            for i = 1:length(obj.Configuration.ListOfElements)
                r(i) = obj.Configuration.ListOfElements{i}.input_section();
            end

            r = r./obj.input_section();
        end
        
        function TM = transfer_matrix(obj, env)

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

                TM = obj.Configuration.ListOfElements{i}.transfer_matrix(env);

                % % Debog
                % figure();
                % perso_plot_transfer_matrix(TM, env);

                TM.T12 = TM.T12 * obj.Configuration.ListOfElements{i}.Configuration.InputSection;
                TM.T21 = TM.T21 / obj.Configuration.ListOfElements{i}.Configuration.InputSection;
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

        function TM_sb = side_branch_transfer_matrix(obj, env, Lx, M)
            
            config = obj.Configuration;

            TM_sb = config.ListOfSubelements{1}.side_branch_transfer_matrix(env, Lx, M);

            for i = 2:length(config.ListOfSubelements)

                TM_sb = matprod(Tm_sb, config.ListOfSubelements{i}.side_branch_transfer_matrix(env, Lx, M));
            end
        end
        
        function Zs = surface_impedance(obj, env, varargin)

            % if nargin > 2 && strcmp(varargin{1}, 'admittance_sum')
                
                Ysum = zeros(1, length(env.w));
                r = obj.input_ratios();
                elem_list = obj.Configuration.ListOfElements;

                for i = 1:length(elem_list)
                    elem = elem_list{i};
                    TM = elem.transfer_matrix(env);
                    Ysum = Ysum + r(i) * TM.T21 ./ TM.T11 / elem.input_section();
                end

                Zs = 1 ./ Ysum;

            % else
                % TM = obj.transfer_matrix(env);
                % Zs = TM.T11 ./ TM.T21; % rigid wall
            % end
        end

        function alpha = alpha(obj, env, varargin) % retourne le vecteur coefficient d'absorption
            Zs = obj.surface_impedance(env, varargin);
            param = env.air.parameters;
            Z0 = param.rho * param.c0;
            alpha = 1 - abs((Zs - Z0) ./ (Zs + Z0)).^2;
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

            % Résultats analytiques
            alpha = obj.alpha(env, varargin);
            f = env.w / (2 * pi);
            plot(f, alpha, 'DisplayName', name)
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
            sum_section = 0;
            r = zeros(1, length(config.ListOfElements));
            
            for i = 1:length(config.ListOfElements)
                sum_section = sum_section + config.ListOfElements{i}.input_section();
            end

            config.InputSection = sum_section;
        end
    end
end

