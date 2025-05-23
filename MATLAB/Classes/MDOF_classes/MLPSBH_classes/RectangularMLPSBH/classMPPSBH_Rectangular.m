classdef classMPPSBH_Rectangular < classelement

    methods
        function obj = classMPPSBH_Rectangular(config)
        
            % Appel du constructeur de la classe parente
            obj@classelement(classelement.create_config({}, 'closed'));
               
            if nargin > 0    
                % Transfert des champs de la configuration d'appel vers la configuration de classe
                obj.Configuration = perso_transfer_fields(config, obj.Configuration);
    
                cavw = config.CavitiesWidth;
                cavd = config.CavitiesDepth;
                sw = config.SlitsWidth;
                pp = config.PlatesPerforatedPartPorosity;
                phr = config.PlatesHolesRadius;
                pt = config.PlatesThickness;
                ct = config.CavitiesThickness;

                % On ajoute péridiquement la cellule plaque + cavité
                for i = 1:length(pp)

                    obj.Configuration.ListOfSubelements{end+1} = Cell_MPPSBHr(Cell_MPPSBHr.create_config(pp(i), phr(i), pt(i), ...
                    ct(i), cavd, cavw, sw(i), sw(i+1)));
                end 
            end
        end
    
        function output_model = set_COMSOL_2D_Model(obj, input_model, index, env)
            output_model = ModelMPPSBH(obj.Configuration, input_model, index, env);
        end
    
        function export_plate_hole_coordinates(obj, folder_name, sfx)
            % Crée un dossier de configuration et y exporte les coordonnées des trous pour chaque plaque
        
            config = obj.Configuration;
        
            % Récupération des données
            N = config.NumberOfPlates;
            radius = round(config.PlatesHolesRadius, 5);  % Rayon en mètres
            spacing = round(config.PlatesWidthHolesDistance, 5);
            num_rows_array = config.PlatesDepthHolesNumber;
            num_cols_array = config.PlatesWidthHolesNumber;
            depth = config.CavitiesDepth - 2e-3;

            % Dossier racine des configurations
            coord_dir = fullfile(folder_name, 'Coordonnées des perforations');
        
            % Création des dossiers si nécessaires
            if ~exist(folder_name, 'dir')
                mkdir(folder_name);
            end
            if ~exist(coord_dir, 'dir')
                mkdir(coord_dir);
            end
        
            % Export des coordonnées pour chaque plaque
            for i = 1:N
                nx = num_cols_array(i);
                ny = num_rows_array(i);
        
                % Coordonnées en mm
                total_width = (nx - 1) * spacing(i);
                x_start = -total_width / 2;
                x_positions = x_start + (0:(nx - 1)) * spacing(i);
                spacing_y = depth / (ny + 1);
                y_positions = linspace(-depth / 2 + spacing_y, depth / 2 - spacing_y, ny);
        
                [X, Y] = meshgrid(x_positions, y_positions);
                hole_coordinates = [X(:), Y(:)] * 1e3;  % mm
                hole_radius = radius(i) * 1e3;  % rayon en mm
        
                % Fichier CSV de la plaque
                filename = fullfile(coord_dir, sprintf('plaque_%02d%s.csv', i, sfx));
                fileID = fopen(filename, 'w');
        
                if fileID == -1
                    error('[✗] Impossible de créer le fichier : %s', filename);
                end
        
                fprintf(fileID, 'X,Y,R\n');  % En-tête CSV
        
                for j = 1:size(hole_coordinates, 1)
                    fprintf(fileID, '%.2f,%.2f,%.3f\n', ...
                        hole_coordinates(j, 1), ...
                        hole_coordinates(j, 2), ...
                        hole_radius);
                end
        
                fclose(fileID);
                fprintf('[✓] Coordonnées exportées : %s\n', filename);
            end
        
            fprintf('[✓] Tous les fichiers de coordonnées ont été exportés dans : %s\n', coord_dir);
        end

        function launch_in_solidworks(obj, folder_name)
            % Lancer l'export et le script Python avec création de dossiers et ouverture de l'explorateur
        
            % === 1. Définition des chemins ===
            base_root = 'E:\OneDrive - ETS\CRIAQ-REAR\Maitrise LB\MATLAB\Classes\MDOF_classes\MLPSBH_classes\RectangularMLPSBH\Configurations';
            output_dir = fullfile(base_root, folder_name);
        
            % === 2. Création du dossier principal si nécessaire ===
            if ~exist(output_dir, 'dir')
                mkdir(output_dir);
                fprintf('[✓] Dossier créé : %s\n', output_dir);
            else
                fprintf('[i] Dossier déjà existant : %s\n', output_dir);
            end
        
            % === 3. Exporter les coordonnées ===
            obj.export_plate_hole_coordinates(folder_name);
        
            % === 4. Appel du script Python ===
            py_script = 'E:\OneDrive - ETS\CRIAQ-REAR\Maitrise LB\MATLAB\Classes\MDOF_classes\MLPSBH_classes\RectangularMLPSBH\MATLAB to SOLIDWORKS\build_MPPSBH_from_json.py';
            command = sprintf('python "%s" "%s"', py_script, output_dir);
        
            fprintf('[▶] Lancement du script Python :\n%s\n', command);
            [status, output] = system(command);
            disp(output);
        
            % === 5. Vérification de l'exécution ===
            if status ~= 0
                error('[✗] Échec de l’exécution Python.');
            else
                fprintf('[✓] Script Python terminé avec succès.\n');
            end
        
            % === 6. Ouverture automatique du dossier ===
            fprintf('[📂] Ouverture du dossier dans l’explorateur...\n');
            system(sprintf('explorer "%s"', output_dir));
        end
    
        function export_report(obj, filename)
    
            config = obj.Configuration;
        
            % === Nom par défaut si non spécifié ===
            if nargin < 2
                filename = fullfile(pwd, [sprintf('%s', datetime('today')), ' - rapport de configuration.xlsx']);
            end
        
            % === Vérifie et crée le dossier si nécessaire ===
            folder = fileparts(filename);
            if ~isempty(folder) && ~isfolder(folder)
                mkdir(folder);
            end
        
            % === Supprime un fichier déjà existant s’il est bloqué ===
            if exist(filename, 'file')
                try
                    delete(filename);
                catch
                    error("Impossible de supprimer %s. Fermez Excel ou changez de nom.", filename);
                end
            end
        
            % === Données ===
            N = config.NumberOfPlates;
            mm = 1000;
            mm2 = 1e6;
        
            % Paramètres globaux
            T2 = table( ...
                config.NumberOfPlates, ...
                config.CavitiesDepth * mm, ...
                config.CavitiesWidth * mm, ...
                config.InputSection * mm2, ...
                string(config.EndStatus), ...
                'VariableNames', { ...
                    'Nombre de plaques', ...
                    'Profondeur des cavitées (mm)', ...
                    'Largeur des cavités (mm)', ...
                    'Section interne des cavités (mm^2)', ...
                    'Terminaison' ...
                } ...
            );
        
            % Table des plaques
            T1 = table( ...
                (1:N)', ...
                round(config.PlatesRealPorosity(:) * 100, 3), ...
                round(config.PlatesHolesRadius(:) * mm, 3), ...
                round(config.SlitsWidth(1:N)' * mm, 3), ...
                round(config.PlatesThickness(:) * mm, 3), ...
                round(config.CavitiesThickness(:) * mm, 3), ...
                config.PlatesWidthHolesNumber(:), ...
                config.PlatesDepthHolesNumber(:), ...
                round(config.PlatesWidthHolesDistance(:) * mm, 3), ...
                round(config.CavitiesDepth ./ (config.PlatesDepthHolesNumber(:) + 1) * mm, 3), ...
                'VariableNames', { ...
                    'Numéro de plaque', ...
                    'Porosité réelle (%)', ...
                    'Rayon des perforations (mm)', ...
                    'Distance entre les centres extrêmes (mm)', ...
                    'Epaisseur des plaques (mm)', ...
                    'Epaisseur des cavités (mm)', ...
                    'Nombre de perforations en profondeur', ...
                    'Nombre de perforations en largeur', ...
                    'Distance en largeur entre deux centres adjacents (mm)', ...
                    'Distance en profondeur entre deux centres adjacents (mm)' ...
                } ...
            );
        
            % === Écriture Excel avec ActiveX pour la gestion avancée ===
            try
                % Créer une instance Excel
                Excel = actxserver('Excel.Application');
                Excel.Visible = false;
                Workbook = Excel.Workbooks.Add();
                
                % Créer une feuille temporaire (pour éviter l'erreur)
                TempSheet = Workbook.Sheets.Add();
                TempSheet.Name = 'Temp';
                
                % Supprimer toutes les autres feuilles (sauf Temp)
                while Workbook.Sheets.Count > 1
                    Workbook.Sheets.Item(2).Delete;
                end
                
                % Créer la première feuille et supprimer la feuille temporaire
                Sheet2 = Workbook.Sheets.Add();
                Sheet2.Name = 'Paramètres globaux';
                Workbook.Sheets.Item('Temp').Delete;
                
                % Créer la deuxième feuille
                Sheet1 = Workbook.Sheets.Add();
                Sheet1.Name = 'Paramètres des plaques';
        
                % === Écrire les données dans la première feuille ===
                perso_write_table_to_excel_sheet(Sheet1, T1);
                
                % === Écrire les données dans la deuxième feuille ===
                perso_write_table_to_excel_sheet(Sheet2, T2);
                
                % Sauvegarder et fermer
                Workbook.SaveAs(filename);
                Workbook.Close();
                Excel.Quit();
                delete(Excel);
                
                fprintf("✅ Rapport créé avec succès : %s\n", filename);
            catch ME
                error("Erreur lors de l’écriture Excel : %s", ME.message);
            end
        end

    end

    methods (Static, Access = public)

        % Définition de la configuration à partir des paramètres JCA
        function config = create_config(number_of_plates, cavities_depth, cavities_width, slits_width, ...
        plates_holes_radius, plates_perforated_part_porosity, ...
        plates_thickness, cavities_thickness)
            
            config = {};
            config.ModelOptions = struct();
            config.NumberOfPlates = number_of_plates;
            config.EndStatus = 'closed';

            % Paramètres globaux
            config.CavitiesDepth = cavities_depth;
            config.CavitiesWidth = cavities_width;
            config.InputSection = cavities_width * cavities_depth;

            % Paramètres variables en fonction des cellules
            config.PlatesThickness = perso_interp_config(plates_thickness, number_of_plates);
            config.CavitiesThickness = perso_interp_config(cavities_thickness, number_of_plates);
            config.SlitsWidth = perso_interp_config(slits_width, number_of_plates + 1);
            config.PlatesHolesRadius = perso_interp_config(plates_holes_radius, number_of_plates);
            config.PlatesPerforatedPartPorosity = perso_interp_config(plates_perforated_part_porosity, number_of_plates);         
        end
        
        % Définition de la configuration à partir de la géomètrie concrète
        function config = create_explicit_config(number_of_plates, cavities_depth, cavities_width, slits_width, ...
            plates_holes_radius, plates_width_holes_distance, ...
            plates_depth_holes_number, plates_width_holes_number, ...
            plates_thickness, cavities_thickness) 

            config = {};
            config.NumberOfPlates = number_of_plates;
            config.EndStatus = 'closed';

            % Paramètres globaux
            config.CavitiesDepth = cavities_depth;
            config.CavitiesWidth = cavities_width;
            config.InputSection = cavities_width * cavities_depth;

            % Paramètres variables en fonction des cellules
            config.PlatesThickness = perso_interp_config(plates_thickness, number_of_plates);
            config.CavitiesThickness = perso_interp_config(cavities_thickness, number_of_plates);
            config.PlatesHolesRadius = perso_interp_config(plates_holes_radius, number_of_plates); % r
            config.PlatesDepthHolesNumber = perso_interp_config(plates_depth_holes_number, number_of_plates); % m
            config.PlatesWidthHolesNumber = perso_interp_config(plates_width_holes_number, number_of_plates); % n
            config.PlatesWidthHolesDistance = perso_interp_config(plates_width_holes_distance, number_of_plates); % d

            % Définition de la largeur de la fente en fonction du nombre de perforations en largeur et du rayon de perforation
            config.SlitsWidth = perso_interp_config({plates_width_holes_distance{:} .* plates_width_holes_number{:}}, number_of_plates+1);
            
            % Définition de la porosité à partir de la répartition des perforations
            plates_holes_number = plates_depth_holes_number{:} .* plates_width_holes_number{:};
            plates_perforated_surface = pi*plates_holes_radius{:}.^2 .* plates_holes_number;
            config.PlatesPerforatedPartPorosity = plates_perforated_surface ./ (slits_width{:} * cavities_depth);
            config.PlatesRealPorosity = plates_perforated_surface / (cavities_width * cavities_depth);
        end

        function validate()

            % close all 
            figure()
            hold on
            title('Validation Rectangular MPPSBH');
            
            % Paramètres de la configuration
            R = 30e-3;
            L = 100e-3;
            N = 10;
            rend = 1e-3;
            d = 0.5e-3;
            t = 0.2e-3;
            phi = 0.03;
            
            % création de l'environnement
            env = create_environnement(23, 100800, 22, 1, 5000, 5000);

            %% Profil linéaire
            
            % calcul de la réponse du modèle analytique
            alpha_model = classMPPSBH_Rectangular(classMPPSBH_Rectangular.create_config(N, R, R, {{R, rend, N+1, 1}}, {phi}, {d/2}, {t}, {L/N - t})).alpha(env);

            plot(env.w / (2*pi), alpha_model, 'Color', 'g', 'LineWidth', 1, 'DisplayName', 'Profil linéaire - Modèle');

            %% Profil quadratique

            % calcul de la réponse du modèle analytique
            alpha_model = classMPPSBH_Rectangular(classMPPSBH_Rectangular.create_config(N, R, R, {{R, rend, N+1, 0.5}}, {phi}, {d/2}, {t}, {L/N - t})).alpha(env);

            plot(env.w / (2*pi), alpha_model, 'Color', 'b', 'LineWidth', 1, 'DisplayName', 'Profil quadratique - Modèle');
            
            % affichage des résultats
            xlabel("Fréquence (Hz)");
            ylabel("Coefficient d'Absorption");
            ylim([0 1]);
            xlim([0 3000]);
            legend();
        end
    end
end
