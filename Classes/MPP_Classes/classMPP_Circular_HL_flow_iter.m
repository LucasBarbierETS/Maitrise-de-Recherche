classdef classMPP_Circular_HL_flow_iter < classMPP_Circular_HL_iter
         
%% Constructeur de classe

    methods

        function obj = classMPP_Circular_HL_flow_iter(config, varargin)
            
            obj@classMPP_Circular_HL_iter(config)

            s = config.Section;
            % s = config.Surface;
            
            obj.Configuration.AirFlowResistivity = @(env, u_rms) classMPP_Circular_HL.air_flow_resistivity(env, config, "v_rms", u_rms/s, 'M', env.M);

            obj.Configuration.Tortuosity = @(env, u_rms) classMPP_Circular_HL.tortuosity(env, config, "v_rms", u_rms/s, 'M', env.M);
        end
    end
end