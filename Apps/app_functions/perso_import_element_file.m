function app = perso_import_element_file(app)
    % Ouvre une boîte de dialogue pour récupérer l'élément
    default_folder = [app.EnvApp.Root, '\Apps\Elements'];
    [file, path] = uigetfile('', 'Sélectionner un fichier', default_folder); 
    if isequal(file,0)
        return; % L'utilisateur a annulé
    end
    selectedfile = fullfile(path, file);

    % Charge l'élément
    class_element = importdata(selectedfile);

    % Ajoute l'élément dans l'app
    app.Elements.add_content(class_element.HandleAppBuilder(app, class_element));

    % Affiche l'élément importé
    app.Elements.Content{end}.show(app);
end