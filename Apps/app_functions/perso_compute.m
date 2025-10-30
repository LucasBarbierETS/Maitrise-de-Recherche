function app = perso_compute(app, name)
    % Construit la liste des éléments de l'application
    list_of_elements = {};
    for i = 1:length(app.Elements.Content)
        list_of_elements{end+1} = app.Elements.Content{i}.app_to_class(app);
    end

    % Crée l'assemblage et affiche le résultat
    assembly = classelementassembly(list_of_elements);
    assembly.plot_alpha(app.Env, name);     
end