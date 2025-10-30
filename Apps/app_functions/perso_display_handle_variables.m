function app = perso_display_handle_variables(app)
    % Réinitialise la table des variables
    app.HandleVariablesTable.Data(:, :) = [];

    var_name = fieldnames(app.HandleVariables);
    n = length(var_name);
    
    for i = 1:n
        app.HandleVariablesTable.Data(i, :) = ...
            {var_name{i}, ...
             app.HandleVariables.(var_name{i}).Value, ...
             app.HandleVariables.(var_name{i}).Description};
    end
end

