classdef classMPP_Circular_HL_flow < classMPP_Circular_HL

% Description
% Ce constructeur de classe permet de créer une plaque microperforée à perforations circulaires
% Il se base sur le modèle de fluide équivalent (JCA) développé dans 'classJCA_Rigid'
% En plus de cela, on intègre la résistivité et la tortuosité modifiée développée par Laly dans [5]

% References
%            [5] Zacharie Laly, Acoustical modeling of micro-perforated panel at high 
%                sound pressure levels using equivalent fluid approach
%                https://linkinghub.elsevier.com/retrieve/pii/S0022460X17306740
%
%            [6] Zacharie Laly, Développement, validation expérimentale et optimisation 
%                des traitements acoustiques des nacelles de turboréacteurs sous hauts 
%                niveaux acoustiques
    methods

        function obj = classMPP_Circular_HL_flow(config)
            
            obj@classMPP_Circular_HL(config)

            phi = config.Porosity;
            pr = config.PerforationsRadius;
            t = config.Thickness;        
            beta = config.Beta;

            obj.Configuration.AirFlowResistivity = @(env) classMPP_Circular_HL_flow.air_flow_resistivity(env, phi, pr, t, beta);

            obj.Configuration.Toruosity = @(env) classMPP_Circular_HL_flow.tortuosity(env, phi, pr, t);
            % obj.Configuration.Toruosity = @(env) classMPP_Circular_HL.tortuosity(env, phi, pr, t);
        end
    end

     methods (Static, Access = public)

         function sig = air_flow_resistivity(env, phi, pr, t, varargin)


            if nargin > 4
                beta = varargin{1};
            else
                beta = 1.6; % [5] p.8 % Validation laly sans écoulement
                % beta = 1.2; Validation Laly avec écoulement
            end

            Cd = 0.76; % [5] p.8
            q = 0.3; % voir modèle Laly écoulement

            % Résistivité au passage de l'air ([5], p. 7, eq. 27)
            sig = 8 * env.air.parameters.eta / (phi * pr^2) ...
                + beta * env.air.parameters.Z0 / (pi * t * Cd^2) ...
                * (-1/2 + classMPP_Circular_HL.f(env, phi)) ... % forts niveaux
                + env.air.parameters.Z0 * (1 - phi^2) / (phi * t) * q * env.M; % écoulement
         end

         function tor = tortuosity(env, phi, pr, t)
             
            psi = 4/3; 
            a = [1.0 -1.4092 0.0 0.33818 0.0 0.06793 -0.02287 0.003015 -0.01614];
            sum_a = dot(a, sqrt(phi).^(0:length(a)-1));

            % Tortuosité non linéaire ([5], p. 7, eq. 28)
            tor = 1 + 2 * psi / (1 + 305 * env.M^3) * 0.48 * sqrt(pi * pr^2) / t * sum_a ...
                * (1 + 1 / (1 - phi^2) ...
                * (-1/2 + classMPP_Circular_HL.f(env, phi)))^(-1);
         end 
     end
end