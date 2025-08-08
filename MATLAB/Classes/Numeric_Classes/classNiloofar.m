classdef classNiloofar

    properties
        Configuration
    end
    methods
        function obj = classNiloofar(config)
            obj.Configuration = config;
            obj.Configuration.EndStatus = 'closed';
        end
        
        function s = input_section(obj) 
            config = obj.Configuration;
            s = config.Width * config.Depth;
        end
            
        function output_model = set_COMSOL_2D_Model(obj, input_model, index, env, varargin)
            output_model = ModelNiloofar(obj.Configuration, input_model, index, env, varargin{:});
        end
    end

    methods (Static)

        function config = create_config(solution_length, width, depth, plates_thickness, increment, ...
                first_layer_thickness, left_cavities_thickness, right_cavities_thickness, first_left_plate_length, ...
                first_right_plate_length, number_of_left_plates)
            
            config = struct();
            config.SolutionLength = solution_length;
            [config.Width, w] = deal(width);
            [config.Depth, d] = deal(depth);
            config.Section = w * d;
            config.PlatesThickness = plates_thickness;
            config.Increment = increment;
            config.FirstLayerThickness = first_layer_thickness;
            config.LeftCavitiesThickness = left_cavities_thickness;
            config.RightCavitiesThickness = right_cavities_thickness;
            config.FirstLeftPlateLength = first_left_plate_length;
            config.FirstRightPlateLength = first_right_plate_length;
            config.NumberOfLeftPlates = number_of_left_plates;
        end
    end
end

