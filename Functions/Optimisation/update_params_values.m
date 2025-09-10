function params = update_params_values(params, values)
    % Cette fonction met à jour la structure avec la valeur courante prise par les variables qu'elle contient

    % Vérifie que la longueur des champs et des valeurs est la même
    fields = fieldnames(params);
    if length(fields) ~= length(values) 
        error('Le nombre de champs et le nombre de valeurs doivent être égaux.');
    end
    
    % Boucle à travers chaque champ et attribue la valeur correspondante
    for i = 1:length(fields)
        params.(fields{i})(1) = values(i);
    end
end