function perso_top_plate_export_report(x_TP, radius_mm, filename)
        
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
            mm = 1000;
            mm2 = 1e6;

            % width = handle_config(x_TP).Width;
            % depth = handle_config(x_TP).Depth;
        
            % Paramètres globaux
            d_inch = radius_mm(x_TP(1)) * 2 / 25.4;
            d_inch_frac = string(strtrim(cellstr(rats(d_inch))));
            d_inch_frac = replace(d_inch_frac, "/", "\");

            T1 = table( ...
                d_inch_frac, ...
                x_TP(2), ...
                'VariableNames', { ...
                    'Diamètres des perforations (inch) ', ...
                    'Distance entre les perforations (mm)'
                    % 'Distance entre les perforations en largeur (mm)', ...
                    % 'Distance entre les perforations en longueur (mm)', ...
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
                Sheet1 = Workbook.Sheets.Add();
                Sheet1.Name = 'Paramètres globaux';
                Workbook.Sheets.Item('Temp').Delete;
        
                % === Écrire les données dans la première feuille ===
                perso_write_table_to_excel_sheet(Sheet1, T1);
                
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