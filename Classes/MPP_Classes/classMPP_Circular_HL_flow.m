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

            try
                beta = config.Beta;
                obj.Configuration.AirFlowResistivity = @(env) classMPP_Circular_HL_flow.air_flow_resistivity(env, phi, pr, t, beta);
            catch
                obj.Configuration.AirFlowResistivity = @(env) classMPP_Circular_HL_flow.air_flow_resistivity(env, phi, pr, t);
            end

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
     
         function validate(handle_env)

            %% Validation avec écoulement (Thèse Laly)

            perso_figure('Validation avec écoulement (Thèse Laly)');

            subplot(1, 2, 1)
            % title('Fig 5.1, M = 0.1 (V = 34 m/s)')
            title('M = 0.1 (V = 34 m/s)')
            hold on 

            data5_1 = load('Thèse_Laly_fig5.1_black.txt');

            SPL = 110;
            M = 0.1;
            env = handle_env(SPL, M);
    
            t = 1e-3;
            r = 0.3e-3;
            phi = 0.038;
            D = 20e-3;
            S = 1; % Surface arbitraire
            beta = 1.2; % Pas un gros impact

            plate_HL = classMPP_Circular_HL(classMPP_Circular_HL.create_config(S, t, r, phi, [], [], beta)); 
            plate_HL_flow = classMPP_Circular_HL_flow(classMPP_Circular_HL_flow.create_config(S, t, r, phi, [], [], beta));
            cavity = classcavity(classcavity.create_config(S, D));
            E_HL = classelement(classelement.create_config({plate_HL, cavity}, 'closed', S));
            E_HL_flow = classelement(classelement.create_config({plate_HL_flow, cavity}, 'closed', S));
    
            % Modèle non linéaire itératif
            plot(env.w/(2*pi), E_HL.alpha(env, 'iter'), 'DisplayName', 'Modèle HL itératif sans écoulement');
            plot(env.w/(2*pi), E_HL_flow.alpha(env, 'iter'), 'DisplayName', 'Modèle HL itératif avec écoulement');
            plot(data5_1(:, 1), data5_1(:, 2), 'DisplayName', 'Données de référence');
            perso_configure_alpha_figure(5000);
   
            %%%

            subplot(1, 2, 2)
            % title('Fig 5.2, M = 0.15')
            title('M = 0.15 (V = 51 m/s)')
            hold on 

            data5_2 = load('Thèse_Laly_fig5.2_black.txt');

            SPL = 120; % Pression incidente
            M = 0.15;
            env = handle_env(SPL, M);
    
            t = 1e-3;
            r = 0.5e-3;
            phi = 0.047;
            D = 40e-3;

            plate_HL = classMPP_Circular_HL(classMPP_Circular_HL.create_config(S, t, r, phi, [], [], beta)); 
            plate_HL_flow = classMPP_Circular_HL_flow(classMPP_Circular_HL_flow.create_config(S, t, r, phi, [], [], beta));
            cavity = classcavity(classcavity.create_config(S, D));
            E_HL = classelement(classelement.create_config({plate_HL, cavity}, 'closed', S));
            E_HL_flow = classelement(classelement.create_config({plate_HL_flow, cavity}, 'closed', S));
    
            % Modèle non linéaire itératif
            plot(env.w/(2*pi), E_HL.alpha(env, 'iter'), 'DisplayName', 'Modèle non-linéaire sans écoulement');
            plot(env.w/(2*pi), E_HL_flow.alpha(env, 'iter'), 'DisplayName', 'Modèle non-linéaire avec écoulement');
            plot(data5_2(:, 1), data5_2(:, 2), 'DisplayName', 'Données de référence');
            perso_configure_alpha_figure(4000);
    
            %%%

            % subplot(2, 2, 3)
            % title('Fig 5.4, M = 0.3')
            % hold on 
            % 
            % data5_4 = load('Thèse_Laly_fig5.4_black.txt');
            % 
            % SPL = 140; % % Pression incidente
            % M = 0.3;
            % env = handle_env(SPL, M);
            % 
            % t = 0.8e-3;
            % r = 0.6e-3;
            % phi = 0.06;
            % D = 30e-3;
            % 
            % plate_HL = classMPP_Circular_HL(classMPP_Circular_HL.create_config(S, t, r, phi, [], [], beta)); 
            % plate_HL_flow = classMPP_Circular_HL_flow(classMPP_Circular_HL_flow.create_config(S, t, r, phi, [], [], beta));
            % cavity = classcavity(classcavity.create_config(S, D));
            % E_HL = classelement(classelement.create_config({plate_HL, cavity}, 'closed', S));
            % E_HL_flow = classelement(classelement.create_config({plate_HL_flow, cavity}, 'closed', S));
            % 
            % % Modèle non linéaire itératif
            % plot(env.w/(2*pi), E_HL.alpha(env), 'DisplayName', 'Modèle non-linéaire sans écoulement');
            % plot(env.w/(2*pi), E_HL_flow.alpha(env), 'DisplayName', 'Modèle non-linéaire avec écoulement');
            % plot(data5_4(:, 1), data5_4(:, 2), 'DisplayName', 'Données de référence');
            % perso_configure_alpha_figure(5000);
            % 
            % %%%
            % 
            % subplot(2, 2, 4)
            % title('Fig 5.5, M = 0.2')
            % hold on 
            % 
            % data5_5 = load('Thèse_Laly_fig5.5_black.txt');
            % 
            % SPL = 145; % % Pression incidente
            % M = 0.2;
            % env = handle_env(SPL, M);
            % 
            % 
            % t = 1.5e-3;
            % r = 0.75e-3;
            % phi = 0.056;
            % D = 28e-3;
            % 
            % plate_HL = classMPP_Circular_HL(classMPP_Circular_HL.create_config(S, t, r, phi, [], [], beta)); 
            % plate_HL_flow = classMPP_Circular_HL_flow(classMPP_Circular_HL_flow.create_config(S, t, r, phi, [], [], beta));
            % cavity = classcavity(classcavity.create_config(S, D));
            % E_HL = classelement(classelement.create_config({plate_HL, cavity}, 'closed', S));
            % E_HL_flow = classelement(classelement.create_config({plate_HL_flow, cavity}, 'closed', S));
            % 
            % % Modèle non linéaire itératif
            % plot(env.w/(2*pi), E_HL.alpha(env), 'DisplayName', 'Modèle non-linéaire sans écoulement');
            % plot(env.w/(2*pi), E_HL_flow.alpha(env), 'DisplayName', 'Modèle non-linéaire avec écoulement');
            % plot(data5_5(:, 1), data5_5(:, 2), 'DisplayName', 'Données de référence');
            % perso_configure_alpha_figure(5000);

         end
     end
end