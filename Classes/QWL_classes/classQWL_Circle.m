classdef classQWL_Circle < classQWL

    % References:
    % [1] Stinson & Champoux, Propagation of sound and the assignment of
    %     shape factors in model porous materials having simple pore geometries
    %     http://asa.scitation.org/doi/10.1121/1.402530

    methods
        
        function obj = classQWL_Circle(config)

            obj@classQWL(config)
        end
    end
    
    methods (Static, Access = public)

        function config = create_config(length, radius, varargin)
        
            config = struct();
            config.Length = length;
            config.Radius = radius;
            config.Section = pi*radius^2;
            config.Surface = pi*radius^2;
            config.PermeabilityCoefficient = 2; % [1] p. 8
            config.HydraulicRadius = radius; % [1] p. 8

            if nargin > 2
                config.CorrectionLength = varargin{1};
            end
        end
    end
end