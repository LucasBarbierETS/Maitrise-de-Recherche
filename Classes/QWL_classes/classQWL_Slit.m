classdef classQWL_Slit < classQWL

    % References:

    % [1] Stinson & Champoux, Propagation of sound and the assignment of
    %     shape factors in model porous materials having simple pore geometries
    %     http://asa.scitation.org/doi/10.1121/1.402530
    % [2] Modeling of perforated plates and screens using rigid frame porous models
    %     Noureddine Atallaa, Franck Sgard
    %     doi:10.1016/j.jsv.2007.01.012

    properties

    % Configuration
    
    end
   
    methods
        function obj = classQWL_Slit(config)

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
            config.PermeabilityCoefficient = 3; % [1] p. 8
            config.HydraulicRadius = width; % [1] p. 8
        end
    end
end