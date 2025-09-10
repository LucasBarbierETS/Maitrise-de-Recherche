function updated_variables = x0_to_variables(x0, variables)
    % Cette fonction met à jour la premières valeur de chaque attribut de la structure 'variables' 
    % par les valeurs courantes de ces variables contenues dans x0

    updated_variables = variables;
    fields = fieldnames(variables);

    for i = 1:length(x0)
        currentfield = fields{i};
        updated_variables.(currentfield)(:, 1) = x0(:, i);
    end 
end

