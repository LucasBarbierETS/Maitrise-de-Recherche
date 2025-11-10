classdef classMPPSBH_Chen < classelement

    %% Références : 

    % [1] A broadband and low-frequency sound absorber of sonic black holes with multi-layered micro-perforated panels

    methods
        function obj = classMPPSBH_Chen(config)
        
            % Appel du constructeur de la classe parente
            obj@classelement(classelement.create_config({}, 'closed', []));
               
            if nargin > 0    
                % Transfert des champs de la configuration d'appel vers la configuration de classe
                obj.Configuration = perso_transfer_fields(config, obj.Configuration);
    
                mpr = config.MainPoresRadius;
                cavr = config.CavitiesRadius;
                pp = config.PlatesPorosity;
                phr = config.PlatesHolesRadius;
                pt = config.PlatesThickness;
                ct = config.CavitiesThickness;

                for i = 1:length(pp)

                    % Plaque perforée (Modèle de Maa)
                    obj.Configuration.ListOfObjects{end+1} = classMPP_Maa(classMPP_Maa.create_config(pi*mpr(i)^2, pt(i), phr(i), pp(i)));
        
                    % Cavité cylindrique
                    hc = (mpr(i) + mpr(i+1))/2;
                    obj.Configuration.ListOfObjects{end+1} = classcavity_cylindrical(classcavity_cylindrical.create_config(ct(i)/2, hc));
                    % obj.Configuration.ListOfObjects{end+1} = classcavity_conical(classcavity_conical.create_config(ct(i)/2, mpr(i), hc));
        
                    % Cavité annnulaire cylindrique
                    annular_cavity = classannularcavity_cylindrical(classannularcavity_cylindrical.create_config(hc, cavr, ct(i), 'Volume'));
                    obj.Configuration.ListOfObjects{end+1} = classjunction_cylindrical(classjunction_cylindrical.create_config(annular_cavity, hc, ct(i)));

                    obj.Configuration.ListOfObjects{end+1} = classcavity_cylindrical(classcavity_cylindrical.create_config(ct(i)/2, hc));
                    % obj.Configuration.ListOfObjects{end+1} = classcavity_conical(classcavity_conical.create_config(ct(i)/2, hc, mpr(i+1)));
                end
            end
        end
    end

    methods (Static, Access = public) % Création des configurations

        % Définition de la configuration à partir des paramètres JCA
        function config = create_config(surface, number_of_plates, plates_thickness, cavities_thickness, ...
                cavities_radius, main_pores_radius, ...
                plates_holes_radius, plates_porosity)

            config = {};
            config.Surface = surface;
            config.NumberOfPlates = number_of_plates;           
            config.PlatesThickness = perso_interp_config(plates_thickness, number_of_plates);
            config.CavitiesThickness = perso_interp_config(cavities_thickness, number_of_plates);
            config.CavitiesRadius = cavities_radius;
            config.MainPoresRadius = perso_interp_config(main_pores_radius, number_of_plates + 1);
            config.PlatesHolesRadius = perso_interp_config(plates_holes_radius, number_of_plates);
            config.PlatesPorosity = perso_interp_config(plates_porosity, number_of_plates);         
        end
    end

    methods (Static, Access = public) % Validation
        
        function validate(env)
            
            perso_figure('Validation classMPPSBH_Chen - profil linéaire');
            hold on

            % Paramètres de la configuration
            R = 30e-3;
            L = 100e-3;
            N = 10;
            rend = 1e-3;
            d = 0.2e-3;
            t = 0.2e-3;
            phi = 0.04;
            
            % Pour cette validation la célérité de l'air doit intégrer un
            % terme dissipatif

            %% Profil linéaire

            % Importation des données de références
            data = load('Chen2024_fig3a_black.txt');
            plot(data(:, 1), data(:, 2), 'DisplayName', 'Résultat numérique de référence');
            
            % Calcul de la réponse du modèle analytique
            config = classMPPSBH_Chen.create_config(pi*R^2, ...
                N, {t}, {L/N - t}, R, {{R, rend, N+1, 1}}, ...
                {d/2}, {phi});
            alpha_model_lin = classMPPSBH_Chen(config).absorption_coefficient(env);
            plot(env.w / (2*pi), alpha_model_lin, 'Color', 'g', 'LineWidth', 1, 'DisplayName', 'Prédiction du code analytique');
            perso_configure_alpha_figure(3000);

            %% Profil quadratique

            perso_figure('Validation classMPPSBH_Chen - profil quadratique');
            hold on

            % Importation des données de références
            data = load('Chen2024_fig3b_black.txt');
            plot(data(:, 1), data(:, 2), 'DisplayName', 'Données de références');

            % calcul de la réponse du modèle analytique
            config = classMPPSBH_Chen.create_config(pi*R^2, ...
                N, {t}, {L/N - t}, R, {{R, rend, N+1, 1/2}}, ...
                {d/2}, {phi});
            alpha_model_quad = classMPPSBH_Chen(config).absorption_coefficient(env);
            plot(env.w / (2*pi), alpha_model_quad, 'Color', 'g', 'LineWidth', 1, 'DisplayName', 'Modèle analytique');
            perso_configure_alpha_figure(3000);

        end
    end
end
