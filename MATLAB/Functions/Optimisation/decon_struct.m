function [fields, values, lower_bounds, upper_bounds] = decon_struct(S)
    % Retourne un cell array 'fields' contenant le nom des variables de la structure et les vecteurs 'values', 'lower_bounds' 
    % et 'upper_bounds' contenant les valeurs des ces variables dans l'ordre ou celles-ci apparaissent dans le tableau.

    fields = fieldnames(S)';
    
    % Preallocate a cell array to hold the values
    values = zeros(1, numel(fields));
    lower_bounds = zeros(1, numel(fields));
    upper_bounds = zeros(1, numel(fields));
    
    % Loop through each field and get the corresponding value
    for i = 1:numel(fields)
        values(i) = S.(fields{i})(1);
        lower_bounds(i) = S.(fields{i})(2);
        upper_bounds(i) = S.(fields{i})(3);

    end
end