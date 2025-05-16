function perso_write_table_to_excel_sheet(sheet, T)
    
    % Écrire les en-têtes en une seule fois
    headers = T.Properties.VariableNames;
    sheet.Range(['A1:' char(64 + width(T)) '1']).Value = headers;

    % Écrire les données en une seule fois
    data = table2cell(T);
    sheet.Range(['A2:' char(64 + width(T)) num2str(height(T) + 1)]).Value = data;
    
    % Ajuster la taille des colonnes
    Range = sheet.UsedRange;
    Range.Columns.AutoFit();
end