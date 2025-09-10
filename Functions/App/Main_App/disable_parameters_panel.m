function disable_parameters_panel(app)

    % Cette fonction prend en entrée une instance de Main_App.mlapp

    % Elle permet de désactiver les élements du panneau d'affichage des paramètres
    % à savoir : 
    %   - le bouton "Delete Subelement"
    %   - le menu déroulant "Subelement Type"

    app.SublementtypeDropDownLabel.Enable = "off";
    app.DeleteSubelementButton.Enable = "off";
end