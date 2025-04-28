function writeCSV(config, filename)

% Ouvrir un fichier pour écriture
fid = fopen(filename, 'w');

% Parcourir chaque champ de la structure
fields = fieldnames(config);
for i = 1:length(fields)
    field = fields{i};
    value = config.(field);
    
    if isnumeric(value) && isvector(value)
        % Écrire le nom du champ suivi des valeurs
        fprintf(fid, '%s,', field);
        fprintf(fid, '%g,', value);
        fprintf(fid, '\n');
    elseif isnumeric(value)
        % Écrire le nom du champ suivi de la valeur unique
        fprintf(fid, '%s,%g\n', field, value);
    elseif ischar(value)
        % Écrire le nom du champ suivi de la valeur de type chaîne
        fprintf(fid, '%s,%s\n', field, value);
    else
        % Gérer d'autres types de données si nécessaire
    end
end

% Fermer le fichier
fclose(fid);

end 