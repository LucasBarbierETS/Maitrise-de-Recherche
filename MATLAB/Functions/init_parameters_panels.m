function init_parameters_panels(app)

    % Initialise les panneaux d'affichages des paramètres des types de sous-élements courants

    % - Porous Material (Rigid)
    app.SubelementTypes.RigidPorousMaterial = struct();
    app.SubelementTypes.RigidPorousMaterial.ParametersPanelStruct = add_parameters_panel_structure(app, 6, ["Porosity", "Airflow Resistivity", "Tortuosity", "Viscous Characteristic Length", "Thermal Characteristic Length", "Thickness"], ["[0-1]", "Pa.s/m2", "(no unit)", "m", "m", "m"]);
    app.SubelementTypes.RigidPorousMaterial.Color = "#335987";

    % - Porous Material (Limp)
    app.SubelementTypes.LimpPorousMaterial.ParametersPanelStruct = add_parameters_panel_structure(app, 7, ["Porosity", "Airflow Resistivity", "Tortuosity", "Viscous Characteristic Length", "Thermal Characteristic Length", "Thickness", "Material Density"], ...
                                                                    ["[0-1]", "Pa.s/m2", "(no unit)", "m", "m", "m", "kg/m3"]);
    app.SubelementTypes.LimpPorousMaterial.Color = "#548FAB";

    % - MPP (Circular)
    app.SubelementTypes.CircularMPP.ParametersPanelStruct = add_parameters_panel_structure(app, 3, ["Porosity", "Thickness", "Radius"], ["[0-1]", "m", "m"]);
    app.SubelementTypes.CircularMPP.Color = "#094F29";
    
    % - MPP (Slit)
    app.SubelementTypes.SlitMPP.ParametersPanelStruct = add_parameters_panel_structure(app, 4, ["Porosity", "Thickness", "Length", "Width"], ["[0-1]", "m", "m", "m"]);
    app.SubelementTypes.SlitMPP.Color = "#429B46";
    
    % - MPP (Rectangular)
    app.SubelementTypes.RectangularMPP.ParametersPanelStruct = add_parameters_panel_structure(app, 4, ["Porosity", "Thickness", "Length", "Width"], ["[0-1]", "m", "m", "m"]);
    app.SubelementTypes.RectangularMPP.Color = "#94C58C"; 

    % - Helmholtz Resonator (Free geometry)
    app.SubelementTypes.HR1.ParametersPanelStruct = add_parameters_panel_structure(app, 3, ["Neck Surface", "Neck Length", "Cavity Volume"], ["m2", "m", "m3"]);
    app.SubelementTypes.HR1.Color = "#8B0001";

    % - Helmholtz Resonator (Cylindrical)
    app.SubelementTypes.HR2.ParametersPanelStruct = add_parameters_panel_structure(app, 4, ["Neck Radius", "Neck Depth", "Cavity Radius", "Cavity Depth"], ["m", "m", "m", "m"]);
    app.SubelementTypes.HR2.Color = "#C92020";

    % - Resistive Screen
    app.SubelementTypes.Screen.ParametersPanelStruct = add_parameters_panel_structure(app, 2, ["Screen Density", "Thickness"], ["kg/m3", "m"]);
    app.SubelementTypes.Screen.Color = "#FFA500";

    % - Grid
    app.SubelementTypes.Grid.ParametersPanelStruct = add_parameters_panel_structure(app, 4, ["Mesh Length", "Mesh Width", "Thickness", "Porosity"], ["m", "m", "m", "%"]);
    app.SubelementTypes.Grid.Color = "#6600A1";

    % - Quarter Wavelength Resonator
    app.SubelementTypes.QWL.ParametersPanelStruct = add_parameters_panel_structure(app, 3, ["Main Radius", "Resonator Radius", "Resonator Length"], ["m", "m", "m"]);
    app.SubelementTypes.QWL.Color = "#C0428A";

    % - Cavity
    app.SubelementTypes.Cavity.ParametersPanelStruct = add_parameters_panel_structure(app, 1, "Length", "m");
    app.SubelementTypes.Cavity.Color = "#30D5C8";
    
    % - Section Change
    app.SubelementTypes.SectionChange.ParametersPanelStruct = add_parameters_panel_structure(app, 2, ["Input Surface", "Output Surface"], ["m2", "m2"]);
    app.SubelementTypes.SectionChange.Color = "#6F4E37";

end

