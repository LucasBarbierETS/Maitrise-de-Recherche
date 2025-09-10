classdef classQWL_Square < classQWL

    % References:
    % [1] Stinson & Champoux, Propagation of sound and the assignment of
    %     shape factors in model porous materials having simple pore geometries
    %     http://asa.scitation.org/doi/10.1121/1.402530

    properties

    % Configuration
    
    end
   
    methods
        function obj = classQWL_Square(config)

            obj@classQWL(config)
        end

        function output_model = set_COMSOL_2D_Model(obj, input_model, index, env, varargin)
            output_model = ModelQWL_Slit(obj.Configuration, input_model, index, env, varargin{:});
        end
    end
    
    methods (Static, Access = public)

        function config = create_config(length, side)
        
            config = struct();
            config.Length = length;
            [config.Width, config.Depth] = deal(side);
            config.Section = side^2;
            config.Surface = side^2;
            config.PermeabilityCoefficient = 1.78; % [1] p. 8
            config.HydraulicRadius = side; % [1] p. 8
        end
    end
end