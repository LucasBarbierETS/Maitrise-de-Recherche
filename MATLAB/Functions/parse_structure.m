function [Parameters, Values, Units] = parse_structure(structure, className, Parameters, Values, Units, env)
    % Ajoute une ligne de titre avec la classe de la structure
    % Utilisée dans : classsubelement.disp_parameters_config()
    
    Parameters{end+1} = ['Class: ', className];
    Values{end+1} = NaN; % Valeur vide pour la classe
    Units{end+1} = ''; % Unité vide pour la classe
    
    % Parcourt chaque champ de la structure
    fields = fieldnames(structure);
    for i = 1:length(fields)
        field = fields{i};
        fullName = strcat(className, '.', field); % Nom complet du champ avec la classe
        
        % Récupérer la valeur du champ
        value = structure.(field);
        
        % Si le champ est une structure ou si c'est un objet de classe, on effectue un appel récursif
        if isstruct(value) 
            [Parameters, Values, Units] = parse_structure(value, class(value), Parameters, Values, Units, env);
        elseif isprop(value, 'Configuration')
            value.disp_parameters_table(env)
        else
            % Ajuster l'unité et convertir la valeur
            [convertedValue, unit] = convert_unit(value, field);
            
            % Ajouter le paramètre, sa valeur et son unité
            Parameters{end+1} = fullName;
            Values{end+1} = convertedValue;
            Units{end+1} = unit;
        end
    end
end