classdef classMPP_Circular_HL_iter < classMPP_Circular_HL

% References
%            [5] Zacharie Laly, Acoustical modeling of micro-perforated panel at high 
%                sound pressure levels using equivalent fluid approach
%                https://linkinghub.elsevier.com/retrieve/pii/S0022460X17306740
%
%            [6] Zacharie Laly, Développement, validation expérimentale et optimisation 
%                des traitements acoustiques des nacelles de turboréacteurs sous hauts 
%                niveaux acoustiques
         
%% Constructeur de classe

    methods

        function obj = classMPP_Circular_HL_iter(config, varargin)
            
            obj@classMPP_Circular_HL(config)

            s = config.Section;
            % s = config.Surface;
            
            obj.Configuration.AirFlowResistivity = @(env, u_rms) classMPP_Circular_HL.air_flow_resistivity(env, config, "v_rms", u_rms/s);

            obj.Configuration.Tortuosity = @(env, u_rms) classMPP_Circular_HL.tortuosity(env, config, "v_rms", u_rms/s);
        end

        function TM = transfer_matrix(obj, env, u_in)

            obj.Configuration.AirFlowResistivity = @(henv) obj.Configuration.AirFlowResistivity(henv, u_in);
            obj.Configuration.Tortuosity = @(henv) obj.Configuration.Tortuosity(henv, u_in);
            TM = transfer_matrix@classMPP_Circular(obj, env);
        end
    end   
end