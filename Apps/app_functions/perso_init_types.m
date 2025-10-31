function app = perso_init_types(app)
        
            % Voir app.SubelementsTypes

            % On sélectionne le menu déroulant associé au type de
            % sous-élements
            dropdown = app.TypeDropDown;

            %% None

            if ~isfield(app.Types, 'None')
                app.Types.None.TypeName = 'None';
                % app.Types.None.Color = 'k';
                % app.Types.None.Marker = '+';
                app.Types.None.HandleDrawFunction = @(obj, ax, args) draw_none(app.EnvApp, obj, ax, args{:});
                dropdown.Items{end + 1} = char();
                dropdown.ItemsData{end + 1} = 'None';
            end

            %% Undefined

            if ~isfield(app.Types, 'Undefined')
                app.Types.Undefined.TypeName = 'Undefined';
                % app.Types.Undefined.Color = 'k';
                % app.Types.Undefined.Marker = 'diamond';
                app.Types.Undefined.HandleDrawFunction = @(obj, ax, args) draw_undefined(app.EnvApp, obj, ax, args{:});
                app.Types.Undefined.ParametersPanelStruct = ...
                    add_parameters_subpanel_structure(app, 'Undefined', {}, {});

                app.Types.Undefined.HandleAppObject = @(app) AppObject(app);

                dropdown.Items{end + 1} = 'Undefined (Choose a type)';
                dropdown.ItemsData{end + 1} = 'Undefined';
            end

            %% Imported Element

            if ~isfield(app.Types, 'classelement_imported')
                app.Types.classelement_imported.TypeName = 'classelement_imported';
                % app.Types.classelement_imported.Color = 'k';
                % app.Types.classelement_imported.Marker = 'diamond';
                app.Types.classelement_imported.HandleDrawFunction = @(obj, ax, args) draw_classelement_imported(app.EnvApp, obj, ax, args{:});
                app.Types.classelement_imported.ParametersPanelStruct = ...
                add_parameters_subpanel_structure(app, 'classelement_imported', {}, {});

                app.Types.classelement_imported.HandleAppObject = @(app) AppObject(app);

                app.Types.classelement_imported.HandleAppConfig = @(class_config_double) ...
                feval(@(class_config_str) struct('FrequencySupport', class_config_str.FrequencySupport, ...
                                                  'SurfaceImpedance', class_config_str.SurfaceImpedance, ...
                                                  'Surface', class_config_str.Surface), ...
                      perso_struct_num2str(class_config_double)); 

                app.Types.classelement_imported.HandleClassObject = @(class_config_double) ...
                classelement_imported(classelement_imported.create_config(class_config_double.FrequencySupport, ...
                                                                          class_config_double.SurfaceImpedance, ...
                                                                          class_config_double.Surface));

                app.Types.classelement_imported.HandleClassConfig = @(app_config_str) ...
                feval(@(app_config_double) struct('FrequencySupport', app_config_double.FrequencySupport, ...
                                                  'SurfaceImpedance', app_config_double.SurfaceImpedance, ...
                                                  'Surface', app_config_double.Surface), ...
                perso_struct_str2double(app_config_str)); 

                dropdown.Items{end + 1} = 'Subelement with Imported Data';
                dropdown.ItemsData{end + 1} = 'classelement_imported';
            end

            %% Element

            if~isfield(app.Types, 'classelement')
                app.Types.classelement.ParametersPanelStruct = add_parameters_subpanel_structure ...
                (app, 'classelement', {'Surface'}, {'m^2'});

                app.Types.classelement.TypeName = 'classelement';
                % app.Types.classelement.Color = 'k';
                % app.Types.classelement.Marker = 's';
                app.Types.classelement.HandleDrawFunction = @(obj, ax, args) draw_classelement(app.EnvApp, obj, ax, args{:});
                app.Types.classelement.HandleAppObject = @(app) AppElement(app);

                app.Types.classelement.HandleClassObject = @(list_of_subelements, app_config_double) ...
                classelement(classelement.create_config(list_of_subelements, 'closed', app_config_double.Surface));
    
                app.Types.classelement.HandleAppConfig = @(class_config_double) ...
                feval(@ (class_config_str) struct('Surface', class_config_str.Surface), ...
                perso_struct_num2str(class_config_double)); 

                app.Types.classelement.HandleClassConfig = @(app_config_str) ...
                feval(@ (app_config_double) struct('Surface', app_config_double.Surface), ...
                perso_struct_str2double(app_config_str)); 

                dropdown.Items{end + 1} = 'Element';
                dropdown.ItemsData{end + 1} = 'classelement';
            end 

            %% Element Assembly

            if~isfield(app.Types, 'classelementassembly')
                app.Types.classelementassembly.ParametersPanelStruct = add_parameters_subpanel_structure ...
                (app, 'classelementassembly', {}, {});

                app.Types.classelementassembly.TypeName = 'classelementassembly';
                % app.Types.classelementassembly.Color = 'k';
                % app.Types.classelementassembly.Marker = 's';
                app.Types.classelementassembly.HandleDrawFunction = @(obj, ax, args) draw_classelementassembly(app.EnvApp, obj, ax, args{:});
                app.Types.classelementassembly.HandleAppObject = @(app) AppElementAssembly(app);

                app.Types.classelementassembly.HandleAppConfig = @(class_config_double) ...
                feval(@ (class_config_str) struct(), ...
                perso_struct_num2str(class_config_double)); 

                app.Types.classelementassembly.HandleClassObject = @(list_of_elements) ...
                classelementassembly(classelementassembly.create_config(list_of_elements));

                app.Types.classelementassembly.HandleClassConfig = @(app_config_str) ...
                feval(@ (app_config_double) struct(), ...
                perso_struct_str2double(app_config_str));

                dropdown.Items{end + 1} = 'Element Assembly';
                dropdown.ItemsData{end + 1} = 'classelementassembly';
            end 

            %% Periodic

            if ~isfield(app.Types, 'Periodic')
                app.Types.Periodic.TypeName = 'Periodic';
                % app.Types.Periodic.Color = 'k';
                % app.Types.Periodic.Marker = 'hexagon';
                app.Types.Periodic.HandleDrawFunction = @(obj, ax, args) draw_periodic(app.EnvApp, obj, ax, args{:});
                app.Types.Periodic.ParametersPanelStruct = ...
                add_parameters_subpanel_structure(app, 'Periodic', {}, {});

                dropdown.Items{end + 1} = 'Periodic';
                dropdown.ItemsData{end + 1} = 'Periodic';
            end 

            %% Junction

            if ~isfield(app.Types, 'Junction')

                app.Types.classjunction.ParametersPanelStruct = add_parameters_subpanel_structure ...
                (app, 'classjunction', {'Junction Element Type', 'Section'}, {'', 'm'});

                app.Types.classjunction.TypeName = 'classjunction';
                % app.Types.classjunction.Color = '#30D5C8';
                % app.Types.classjunction.Marker = 'diamond';
                app.Types.classjunction.HandleDrawFunction = @(obj, ax, args) draw_classjunction(app.EnvApp, obj, ax, args{:});
                app.Types.classjunction.HandleAppObject = @(app) AppJunction(app);

                app.Types.classjunction.HandleClassObject = @(jcn_element, app_config_double) ...
                classjunction(classjunction.create_config( ...
                jcn_element, app_config_double.Section));
    
                app.Types.classjunction.HandleAppConfig = @(class_config_double) ...
                feval(@(class_config_str) struct('JunctionElementType', class(class_config_str.JunctionElement), ...
                'Section', class_config_str.Section), perso_struct_num2str(class_config_double));

                app.Types.classjunction.HandleClassConfig = @(app_config_str) ...
                feval(@(app_config_double) struct('Section', app_config_double.Section), perso_struct_str2double(app_config_str));
                
                dropdown.Items{end + 1} = 'Junction';
                dropdown.ItemsData{end + 1} = 'classjunction';
            end

            %% Porous Material (Rigid)

            if ~isfield(app.Types, 'classJCA_Rigid')

                app.Types.classJCA_Rigid .ParametersPanelStruct = ...
                add_parameters_subpanel_structure(app,  'classJCA_Rigid', ...
                {'Thickness', 'Section', 'Porosity', 'AirFlow Resistivity', 'Tortuosity', 'Viscous Caracteristic Length', ...
                'Thermal Caracteristic Length'}, ...
                {'m', 'm^2', '[0-1]', 'Pa.s/m2', '(no unit)', 'm', 'm'});
    
                app.Types.classJCA_Rigid.TypeName = 'classJCA_Rigid';
                % app.Types.classJCA_Rigid.Color = '#548FAB';
                % app.Types.classJCA_Rigid.Marker = 'diamond';
                app.Types.classJCA_Rigid.HandleDrawFunction = @(obj, ax, args) draw_classJCA_rigid(app.EnvApp, obj, ax, args{:});
                app.Types.classJCA_Rigid.HandleAppObject = @(app) AppSubelement(app);

                app.Types.classJCA_Rigid.HandleAppConfig = @(class_config_double) ...
                feval(@(class_config_str) struct('Thickness', class_config_str.Thickness, ...
                                                  'Section', class_config_str.Section, ...
                                                  'Porosity', class_config_str.Porosity, ...
                                                  'AirFlowResistivity', class_config_str.AirFlowResistivity, ...
                                                  'Tortuosity', class_config_str.Tortuosity, ...
                                                  'ViscousCaracteristicLength', class_config_str.ViscousCaracteristicLength, ...
                                                  'ThermalCaracteristicLength', class_config_str.ThermalCaracteristicLength), ...
                       perso_struct_num2str(class_config_double)); 

                app.Types.classJCA_Rigid.HandleClassObject = @(class_config_double) ...
                classJCA_Rigid(classJCA_Rigid.create_config(class_config_double.Section, ...
                                                            class_config_double.Thickness, ...
                                                            class_config_double.Porosity, ...
                                                            class_config_double.Tortuosity, ...
                                                            class_config_double.AirFlowResistivity, ...
                                                            class_config_double.ViscousCaracteristicLength, ...
                                                            class_config_double.ThermalCaracteristicLength));

                app.Types.classJCA_Rigid.HandleClassConfig = @(app_config_str) ...
                feval(@(app_config_double) struct('Thickness', app_config_double.Thickness, ...
                                                  'Section', app_config_double.Section, ...
                                                  'Porosity', app_config_double.Porosity, ...
                                                  'AirFlowResistivity', app_config_double.AirFlowResistivity, ...
                                                  'Tortuosity', app_config_double.Tortuosity, ...
                                                  'ViscousCaracteristicLength', app_config_double.ViscousCaracteristicLength, ...
                                                  'ThermalCaracteristicLength', app_config_double.ThermalCaracteristicLength), ...
                       perso_struct_str2double(app_config_str)); 
 
                dropdown.Items{end + 1} = 'JCA MAterial';
                dropdown.ItemsData{end + 1} = 'classJCA_Rigid';
            end
        
            %% Perforated Plate (Circular)

            if ~isfield(app.Types, 'classMPP_Circular')
                app.Types.classMPP_Circular.ParametersPanelStruct = ...
                add_parameters_subpanel_structure(app, 'classMPP_Circular', ...
                {'Relative Porosity', 'Thickness', 'Perforations Radius' 'Perforated Area Surface' 'Thickness Correction'}, ...
                {'[0-1]', 'm', 'm', 'm^2', 'm'});
    
                app.Types.classMPP_Circular.TypeName = 'classMPP_Circular';
                % app.Types.classMPP_Circular.Color = '#094F29';
                % app.Types.classMPP_Circular.Marker = 'o';
                app.Types.classMPP_Circular.HandleDrawFunction = @(obj, ax, args) draw_classMPP_Circular(app.EnvApp, obj, ax, args{:});
                app.Types.classMPP_Circular.HandleAppObject = @(app) AppSubelement(app);
                
                % Permet de créer l'objet de classe à partir de la configuration d'application
                app.Types.classMPP_Circular.HandleClassObject = @(app_config_double) ...
                classMPP_Circular(classMPP_Circular.create_config(app_config_double.PerforatedAreaSurface, ...
                app_config_double.Thickness, app_config_double.PerforationsRadius, app_config_double.RelativePorosity));
    
                % Permet de créer une configuration d'application à partir d'une configuration de classe/ configuration d'appel
                app.Types.classMPP_Circular.HandleAppConfig = @(class_config_double) ...
                feval(@(class_config_str) struct('RelativePorosity', class_config_str.RelativePorosity, ...
                'Thickness', class_config_str.Thickness, ...
                'PerforationsRadius', class_config_str.PerforationsRadius, ...
                'ThicknessCorrection', class_config_str.ThicknessCorrection, ...
                'PerforatedAreaSurface', class_config_str.PerforatedAreaSurface, ...
                'Section', class_config_str.Section), perso_struct_num2str(class_config_double)); 

                % Permet de créer une configuration de classe permettant de construire l'objet par la suite
                app.Types.classMPP_Circular.HandleClassConfig = @(app_config_str) ...
                feval(@(app_config_double) struct('RelativePorosity', app_config_double.RelativePorosity, ...
                'Thickness', app_config_double.Thickness, ...
                'PerforationsRadius', app_config_double.PerforationsRadius, ...
                'PerforatedAreaSurface', app_config_double.PerforatedAreaSurface, ...
                'Section', app_config_double.PerforatedAreaSurface * app_config_double.RelativePorosity, ...
                'ThicknessCorrection', app_config_double.ThicknessCorrection), perso_struct_str2double(app_config_str)); 

                dropdown.Items{end + 1} = 'Perforated plate with circular perforations';
                dropdown.ItemsData{end + 1} = 'classMPP_Circular';
            end

            % %% Perforated Plate (Slit)
            % if ~isfield(app.SubelementsTypes, 'SlitMPP')
            % 
            %     app.SubelementsTypes.SlitMPP.ParametersPanelStruct = add_parameters_subpanel_structure ...
            %     (app, 'classMPP_Slit', {'Porosity', 'Thickness', 'Length', 'Width'}, ...
            %     {'[0-1]', 'm', 'm', 'm'});
            % 
            %     app.SubelementsTypes.SlitMPP.TypeName = 'classMPP_Slit';
            %     app.SubelementsTypes.SlitMPP.Color = '#429B46';
            %     app.SubelementsTypes.SlitMPP.Marker = 'diamond';
            %     app.SubelementsTypes.SlitMPP.HandleClassObject = @(config) classMPP_Slit(config);
            % 
                % dropdown.Items{end + 1} = 'Perforated Plate (Slit)';
                % dropdown.ItemsData{end + 1} = 'SlitMPP';
            % 
            %     app.ItemsToTypes('Perforated Plate (Slit)') = app.SubelementsTypes.SlitMPP;
            %     app.TypesToItems('SlitMPP') = 'Perforated Plate (Slit)';
            % end
                        
            % %% Perforated Plate (Rectangular)
            % if ~isfield(app.SubelementsTypes, 'RectangularMPP')
            % 
            %     app.SubelementsTypes.RectangularMPP.ParametersPanelStruct = add_parameters_subpanel_structure ...
            %     (app, 'classMPP_Rectangular', {'Porosity', 'Thickness', 'Length', 'Width'}, ...
            %     {'[0-1]', 'm', 'm', 'm'});
            % 
            %     app.SubelementsTypes.RectangularMPP = 'RectangularMPP';
            %     app.SubelementsTypes.RectangularMPP.Color = '#94C58C'; 
            %     app.SubelementsTypes.RectangularMPP.Marker = 'diamond';
            %     app.SubelementsTypes.RectangularMPP.HandleClassObject = @(config) classMPP_Rectangular(config);
            % 
                % dropdown.Items{end + 1} = 'Perforated Plate (Rectangular)';
                % dropdown.ItemsData{end + 1} = 'RectangularMPP';
            % 
            %     app.ItemsToTypes('Perforated Plate (Rectangular)') = app.SubelementsTypes.RectangularMPP;
            %     app.TypesToItems('RectangularMPP') = 'Perforated Plate (Rectangular)';
            % end

            % %% Helmholtz Resonator (Free geometry)
            % app.SubelementsTypes.FreeHelmoltzResonator.ParametersPanelStruct = add_parameters_subpanel_structure ...
            % (app, 'FreeHelmoltzResonator', {'Neck Surface', 'Neck Length', 'Cavity Volume'}, ...
            % {'m2', 'm', 'm3'});
            %
            % app.SubelementsTypes.FreeHelmoltzResonator.Color = '#8B0001';
            % app.SubelementsClassesNames('Helmholtz Resonator (Free Geometry)') = 'FreeHelmoltzResonator';
            % app.SubelementsClassesNames('FreeHelmoltzResonator') = 'Helmholtz Resonator (Free Geometry)';

            % % Helmholtz Resonator (Cylindrical)
            % app.SubelementsTypes.CylindricalHelmholtzResonator.ParametersPanelStruct = add_parameters_subpanel_structure ...
            % (app, 'CylindricalHelmholtzResonator', 4, {'Neck Radius', 'Neck Depth', 'Cavity Radius', ...
            % 'Cavity Depth'}, {'m', 'm', 'm', 'm'});
            %
            % app.SubelementsTypes.CylindricalHelmholtzResonator.Color = '#C92020';
            % app.SubelementsClassesNames('Helmholtz Resonator (Cylindrical)') = 'CylindricalHelmholtzResonator';
            % app.SubelementsClassesNames('CylindricalHelmholtzResonator') = 'Helmholtz Resonator (Cylindrical)';
        
            % %% Resistive Screen
            % 
            % if ~isfield(app.SubelementsTypes, 'Screen')
            % 
            %     app.SubelementsTypes.Screen.ParametersPanelStruct = add_parameters_subpanel_structure ...
            %     (app, 'classscreen', {'Screen Density', 'Thickness'}, {'kg/m3', 'm'});
            % 
            %     app.SubelementsTypes.Screen.Color = '#FFA500';
            %     app.SubelementsTypes.Screen.Marker = 'diamond';
            %     app.SubelementsTypes.Screen.HandleClassObject = @(config) classscreen(config);
            % 
            %     dropdown.Items{end + 1} = 'Resistive Screen';
            %     dropdown.ItemsData{end + 1} = 'Screen';
            % 
            %     app.ItemsToTypes('Resistive Screen') = app.SubelementsTypes.Screen;
            %     app.TypesToItems('Screen') = 'Resistive Screen';
            % end

            % %% Protective Grid
            % 
            % if ~isfield(app.SubelementsTypes, 'Grid')
            % 
            %     app.SubelementsTypes.Grid.ParametersPanelSt.QWL.ruct = add_parameters_subpanel_structure ...
            %     (app, 'classgrid', {'Mesh Length', 'Mesh Width', 'Thickness', 'Porosity'}, ...
            %     {'m', 'm', 'm', '%'});
            % 
            %     app.SubelementsTypes.Grid.Color = '#6600A1';
            %     app.SubelementsTypes.Grid.Marker = 'diamond';
            %     app.SubelementsTypes.Grid.HandleClassObject = @(config) classgrid(config);
            % 
            %     dropdown.Items{end + 1} = 'Protective Grid';
            %     dropdown.ItemsData{end + 1} =  'Grid';
            % 
            %     app.ItemsToTypes('Protective Grid') = app.SubelementsTypes.Grid;
            %     app.TypesToItems('Grid') = 'Pretective Grid';
            % end
        
            % %% Quarter Wavelength Resonator
            % 
            % if ~isfield(app.SubelementsTypes, 'QWL')
            % 
            %     app.SubelementsTypes.QWL.ParametersPanelStruct = add_parameters_subpanel_structure ...
            %     (app, 'classQWL', {'Main Radius', 'Resonator Radius', 'Resonator Length'}, ...
            %     {'m', 'm', 'm'});
            % 
            % 
            %     app.SubelementsTypes.QWL.Color = '#C0428A';
            %     app.SubelementsTypes.QWL.Marker = 'diamond';
            %     app.SubelementsTypes.QWL.HandleClassObject = @(config) classQWL(config);
            % 
            %     dropdown.Items{end + 1} = 'Quarter Wavelength Resonator';
            %     dropdown.ItemsData{end + 1} = 'QWL';
            % 
            %     app.ItemsToTypes('Quarter Wavelength Resonator') = app.SubelementsTypes.QWL;
            %     app.TypesToItems('QWL') = 'Quarter Wavelength Resonator';
            % end 

            %% Quarter Wavelength Resonator (Slit)

            if ~isfield(app.Types, 'classQWL_Slit')

                app.Types.classQWL_Slit.ParametersPanelStruct = ...
                add_parameters_subpanel_structure(app,  'classQWL_Slit', ...
                {'Length', 'Width', 'Depth'}, {'m', 'm', 'm'});

                app.Types.classQWL_Slit.TypeName = 'classQWL_Slit';
                % app.Types.classQWL_Slit.Color = '#C0428A';
                % app.Types.classQWL_Slit.Marker = '_';
                app.Types.classQWL_Slit.HandleDrawFunction = @(obj, ax, args) draw_classQWL_Slit(app.EnvApp, obj, ax, args{:});
                app.Types.classQWL_Slit.HandleAppObject = @(app) AppSubelement(app);

                % Permet de créer l'objet de classe à partir de la configuration d'application
                app.Types.classQWL_Slit.HandleClassObject = @(app_config_double) ...
                classQWL_Slit(classQWL_Slit.create_config(app_config_double.Length, ...
                app_config_double.Width, app_config_double.Depth));
    
                % Permet de créer une configuration d'application à partir d'une configuration de classe/ configuration d'appel
                app.Types.classQWL_Slit.HandleAppConfig = @(class_config_double) ...
                feval(@ (class_config_str) struct('Length', class_config_str.Length, 'Width', class_config_str.Width, ...
                'Depth', class_config_str.Depth), perso_struct_num2str(class_config_double)); %#ok<*FVAL>

                % Permet de créer une configuration d'application à partir d'une configuration de classe/ configuration d'appel
                app.Types.classQWL_Slit.HandleClassConfig = @(app_config_str) ...
                feval(@ (app_config_double) struct('Length', app_config_double.Length, 'Width', app_config_double.Width, ...
                'Depth', app_config_double.Depth), perso_struct_str2double(app_config_str));
    
                dropdown.Items{end + 1} = 'Quarter Wavelength Resonator - slit';
                dropdown.ItemsData{end + 1} = 'classQWL_Slit';
            end 


            %% Quarter Wavelength Resonator (Circle)

            if ~isfield(app.Types, 'classQWL_Circle')

                app.Types.classQWL_Circle.ParametersPanelStruct = ...
                add_parameters_subpanel_structure(app,  'classQWL_Circle', ...
                {'Length', 'Radius'}, {'m', 'm'});

                app.Types.classQWL_Circle.TypeName = 'classQWL_Circle';
                % app.Types.classQWL_Circle.Color = '#C8A2C8';
                % app.Types.classQWL_Circle.Marker = '_';
                app.Types.classQWL_Circle.HandleDrawFunction = @(obj, ax, args) draw_classQWL_Circle(app.EnvApp, obj, ax, args{:});
                app.Types.classQWL_Circle.HandleAppObject = @(app) AppSubelement(app);

                % Permet de créer l'objet de classe à partir de la configuration d'application
                app.Types.classQWL_Circle.HandleClassObject = @(app_config_double) ...
                classQWL_Circle(classQWL_Circle.create_config(app_config_double.Length, ...
                app_config_double.Width));
    
                % Permet de créer une configuration d'application à partir d'une configuration de classe/ configuration d'appel
                app.Types.classQWL_Circle.HandleAppConfig = @(class_config_double) ...
                feval(@ (class_config_str) struct('Length', class_config_str.Length, 'Radius', class_config_str.Radius ...
                ), perso_struct_num2str(class_config_double)); %#ok<*FVAL>

                % Permet de créer une configuration d'application à partir d'une configuration de classe/ configuration d'appel
                app.Types.classQWL_Circle.HandleClassConfig = @(app_config_str) ...
                feval(@ (app_config_double) struct('Length', app_config_double.Length, 'Radius', app_config_double.Radius)...
                , perso_struct_str2double(app_config_str));
    
                dropdown.Items{end + 1} = 'Quarter Wavelength Resonator - circular';
                dropdown.ItemsData{end + 1} = 'classQWL_Circle';
            end 

            %% Cavity

            if ~isfield(app.Types, 'classcavity')

                app.Types.classcavity.ParametersPanelStruct = ...
                add_parameters_subpanel_structure(app, 'classcavity', ...
                {'Thickness', 'Section'}, {'m', 'm^2'});
    
                app.Types.classcavity.TypeName = 'classcavity';
                % app.Types.classcavity.Color = '#30D5C8';
                % app.Types.classcavity.Marker = '_';
                app.Types.classcavity.HandleDrawFunction = @(obj, ax, args) draw_classcavity(app.EnvApp, obj, ax, args{:});
                app.Types.classcavity.HandleAppObject = @(app) AppSubelement(app);

                app.Types.classcavity.HandleClassObject = @(app_config_double) ...
                classcavity(classcavity.create_config(app_config_double.Thickness, app_config_double.Section));

                app.Types.classcavity.HandleAppConfig = @(class_config_double) ...
                feval(@(class_config_str) struct('Thickness', class_config_str.Thickness, 'Section', class_config_str.Section), ...
                perso_struct_num2str(class_config_double));

                app.Types.classcavity.HandleClassConfig = @(app_config_str) ...
                feval(@(app_config_double) struct('Thickness', app_config_double.Thickness, 'Section', app_config_double.Section), ...
                perso_struct_str2double(app_config_str));

                dropdown.Items{end + 1} = 'Cavity';
                dropdown.ItemsData{end + 1} = 'classcavity';
            end


            %% Annular cavity cylindrical

             if ~isfield(app.Types, 'classannularcavity_cylindrical')

                app.Types.classannularcavity_cylindrical.ParametersPanelStruct = ...
                add_parameters_subpanel_structure(app, 'classannularcavity_cylindrical', ...
                {'Main pore radius', 'dead end radius', 'dead end thickness', 'Cavity Model'}, ...
                {'m', 'm', 'm', 'dropdown'}, ...
                {{}, {}, {}, {'Hankel', 'Volume'}});

                app.Types.classannularcavity_cylindrical.TypeName = 'classannularcavity_cylindrical';
                % app.Types.classannularcavity_cylindrical.Color = '#FFA500';
                % app.Types.classannularcavity_cylindrical.Marker = '_';
                app.Types.classannularcavity_cylindrical.HandleDrawFunction = @(obj, ax, args) draw_annularcavitycylindrical(app.EnvApp, obj, ax, args{:});
                app.Types.classannularcavity_cylindrical.HandleAppObject = @(app) AppSubelement(app);

                app.Types.classannularcavity_cylindrical.HandleClassObject = @(app_config_double) ...
                classannularcavity_cylindrical(classannularcavity_cylindrical.create_config(app_config_double.MainPoreRadius, app_config_double.DeadEndRadius, ...
                app_config_double.DeadEndThickness, app_config_double.CavityModel));

                app.Types.classannularcavity_cylindrical.HandleAppConfig = @(class_config_double) ...
                feval(@(class_config_str) struct('MainPoreRadius', class_config_str.MainPoreRadius, 'DeadEndRadius', class_config_str.DeadEndRadius, ...
                'DeadEndThickness', class_config_str.DeadEndThickness, 'CavityModel', class_config_str.CavityModel),  ...
                perso_struct_num2str(class_config_double));

                app.Types.classannularcavity_cylindrical.HandleClassConfig = @(app_config_str) ...
                feval(@(app_config_double) struct('MainPoreRadius', app_config_double.MainPoreRadius, 'DeadEndRadius', app_config_double.DeadEndRadius, ...
                'DeadEndThickness', app_config_double.DeadEndThickness, 'CavityModel', app_config_double.CavityModel), ...
                perso_struct_str2double(app_config_str));

                dropdown.Items{end + 1} = 'Annular cavity (cylindrical-shaped)';
                dropdown.ItemsData{end + 1} = 'classannularcavity_cylindrical';
            end 

            %% Annular cavity Cubical

            if ~isfield(app.Types, 'classannularcavity_cubical')

                app.Types.classannularcavity_cubical.ParametersPanelStruct = add_parameters_subpanel_structure ...
                (app, 'classannularcavity_cubical', {'Main pore width', 'Main pore depth', ...
                'Cavity Width', 'Cavity Depth', 'Cavity Thickness'}, {'m', 'm', 'm', 'm', 'm'});

                app.Types.classannularcavity_cubical.TypeName = 'classannularcavity_cubical';
                % app.Types.classannularcavity_cubical.Color = '#A3F25C';
                % app.Types.classannularcavity_cubical.Marker = '_';
                app.Types.classannularcavity_cubical.HandleDrawFunction = @(obj, ax, args) draw_classannularcavitycubical(app.EnvApp, obj, ax, args{:});
                app.Types.classannularcavity_cubical.HandleAppObject = @(app) AppSubelement(app);

                app.Types.classannularcavity_cubical.HandleClassObject = @(app_config_double) ...
                classannularcavity_cubical(classannularcavity_cubical.create_config(app_config_double.MainPoreWidth, app_config_double.MainPoreDepth, ...
                app_config_double.CavityWidth, app_config_double.CavityDepth, app_config_double.CavityThickness));

                app.Types.classannularcavity_cubical.HandleAppConfig = @(class_config_double) ...
                feval(@(class_config_str) struct('MainPoreWidth', class_config_str.MainPoreWidth, 'MainPoreDepth', class_config_str.MainPoreDepth, ...
                'CavityWidth', class_config_str.CavityWidth, 'CavityDepth', class_config_str.CavityDepth, 'CavityThickness', class_config_str.CavityThickness),  ...
                perso_struct_num2str(class_config_double));

                app.Types.classannularcavity_cubical.HandleClassConfig = @(app_config_str) ...
                feval(@(app_config_double) struct('MainPoreWidth', app_config_double.MainPoreWidth, 'MainPoreDepth', app_config_double.MainPoreDepth, ...
                'CavityWidth', app_config_double.CavityWidth, 'CavityDepth', app_config_double.CavityDepth, 'CavityThickness', app_config_double.CavityThickness), ...
                perso_struct_str2double(app_config_str));
                
                dropdown.Items{end + 1} = 'Annular cavity (cubic-shaped)';
                dropdown.ItemsData{end + 1} = 'classannularcavity_cubical';
            end 

            %% Annular cavity Trapezoidal

            if ~isfield(app.Types, 'classannularcavity_trapezoidal')

                app.Types.classannularcavity_trapezoidal.ParametersPanelStruct = add_parameters_subpanel_structure ...
                (app, 'classannularcavity_trapezoidal', {'Main Pore Width In', 'Main Pore Width Out', ...
                'Cavity Width', 'Cavity Depth', 'Cavity Thickness'}, {'m', 'm', 'm', 'm', 'm'});

                app.Types.classannularcavity_trapezoidal.TypeName = 'classannularcavity_rectangular';
                % app.Types.classannularcavity_trapezoidal.Color = '#7B3FE1';
                % app.Types.classannularcavity_trapezoidal.Marker = '_';
                app.Types.classannularcavity_trapezoidal.HandleDrawFunction = @(obj, ax, args) draw_classannularcavitytrapezoidal(app.EnvApp, obj, ax, args{:});
                app.Types.classannularcavity_trapezoidal.HandleAppObject = @(app) AppSubelement(app);

                app.Types.classannularcavity_trapezoidal.HandleClassObject = @(app_config_double) ...
                classannularcavity_trapezoidal(classannularcavity_trapezoidal.create_config(app_config_double.MainPoreWidthIn, app_config_double.MainPoreWidthOut, ...
                app_config_double.CavityWidth, app_config_double.CavityDepth, app_config_double.CavityThickness));

                app.Types.classannularcavity_trapezoidal.HandleAppConfig = @(class_config_double) ...
                feval(@(class_config_str) struct('MainPoreWidthIn', class_config_str.MainPoreWidthIn, 'MainPoreWidthOut', class_config_str.MainPoreWidthOut, ...
                'CavityWidth', class_config_str.CavityWidth, 'CavityDepth', class_config_str.CavityDepth, 'CavityThickness', class_config_str.CavityThickness),  ...
                perso_struct_num2str(class_config_double));

                app.Types.classannularcavity_trapezoidal.HandleClassConfig = @(app_config_str) ...
                feval(@(app_config_double) struct('MainPoreWidthIn', app_config_double.MainPoreWidthIn, 'MainPoreWidthOut', app_config_double.MainPoreWidthOut, ...
                'CavityWidth', app_config_double.CavityWidth, 'CavityDepth', app_config_double.CavityDepth, 'CavityThickness', app_config_double.CavityThickness), ...
                perso_struct_str2double(app_config_str));
                
                dropdown.Items{end + 1} = 'Annular cavity (trapezoic-shaped)';
                dropdown.ItemsData{end + 1} = 'classannularcavity_trapezoidal';
            end 
        end