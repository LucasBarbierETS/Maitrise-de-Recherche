classdef classelement < classobject
    
    properties 

        ListOfObjects
    end

    methods % Constructeur
        
        function obj = classelement(config)
            
            obj@classobject(config)
            obj.HandleAppBuilder = @(app, class_elm) AppElement.class_to_app(app, class_elm);
            obj.HandleAppConfig = @(class_config) struct('Surface', class_config.Surface);
        end
    end

    methods % Matrices

        function [TM, options] = transfer_matrix(obj, env, options) 

            % Gestion des options
            default = struct('Id', 1);
            options = parse_options(options, default, {});

            config = obj.Configuration;
            TM = perso_empty_TM(env.w);

            for i = 1:length(config.ListOfObjects)
                
                sblm = config.ListOfObjects{i};
                options.Id = [options.Id, i];

                if isa(sblm, 'classelement_imported') || isa(sblm, 'classelementassembly')
                    
                    S = sblm.Configuration.Surface;

                    try
                        TM.T11 = TM.T11 .* sblm.surface_impedance(env, options)/S + TM.T12;
                    catch
                        sprinf('pause!');
                    end
                    TM.T21 = TM.T21 .* sblm.surface_impedance(env, options)/S + TM.T22;
                    return
                end

                try
                    [sblm_TM, options] = sblm.transfer_matrix(env, options);
                catch
                    error('Erreur dans classelement/transfer_matrix');
                end

                TM = matprod(TM, sblm_TM);

                % % Debog : Tracé de la matrice de transfert incrémentée
                % perso_figure('Tracé de la matrice de transfert incrémentée dans classelement/transfer_matrix');
                % if i == 1
                %     clf;
                % end
                % 
                % if all(structfun(@(x) all(isnan(x), 'all'), TM))
                %     error('Matrice de transfert vide dans classelement/transfer_matrix')
                % end
                % 
                % sgtitle(class(sblm))
                % perso_plot_transfer_matrix(TM, env, 'TM');
                % 
                % if isprop(sblm.Configuration, 'EndStatus') && strcmp(sblm.Configuration.EndStatus, 'closed')
                %     break
                % end
            end
        end
                    
        % function [TM_inv, options] = inverse_transfer_matrix(obj, env, options) 
        % 
        %     arguments
        %         obj
        %         env
        %         options.pt_in = NaN
        %         options.u_in = NaN
        %         options.TM = NaN
        %         options.IndexPosition = []
        %     end
        % 
        %     config = obj.Configuration;
        %     TM_inv = perso_empty_TM(env.w);
        %     idp = options.IndexPosition;
        % 
        %     for i = 1:length(config.ListOfObjects)
        % 
        %         sblm = config.ListOfObjects{i};
        %         if isprop(sblm.Configuration, 'EndStatus') && strcmp(sblm.Configuration.EndStatus, 'closed')
        %             break
        %         end
        % 
        %         options.IndexPosition = [idp, i];
        %         args = namedargs2cell(options);
        %         [sblm_TM_inv, options] = sblm.inverse_transfer_matrix(env, options);
        %         TM_inv = matprod(sblm_TM_inv, TM_inv);
        % 
        %         % % Debog : Tracé de la matrice de transfert incrémentée
        %         % perso_figure('Tracé de la matrice de transfert incrémentée dans classelement/transfer_matrix');
        %         % if i == 1
        %         %     clf;
        %         % end
        %         % 
        %         % if all(structfun(@(x) all(isnan(x), 'all'), TM))
        %         %     error('Matrice de transfert vide dans classelementassembly/transfer_matrix')
        %         % end
        %         %
        %         % sgtitle(class(sblm))
        %         % perso_plot_transfer_matrix(TM, env, 'TM');
        %     end
        % end
      
        % function TM_sb = side_branch_transfer_matrix(obj, env, Lx, M) avec écoulement
        % 
        %     opts = optimoptions('fsolve','Display','off','FunctionTolerance',1e-12,'StepTolerance',1e-12);
        % 
        %     TM_sb = struct();
        % 
        %     % perso_ouvrir_lien_Obsidian('obsidian://open?vault=Maitrise%20REAR&file=Notes%20atomiques%2FDescription%20du%20mod%C3%A8le%20approch%C3%A9%20utilis%C3%A9%20%C3%A0%20partir%20du%20nombre%20de%20Mach%20moyen')
        %     % Z = obj.surface_impedance_iter(env);
        %     Z = obj.surface_impedance(env);
        %     Lz = obj.Configuration.ListOfObjects{1}.Configuration.Width;
        %     param = env.air.parameters;
        %     rho0 = param.rho;
        %     c0 = param.c0;
        %     Z0 = param.Z0;
        %     w = env.w;
        %     k0 = w/c0;
        % 
        %     % Si le nombre de Mach de l'écoulement n'est pas donné
        %     if nargin < 4
        % 
        %         % Cas sans écoulement
        %         M = 0;
        %         f = @(i, u) (u.^2 + (1/3).*u.^4 + (2/15).*u.^6) - 1j * rho0 * Lx * w(i) / Z(i);
        %         u  = perso_fsolve(f, w);
        %         kx = u / Lx; 
        % 
        %         % % Debog : kx
        %         % perso_figure('Debog - classelement - side_branch_transfer_matrix - Cas sans écoulement - kx')
        %         % subplot(1, 2, 1)
        %         % plot(env.w/(2*pi), real(kx))
        %         % subplot(1, 2, 2)
        %         % plot(env.w/(2*pi), imag(kx))
        %         % % close()
        % 
        %         kz_frwrd = sqrt((w/c0).^2 - kx'.^2);
        %         kz_bckwrd = kz_frwrd;
        % 
        %     % Si il est donné    
        %     else 
        % 
        %         % Cas avec écoulement
        %         fM_frwrd = @(i, y) (1j/(1+M)^2) ...
        %         + ( 1j*M/( (k0(i)^2) * Lx^2 * (1+M) ) -  Z(i)/(rho0*w(i)*Lx) ) * y.^2 ...
        %         + ( 1j*M/( 4*(k0(i)^4)*Lx^4 )       -  Z(i)/(3*rho0*w(i)*Lx) ) * y.^4 ...
        %         + ( 1j*M*(1-M^2)/( 8*(k0(i)^6)*Lx^6 ) - 2*Z(i)/(15*rho0*w(i)*Lx) ) * y.^6;
        %         % kx_frwrd = perso_fsolve(fM_frwrd, w)/Lx; % traitement d'un seul côté
        %         kx_frwrd = 2 * perso_fsolve(fM_frwrd, w)/Lx; % traitement des deux côtés
        %         kz_frwrd = (-M .* k0 + sqrt(k0.^2 - (1 - M.^2) .* kx_frwrd'.^2)) / (1 - M.^2);
        % 
        %         fM_bckwrd = @(i, z) (-1j/(1-M)^2) ...
        %         + ( 1j*M/( (k0(i)^2)*Lx^2*(1-M) ) +  Z(i)/(rho0*w(i)*Lx) ) * z.^2 ...
        %         + ( 1j*M/( 4*(k0(i)^4)*Lx^4 )      +  Z(i)/(3*rho0*w(i)*Lx) ) * z.^4 ...
        %         + ( 1j*M*(1-M^2)/( 8*(k0(i)^6)*Lx^6 ) + 2*Z(i)/(15*rho0*w(i)*Lx) ) * z.^6;
        %         % kx_bckwrd = perso_fsolve(fM_bckwrd, w)/Lx; % traitement d'un seul côté
        %         kx_bckwrd = 2 * perso_fsolve(fM_bckwrd, w)/Lx; % traitement des deux côtés
        %         kz_bckwrd = (M .* k0 + sqrt(k0.^2 - (1 - M.^2) .* kx_bckwrd'.^2)) ./ (1 - M.^2);
        %     end 
        % 
        %     % Calcul des éléments de la matrice
        %     Y_frwrd = Z0 .* (k0 - M .* kz_frwrd) ./ kz_frwrd;
        %     Y_bckwrd = Z0 .* (k0 + M .* kz_bckwrd) ./ kz_bckwrd;
        %     exp_term = exp(1j .* (kz_frwrd - kz_bckwrd) .* Lz)./(Y_frwrd + Y_bckwrd);
        %     TM_sb.T11 = exp_term.*(Y_bckwrd .* exp(-1j .* Lz .* kz_frwrd) + Y_frwrd .* exp(1j .* Lz .* kz_bckwrd));
        %     TM_sb.T12 = exp_term.*(Y_frwrd .* Y_bckwrd .* (exp(1j .* Lz .* kz_bckwrd) - exp(-1j .* Lz .* kz_frwrd)));
        %     TM_sb.T21 = exp_term.*(exp(1j .* Lz .* kz_bckwrd) - exp(-1j .* Lz .* kz_frwrd));
        %     TM_sb.T22 = exp_term.*(Y_frwrd .* exp(-1j .* Lz .* kz_frwrd) + Y_bckwrd .* exp(1j .* Lz .* kz_bckwrd));
        % end

        function TM_sb = side_branch_transfer_matrix(obj, env, Lx, M)
            
            config = obj.Configuration;

            TM_sb = config.ListOfObjects{1}.side_branch_transfer_matrix(env, Lx, M);

            for i = 2:length(config.ListOfObjects)

                TM_sb = matprod(Tm_sb, config.ListOfObjects{i}.side_branch_transfer_matrix(env, Lx, M));
            end
        end
    end

    methods % Indicateurs acoustiques

        function Zs = surface_impedance(obj, env, options)

            % Gestion des options
            default = struct('tolerance', 1e-3, ...
                             'max_iter', 500, ...
                             'HL_method', "linear", ...
                             'Flow_method', "without", ...
                             'Id', 1, ...
                             'u_ext', zeros(1, length(env.w)), ...
                             'u_in', zeros(1, length(env.w)), ...
                             'pt_in', env.pt);
        
            valid = struct('HL_method', ["linear", "all", "first", "retropropagation"], ...
                           'Flow_method', ["with", "without"]);

            options = parse_options(options, default, valid);

            % Initialisation de l'algorithme itératif
            iter = 0;
            converged = false;
            S = obj.Configuration.Surface;

            while ~converged && iter < options.max_iter
                iter = iter + 1;

                [TM, options] = obj.transfer_matrix(env, options);
                Zs = S * TM.T11 ./ TM.T21;
                u_ext = env.pt ./ Zs * S;

                % % Debog : Matrice de transfert inverse
                % perso_figure('TM d''un sous-élement dans classelement/surface_impedance')
                % clf;
                % sgtitle(class(obj))
                % perso_plot_transfer_matrix(TM, env, 'TM'); 

                % % Debog : Tracé de l'impédance de surface
                % perso_figure('Impédance de surface dans classsubelement/surface_impedance');
                % perso_plot_surface_impedance(env.w/(2*pi), Zs, env, ['Itération ', num2str(iter)]);

                % % Debog : Partie réelle négative
                % find(real(Zs) < 0);

                % % Debog : Vitesse RMS à l'entrée de l'assemblage
                % perso_figure('u dans classelement/surface_impedance');
                % plot(env.w/(2*pi), u_ext);
                
                convergence_criterium = max(abs(options.u_ext - u_ext));

                % % Debog : Critère de convergence
                % perso_figure('Convergence dans classsubelement/surface_impedance');
                % scatter(iter, convergence_criterium, 'Color', 'b', 'HandleVisibility', 'off');
                % % ylim([-1e-2 1e-2]);

                if convergence_criterium < options.tolerance
                    converged = true;
                else
                    options.u_ext = u_ext;
                end   
            end
        end
        
        function R = reflexion_coefficient(obj, env, options)

            Z0 = env.air.parameters.Z0;
            Zs = obj.surface_impedance(env, options);
            R = (Zs - Z0) ./ (Zs + Z0);
        end

        function alpha = absorption_coefficient(obj, env, options) 

            alpha = 1 - abs(obj.reflexion_coefficient(env, options)).^2;
        end
   
        function TL = transmission_loss(obj, env, options)


            TM = obj.transfer_matrix(env, options);
            S = obj.Configuration.Surface;
            param = env.air.parameters;
            Z0 = param.Z0;
            
            % % Convention Pression - Vitesse
            % TL = 20 * log10(abs(0.5 * (TM.T11 + TM.T12/Z0 + Z0*TM.T21 + TM.T22)));

            % Convention Pression - Débit
            TL = 20 * log10(abs(0.5 * (TM.T11 + TM.T12 * S/Z0 + Z0/S * TM.T21 + TM.T22)));
        end 
         
        function mean_alpha = alpha_mean(obj, env, f_min, f_max)
            mask = @(env) (env.w / (2*pi) > f_min & env.w / (2*pi) < f_max);
            alpha = obj.absorption_coefficient(env);
            mean_alpha = mean(alpha(mask(env)));
        end

        function [peak_frequencies, peak_alpha] = alpha_peak(obj, env, varargin) 
            % Retourne les fréquences et les amplitudes des pics d'absorption (y compris les maximums locaux)

            if nargin > 2
                a = varargin{1};
            else
                % Calculer la fonction alpha à partir de l'objet et de l'environnement
                a = obj.absorption_coefficient(env);
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

            error = 1/length(env.w)*sum(abs(obj.absorption_coefficient(env) - alpha_comp)./alpha_comp);
            % perso_ouvrir_lien_Zotero('zotero://open-pdf/library/items/233HZ8GN?page=8&annotation=62TL63NL');
        end   
    end


    methods        
            
        function output_model = set_COMSOL_2D_Model(obj, input_model, elem_index, env)
            
            config = obj.Configuration;
            for i = 1:length(config.ListOfObjects)
                input_model = config.ListOfObjects{i}.set_COMSOL_2D_Model(input_model, elem_index, i, env);
            end

            output_model = input_model;
        end
                
        function disp_subelements_parameters_table(obj, env)

            obj.disp_parameters_table(env);
            config = obj.Configuration;
            for i = 1: length(config.ListOfObjects)
                % Si le sous-élement est un objet de classe 'classelement', on appelle la fonction de manière récursive
                if isfield(config.ListOfObjects{i}.Configuration, 'ListOfObjects')
                    config.ListOfObjects{i}.disp_subelements_parameters_table(env);
                else
                    config.ListOfObjects{i}.disp_parameters_table(env)
                end
            end
        end

        function obj = plot_surface_impedance(obj, env, name, varargin)

            hold on
            
            if nargin > 3
                Zs = obj.surface_impedance(env, varargin{:});
            else
                Zs = obj.surface_impedance(env, {});
            end

            % On normalise l'impédance
            % Zsn = Zs/env.air.parameters.Z0;
            perso_plot_surface_impedance(env.w/(2*pi), Zs, env, name)
         end
        
        function save_class_object(obj, filename)

            path = 'E:\OneDrive - ETS\CRIAQ-REAR\Maitrise LB\MATLAB\Apps\Configurations\';
            fullpath = fullfile(path, filename);
            save(fullpath, 'obj');
        end
    end

    methods (Static, Access = public) % Création des configurations

        function config = create_config(list_of_subelements, end_status, surface)

            config = {};
            config.ListOfObjects = list_of_subelements;
            config.EndStatus = end_status;
            config.Surface = surface;
        end
    end
end
