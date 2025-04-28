function display_struct_as_table(struct_obj)
    % Convertit la structure en table
    table_obj = struct2table(struct_obj);
    
    % Affiche la table
    disp(table_obj);
end