classdef classNiloofar

    properties
        Configuration
    end
    methods
        function obj = classNiloofar(config)
            obj.Configuration = config;
            obj.Configuration.EndStatus = 'closed';
        end
        
        function output_model = set_COMSOL_2D_Model(obj, input_model, index, env)
            output_model = ModelNiloofar(obj.Configuration, input_model, index, env);
        end
    end
    methods (Static)
        function config = create_config(solution_length, cavities_width, plates_thickness, increment, ...
                first_layer_thickness, left_cavities_thickness, right_cavities_thickness, first_left_plate_length, ...
                first_right_plate_length, number_of_left_plates, input_section)
            
            config = struct();
            config.SolutionLength = solution_length;
            config.CavitiesWidth = cavities_width;
            config.PlatesThickness = plates_thickness;
            config.Increment = increment;
            config.FirstLayerThickness = first_layer_thickness;
            config.LeftCavitiesThickness = left_cavities_thickness;
            config.RightCavitiesThickness = right_cavities_thickness;
            config.FirstLeftPlateLength = first_left_plate_length;
            config.FirstRightPlateLength = first_right_plate_length;
            config.NumberOfLeftPlates = number_of_left_plates;
            config.InputSection = input_section;
        end
    end
end

