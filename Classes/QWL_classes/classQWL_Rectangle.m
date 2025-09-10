classdef classQWL_Rectangle < classQWL

    % References:

    % [1] Stinson & Champoux, Propagation of sound and the assignment of
    %     shape factors in model porous materials having simple pore geometries
    %     http://asa.scitation.org/doi/10.1121/1.402530

    properties

    % Configuration
    
    end
   
    methods
        function obj = classQWL_Rectangle(config)

            obj@classQWL(config)
        end

        function output_model = set_COMSOL_2D_Model(obj, input_model, index, env, varargin)
            output_model = ModelQWL_Slit(obj.Configuration, input_model, index, env, varargin{:});
        end
    end
    
    methods (Static, Access = public)

        function config = create_config(length, width, depth)
        
            config = struct();
            config.Length = length;
            [config.Width, w] = deal(width);
            [config.Depth, d] = deal(depth);
            config.Section = w * d;
            config.Surface = w * d;
            config.PermeabilityCoefficient = 1.78; % [1] p. 8
            config.HydraulicRadius = 2 * w*d / (w + d); % [1] p. 8
        end
    end
end