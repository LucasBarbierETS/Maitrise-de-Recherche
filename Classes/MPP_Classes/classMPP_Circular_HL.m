classdef classMPP_Circular_HL < classMPP_Circular

% References : 
%            [5] Zacharie Laly, Acoustical modeling of micro-perforated panel at high 
%                sound pressure levels using equivalent fluid approach
%                https://linkinghub.elsevier.com/retrieve/pii/S0022460X17306740
%
%            [6] Zacharie Laly, Développement, validation expérimentale et optimisation 
%                des traitements acoustiques des nacelles de turboréacteurs sous hauts 
%                niveaux acoustiques
         
    methods

        function obj = classMPP_Circular_HL(config)
            
            obj@classMPP_Circular(config)
         
            obj.Configuration.AirFlowResistivity = @(env) classMPP_Circular_HL.air_flow_resistivity(env, config);

            obj.Configuration.Tortuosity = @(env) classMPP_Circular_HL.tortuosity(env, config);
        end
    end

     methods (Static, Access = public)

        function config = create_config(surface, thickness, perforations_radius, porosity, varargin)
            
            % Cette méthode permet de créer une configuration d'appel spéciale dans le cas ou les perforations de la MPP sont cylindriques
            
            config = struct();
            config.Surface = surface;
            config.Thickness = thickness;
            config.PerforationsRadius = perforations_radius;
            config.Porosity = porosity;
            config.Section = surface * porosity;

            if nargin > 4
                config.Width = varargin{1};
                config.Depth = varargin{2};
            end

            if nargin > 5
                config.Beta = varargin{3};
            end
         end
        
        function f = f(env, phi)

            % Fonction intermédiaire ([5] eq. 27, eq. 28)
            % Cette fonction provient d'une formulation de la résistivité au passage de l'air qui fait référence explicitement au
            % niveau de pression. L'article de référence indique que cette expression est obtenue en utilisant une analogie de circuit
            % équivalent en appliquant l'équation de conservation de la quantité de mouvement sous la forme de la loi de Bernouilli
            % appliquée à un écoulement laminaire et incompressible

            
            f = sqrt(1/4 + 2*sqrt(2) * env.pi_rms ...
                / (env.air.parameters.rho * env.air.parameters.c0^2) ...
                * (1 - phi^2) / phi^2);

            % % Debog
            % perso_figure('Debog - classMPP_Circular_HL - f - env.pi_rms')
            % plot(env.w/(2*pi), env.pi_rms)
            % % ylim([0 5e3]);
        end

        function sig = air_flow_resistivity(env, config, options)

            arguments
                env
                config
                options.v_rms double = []
                options.M double = []
            end

            phi = config.RelativePorosity;
            pr = config.PerforationsRadius;
            t = config.Thickness;

            %% Paramètres optionnels
            if isfield(config, 'Beta')
                beta = config.Beta;
            else
                beta = 1.6; % [5] p.8
            end

            if isfield(config, 'Cd')
                Cd = config.Cd;
            else
                Cd = 0.76; % [5] p.8
            end

            if isfield(config, 'q')
                q = config.q;
            else
                q = 0.3; % voir modèle Laly écoulement
            end

            %% Calculs des composantes de la résistivité
            % Composante associée aux forts niveaux
            if isempty(options.v_rms)
                sig_HL = 8 * env.air.parameters.eta / (phi * pr^2) ...
                    + beta * env.air.parameters.Z0 / (pi * t * Cd^2) ...
                    * (-1/2 + classMPP_Circular_HL.f(env, phi)); ... % forts niveaux ([5], p. 7, eq. 27)

            else
                % Résistivité au passage de l'air ([5], p. 7, eq. 20)
                sig_HL = 8 * env.air.parameters.eta / (phi * pr^2) ... résistivité linéaire
                + beta * env.air.parameters.rho * (1 - phi^2) / (pi * t * phi * Cd^2) * options.v_rms; ... 
            end

            % Composante associée à la présence d'un écoulement rasant
            if isempty(options.M)
                sig_M = 0;
            else
                sig_M = env.air.parameters.Z0 * (1 - phi^2) / (phi * t) * q * options.M;
            end

            sig = sig_HL + sig_M;

            % % debog : Tracé de la résistivité au passage de l'air en fonction de la fréquence
            % perso_figure('Résistivité au passage de l''air dans classMPP_Circular_HL')
            % plot(abs(sig))
            % % close();
         end

         function tor = tortuosity(env, config, options)

            arguments
                env
                config
                options.v_rms double = []
                options.M double = []
            end

            phi = config.RelativePorosity;
            pr = config.PerforationsRadius;
            t = config.Thickness;
             
            psi = 4/3; 
            a = [1.0 -1.4092 0.0 0.33818 0.0 0.06793 -0.02287 0.003015 -0.01614];
            sum_a = dot(a, sqrt(phi).^(0:length(a)-1));

            if isempty(options.v_rms)
                % Tortuosité non linéaire ([5], p. 7, eq. 28)
                torNL = 2 * psi * 0.48 * sqrt(pi * pr^2) / t * sum_a ...    
                    * (1 + 1 / (1 - phi^2) ...
                    * (-1/2 + classMPP_Circular_HL.f(env, phi))).^(-1);

            else
                % Tortuosité non linéaire ([5], p. 7, eq. 22, 23)
                torNL = 2 * psi ./ (t * (1 + options.v_rms / (phi * env.air.parameters.c0))) ...
                * 0.48 * sqrt(pi * pr^2) * sum_a;
            end

            if ~isempty(options.M)
                torNL = torNL / (1 + 305 * options.M^3); % ([5], p. 7, eq. 28) 
            end

            tor = 1 + torNL;
         end
    
        function validate(handle_env)

            close();
            
            %% Thèse Laly - Models Comparison

            perso_figure('Validation classMPP_Circular_HL - Thèse Laly - Models Comparison');

            % subplot(2, 2, 1)
            title('Fig 3.3 - SPL = 110 dB')
            hold on 

            data3_3 = load('Thèse_Laly_fig3.3_red.txt');

            SPL = 110; 
            M = 0;
            env = handle_env(SPL, M);

            t = 1e-3;
            r = 0.25e-3/2;
            phi = 0.028;
            D = 30e-3;
            S = 1; % Surface arbitraire

            plate_HL = classMPP_Circular_HL(classMPP_Circular_HL.create_config(S, t, r, phi)); 
            cavity = classcavity(classcavity.create_config(S, D));
            E_HL = classelement(classelement.create_config({plate_HL, cavity}, 'closed', S));
            % plot(env.w/(2*pi), E_HL.alpha(env), 'DisplayName', 'Modèle non-linéaire');
            plot(env.w/(2*pi), E_HL.alpha(env, 'iter'), 'DisplayName', 'Modèle non-linéaire itératif');
            plot(env.w/(2*pi), E_HL.alpha(env, 'iter Laly'), 'DisplayName', 'Modèle non-linéaire itératif Laly');
            plot(data3_3(:, 1), data3_3(:, 2), 'DisplayName', 'Résultat expérimental de référence');
            perso_configure_alpha_figure(4000);

            %%%

            % subplot(2, 2, 2)
            title('Fig 3.4 - SPL = 135 dB')
            hold on 

            data3_4 = load('Thèse_Laly_fig3.4_black.txt');

            SPL = 135; % Pression incidente
            M = 0;
            env = handle_env(SPL, M);

            t = 1.2e-3;
            r = 1e-3/2;
            phi = 0.0417;
            D = 40e-3;

            plate = classMPP_Circular_HL(classMPP_Circular.create_config(S, t, r, phi)); 
            plate_HL = classMPP_Circular_HL(classMPP_Circular_HL.create_config(S, t, r, phi)); 
            cavity = classcavity(classcavity.create_config(S, D));
            E = classelement(classelement.create_config({plate, cavity}, 'closed', S));
            E_HL = classelement(classelement.create_config({plate_HL, cavity}, 'closed', S));
            plot(env.w/(2*pi), E.alpha(env), 'DisplayName', 'Prédiction du modèle linéaire');
            % plot(env.w/(2*pi), E_HL.alpha(env), 'DisplayName', 'Modèle non-linéaire');
            plot(env.w/(2*pi), E_HL.alpha(env, 'iter Laly'), 'DisplayName', 'Prédiction du modèle fort niveau');
            plot(data3_4(:, 1), data3_4(:, 2), 'DisplayName', 'Résultat expérimental de référence');
            perso_configure_alpha_figure(4000);

            %%%

            subplot(2, 2, 3)
            title('Fig 3.5 - SPL = 143 dB')
            hold on 

            data3_5 = load('Thèse_Laly_fig3.5_black.txt');

            SPL = 143; % Pression incidente
            M = 0;
            env = handle_env(SPL, M);

            t = 0.8e-3;
            r = 1.2e-3/2;
            phi = 0.0523;
            D = 28e-3;

            plate = classMPP_Circular_HL(classMPP_Circular.create_config(S, t, r, phi)); 
            plate_HL = classMPP_Circular_HL(classMPP_Circular_HL.create_config(S, t, r, phi)); 
            cavity = classcavity(classcavity.create_config(S, D));
            E = classelement(classelement.create_config({plate, cavity}, 'closed', S));
            E_HL = classelement(classelement.create_config({plate_HL, cavity}, 'closed', S));
            plot(env.w/(2*pi), E.alpha(env), 'DisplayName', 'Prédiction du modèle linéaire');
            % plot(env.w/(2*pi), E_HL.alpha(env), 'DisplayName', 'Modèle non-linéaire');
            plot(env.w/(2*pi), E_HL.alpha(env, 'iter Laly'), 'DisplayName', 'Prédiction du modèle fort niveau');
            plot(data3_5(:, 1), data3_5(:, 2), 'DisplayName', 'Résultat expérimental de référence');
            perso_configure_alpha_figure(4000);
s
            %%%

            subplot(2, 2, 4)
            title('Fig 3.6 - SPL = 150 dB')
            hold on 

            data3_6 = load('Thèse_Laly_fig3.6_magenta.txt');

            SPL = 150; % Pression incidente
            M = 0;
            env = handle_env(SPL, M);

            t = 1.2e-3;
            r = 1.2e-3/2;
            phi = 0.072;
            D = 43e-3;

            plate_HL = classMPP_Circular_HL(classMPP_Circular_HL.create_config(S, t, r, phi)); 
            cavity = classcavity(classcavity.create_config(S, D));
            E_HL = classelement(classelement.create_config({plate_HL, cavity}, 'closed', S));
            % plot(env.w/(2*pi), E_HL.alpha(env), 'DisplayName', 'Modèle non-linéaire');
            plot(env.w/(2*pi), E_HL.alpha(env, 'iter Laly'), 'DisplayName', 'Prédiction du modèle fort niveau');
            plot(data3_6(:, 1), data3_6(:, 2), 'DisplayName', 'Données de référence');
            perso_configure_alpha_figure(4000);

            
            %% Thèse Laly - Validation with litterature data
            
            perso_figure('Validation classMPP_Circular_HL - Thèse Laly - Validation with litterature data');

            title('Fig 3.8 - SPL = 143 dB')
            hold on 

            data3_8 = load('Thèse_Laly_fig3.8_grey.txt');

            SPL = 143; 
            M = 0;
            env = handle_env(SPL, M);

            t = 1e-3;
            r = 1e-3/2;
            phi = 0.0514;
            D = 100e-3;
            S = 1; % Surface arbitraire

            plate = classMPP_Circular_HL(classMPP_Circular.create_config(S, t, r, phi)); 
            plate_HL = classMPP_Circular_HL(classMPP_Circular_HL.create_config(S, t, r, phi)); 
            cavity = classcavity(classcavity.create_config(S, D));
            E = classelement(classelement.create_config({plate, cavity}, 'closed', S));
            E_HL = classelement(classelement.create_config({plate_HL, cavity}, 'closed', S));
            plot(env.w/(2*pi), E.alpha(env), 'DisplayName', 'Prédiction du modèle linéaire');
            % plot(env.w/(2*pi), E_HL.alpha(env), 'DisplayName', 'Modèle non-linéaire');
            plot(env.w/(2*pi), E_HL.alpha(env, 'iter Laly'), 'DisplayName', 'Prédiction du modèle fort niveau');
            plot(data3_8(:, 1), data3_8(:, 2), 'DisplayName', 'Résultat expérimental de référence');
            perso_configure_alpha_figure(4000);
            xlim([200 1400])
            ylim([0 1])
            
            %% Thèse Laly - Validation on own measurements

            perso_figure('Validation classMPP_Circular_HL - Thèse Laly - Validation on own measurements');

            subplot(2, 2, 1)
            title('Fig 3.11 - MPP#1 - SPL = 125, 150 dB')
            hold on 

            data3_11_125 = load('Thèse_Laly_fig3.11_grey125.txt');
            data3_11_150 = load('Thèse_Laly_fig3.11_grey150.txt');

            SPL1 = 125; 
            SPL2 = 150;
            M = 0;
            env1 = handle_env(SPL1, M);
            env2 = handle_env(SPL2, M);

            t = 0.86e-3;
            r = 1.517e-3/2;
            phi = 0.0523;
            D = 25e-3;
            % S = 29e-3^2; % Surface arbitraire
            S = 1;

            plate_HL = classMPP_Circular_HL(classMPP_Circular_HL.create_config(S, t, r, phi)); 
            cavity = classcavity(classcavity.create_config(S, D));
            E_HL = classelement(classelement.create_config({plate_HL, cavity}, 'closed', S));
            plot(env1.w/(2*pi), E_HL.alpha(env1), 'DisplayName', 'Modèle non-linéaire  - 125 dB');
            plot(env1.w/(2*pi), E_HL.alpha(env1, 'iter'), 'DisplayName', 'Modèle non-linéaire itératif - 125 dB');
            plot(data3_11_125(:, 1), data3_11_125(:, 2), 'DisplayName', 'Données de référence - 125 dB');
            plot(env2.w/(2*pi), E_HL.alpha(env2), 'DisplayName', 'Modèle non-linéaire - 150 dB');
            plot(env2.w/(2*pi), E_HL.alpha(env2, 'iter'), 'DisplayName', 'Modèle non-linéaire itératif - 150 dB');
            plot(data3_11_150(:, 1), data3_11_150(:, 2), 'DisplayName', 'Données de référence - 150 dB ');
            perso_configure_alpha_figure(4000);

            %%%

            subplot(2, 2, 2)
            title('Fig 3.12 - MPP#2, SPL = 140 dB')
            hold on 

            data3_12 = load('Thèse_Laly_fig3.12_grey.txt');

            SPL = 140;
            M = 0;
            env = handle_env(SPL, M);

            t = 1.2e-3;
            r = 1.38e-3/2;
            phi = 0.049;
            D = 30e-3;

            plate_HL = classMPP_Circular_HL(classMPP_Circular_HL.create_config(S, t, r, phi)); 
            cavity = classcavity(classcavity.create_config(S, D));
            E_HL = classelement(classelement.create_config({plate_HL, cavity}, 'closed', S));
            plot(env.w/(2*pi), E_HL.alpha(env), 'DisplayName', 'Modèle non-linéaire');
            plot(env.w/(2*pi), E_HL.alpha(env, 'iter'), 'DisplayName', 'Modèle non-linéaire itératif');
            plot(data3_12(:, 1), data3_12(:, 2), 'DisplayName', 'Données de référence');
            perso_configure_alpha_figure(4000);

            %%%

            subplot(2, 2, 3)
            title('Fig 3.13 - MPP#2, SPL = 150 dB')
            hold on 

            data3_13 = load('Thèse_Laly_fig3.13_grey.txt');

            SPL = 150; % Pression incidente
            M = 0;
            env = handle_env(SPL, M);

            t = 1e-3;
            r = 1.38e-3/2;
            phi = 0.049;
            D = 30e-3;

            plate_HL = classMPP_Circular_HL(classMPP_Circular_HL.create_config(S, t, r, phi)); 
            cavity = classcavity(classcavity.create_config(S, D));
            E_HL = classelement(classelement.create_config({plate_HL, cavity}, 'closed', S));
            plot(env.w/(2*pi), E_HL.alpha(env), 'DisplayName', 'Modèle non-linéaire');
            plot(env.w/(2*pi), E_HL.alpha(env, 'iter'), 'DisplayName', 'Modèle non-linéaire itératif');
            plot(data3_13(:, 1), data3_13(:, 2), 'DisplayName', 'Données de référence');
            perso_configure_alpha_figure(4000);

            %%%

            subplot(2, 2, 4)
            title('Fig 3.14 - MPP#3, SPL = 150 dB')
            hold on 

            data3_14 = load('Thèse_Laly_fig3.14_grey.txt');

            SPL = 150; % Pression incidente
            M = 0;
            env = handle_env(SPL, M);

            t = 1e-3;
            r = 1.43e-3/2;
            phi = 0.0754;
            D = 17.5e-3;

            plate_HL = classMPP_Circular_HL(classMPP_Circular_HL.create_config(S, t, r, phi)); 
            cavity = classcavity(classcavity.create_config(S, D));
            E_HL = classelement(classelement.create_config({plate_HL, cavity}, 'closed', S));
            plot(env.w/(2*pi), E_HL.alpha(env), 'DisplayName', 'Modèle non-linéaire');
            plot(env.w/(2*pi), E_HL.alpha(env, 'iter'), 'DisplayName', 'Modèle non-linéaire itératif');
            plot(data3_14(:, 1), data3_14(:, 2), 'DisplayName', 'Données de référence');
            perso_configure_alpha_figure(4000);
         end
     end
end