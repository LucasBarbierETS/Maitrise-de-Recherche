 classdef classelementassembly

    % References :
    
    %         [1] Transfer Matrix Method Applied to the Parallel Assembly 
    %             of Sound Absorbing Materials
    %         [2] Comparison between parallel transfer matrix method and 
    %             admittance sum method

    % Par besoin de formulation d'une condition de fin, les éléments ouverts d'un objet de classe classelementassembly débouchent tous sur un même plan
    % dans la direction de propagation de l'onde
    
    properties

        HandleAppBuilder = @(app, class_element_assembly) AppElementAssembly.class_to_app(app, class_element_assembly)
        Configuration
    end
    
    methods % Constructeur
        function obj = classelementassembly(config)

            obj.Configuration = config;
        end
    end

    methods % Matrices
        function TM = transfer_matrix(obj, env, options)

            arguments
                obj
                env
                options.pt_in = NaN
                options.u_in = NaN
                options.IndexPosition = []
            end
            
            args = namedargs2cell(options);
            opened_elements = obj.Configuration.OpenedElements;
            closed_elements = obj.Configuration.ClosedElements;

            % Somme des admittances

            Yu = zeros(1, length(env.w));

            if isempty(opened_elements)
                
                for k = 1:length(closed_elements)
                    
                    TM = closed_elements{k}.transfer_matrix(env, args{:});
                    Yu = Yu + TM.T21 ./ TM.T11;
                end
            
                TM = struct();
                TM.T11 = ones(1, length(env.w));
                TM.T21 = Yu;
                TM.T12 = zeros(1, length(env.w)); 
                TM.T22 = zeros(1, length(env.w));
                return
            end
        
            % P-TMM

            A = 0; B = 0; C = 0; D = 0;
       
            % Éléments ouverts
            for j = 1:length(opened_elements)
                
                YM = opened_elements{j}.admittance_matrix(env, args{:});
                A = A + YM.Y22;
                B = B + YM.Y21;
                C = C + YM.Y12;
                D = D + YM.Y11;
            end
        
            % Éléments fermés
            for k = 1:length(closed_elements)
                
                YM = closed_elements(k).admittance_matrix(env, args{:});
                D = D + YM.Y11 - YM.Y12 .* YM.Y21 ./ YM.Y22;
            end
        
            % Matrice finale (équation [2] eq. 3)
            TM = struct();
            TM.T11 = -A ./ B;
            TM.T12 =  1 ./ B;
            TM.T21 = C - A .* D ./ B;
            TM.T22 = D ./ B;
        end 
        
        function TM_sb = side_branch_transfer_matrix(obj, env, Lx, M)
            
            config = obj.Configuration;

            TM_sb = config.ListOfSubelements{1}.side_branch_transfer_matrix(env, Lx, M);

            for i = 2:length(config.ListOfSubelements)

                TM_sb = matprod(Tm_sb, config.ListOfSubelements{i}.side_branch_transfer_matrix(env, Lx, M));
            end
        end
    end

    methods % Indicateurs acoustiques
        
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

        function Zs_iter = surface_impedance_iter(obj, env, options)

            arguments
                obj
                env
                options.tolerance = 1e-3
                options.max_iter = 500;
            end

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
            u = zeros(1, length(env.w));
            pt = env.pt;
            Zs_iter = 0;
            iter = 0;
            converged = false;

            while ~converged && iter < options.max_iter
                iter = iter + 1;

                Zs = obj.surface_impedance(env, 'pt_in', pt, 'u_in', u);
                new_u = pt ./ Zs * obj.Configuration.Surface;

                % % Debog : Tracé de l'impédance de surface
                % perso_figure('Impédance de surface de l''assemblage dans classelementassembly\surface_impedance_iter');
                % perso_plot_surface_impedance(env.w/(2*pi), Zs, env, ['Itération ', num2str(iter)]);

                % % Debog : Partie réelle négative
                % find(real(Zs) < 0);

                % % Debog : Vitesse RMS à l'entrée de l'assemblage
                % perso_figure('u dans classelementassembly\surface_impedance_iter');
                % plot(env.w/(2*pi), new_u);
                
                convergence_criterium = max(abs(u - new_u));

                % % Debog : Critère de convergence
                % perso_figure('Convergence dans classelementassembly\surface_impedance_iter');
                % scatter(iter, convergence_criterium, 'Color', 'b', 'HandleVisibility', 'off');
                % % ylim([-1e-2 1e-2]);

                if convergence_criterium < options.tolerance
                    converged = true;
                    Zs_iter = Zs;
                else
                    u = new_u;
                end   
            end
        end
        
        function alpha = alpha(obj, env, varargin) % retourne le vecteur coefficient d'absorption

            if nargin > 2 && strcmp(varargin{1}, "iter")
                if nargin > 3
                    Zs = obj.surface_impedance_iter(env, varargin{2});
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

    methods (Static, Access = public) % Configurations

        function config = create_config(list_of_elements)

            config = struct();
            config.ListOfElements = list_of_elements;
            config.EndStatus = 'closed';
            sum_surface = 0;

            for i = 1:length(config.ListOfElements)
                sum_surface = sum_surface + config.ListOfElements{i}.Configuration.Surface;
                if strcmp(config.ListOfElements{i}.Configuration, 'opened')
                    config.EndStatus = 'opened';
                end
            end

            config.OpenedElements = cell({});
            config.ClosedElements = cell({});

            for i = 1:length(config.ListOfElements)
        
                if strcmp(config.ListOfElements{i}.Configuration.EndStatus, 'opened')
                    config.OpenedElements{end+1} = config.ListOfElements{i};
                else
                    config.ClosedElements{end+1} = config.ListOfElements{i};
                end
            end
        
            config.Surface = sum_surface;
        end
    end
 end