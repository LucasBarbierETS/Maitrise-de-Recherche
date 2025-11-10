classdef classMultiAnnular_Chen_MTMM < classMultiAnnular_Chen

    %% Références : 

    % [1] A broadband and low-frequency sound absorber of sonic black holes with multi-layered micro-perforated panels

    methods
        function obj = classMultiAnnular_Chen_MTMM(config)
        
            % Appel du constructeur de la classe parente
            obj@classMultiAnnular_Chen({});
               
            if nargin > 0 && ~isempty(config)     
                % Transfert des champs de la configuration d'appel vers la configuration de classe
                obj.Configuration = perso_transfer_fields(config, obj.Configuration);
    
                rmp = config.MainPoresRadius;
                tmp = config.MainPoresThickness;
                rde = config.DeadEndRadius;
                hde = config.DeadEndThickness;

                for i = 1:config.CellNumber

                    % Cavité cylindrique avec pertes
                    obj.Configuration.ListOfObjects{end+1} = classcavity_cylindrical(classcavity_cylindrical.create_config(tmp, rmp(i)));
        
                    % Cavité conique
                    hc = (rmp(i) + rmp(i+1))/2;
                    % obj.Configuration.ListOfObjects{end+1} = classcavity_cylindrical(classcavity_cylindrical.create_config(hde/2, rmp(i)));
                    obj.Configuration.ListOfObjects{end+1} = classcavity_conical(classcavity_conical.create_config(hde/2, rmp(i), hc));
        
                    % Cavité annnulaire toroidale
                    annular_cavity = classannularcavity_toroidal(classannularcavity_toroidal.create_config(rmp(i), rmp(i+1), rde, hde, 'Hankel_Chen'));
                    obj.Configuration.ListOfObjects{end+1} = classjunction_cylindrical(classjunction_cylindrical.create_config(annular_cavity, hc, hde));

                    % Cavité conique
                    obj.Configuration.ListOfObjects{end+1} = classcavity_conical(classcavity_conical.create_config(hde/2, hc, rmp(i+1)));
                    % obj.Configuration.ListOfObjects{end+1} = classcavity_cylindrical(classcavity_cylindrical.create_config(hde/2, hc));
                end
            end
        end
    end

    methods (Static, Access = public) % Validation
        
        function validate(env)
            
            % Paramètres de la configuration
            R = 30e-3;
            L = 100e-3;
            rend = 2e-3;
            t = 0.2e-3;
            config = @(N) classMultiAnnular_Chen_MTMM.create_config(R, perso_interp_config({{R, rend, N+1, 1}}, N+1), t, R, L/N - t, N);
            
            % Pour cette validation la célérité de l'air doit intégrer un
            % terme dissipatif

            %% 10 plaques

            N = 10;
            
            % ax1 = fig.nextAxes('Validation classMultiAnnular_Chen - 10 plaques');
            perso_figure('Validation classMultiAnnular_Chen - 10 plaques');
            hold on

            % Importation des données de références
            data_mod = load('validation classMultiAnnular_Chen ChenMTMM2024 fig7a black.txt');
            plot(data_mod(:, 1), data_mod(:, 2), 'DisplayName', 'Données de références - Modèle');

            data_fem = load('validation classMultiAnnular_Chen ChenMTMM2024 fig7a red.txt');
            plot(data_fem(:, 1), data_fem(:, 2), 'DisplayName', 'Données de références - FEM');
            
            % Calcul de la réponse du modèle analytique
            alpha_model = classMultiAnnular_Chen(config(N)).alpha(env);
            alpha_model_MTMM = classMultiAnnular_Chen_MTMM(config(N)).alpha(env);
            % alpha_model_MTMM_subdiv = classMultiAnnular_Chen_MTMM_subdiv(config(N)).alpha(env);
            plot(env.w / (2*pi), alpha_model, 'Color', 'g', 'LineWidth', 1, 'DisplayName', 'Modèle');
            plot(env.w / (2*pi), alpha_model_MTMM, 'Color', 'k', 'LineWidth', 1, 'DisplayName', 'Modèle MTMM');
            % plot(env.w / (2*pi), alpha_model_MTMM_subdiv, 'Color', 'k', 'LineWidth', 1, 'DisplayName', 'Modèle MTMM subdiv');
            perso_configure_alpha_figure(3000);

            %% 20 Plaques

            N = 20;

            % ax2 = fig.nextAxes('Validation classMultiAnnular_Chen - 20 plaques');
            perso_figure('Validation classMultiAnnular_Chen - 20 plaques');
            hold on

            % Importation des données de références
            data_mod = load('validation classMultiAnnular_Chen ChenMTMM2024 fig7b black.txt');
            plot(data_mod(:, 1), data_mod(:, 2), 'DisplayName', 'Données de références - Modèle');

            data_fem = load('validation classMultiAnnular_Chen ChenMTMM2024 fig7b red.txt');
            plot(data_fem(:, 1), data_fem(:, 2), 'DisplayName', 'Données de références - FEM');
            
            % Calcul de la réponse du modèle analytique
            alpha_model = classMultiAnnular_Chen(config(N)).alpha(env);
            alpha_model_MTMM = classMultiAnnular_Chen_MTMM(config(N)).alpha(env);
            % alpha_model_MTMM_subdiv = classMultiAnnular_Chen_MTMM_subdiv(config(N)).alpha(env);
            plot(env.w / (2*pi), alpha_model, 'Color', 'g', 'LineWidth', 1, 'DisplayName', 'Modèle');
            plot(env.w / (2*pi), alpha_model_MTMM, 'Color', 'k', 'LineWidth', 1, 'DisplayName', 'Modèle MTMM');
            % plot(env.w / (2*pi), alpha_model_MTMM_subdiv, 'Color', 'k', 'LineWidth', 1, 'DisplayName', 'Modèle MTMM subdiv');
            perso_configure_alpha_figure(3000);

            %% 30 Plaques

            N = 30;

            % ax3 = fig.nextAxes('Validation classMultiAnnular_Chen - 30 plaques');
            perso_figure('Validation classMultiAnnular_Chen - 30 plaques');
            hold on

            % Importation des données de références
            data_mod = load('validation classMultiAnnular_Chen ChenMTMM2024 fig7c black.txt');
            plot(data_mod(:, 1), data_mod(:, 2), 'DisplayName', 'Données de références - Modèle');

            data_fem = load('Validation\validation classMultiAnnular_Chen ChenMTMM2024 fig7c red.txt');
            plot(data_fem(:, 1), data_fem(:, 2), 'DisplayName', 'Données de références - FEM');
            
            % Calcul de la réponse du modèle analytique
            alpha_model = classMultiAnnular_Chen(config(N)).alpha(env);
            alpha_model_MTMM = classMultiAnnular_Chen_MTMM(config(N)).alpha(env);
            % alpha_model_MTMM_subdiv = classMultiAnnular_Chen_MTMM_subdiv(config(N)).alpha(env);
            plot(env.w / (2*pi), alpha_model, 'Color', 'g', 'LineWidth', 1, 'DisplayName', 'Modèle');
            plot(env.w / (2*pi), alpha_model_MTMM, 'Color', 'k', 'LineWidth', 1, 'DisplayName', 'Modèle MTMM');
            % plot(env.w / (2*pi), alpha_model_MTMM_subdiv, 'Color', 'k', 'LineWidth', 1, 'DisplayName', 'Modèle MTMM subdiv');
            perso_configure_alpha_figure(3000);

            %% 40 Plaques

            N = 40;

            % ax4 = fig.nextAxes('Validation classMultiAnnular_Chen - 40 plaques');
            perso_figure('Validation classMultiAnnular_Chen - 40 plaques');
            hold on

            % Importation des données de références
            data_mod = load('validation classMultiAnnular_Chen ChenMTMM2024 fig7d black.txt');
            plot(data_mod(:, 1), data_mod(:, 2), 'DisplayName', 'Données de références - Modèle');

            data_fem = load('validation classMultiAnnular_Chen ChenMTMM2024 fig7d red.txt');
            plot(data_fem(:, 1), data_fem(:, 2), 'DisplayName', 'Données de références - FEM');
            
            % Calcul de la réponse du modèle analytique
            alpha_model = classMultiAnnular_Chen(config(N)).alpha(env);
            alpha_model_MTMM = classMultiAnnular_Chen_MTMM(config(N)).alpha(env);
            % alpha_model_MTMM_subdiv = classMultiAnnular_Chen_MTMM_subdiv(config(N)).alpha(env);
            plot(env.w / (2*pi), alpha_model, 'Color', 'g', 'LineWidth', 1, 'DisplayName', 'Modèle');
            plot(env.w / (2*pi), alpha_model_MTMM, 'Color', 'k', 'LineWidth', 1, 'DisplayName', 'Modèle MTMM');
            % plot(env.w / (2*pi), alpha_model_MTMM_subdiv, 'Color', 'k', 'LineWidth', 1, 'DisplayName', 'Modèle MTMM subdiv');
            perso_configure_alpha_figure(3000);

        end
    end
end
