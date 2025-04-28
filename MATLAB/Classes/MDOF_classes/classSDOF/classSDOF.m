classdef classSDOF < classelement
    
    methods
        function obj = classSDOF(config)

            obj@classelement(classelement.create_config({}, 'opened'));
            obj.Configuration = perso_transfer_fields(config, obj.Configuration);

            % Paramètres de la plaque
            pp = config.PlatePorosity;
            phr = config.PlateHolesRadius;
            pt = config.PlateThickness;
            
            % Paramètres de la cavité
            ct = config.CavityThickness;
            cd = config.CavityDepth;
            cw = config.CavityWidth;

            % On choisit le modèle linéaire ou non
            if strcmp(config.HighLevel, 'false')
                obj.Configuration.ListOfSubelements{end+1} = classMPP_Circular( ...
                    classMPP_Circular.create_config(pp, phr, pt, cd*cw));
            elseif strcmp(config.HighLevel, 'true')
                obj.Configuration.ListOfSubelements{end+1} = classMPP_Circular_HL( ...
                    classMPP_Circular_HL.create_config(pp, phr, pt, cd*cw));
            end

            obj.Configuration.ListOfSubelements{end+1} = classcavity(classcavity.create_config(ct, cd*cw));
        end
    
        function output_model = set_COMSOL_2D_Model(obj, input_model, index, env)
            output_model = ModelSDOF(obj.Configuration, input_model, index, env);
        end
    end

    methods (Static)

        function config = create_config(plate_porosity, plate_holes_radius, plate_thickness, ...
            cavity_thickness, cavity_depth, cavity_width, high_level)

            config = struct();
            config.InputSection = cavity_depth*cavity_width;

            % Paramètres de la plaque
            config.PlatePorosity = plate_porosity;
            config.PlateHolesRadius = plate_holes_radius;
            config.PlateThickness = plate_thickness;

            % Paramètres de la cavité
            config.CavityThickness = cavity_thickness;
            config.CavityDepth = cavity_depth;
            config.CavityWidth = cavity_width;
            config.HighLevel = high_level;
        end
    end
end

