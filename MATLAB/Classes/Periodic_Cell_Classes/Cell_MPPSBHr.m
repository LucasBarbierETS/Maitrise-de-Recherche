classdef Cell_MPPSBHr < classelement
    
    % Cette classe constitue une cellule périodique comprenant : 
    %   - une plaque microperforée (classMPP_Circular)
    %   - une cellule comprenant le pore principale et une cavité bilatérale (CellBilateralCavity)
    
    methods
        function obj = Cell_MPPSBHr(config)
            
            % Appel du constructeur de la classe parente
            obj@classelement(classelement.create_config({}, 'opened'));

            % On transfert les champs de la structure d'appel vers ceux de
            % a structure de classe
            obj.Configuration = perso_transfer_fields(config, obj.Configuration);

            % Paramètres de la plaque
            p = config.Porosity;
            phr = config.PlateHolesRadius;
            t = config.Thickness;
            
            % Paramètres de la cellule
            ct = config.CavityThickness;
            cd = config.CavityDepth;
            cw = config.CavityWidth;

            ciw = config.CellInnerWidth;
            cow = config.CellOuterWidth;
            pmw = (ciw + cow)/2; % pore mean width

            cid = config.CellInnerDepth;
            cod = config.CellOuterDepth;
            pmd = (cid + cod)/2; % pore mean depth

            cm = config.CavityMethod;

            % Plaque perforée (Modèle de Maa)
            obj.Configuration.ListOfSubelements{end+1} = classMPP_Circular(classMPP_Circular.create_config(p, phr, t, ciw, cid));

            % Cavité cylindrique
            obj.Configuration.ListOfSubelements{end+1} = classcavity(classcavity.create_config(ct/2, ciw, cid));

            if strcmp(cm, 'volume')
                % Cavité cubique en parallèle
                cc = classcubicalcavity(classcubicalcavity.create_config(pmw, pmd, cw, cd, ct));
                obj.Configuration.ListOfSubelements{end+1} = classjunction(classjunction.create_config(cc, pmw, pmd));
            end

            % Cavité cylindrique
            obj.Configuration.ListOfSubelements{end+1} = classcavity(classcavity.create_config(ct/2, pmw, pmd));
        end
    end

    methods (Static)

        function config = create_config(porosity, plate_holes_radius, thickness, ...
                cavity_thickness, cavity_depth, cavity_width, cell_inner_width, cell_outer_width, ...
                cell_inner_depth, cell_outer_depth, cavity_method)

            config = struct();

            % Paramètres de la plaque
            config.Porosity = porosity;
            config.PlateHolesRadius = plate_holes_radius;
            config.Thickness = thickness;

            % Paramètres de la cellule
            config.CavityThickness = cavity_thickness;
            config.CavityDepth = cavity_depth;
            config.CavityWidth = cavity_width;
            config.CellInnerWidth = cell_inner_width;
            config.CellOuterWidth = cell_outer_width;
            config.Section = cell_inner_width * cell_inner_depth;
            % config.Section = cavity_width * cavity_depth;
            config.CellInnerDepth = cell_inner_depth;
            config.CellOuterDepth = cell_outer_depth;
            config.CavityMethod = cavity_method;
        end

        function type = type(app)
            type = struct();
            type.TypeName = 'CellMPP';
            type.Color = '#7D3F8C';
            type.Marker = 'o';

            type.HandleAppObject = @(app) AppSubelement(app);
            
            type.HandleClassObject = @(app_config_double) ...
                classMPP_Circular(classMPP_Circular.create_config(app_config_double.PlatePorosity, ...
                app_config_double.PerforationsRadius, app_config_double.PlateThickness, ...
                app_config_double.PlateSection, app_config_double.ThicknessCorrection));
            
            type.HandleAppConfig = @(class_config_double) ...
                feval(@ (class_config_str) struct('PlatePorosity', class_config_str.PlatePorosity, ...
                'PlateThickness', class_config_str.PlateThickness, ...
                'PerforationsRadius', class_config_str.PerforationsRadius, ...
                'PlateSection', class_config_str.PlateSection, ...
                'ThicknessCorrection', class_config_str.ThicknessCorrection, ...
                'InputSection', class_config_str.InputSection), perso_struct_num2str(class_config_double)); 

            type.HandleClassConfig = @(app_config_str) ...
                feval(@ (app_config_double) struct('PlatePorosity', app_config_double.PlatePorosity, ...
                'PlateThickness', app_config_double.PlateThickness, ...
                'PerforationsRadius', app_config_double.PerforationsRadius, ...
                'PlateSection', app_config_double.PlateSection, ...
                'ThicknessCorrection', app_config_double.ThicknessCorrection, ...
                'InputSection', app_config_double.InputSection), perso_struct_str2double(app_config_str)); 
        end 
    end
end

