function S = recon_struct(fields, values, lower_bounds, upper_bounds)

    % Cette fonction permet de transférer dans une structure les valeurs contenues dans plusieurs vecteurs

    % Vérifie que la longueur des champs et des valeurs est la même
    if length(fields) ~= length(values) || length(fields) ~= length(lower_bounds) || length(fields) ~= length(upper_bounds)
        error('Le nombre de champs, de valeurs, de bornes inférieures et de bornes supérieures doit être le même.');
    end
    
    % Initialise une structure vide
    S = struct();
    
    % Boucle à travers chaque champ et attribue la valeur correspondante
    for i = 1:length(fields)
        S.(fields{i}) = [values(i), lower_bounds(i), upper_bounds(i)];
    end
end