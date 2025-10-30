function app = perso_subelement_type_dropdown_value_changed(app)
% Callback externe pour le changement de valeur du menu déroulant des sous-éléments

    % On sélectionne le menu déroulant
    subelement_type_dropdown = app.ParametersPanel.Components.SubelementParameters.UIObject.Children(2);

    % On récupère le type de sous-éléments associé
    current_type_name = app.Types.(subelement_type_dropdown.Value).TypeName;

    % On affiche le panneau de paramètres associé
    app.Types.SubelementsParametersPanel.Components.(current_type_name).show();                
end