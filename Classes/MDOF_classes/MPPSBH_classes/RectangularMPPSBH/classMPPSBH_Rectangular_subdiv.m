classdef classMPPSBH_Rectangular_subdiv < classelement

    methods
        function obj = classMPPSBH_Rectangular_subdiv(config)
        
            % Appel du constructeur de la classe parente
            obj@classelement(classelement.create_config({}, 'closed', []));
               
            if nargin > 0  && ~isempty(config) && length(fields(config)) > 3
                % Transfert des champs de la configuration d'appel vers la configuration de classe
                obj.Configuration = perso_transfer_fields(config, obj.Configuration);
    
                cavw = config.CavitiesWidth;
                cavd = config.CavitiesDepth;
                mpw = config.MainPoresWidth;
                mpd = config.MainPoresDepth;
                pp = config.PlatesPorosity;
                phr = config.PlatesHolesRadius;
                pt = config.PlatesThickness;
                ct = config.CavitiesThickness;

                % On ajoute péridiquement la cellule plaque + cavité
                for i = 1:length(pp)

                    % Plaque perforée
                    obj.Configuration.ListOfSubelements{end+1} = classMPP_Circular(classMPP_Circular.create_config(mpw(i)*mpd(i), pt(i), phr(i), pp(i), mpw(i), mpd(i)));
        
                    % Cavité trapezoidale
                    wc = (mpw(i) + mpw(i+1))/2;
                    dc = (mpd(i) + mpd(i+1))/2;
                    obj.Configuration.ListOfSubelements{end+1} = classcavity_trapezoidal_subdiv(classcavity_trapezoidal_subdiv.create_config(ct(i)/2, mpw(i), mpd(i), wc, dc, 10));
    
                    % Cavité cubique en parallèle
                    annular_cavity = classannularcavity_cubical(classannularcavity_cubical.create_config(wc, dc, cavw, cavd, ct(i), 'Volume'));
                    obj.Configuration.ListOfSubelements{end+1} = classjunction(classjunction.create_config(annular_cavity, wc, dc));
        
                    % Cavité trapezoidale
                    obj.Configuration.ListOfSubelements{end+1} = classcavity_trapezoidal_subdiv(classcavity_trapezoidal_subdiv.create_config(ct(i)/2, wc, dc, mpw(i+1), mpd(i+1), 10));
                end 
            end
        end
    end

    methods % Création des modèles COMSOL
        
        function output_model = set_COMSOL_2D_Model(obj, input_model, elem_index, sblm_index, env)
            output_model = ModelMPPSBH(obj.Configuration, input_model, elem_index, sblm_index, env);
        end

        function output_model = set_COMSOL_3D_Model(obj, input_model, index, env)
            output_model = ModelMPPSBH_3D(obj.Configuration, input_model, index, env);
        end

        function output_model = set_COMSOL_3D_Model_ap(obj, input_model, index, env)
            output_model = ModelMPPSBH_3D_ap(obj.Configuration, input_model, index, env);
        end
    end

    methods % Gestion des configurations
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
                config.Surface * mm2, ...
                'VariableNames', { ...
                    'Nombre de plaques', ...
                    'Profondeur des cavitées (mm)', ...
                    'Largeur des cavités (mm)', ...
                    'Surface apparente (mm^2)', ...
                } ...
            );
        
            % Table des plaques
            d_inch = config.PlatesHolesRadius(:) * 1e3 * 2 / 25.4;
            d_inch_frac = string(strtrim(cellstr(rats(d_inch))));
            d_inch_frac = replace(d_inch_frac, "/", "\");
            T1 = table( ...
                (1:N)', ...
                round(config.PlatesPorosity(:) * 100, 3), ...
                d_inch_frac, ... round(config.PlatesHolesRadius(:) * mm, 3), ...
                round(config.MainPoresWidth(1:N)' * mm, 3), ...
                round(config.PlatesThickness(:) * mm, 3), ...
                round(config.CavitiesThickness(:) * mm, 3), ...
                config.PlatesWidthHolesNumber(:), ...
                config.PlatesDepthHolesNumber(:), ...
                round(config.PlatesWidthHolesDistance(:) * mm, 3), ...
                round(config.CavitiesDepth ./ (config.PlatesDepthHolesNumber(:) + 1) * mm, 3), ...
                'VariableNames', { ...
                    'Numéro de plaque', ...
                    'Porosité de la fente (%)', ...
                    'Diamètre des perforations (inch)', ...
                    'Largeur de la fente (Distance entre les centres extrêmes) (mm)', ...
                    'Epaisseur des plaques (mm)', ...
                    'Epaisseur des cavités (mm)', ...
                    'Nombre de perforations en largeur', ...
                    'Nombre de perforations en profondeur', ...
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

        function export_DXF(obj)

            outputFolder = uigetdir();
            
            config = obj.Configuration;
            externalWidth = 37.8;
            externalDepth = 37.8;
            
            % Extraire les dimensions de la cavité
            cavityWidth = config.CavitiesWidth * 1e3;
            cavityDepth = config.CavitiesDepth * 1e3;
            
            % Nombre de plaques
            numPlates = config.NumberOfPlates;

            % Paramètre de kerf
            kerf = 0.2; % Exemple : ajuster selon votre machine laser, ici 0.3 mm
            
            % Générer un fichier DXF pour chaque plaque
            for plateIdx = 1:numPlates
                % Nom du fichier DXF pour cette plaque
                outputFilename = fullfile(outputFolder, sprintf('perforations_plaque_%d.dxf', plateIdx));
                
                % Ouvrir le fichier DXF pour cette plaque
                fileID = fopen(outputFilename, 'w');
                
                % Écrire l'en-tête DXF
                fprintf(fileID, '0\nSECTION\n2\nHEADER\n0\nENDSEC\n');
                fprintf(fileID, '0\nSECTION\n2\nTABLES\n0\nENDSEC\n');
                fprintf(fileID, '0\nSECTION\n2\nBLOCKS\n0\nENDSEC\n');
                fprintf(fileID, '0\nSECTION\n2\nENTITIES\n');
                
                % Récupérer les informations de perforations pour cette plaque
                % r = config.PlatesHolesRadius(plateIdx) * 1e3;
                pw = config.PlatesWidthHolesNumber(plateIdx);
                pd = config.PlatesDepthHolesNumber(plateIdx);
                dw = config.PlatesWidthHolesDistance(plateIdx) * 1e3;
                dd = config.PlatesDepthHolesDistance(plateIdx) * 1e3;
                
                % Espacement des trous dans la direction X et Y
                xSpacing = dw;
                ySpacing = dd;
        
                xOffset = (externalWidth - (pw - 1) * xSpacing) / 2;
                yOffset = (externalDepth - (pd - 1) * ySpacing) / 2;
                
                % Générer les cercles pour les perforations de la plaque
                for i = 1:pw
                    for j = 1:pd
                        x = xOffset + (i - 1) * xSpacing;
                        y = yOffset + (j - 1) * ySpacing;
                        
                        numpasses = 1; % Nombre de couches concentriques

                        
                        % Générer les cercles concentriques avec couleurs progressives
                        for k = 1:numpasses
                            % Rayon de chaque conche concentrique
                            % concheRadius = radius - k * kerf/2; % Réduction progressive du rayon
                            concheRadius = 0.1;

                            % Cercle concentrique avec une épaisseur minimale du tracé
                            %                  forme      calque        couleur  transparence              coordonnées                 rayon      
                            fprintf(fileID, '0\nCIRCLE\n8\n0\n62\n%d\n370\n-1\n10\n%f\n20\n%f\n30\n0.0\n40\n%f\n', ...
                                    k, x, y, concheRadius);
                        end
                    end
                end
                
                % Définir les coins du rectangle (carré de 37.8 mm x 37.8 mm)
                width = externalWidth;   % en mm (ex : 37.8)
                height = externalDepth;  % en mm (ex : 37.8)
                
                % Bas gauche
                x0 = 0;
                y0 = 0;
                
                % Tracer les 4 côtés du carré avec des entités LINE, noir (couleur 7)
                fprintf(fileID, '0\nLINE\n8\n0\n62\n7\n370\n-1\n10\n%f\n20\n%f\n30\n0.0\n11\n%f\n21\n%f\n31\n0.0\n', ...
                        x0, y0, x0+width, y0); % Bas
                
                fprintf(fileID, '0\nLINE\n8\n0\n62\n7\n370\n-1\n10\n%f\n20\n%f\n30\n0.0\n11\n%f\n21\n%f\n31\n0.0\n', ...
                        x0+width, y0, x0+width, y0+height); % Droite
                
                fprintf(fileID, '0\nLINE\n8\n0\n62\n7\n370\n-1\n10\n%f\n20\n%f\n30\n0.0\n11\n%f\n21\n%f\n31\n0.0\n', ...
                        x0+width, y0+height, x0, y0+height); % Haut
                
                fprintf(fileID, '0\nLINE\n8\n0\n62\n7\n370\n-1\n10\n%f\n20\n%f\n30\n0.0\n11\n%f\n21\n%f\n31\n0.0\n', ...
                        x0, y0+height, x0, y0); % Gauche
                        
                % Fermer la section des entités
                fprintf(fileID, '0\nENDSEC\n');
                
                % Écrire la fin du fichier DXF
                fprintf(fileID, '0\nSECTION\n2\nOBJECTS\n0\nENDSEC\n');
                fprintf(fileID, '0\nENDSEC\n');
                fprintf(fileID, '0\nEOF\n');
                
                % Fermer le fichier
                fclose(fileID);
                
                disp(['Fichier DXF généré : ', outputFilename]);
            end
        end
   
        function CNC_report(obj)

            outputFolder = uigetdir();
            config = obj.Configuration;
            
            % Récupérer les informations de l'objet
            pw = config.PlatesWidthHolesNumber;
            pd = config.PlatesDepthHolesNumber;
            dw = config.PlatesWidthHolesDistance;
            dd = config.PlatesDepthHolesDistance;
            r = config.PlatesHolesRadius;
            cw = config.CavitiesWidth;
            cd = config.CavitiesDepth;
            
            % Nombre de plaques
            numPlates = obj.Configuration.NumberOfPlates;
            
            % Boucle pour chaque plaque
            for plateIdx = 1:numPlates

                % Nom du fichier DXF pour cette plaque
                outputFilename = fullfile(outputFolder, sprintf('CNC_perforations_plaque_%d.txt', plateIdx));
                
                % Ouvrir le fichier DXF pour cette plaque
                fileID = fopen(outputFilename, 'w');

                fprintf(fileID, 'Plaque %d:\n', plateIdx);
                
                % Position du trou inférieur gauche
                x_position = 1e3 * (cw/2 - dw(plateIdx) * (pw(plateIdx) - 1)/2);
                y_position = 1e3 * (cd/2 - dd(plateIdx) * (pd(plateIdx) - 1)/2);
                fprintf(fileID, '  - Position du trou inférieur gauche : (%.3f, %.3f) mm\n', x_position, y_position);
                
                % Rayon des perforations
                hole_radius = r(plateIdx) * 1e3;
                fprintf(fileID, '  - Rayon des perforations : %.3f mm\n', hole_radius);
                
                % Offset entre chaque trou
                offset_x = dw(plateIdx) * 1e3;
                offset_y = dd(plateIdx) * 1e3;
                fprintf(fileID, '  - Offset entre chaque trou : (%.3f, %.3f) mm\n\n', offset_x, offset_y);
                
                % Fermer le fichier
                fclose(fileID);
            end   
        end
    
        function plot_2D_geometry(obj, varargin)

            % Configuration de la fenêtre d'affichage
            if nargin > 1
                ax = varargin{1};
                cla(ax);
            else
                ax = uiaxes();
            end

            hold(ax, "on");
            axis(ax, "equal");

            config = obj.Configuration;
            cw = config.CavitiesWidth;
            ct = config.CavitiesThickness;
            mpw = config.MainPoresWidth;
            pt = config.PlatesThickness;
            pp = config.PlatesPorosity;

            tt = 0; % total thickness

            for i = config.NumberOfPlates:-1:1 % itération à rebours

                % Tracé de la cavité i
                rectangle(ax, 'Position', [-cw/2 tt cw ct(i)], 'Facecolor', [1 1 1]);
                tt = tt + ct(i);

                % Tracé du pore i
                rectangle(ax, 'Position', [-mpw(i)/2 tt mpw(i) pt(i)], 'Facecolor', pp(i) * [1 1 1]);
                tt = tt + pt(i);
            end
        end
    
    end

    methods (Static, Access = public) % Création des configurations

        % Définition de la configuration à partir des paramètres JCA
        function config = create_config(surface, number_of_plates, cavities_depth, cavities_width, main_pores_width, main_pores_depth, plates_holes_radius, plates_perforated_part_porosity, plates_thickness, cavities_thickness)
            
            config = {};
            config.Surface = surface;
            config.NumberOfPlates = number_of_plates;
            config.EndStatus = 'closed';

            % Paramètres globaux
            config.CavitiesDepth = cavities_depth;
            config.CavitiesWidth = cavities_width;

            % Paramètres variables en fonction des cellules
            config.PlatesThickness = perso_interp_config(plates_thickness, number_of_plates);
            config.CavitiesThickness = perso_interp_config(cavities_thickness, number_of_plates);
            config.MainPoresWidth = perso_interp_config(main_pores_width, number_of_plates + 1);
            config.MainPoresDepth = perso_interp_config(main_pores_depth, number_of_plates + 1);
            config.PlatesHolesRadius = perso_interp_config(plates_holes_radius, number_of_plates);
            config.PlatesPorosity = perso_interp_config(plates_perforated_part_porosity, number_of_plates);         
        end

        function config = create_explicit_rectangular_pattern_config(surface, number_of_plates, cavities_depth, cavities_width, plates_holes_radius, plates_width_holes_distance, plates_depth_holes_distance, plates_depth_holes_number, plates_width_holes_number, plates_thickness, cavities_thickness) 

            config = {};
            config.Surface = surface;
            [config.NumberOfPlates, N] = deal(number_of_plates);

            % Paramètres globaux
            config.CavitiesDepth = cavities_depth;
            config.CavitiesWidth = cavities_width;

            % Paramètres variables en fonction des cellules
            config.PlatesThickness = perso_interp_config(plates_thickness, N);
            config.CavitiesThickness = perso_interp_config(cavities_thickness, N);
            [config.PlatesHolesRadius, hr] = deal(perso_interp_config(plates_holes_radius, N)); % r
            [config.PlatesDepthHolesNumber, pd] = deal(perso_interp_config(plates_depth_holes_number, N)); % m
            [config.PlatesWidthHolesNumber, pw] = deal(perso_interp_config(plates_width_holes_number, N)); % n

            [config.PlatesWidthHolesDistance, dw] = deal(perso_interp_config(plates_width_holes_distance, N)); % d
            [config.PlatesDepthHolesDistance, dd] = deal(perso_interp_config(plates_depth_holes_distance, N)); % d

            [config.MainPoresWidth, mpw] = deal(perso_interp_config({2 * hr + (pw-1) .* dw}, N + 1));
            [config.MainPoresDepth, mpd] = deal(perso_interp_config({2 * hr + (pd-1) .* dd}, N + 1));
            
            % Définition de la porosité à partir de la répartition des perforations
            Nh = pd .* pw; % nombre total de perforations
            config.PlatesPorosity = pi * hr.^2 .* Nh ./ (mpw(1:end-1) .* mpd(1:end-1));
        end

        function config = create_explicit_rectangular_pattern_config_without_first_plate(surface, number_of_plates, cavities_depth, cavities_width, plates_holes_radius, ...
            plates_width_holes_distance, plates_depth_holes_distance, ...
            plates_depth_holes_number, plates_width_holes_number, ...
            plates_thickness, cavities_thickness, varargin) 

            config = {};
            config.Surface = surface;
            [config.NumberOfPlates, N] = deal(number_of_plates);
            config.EndStatus = 'closed';

            % Paramètres globaux
            [config.CavitiesDepth, cd] = deal(cavities_depth);
            [config.CavitiesWidth, cw] = deal(cavities_width);

            % Paramètres variables en fonction des cellules
            config.PlatesThickness = perso_interp_config(plates_thickness, N);
            config.CavitiesThickness = perso_interp_config(cavities_thickness, N);
            [config.PlatesHolesRadius, hr] = deal(perso_interp_config(plates_holes_radius, N)); % r
            [config.PlatesDepthHolesNumber, pd] = deal(perso_interp_config(plates_depth_holes_number, N)); % m
            [config.PlatesWidthHolesNumber, pw] = deal(perso_interp_config(plates_width_holes_number, N)); % n

            [config.PlatesWidthHolesDistance, dw] = deal(perso_interp_config(plates_width_holes_distance, N)); % d
            [config.PlatesDepthHolesDistance, dd] = deal(perso_interp_config(plates_depth_holes_distance, N)); % d

            [config.MainPoresWidth, mpw] = deal(perso_interp_config({2 * hr + (pw-1) .* dw}, N + 1));
            [config.MainPoresDepth, mpd] = deal(perso_interp_config({2 * hr + (pd-1) .* dd}, N + 1));
            
            % Définition de la porosité à partir de la répartition des perforations
            Nh = pd .* pw; % nombre total de perforations
            [plates_perforated_surface, Sperf] = deal(pi * hr.^2 .* Nh);
            config.PlatesPerforatedPartPorosity = Sperf ./ (mpw(1:end-1) .* mpd(1:end-1));
            config.PlatesRealPorosity = plates_perforated_surface / (cw * cd);

            % Méthode de prise en compte des cavités latérales
            if nargin > 8
                config.CavitiesMethod = repmat(varargin(1), 1, N);
            else
                config.CavitiesMethod = repmat({'Volume'}, 1, N);
            end
        end

        function config = create_explicit_square_pattern_config(surface, number_of_plates, cavities_depth, cavities_width, ...
            plates_holes_radius, plates_holes_distance, ...
            plates_holes_number_for_each_row, ...
            plates_thickness, cavities_thickness, varargin) 

            config = {};
            config.Surface = surface;
            [config.NumberOfPlates, N] = deal(number_of_plates);
            config.EndStatus = 'closed';

            % Paramètres globaux
            [config.CavitiesDepth, cd] = deal(cavities_depth);
            [config.CavitiesWidth, cw] = deal(cavities_width);

            % Paramètres variables en fonction des cellules
            config.PlatesThickness = perso_interp_config(plates_thickness, N);
            config.CavitiesThickness = perso_interp_config(cavities_thickness, N);
            [config.PlatesHolesRadius, hr] = deal(perso_interp_config(plates_holes_radius, N));

            [config.PlatesWidthHolesNumber, pw] = deal(perso_interp_config(plates_holes_number_for_each_row, N));
            [config.PlatesDepthHolesNumber, pd] = deal(perso_interp_config(plates_holes_number_for_each_row, N));
            [config.PlatesWidthHolesDistance, dw] = deal(perso_interp_config(plates_holes_distance, N));
            [config.PlatesDepthHolesDistance, dd] = deal(perso_interp_config(plates_holes_distance, N));

            [config.MainPoresWidth, mpw] = deal(perso_interp_config({2 * hr + (pw-1) .* dw}, N + 1));
            [config.MainPoresDepth, mpd] = deal(perso_interp_config({2 * hr + (pd-1) .* dd}, N + 1));
            
            % Définition de la porosité à partir de la répartition des perforations
            Nh = pd .* pw; % nombre total de perforations
            [plates_perforated_surface, Sperf] = deal(pi * hr.^2 .* Nh);
            config.PlatesPorosity = deal(Sperf ./ (mpw(1:end-1) .* mpd(1:end-1)));
            config.PlatesRealPorosity = plates_perforated_surface / (cw * cd);

            % Méthode de prise en compte des cavités latérales
            if nargin > 8
                config.CavitiesMethod = repmat(varargin(1), 1, N);
            else
                config.CavitiesMethod = repmat({'Volume'}, 1, N);
            end

            % Dimension de l'élement à la sortie
            if nargin > 9
                config.ElementWidth = varargin{2};
            end
        end
    end

    methods (Static, Access = public) % Validation
        
        function validate()

            % close all 
            figure()
            hold on
            title('Validation Rectangular MPPSBH');
            
            % Paramètres de la configuration
            R = 30e-3;
            L = 100e-3;
            N = 20;
            rend = 3e-3;
            d = 0.5e-3;
            t = 0.2e-3;
            phi = 0.03;
            
            % création de l'environnement
            env = create_environnement(23, 100800, 22, 1, 5000, 5000, 140);

            %% Profil linéaire
            config = classMPPSBH_Rectangular_subdiv.create_config( ...
                N, R, R, {{R, rend, N+1, 1}}, {{R, rend, N+1, 1}}, ...
                {d/2}, {phi}, {t}, {L/N - t});
            
            % calcul de la réponse des modèles analytiques
            alpha_model = classMPPSBH_Rectangular_subdiv(config).alpha(env);
            alpha_model_HL = classMPPSBH_Rectangular_HL(config).alpha(env);
            alpha_model_HL_fp = classMPPSBH_Rectangular_HL_first_plate(config).alpha(env);


            plot(env.w / (2*pi), alpha_model, 'Color', 'g', 'LineWidth', 1, 'DisplayName', 'Modèle linéaire');
            plot(env.w / (2*pi), alpha_model_HL, 'Color', 'g', 'LineWidth', 1, 'DisplayName', 'Modèle forts niveaux');
            plot(env.w / (2*pi), alpha_model_HL_fp, 'Color', 'g', 'LineWidth', 1, 'DisplayName', 'Modèle forts niveaux sur la première plaque');

            %% Profil quadratique

            % % calcul de la réponse du modèle analytique
            % alpha_model = classMPPSBH_Rectangular(classMPPSBH_Rectangular.create_config(N, R, R, {{R, rend, N+1, 0.5}}, {phi}, {d/2}, {t}, {L/N - t})).alpha(env);
            % 
            % plot(env.w / (2*pi), alpha_model, 'Color', 'b', 'LineWidth', 1, 'DisplayName', 'Profil quadratique - Modèle');
            % 
            % % affichage des résultats
            % xlabel("Fréquence (Hz)");
            % ylabel("Coefficient d'Absorption");
            % ylim([0 1]);
            % xlim([0 3000]);
            % legend();
        end
    end
end
