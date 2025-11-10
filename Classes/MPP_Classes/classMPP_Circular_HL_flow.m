classdef classMPP_Circular_HL_flow < classMPP_Circular_HL

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

            obj.Configuration.AirFlowResistivity = @(env) classMPP_Circular_HL.air_flow_resistivity(env, config, 'M', env.M);

            obj.Configuration.Tortuosity = @(env) classMPP_Circular_HL.tortuosity(env, config, 'M', env.M);
        end
    end
     
     methods (Static, Access = public)
         function validate(handle_env)

            %% Validation avec écoulement (Thèse Laly)

            perso_figure('Validation avec écoulement (Thèse Laly)');

            % subplot(1, 2, 1)
            % title('Fig 5.1, M = 0.1 (V = 34 m/s)')
            title('MPP + cavité 3, SPL = 110 dB, M = 0.1 (V = 34 m/s)')
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
            plot(env.w/(2*pi), E_HL.absorption_coefficient(env, 'iter'), 'DisplayName', 'Prédiction du code HL sans écoulement');
            plot(env.w/(2*pi), E_HL_flow.absorption_coefficient(env, 'iter'), 'DisplayName', 'Prédiction du code HL avec écoulement');
            plot(data5_1(:, 1), data5_1(:, 2), 'DisplayName', 'Prédiction du modèle de référence');
            perso_configure_alpha_figure(5000);
   
            %%%

            subplot(1, 2, 2)
            % title('Fig 5.2, M = 0.15')
            title('MPP + cavité 4, SPL = 120 dB, M = 0.15 (V = 51 m/s)')
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
            plot(env.w/(2*pi), E_HL.absorption_coefficient(env, 'iter'), 'DisplayName', 'Prédiction du code HL sans écoulement');
            plot(env.w/(2*pi), E_HL_flow.absorption_coefficient(env, 'iter'), 'DisplayName', 'Prédiction du code HL avec écoulement');
            plot(data5_2(:, 1), data5_2(:, 2), 'DisplayName', 'Prédiction du modèle de référence');
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
            % plot(env.w/(2*pi), E_HL.absorption_coefficient(env), 'DisplayName', 'Modèle non-linéaire sans écoulement');
            % plot(env.w/(2*pi), E_HL_flow.absorption_coefficient(env), 'DisplayName', 'Modèle non-linéaire avec écoulement');
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
            % plot(env.w/(2*pi), E_HL.absorption_coefficient(env), 'DisplayName', 'Modèle non-linéaire sans écoulement');
            % plot(env.w/(2*pi), E_HL_flow.absorption_coefficient(env), 'DisplayName', 'Modèle non-linéaire avec écoulement');
            % plot(data5_5(:, 1), data5_5(:, 2), 'DisplayName', 'Données de référence');
            % perso_configure_alpha_figure(5000);

         end
     end
end