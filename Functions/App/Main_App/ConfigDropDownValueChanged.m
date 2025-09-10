function ConfigDropDownValueChanged(app, event)

    % Cette fonction remplace les champs de la fenêtre d'affichage des paramètres d'un type 
    % de sous-élement par les valeurs associées enregistrées dans la configuration sélectionnée 
    % dans le menu déroulant

    % Obtenez les noms des paramètres dans la structure SubelementTypes
    subelement_types = fieldnames(app.SubelementTypes);
    
    % Parcourez tous les noms des paramètres
    for i = 1:length(subelement_types)
        % Vérifiez si le panneau des paramètres est visible
        if app.SubelementTypes.(subelement_types{i}).ParametersPanel.Visible == "on"
            % Obtenez la valeur sélectionnée dans le menu déroulant de configuration
            value = app.SubelementTypes.(subelement_types{i}).ConfigDropDown.Value;
            % Obtenez les noms des configurations
            configs = fieldnames(app.SubelementTypes.(subelement_types{i}).Configurations);
            
            % Parcourez toutes les variables
            for j = 1:length(configs)
                % Si le nom de la configuration correspond à la valeur sélectionnée dans le menu déroulant
                if strcmp(app.SubelementTypes.(subelement_types{i}).Configurations.(configs{j}).Name, value)
                    % Parcourez tous les champs d'édition des paramètres
                    for k = 1:length(app.SubelementTypes.(subelement_types{i}).ParametersPanel.ParameterEditField)
                        % Mettez à jour la valeur des champs d'édition des paramètres
                        app.SubelementTypes.(subelement_types{i}).ParametersPanel.ParameterEditField{k}.Value = app.SubelementTypes.(subelement_types{i}).Configurations.(configs{j}).Value(k);
                    end
                end
            end
        end
    end
end


