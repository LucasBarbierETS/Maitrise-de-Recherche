classdef classcavity_rectangular < classcavity
 
    methods 

        function obj = classcavity_rectangular(config) 
            
            obj@classcavity(config);
        end
    
        function output_model = set_COMSOL_2D_Model(obj, input_model, elem_index, sblm_index, env)
            output_model = ModelCavity(obj.Configuration, input_model, elem_index, sblm_index, env);
        end
    end

    methods (Static, Access = public)
    
        function config = create_config(thickness, width, depth)

            config = struct();
            config.Thickness = thickness;
            [config.Width, w] = deal(width);
            [config.Depth, d] = deal(depth);
            [config.Section, config.Surface] = deal(w*d);
        end
    end
end