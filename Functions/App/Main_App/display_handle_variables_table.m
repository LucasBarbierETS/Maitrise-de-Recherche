function display_handle_variables_table(app)

    % Cette fonction prend pour argument l'application principale

    % Cette fonction permet d'afficher le tableau des variables muettes à partir de la structure
    % app.HandleVariables
   
    % On récupère la taille et le nom des variables de la structure app.HandleVariables
    variables_names = fieldnames(app.HandleVariables);
    variables_number = length(variables_names);

    % On conditionne les données dans des vecteurs et des cell array
    lower_bounds = zeros(1, variables_number);   
    upper_bounds = zeros(1, variables_number);
    units = cell(1, variables_number);
    descriptions = cell(1, variables_number);

    for i = 1:variables_number
        lower_bounds(i) = app.HandleVariables.(variables_names{i}).UpperBound;
        upper_bounds(i) = app.HandleVariables.(variables_names{i}).LowerBound;
        units{i} = app.HandleVariables.(variables_names{i}).Unit;
        descriptions{i} = app.HandleVariables.(variables_names{i}).Decription;
    end
    
   % On met à jour la structure app.HandleVariables
   HandleParametersTable = table(variables_names, lower_bounds, upper_bounds, units, descriptions);
   HandleParametersTable.Properties.VariableNames = ["Name" "Value" "Lower born" "Upper born" "Despcription"];
   app.HandleVariablesTable.Data = HandleParametersTable;

end

