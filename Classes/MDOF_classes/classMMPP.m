classdef classMMPP < classelement

    methods

        function obj = classMMPP(config)
        
            % Appel du constructeur de la classe parente
            obj@classelement(classelement.create_config({}, 'closed', []));
               
            if nargin > 0  && ~isempty(config) && length(fields(config)) > 3
                % Transfert des champs de la configuration d'appel vers la configuration de classe
                obj.Configuration = perso_transfer_fields(config, obj.Configuration);
    
                w = config.Width;
                d = config.Depth;
                pp = config.PlatesPorosity;
                phr = config.PlatesHolesRadius;
                pt = config.PlatesThickness;
                ct = config.CavitiesThickness;
                N = config.NumberOfPlates;

                % On ajoute péridiquement la cellule plaque + cavité
                for i = 1:N

                    % Plaque perforée
                    obj.Configuration.ListOfSubelements{end+1} = classMPP_Circular(classMPP_Circular.create_config(w*d, pt(i), phr(i), pp(i), w, d));
        
                    % Cavité 
                    obj.Configuration.ListOfSubelements{end+1} = classcavity(classcavity.create_config(ct(i), w, d));
                end 
            end
        end
    end

    methods (Static, Access = public) % Création des configurations

        % Définition de la configuration à partir des paramètres JCA
        function config = create_config(surface, number_of_plates, depth, width, ...
                plates_holes_radius, plates_porosity, ...
                plates_thickness, cavities_thickness)
            
            config = {};
            config.Surface = surface;
            config.NumberOfPlates = number_of_plates;
            config.EndStatus = 'closed';

            % Paramètres globaux
            config.Depth = depth;
            config.Width = width;

            % Paramètres variables en fonction des cellules
            config.PlatesThickness = perso_interp_config(plates_thickness, number_of_plates);
            config.CavitiesThickness = perso_interp_config(cavities_thickness, number_of_plates);
            config.PlatesHolesRadius = perso_interp_config(plates_holes_radius, number_of_plates);
            config.PlatesPorosity = perso_interp_config(plates_porosity, number_of_plates);         
        end 
    end

    methods (Static, Access = public)
        
        function validate()

            perso_figure('Validation classMMPP - Coefficient d''absorption')

            % Données de référence : [1], fig. 3, 4 p. 9, 10

            % panel 1
            phi = 0.025; % porosité de la plaque
            d = 1e-3; % épaisseur de la plaque
            r = 0.5e-3; % diamètre des perforations
            s = 1; % Section arbitraire
            c = sqrt(s);

            D = 60e-3;
            MMPP = classMMPP(classMMPP.create_config(s, 1, c, c, {r}, {phi}, {d}, {D}));

            % création de l'environnement
            env = create_environnement(23, 100800, 22, 1, 5000, 100);

            % importation des données de références
            % data1 = csvread('Atalla2007_fig3_black_square.txt'); % Approche modale
            data2 = csvread('Atalla2007_fig3_red.txt'); % Modèle Ingard
            % [x_data1, y_data1] = perso_interpole_et_lisse(data1(:, 1), data1(:, 2), 1000, 0.05);
            [x_data2, y_data2] = perso_interpole_et_lisse(data2(:, 1), data2(:, 2), 1000, 0.05);
            % affichage des résultats

            hold on
            subtitle("Atalla2007 - fig. 3 - p. 9")
            plot(env.w / (2*pi), MMPP.alpha(env), 'Color', 'b', 'LineWidth', 1, 'DisplayName', 'Modèle analytique');
            % plot(x_data1, y_data1, 'Color', 'g','LineWidth', 1, 'LineStyle', '--', 'DisplayName', 'Données de références');
            plot(x_data2, y_data2, 'Color', 'g','LineWidth', 1, 'LineStyle', '--', 'DisplayName', 'Données de références - Ingard');
            perso_configure_alpha_figure(5000);
        end
    end
end
