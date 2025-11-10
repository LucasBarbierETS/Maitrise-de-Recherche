classdef classMMPP < classelement

    methods

        function obj = classMMPP(config)
        
            % Appel du constructeur de la classe parente
            obj@classelement(classelement.create_config({}, 'closed', []));
               
            if nargin > 0  && ~isempty(config) && length(fields(config)) > 3
                % Transfert des champs de la configuration d'appel vers la configuration de classe
                obj.Configuration = perso_transfer_fields(config, obj.Configuration);
    
                s = config.Surface;
                pp = config.PlatesPorosity;
                phr = config.PlatesHolesRadius;
                pt = config.PlatesThickness;
                ct = config.CavitiesThickness;
                N = config.NumberOfPlates;

                % On ajoute péridiquement la cellule plaque + cavité
                for i = 1:N

                    % Plaque perforée
                    obj.Configuration.ListOfObjects{end+1} = classMPP_Circular(classMPP_Circular.create_config(s, pt(i), phr(i), pp(i)));
        
                    % Cavité 
                    obj.Configuration.ListOfObjects{end+1} = classcavity(classcavity.create_config(s, ct(i)));
                end 
            end
        end
    end

    methods (Static, Access = public) % Création des configurations

        % Définition de la configuration à partir des paramètres JCA
        function config = create_config(surface, number_of_plates, ...
                plates_holes_radius, plates_porosity, ...
                plates_thickness, cavities_thickness, varargin)
            
            config = {};
            % Paramètres globaux 
            config.Surface = surface;
            config.NumberOfPlates = number_of_plates;
            config.EndStatus = 'closed';

            if nargin > 6
                config.Depth = varargin{1};
                config.Width = varargin{2};
            end

            % Paramètres variables en fonction des cellules
            config.PlatesThickness = perso_interp_config(plates_thickness, number_of_plates);
            config.CavitiesThickness = perso_interp_config(cavities_thickness, number_of_plates);
            config.PlatesHolesRadius = perso_interp_config(plates_holes_radius, number_of_plates);
            config.PlatesPorosity = perso_interp_config(plates_porosity, number_of_plates);         
        end 
    end

    methods (Static, Access = public)

        function validate(handle_env)

            perso_figure('Validation classMMPP - Coefficient d''absorption');

            % Données de références : perso_ouvrir_lien_Zotero('zotero://open-pdf/library/items/CMZQ7B9B?page=87&annotation=K6KB5V85');

            SPL = 145; % Pression incidente
            M = 0;

            % MPP 1
            phi = {0.0629, 0.0465}; % porosité de la plaque
            d = {1e-3, 1e-3}; % épaisseur de la plaque
            r = {1.4e-3/2, 1.33e-3/2}; % diamètre des perforations
            R = 30e-3; % Rayon de plaque arbitraire
            s = pi*R^2; % Surfaces

            D = {30e-3, 30e-3};
            config = classMMPP.create_config(s, 2, r, phi, d, D);
            MMPP = classMMPP(config);
            MMPP_HL_fp = classMMPP_HL_first_plate(config);
            MMPP_HL = classMMPP_HL(config);

            % création de l'environnement
            env = handle_env(SPL, M);

            % importation des données de références
            data1 = readmatrix('validation class_MMPP_HL_iter thèseLaly fig3.16 grey.txt'); % Approche modale
            % data2 = csvread('Atalla2007_fig3_red.txt'); % Modèle Ingard
            [x_data1, y_data1] = perso_interpole_et_lisse(data1(:, 1), data1(:, 2), 1000, 0.05);
            % [x_data2, y_data2] = perso_interpole_et_lisse(data2(:, 1), data2(:, 2), 1000, 0.05);
            % affichage des résultats

            hold on
            % subtitle("Atalla2007 - fig. 3 - p. 9")
            % plot(env.w / (2*pi), MMPP.alpha(env), 'Color', 'g', 'LineWidth', 0.5, 'DisplayName', 'Modèle analytique linéaire');
            % plot(env.w / (2*pi), MMPP_HL_fp.alpha(env), 'Color', 'r', 'LineWidth', 0.5, 'DisplayName', 'Modèle analytique HL appliqué à la première plaque');
            plot(env.w / (2*pi), MMPP_HL.alpha(env), 'Color', 'm', 'LineWidth', 0.5, 'DisplayName', 'Modèle analytique HL');
            plot(x_data1, y_data1, 'Color', 'g','LineWidth', 1, 'LineStyle', '--', 'DisplayName', 'Données de références - Mesure');
            % plot(x_data2, y_data2, 'Color', 'g','LineWidth', 1, 'LineStyle', '--', 'DisplayName', 'Données de références - Ingard');
            perso_configure_alpha_figure(5000);
        end
    end
end
