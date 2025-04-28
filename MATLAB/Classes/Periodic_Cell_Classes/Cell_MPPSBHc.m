classdef Cell_MPPSBHc < classelement
    
    % Cette classe constitue une cellule périodique comprenant : 
    %   - une plaque microperforée (classMPP_Maa)
    %   - une cavité cylindrique
    %   - une cavité toroidale en parallèle 
    
    methods
        function obj = Cell_MPPSBHc(config)
            
            % Appel du constructeur de la classe parente
            obj@classelement(classelement.create_config({}, 'opened'));

            % On transfert les champs de la structure d'appel vers ceux de
            % a structure de classe
            obj.Configuration = perso_transfer_fields(config, obj.Configuration);

            % Paramètres de la plaque
            pp = config.PlatePorosity;
            phr = config.PlateHolesRadius;
            pt = config.PlateThickness;
            
            % Paramètres de la cellule
            ct = config.CavityThickness;
            cr = config.CavityRadius;
            cir = config.CellInnerRadius;
            cor = config.CellOuterRadius;
            pmr = (cir + cor)/2; % pore mean radius
            SMPP = pi*cir^2;
            Scav = pi*pmr^2;

            % Référence : perso_ouvrir_lien_Zotero('zotero://open-pdf/library/items/AH7QFLYS?page=4&annotation=64Y6HACJ')

            % Plaque perforée
            obj.Configuration.ListOfSubelements{end+1} = classMPP_Maa(classMPP_Maa.create_config(pp, phr, pt, SMPP));

            % Cavité cylindrique
            obj.Configuration.ListOfSubelements{end+1} = classcavity(classcavity.create_config(ct, Scav));

            % Cavité annulaire en parallèle
            ac = classannularcavity(classannularcavity.create_config(pmr, cr, ct, 'Volume'));
            obj.Configuration.ListOfSubelements{end+1} = classjunction(classjunction.create_config(Scav, ac));
        end
    end

    methods (Static)

        function config = create_config(plate_porosity, plate_holes_radius, plate_thickness, ...
                cavity_thickness, cavity_radius, cell_inner_radius, cell_outer_radius)

            config = struct();

            % Paramètres de la plaque
            config.PlatePorosity = plate_porosity;
            config.PlateHolesRadius = plate_holes_radius;
            config.PlateThickness = plate_thickness;

            % Paramètres de la cellule
            config.CavityThickness = cavity_thickness;
            config.CavityRadius = cavity_radius;
            config.CellInnerRadius = cell_inner_radius;
            config.CellOuterRadius = cell_outer_radius;
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

