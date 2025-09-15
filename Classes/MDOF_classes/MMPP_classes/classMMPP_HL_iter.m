classdef classMMPP_HL_iter < classMMPP

    methods

        function obj = classMMPP_HL_iter(config)
        
            obj@classMMPP({});
               
            if nargin > 0  && ~isempty(config)
                % Transfert des champs de la configuration d'appel vers la configuration de classe
                obj.Configuration = perso_transfer_fields(config, obj.Configuration);
    
                S = config.Surface;
                pp = config.PlatesPorosity;
                phr = config.PlatesHolesRadius;
                pt = config.PlatesThickness;
                ct = config.CavitiesThickness;
                N = config.NumberOfPlates;

                % On ajoute péridiquement la cellule plaque + cavité
                for i = 1:N

                    % Plaque perforée
                    obj.Configuration.ListOfSubelements{end+1} = classMPP_Circular_HL_iter(classMPP_Circular.create_config(S, pt(i), phr(i), pp(i)));
        
                    % Cavité 
                    obj.Configuration.ListOfSubelements{end+1} = classcavity(classcavity.create_config(S, ct(i)));
                end 
            end
        end
    
        function Zs_iter = surface_impedance_iter(obj, env, varargin)

            % Dans cette méthode on obtient de manière itérative la
            % pression incidente à partir du niveau de pression totale RMS
            % puis on applique ce niveau à toutes les plaques

            %% Initialisation de la procédure

            u_rms = zeros(1, length(env.w));

            try
                pt_rms = repmat(env.pt_rms, 1, length(env.w));
            catch
                sprintf('Pression acoustique totale manquante')
            end
            
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

            %% Procédure itérative

            while ~converged && iter < max_iter
                
                %% Calcul de la nouvelle impédance de surface
                
                iter = iter + 1;

                TM = obj.transfer_matrix_iter(env, pt_rms, u_rms);

                % % debog : Matrice de transfert de l'élement
                % perso_figure('TM')
                % perso_plot_transfer_matrix(TM, env);

                % Vérification du critère de convergence
                Zs = obj.surface_impedance(env, TM);

                % % Debog : Tracé de l'impédance de surface
                % perso_figure('Zs');
                % perso_plot_surface_impedance(Zs, env, ['itération ', num2str(iter)]);

                %% Calcul du nouveau débit RMS d'entrée

                % Formulation en Pression - Débit
                new_u_rms = abs(pt_rms) ./ abs(Zs) * obj.Configuration.Surface;
                % new_u_rms = abs(p_rms) ./ abs(Zs);

                % % Debog (suite)
                % perso_figure('u_rms');
                % plot(env.w/(2*pi), new_u_rms, 'DisplayName', ['Itération ', num2str(iter)])

                %% Vérification du critère de convergence

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
    end
end
