function SubelementtypeDropDownValueChanged(app)
           
    % Cette commande contrôle l'affichage de la fenêtre des paramètres du sous-élement courant
    % La valeur du menu déroulant peux changer si :
    %   - l'utiliateur change manuellement le type d'un sous-élement de la configuration
    %   - l'utilisateur clique sur un sous-élement dont le type est différent du sous-élement précedemment sélectionné

    value = app.SublementtypeDropDown.Value;

    switch value
        case 'Porous Material (Rigid)'
            app.SubelementTypes.RigidPorousMaterial.ParametersPanelStruct.Visible = "on";
            app.SubelementTypes.LimpPorousMaterial.ParametersPanelStruct.Visible = "off";
            app.SubelementTypes.CircularMPP.ParametersPanelStruct.Visible = "off";
            app.SubelementTypes.SlitMPP.ParametersPanelStruct.Visible = "off";
            app.SubelementTypes.RectangularMPP.ParametersPanelStruct.Visible = "off";
            app.SubelementTypes.HR1.ParametersPanelStruct.Visible = "off";
            app.SubelementTypes.HR2.ParametersPanelStruct.Visible = "off";
            app.SubelementTypes.Screen.ParametersPanelStruct.Visible = "off";
            app.SubelementTypes.Grid.ParametersPanelStruct.Visible = "off";
            app.SubelementTypes.QWL.ParametersPanelStruct.Visible = "off";
            app.SubelementTypes.Cavity.ParametersPanelStruct.Visible = "off";
            app.SubelementTypes.SectionChange.ParametersPanelStruct.Visible = "off";
            app.SubelementTypes.SelectedSubelementHandleFunction = "classJCA";

        case 'Porous Material (Limp)'
            app.SubelementTypes.RigidPorousMaterial.ParametersPanelStruct.Visible = "off";
            app.SubelementTypes.LimpPorousMaterial.ParametersPanelStruct.Visible = "on";
            app.SubelementTypes.CircularMPP.ParametersPanelStruct.Visible = "off";
            app.SubelementTypes.SlitMPP.ParametersPanelStruct.Visible = "off";
            app.SubelementTypes.RectangularMPP.ParametersPanelStruct.Visible = "off";
            app.SubelementTypes.HR1.ParametersPanelStruct.Visible = "off";
            app.SubelementTypes.HR2.ParametersPanelStruct.Visible = "off";
            app.SubelementTypes.Screen.ParametersPanelStruct.Visible = "off";
            app.SubelementTypes.Grid.ParametersPanelStruct.Visible = "off";
            app.SubelementTypes.QWL.ParametersPanelStruct.Visible = "off";
            app.SubelementTypes.Cavity.ParametersPanelStruct.Visible = "off";
            app.SubelementTypes.SectionChange.ParametersPanelStruct.Visible = "off";
            app.SubelementTypes.SelectedSubelementHandleFunction = "classJCA";

        case 'MPP (Circular)'
            app.SubelementTypes.RigidPorousMaterial.ParametersPanelStruct.Visible = "off";
            app.SubelementTypes.LimpPorousMaterial.ParametersPanelStruct.Visible = "off";
            app.SubelementTypes.CircularMPP.ParametersPanelStruct.Visible = "on";
            app.SubelementTypes.SlitMPP.ParametersPanelStruct.Visible = "off";
            app.SubelementTypes.RectangularMPP.ParametersPanelStruct.Visible = "off";
            app.SubelementTypes.HR1.ParametersPanelStruct.Visible = "off";
            app.SubelementTypes.HR2.ParametersPanelStruct.Visible = "off";
            app.SubelementTypes.Screen.ParametersPanelStruct.Visible = "off";
            app.SubelementTypes.Grid.ParametersPanelStruct.Visible = "off";
            app.SubelementTypes.QWL.ParametersPanelStruct.Visible = "off";
            app.SubelementTypes.Cavity.ParametersPanelStruct.Visible = "off";
            app.SubelementTypes.SectionChange.ParametersPanelStruct.Visible = "off";
            app.SubelementTypes.SelectedSubelementHandleFunction = "classMPP";

        case 'MPP (Slits)'
            app.SubelementTypes.RigidPorousMaterial.ParametersPanelStruct.Visible = "off";
            app.SubelementTypes.LimpPorousMaterial.ParametersPanelStruct.Visible = "off";
            app.SubelementTypes.CircularMPP.ParametersPanelStruct.Visible = "off";
            app.SubelementTypes.SlitMPP.ParametersPanelStruct.Visible = "on";
            app.SubelementTypes.RectangularMPP.ParametersPanelStruct.Visible = "off";
            app.SubelementTypes.HR1.ParametersPanelStruct.Visible = "off";
            app.SubelementTypes.HR2.ParametersPanelStruct.Visible = "off";
            app.SubelementTypes.Screen.ParametersPanelStruct.Visible = "off";
            app.SubelementTypes.Grid.ParametersPanelStruct.Visible = "off";
            app.SubelementTypes.QWL.ParametersPanelStruct.Visible = "off";
            app.SubelementTypes.Cavity.ParametersPanelStruct.Visible = "off";
            app.SubelementTypes.SectionChange.ParametersPanelStruct.Visible = "off";
            app.SubelementTypes.SelectedSubelementHandleFunction = "classMPP";

        case 'MPP (Rectangular)'
            app.SubelementTypes.RigidPorousMaterial.ParametersPanelStruct.Visible = "off";
            app.SubelementTypes.LimpPorousMaterial.ParametersPanelStruct.Visible = "off";
            app.SubelementTypes.CircularMPP.ParametersPanelStruct.Visible = "off";
            app.SubelementTypes.SlitMPP.ParametersPanelStruct.Visible = "off";
            app.SubelementTypes.RectangularMPP.ParametersPanelStruct.Visible = "on";
            app.SubelementTypes.HR1.ParametersPanelStruct.Visible = "off";
            app.SubelementTypes.HR2.ParametersPanelStruct.Visible = "off";
            app.SubelementTypes.Screen.ParametersPanelStruct.Visible = "off";
            app.SubelementTypes.Grid.ParametersPanelStruct.Visible = "off";
            app.SubelementTypes.QWL.ParametersPanelStruct.Visible = "off";
            app.SubelementTypes.Cavity.ParametersPanelStruct.Visible = "off";
            app.SubelementTypes.SectionChange.ParametersPanelStruct.Visible = "off";
            app.SubelementTypes.SelectedSubelementHandleFunction = "classMPP";

        case 'Helmholtz Resonator (Free Geometry)'
            app.SubelementTypes.RigidPorousMaterial.ParametersPanelStruct.Visible = "off";
            app.SubelementTypes.LimpPorousMaterial.ParametersPanelStruct.Visible = "off";
            app.SubelementTypes.CircularMPP.ParametersPanelStruct.Visible = "off";
            app.SubelementTypes.SlitMPP.ParametersPanelStruct.Visible = "off";
            app.SubelementTypes.RectangularMPP.ParametersPanelStruct.Visible = "off";
            app.SubelementTypes.HR1.ParametersPanelStruct.Visible = "on";
            app.SubelementTypes.HR2.ParametersPanelStruct.Visible = "off";
            app.SubelementTypes.Screen.ParametersPanelStruct.Visible = "off";
            app.SubelementTypes.Grid.ParametersPanelStruct.Visible = "off";
            app.SubelementTypes.QWL.ParametersPanelStruct.Visible = "off";
            app.SubelementTypes.Cavity.ParametersPanelStruct.Visible = "off";
            app.SubelementTypes.SectionChange.ParametersPanelStruct.Visible = "off";
            app.SubelementTypes.SelectedSubelementHandleFunction = "classHR1";

        case 'Helmholtz Resonator (Cylindrical)'
            app.SubelementTypes.RigidPorousMaterial.ParametersPanelStruct.Visible = "off";
            app.SubelementTypes.LimpPorousMaterial.ParametersPanelStruct.Visible = "off";
            app.SubelementTypes.CircularMPP.ParametersPanelStruct.Visible = "off";
            app.SubelementTypes.SlitMPP.ParametersPanelStruct.Visible = "off";
            app.SubelementTypes.RectangularMPP.ParametersPanelStruct.Visible = "off";
            app.SubelementTypes.HR1.ParametersPanelStruct.Visible = "off";
            app.SubelementTypes.HR2.ParametersPanelStruct.Visible = "on";
            app.SubelementTypes.Screen.ParametersPanelStruct.Visible = "off";
            app.SubelementTypes.Grid.ParametersPanelStruct.Visible = "off";
            app.SubelementTypes.QWL.ParametersPanelStruct.Visible = "off";
            app.SubelementTypes.Cavity.ParametersPanelStruct.Visible = "off";
            app.SubelementTypes.SectionChange.ParametersPanelStruct.Visible = "off";
            app.SubelementTypes.SelectedSubelementHandleFunction = "classHR2";

        case 'Resistive Screen'
            app.SubelementTypes.RigidPorousMaterial.ParametersPanelStruct.Visible = "off";
            app.SubelementTypes.LimpPorousMaterial.ParametersPanelStruct.Visible = "off";
            app.SubelementTypes.CircularMPP.ParametersPanelStruct.Visible = "off";
            app.SubelementTypes.SlitMPP.ParametersPanelStruct.Visible = "off";
            app.SubelementTypes.RectangularMPP.ParametersPanelStruct.Visible = "off";
            app.SubelementTypes.HR1.ParametersPanelStruct.Visible = "off";
            app.SubelementTypes.HR2.ParametersPanelStruct.Visible = "off";
            app.SubelementTypes.Screen.ParametersPanelStruct.Visible = "on";
            app.SubelementTypes.Grid.ParametersPanelStruct.Visible = "off";
            app.SubelementTypes.QWL.ParametersPanelStruct.Visible = "off";
            app.SubelementTypes.Cavity.ParametersPanelStruct.Visible = "off";
            app.SubelementTypes.SectionChange.ParametersPanelStruct.Visible = "off";
            app.SubelementTypes.SelectedSubelementHandleFunction = "classscreen";

        case 'Protective Grid'
            app.SubelementTypes.RigidPorousMaterial.ParametersPanelStruct.Visible = "off";
            app.SubelementTypes.LimpPorousMaterial.ParametersPanelStruct.Visible = "off";
            app.SubelementTypes.CircularMPP.ParametersPanelStruct.Visible = "off";
            app.SubelementTypes.SlitMPP.ParametersPanelStruct.Visible = "off";
            app.SubelementTypes.RectangularMPP.ParametersPanelStruct.Visible = "off";
            app.SubelementTypes.HR1.ParametersPanelStruct.Visible = "off";
            app.SubelementTypes.HR2.ParametersPanelStruct.Visible = "off";
            app.SubelementTypes.Screen.ParametersPanelStruct.Visible = "off";
            app.SubelementTypes.Grid.ParametersPanelStruct.Visible = "on";
            app.SubelementTypes.QWL.ParametersPanelStruct.Visible = "off";
            app.SubelementTypes.Cavity.ParametersPanelStruct.Visible = "off";
            app.SubelementTypes.SectionChange.ParametersPanelStruct.Visible = "off";
            app.SubelementTypes.SelectedSubelementHandleFunction = "classgrid";

        case 'Quarter Wavelength Resonator'

            app.SubelementTypes.RigidPorousMaterial.ParametersPanelStruct.Visible = "off";
            app.SubelementTypes.LimpPorousMaterial.ParametersPanelStruct.Visible = "off";
            app.SubelementTypes.CircularMPP.ParametersPanelStruct.Visible = "off";
            app.SubelementTypes.SlitMPP.ParametersPanelStruct.Visible = "off";
            app.SubelementTypes.RectangularMPP.ParametersPanelStruct.Visible = "off";
            app.SubelementTypes.HR1.ParametersPanelStruct.Visible = "off";
            app.SubelementTypes.HR2.ParametersPanelStruct.Visible = "off";
            app.SubelementTypes.Screen.ParametersPanelStruct.Visible = "off";
            app.SubelementTypes.Grid.ParametersPanelStruct.Visible = "off";
            app.SubelementTypes.QWL.ParametersPanelStruct.Visible = "on";
            app.SubelementTypes.Cavity.ParametersPanelStruct.Visible = "off";
            app.SubelementTypes.SectionChange.ParametersPanelStruct.Visible = "off";
            app.SubelementTypes.SelectedSubelementHandleFunction = "classQWL";

        case 'Cavity'
            app.SubelementTypes.RigidPorousMaterial.ParametersPanelStruct.Visible = "off";
            app.SubelementTypes.LimpPorousMaterial.ParametersPanelStruct.Visible = "off";
            app.SubelementTypes.CircularMPP.ParametersPanelStruct.Visible = "off";
            app.SubelementTypes.SlitMPP.ParametersPanelStruct.Visible = "off";
            app.SubelementTypes.RectangularMPP.ParametersPanelStruct.Visible = "off";
            app.SubelementTypes.HR1.ParametersPanelStruct.Visible = "off";
            app.SubelementTypes.HR2.ParametersPanelStruct.Visible = "off";
            app.SubelementTypes.Screen.ParametersPanelStruct.Visible = "off";
            app.SubelementTypes.Grid.ParametersPanelStruct.Visible = "off";
            app.SubelementTypes.QWL.ParametersPanelStruct.Visible = "off";
            app.SubelementTypes.Cavity.ParametersPanelStruct.Visible = "on";
            app.SubelementTypes.SectionChange.ParametersPanelStruct.Visible = "off";
            app.SubelementTypes.SelectedSubelementHandleFunction = "classcavity";

        case 'Section Change'

            app.SubelementTypes.RigidPorousMaterial.ParametersPanelStruct.Visible = "off";
            app.SubelementTypes.LimpPorousMaterial.ParametersPanelStruct.Visible = "off";
            app.SubelementTypes.CircularMPP.ParametersPanelStruct.Visible = "off";
            app.SubelementTypes.SlitMPP.ParametersPanelStruct.Visible = "off";
            app.SubelementTypes.RectangularMPP.ParametersPanelStruct.Visible = "off";
            app.SubelementTypes.HR1.ParametersPanelStruct.Visible = "off";
            app.SubelementTypes.HR2.ParametersPanelStruct.Visible = "off";
            app.SubelementTypes.Screen.ParametersPanelStruct.Visible = "off";
            app.SubelementTypes.Grid.ParametersPanelStruct.Visible = "off";
            app.SubelementTypes.QWL.ParametersPanelStruct.Visible = "off";
            app.SubelementTypes.Cavity.ParametersPanelStruct.Visible = "off";
            app.SubelementTypes.SectionChange.ParametersPanelStruct.Visible = "on";
            app.SubelementTypes.SelectedSubelementHandleFunction = "classsectionchange";

        otherwise
            app.SubelementTypes.RigidPorousMaterial.ParametersPanelStruct.Visible = "off";
            app.SubelementTypes.LimpPorousMaterial.ParametersPanelStruct.Visible = "off";
            app.SubelementTypes.CircularMPP.ParametersPanelStruct.Visible = "off";
            app.SubelementTypes.SlitMPP.ParametersPanelStruct.Visible = "off";
            app.SubelementTypes.RectangularMPP.ParametersPanelStruct.Visible = "off";
            app.SubelementTypes.HR1.ParametersPanelStruct.Visible = "off";
            app.SubelementTypes.HR2.ParametersPanelStruct.Visible = "off";
            app.SubelementTypes.Screen.ParametersPanelStruct.Visible = "off";
            app.SubelementTypes.Grid.ParametersPanelStruct.Visible = "off";
            app.SubelementTypes.QWL.ParametersPanelStruct.Visible = "off";
            app.SubelementTypes.Cavity.ParametersPanelStruct.Visible = "off";
            app.SubelementTypes.SectionChange.ParametersPanelStruct.Visible = "off";
            app.SubelementTypes.SelectedSubelementHandleFunction = "";
    end

end
