classdef classMPP_Circular_HL_bis < classJCA_Rigid

%% References:

%            [1] Atalla, Noureddine, et Franck Sgard. « Modeling of Perforated 
%                Plates and Screens Using Rigid Frame Porous Models ». Journal 
%                of Sound and Vibration, vol. 303, no 1‑2, juin 2007, p. 195‑208.
%                DOI.org (Crossref), https://doi.org/10.1016/j.jsv.2007.01.012.
% 
%            [2] Ingard, Uno. « On the Theory and Design of Acoustic Resonators ». 
%                The Journal of the Acoustical Society of America, vol. 25, no 6, 
%                juin 2005, p. 1037. world, asa.scitation.org, 
%                https://doi.org/10.1121/1.1907235.
% 
%            [3] Okuzono, Takeshi, et al. "Note on Microperforated Panel Model Using
%                Equivalent-Fluid-Based Absorption Elements." Acoustical Science and 
%                Technology, vol. 40, no. 3, May 2019, pp. 221–24. DOI.org (Crossref), 
%                https://doi.org/10.1250/ast.40.221.)
%
%            [4] Stinson & Champoux, Propagation of sound and the assignment of 
%                shape factors in model porous materials having simple pore geometries
%                http://asa.scitation.org/doi/10.1121/1.402530
%
%            [5] Zacharie Laly, Acoustical modeling of micro-perforated panel at high 
%                sound pressure levels using equivalent fluid approach
%                https://linkinghub.elsevier.com/retrieve/pii/S0022460X17306740
%
%            [6] Zacharie Laly, Développement, validation expérimentale et optimisation 
%                des traitements acoustiques des nacelles de turboréacteurs sous hauts 
%                niveaux acoustiques

%% Description

% Ce constructeur de classe permet de créer une plaque microperforée à perforations circulaires
% Il se base sur le modèle de fluide équivalent (JCA) développé dans 'classJCA_Rigid'
% En plus de cela, on intègre la résistivité et la tortuosité modifiée développée par Laly dans [5]

                 
%% Constructeur de classe

    properties
        
      Type = 'CircularMPP' % pourquoi et ou est-ce utile?
           
      % Propriétés héritées du superconstructeur : 

      % Configuration
      %              .JCAParameters
      %              .Thickness

      % EquivalentParameters

    end

    methods

        function obj = classMPP_Circular_HL_bis(config)

            % On appelle le superconstructeur 
            obj@classJCA_Rigid(config);
            obj.Configuration = config;
        end
    end

    methods (Static, Access = public)

        function config = create_config(plate_porosity, plate_thickness, perforations_radius)
        % Cette méthode permet de créer une configuration d'appel spéciale dans le cas ou les perforations
        % de la MPP sont cylindriques. 
        % Les variables manquantes sont suspendues pour être appelées plus tard dans l'environnement env.

            phi = plate_porosity;
            t = plate_thickness;
            pr = perforations_radius;

            % Coefficient de perméabilité pour une perforation circulaire (Carman)
            k0 = 2; % [4] p.8 

            % Rayon Hydraulique 
            rh = pr; % [4] p.8 

            beta = 1.6; % [5] p.8
            Cd = 0.76; % [5] p.8

            % La résistivité tient compte du niveau sonore dans l'expression de la 
            % resistance non linéaire avec le coefficient de décharge Cd, et la pression rms 
            % dans l'orifice Pi

            % fonction intermédiaire, [5] eq. 27, eq. 28
            f = @(env) sqrt(1/4 + 2*sqrt(2) * env.p / (env.air.parameters.rho * env.air.parameters.c0^2) ...
                    * (1 - phi^2) / phi^2);

            sig = @(env) 4 * k0 * env.air.parameters.eta / (phi * pr^2) ... % [5], p. 7, eq. 27
                + beta * env.air.parameters.Z0 / (pi * t * Cd^2) * (-1/2 + f(env));
            
            % La tortuosité diminue lorsque le niveau sonore augmente. En effet les turbulences
            % ont tendances tendance à diminuer les phénomènes de radiation
            
            psi = 4/3; 
            a = [1.0 -1.4092 0.0 0.33818 0.0 0.06793 -0.02287 0.003015 -0.01614];

            sum_a = dot(a, sqrt(phi).^(0:length(a)-1));

            tor = @(env) 1 + 2 * psi * 0.48 * sqrt(pi * pr^2) / t * sum_a ... % [5], p. 7, eq. 28
                * (1 + 1 / (1 - phi^2) * (-1/2 + f(env)))^(-1);

            config = classJCA_Rigid.create_config(phi, tor, sig, rh, rh, t);
        end   
     
        function validate()

            figure();
            title("Validation MPP_Circular_HL - Laly2017")

            %% Résistivité au passage de l'air (Laly2017)
            % Données de référence : [6], fig. 3.29, p. 68
            
            subplot(2, 3, 1)
            hold on            

            % importation des données de références
            data = csvread('Laly2017_fig3.29.txt');
            [x_data, y_data] = interpole_et_lisse(data(:, 1), data(:, 2), 1000, 0.05);
            plot(x_data, y_data, 'g--', 'DisplayName', 'Données de référence');

            % création de l'environnement
            env = create_environnement(23, 100800, 22, 1, 5000, 200);

            % Paramètres de la configuration
            dB = 50:5:160; % niveau de pression
            sig_HL = zeros(1, length(dB));
            t = 1.2e-3; % épaisseur de la plaque
            d = 0.8e-3; % diamètre des perforations
            phi = 0.018; % porosité de la plaque
            config_HL = classMPP_Circular_HL_bis.create_config(phi, t, d/2);
            MPP_HL = classMPP_Circular_HL_bis(config_HL);

            Pref = 20e-6;
            db2rms = @(dB) Pref * 10^(dB/20);

            for i = 1:length(dB)
                env.p = db2rms(dB(i));
                sig_HL(i) = MPP_HL.Configuration.JCAParameters.AirFlowResistivity(env);
            end
            
            % affichage des résultats
            plot(dB, sig_HL, 'r--o', 'DisplayName', 'Modèle non linéaire');
            xlabel("Niveau de pression SPL (dB)")
            ylabel("Résistivité (Pa.s/m)")
            xlim([50 160])
            subtitle('Résistivité au passage de l''air - fig. 3.29, p. 68')
            legend()

            %% Tortuosité (Laly2017)
            % Données de référence : [6], fig. 3.28, p. 67

            subplot(2, 3, 2)
            hold on
            
            % création de l'environnement
            env = create_environnement(23, 100800, 22, 1, 5000, 200);
            
            % Paramètres de la configuration
            dB = 50:5:150; % niveau de pression
            phi = 0:0.005:0.10;
            tor_HL = zeros(length(phi), length(dB));
            t = 1.0e-3; % épaisseur de la plaque
            d = 0.8e-3; % diamètre des perforations
            
            for i = 1:length(phi)
                config_HL = classMPP_Circular_HL_bis.create_config(phi(i), t, d/2); 
                MPP_HL = classMPP_Circular_HL_bis(config_HL);
                for j = 1:length(dB)               
                    env.p = db2rms(dB(j));
                    tor_HL(i, j) = MPP_HL.Configuration.JCAParameters.Tortuosity(env);               
                end
            end

            % affichage des résultats
            contourf(dB, phi*100, tor_HL);
            colorbar;
            colormap(jet);
            clim([1 1.8]);
            xlabel("Niveau de pression SPL (dB)")
            ylabel("Porosité (ad)")
            ylim([0.5 10])
            xlim([50 150])           
            subtitle('Tortuosité - fig. 3.28, p. 67')

            %% multiMPP + Cavité à différents niveaux de pression (Laly2017)
            % Données de référence : [6], fig. 7.12, p. 189
            path = ['C:\Users\Utilisateur\OneDrive - ETS\CRIAQ-REAR\Maitrise LB\' ...
                    'Classes\MPP_Classes\Validation\Laly2017\fig 7.12\'];

            subplot(2, 3, 4)
            hold on

            % Paramètres de la configuration
            nb = 2; % Nombre de MPP
            dB = [100 130 150]; % niveau de pression
            t = [1e-3 1e-3]; % épaisseur de la plaque
            d = [1.45e-3 1.45e-3 1.35e-3]; % diamètre des perforations
            D = 32e-3; % épaisseur de la cavité arrière
            phi = [0.083 0.078 0.049]; % porosité de la plaque
            
            % création de l'environnement
            env = create_environnement(23, 100800, 22, 1, 5000, 200);
            
            % création de l'élement
            list = {};
            for i = 1:nb
                list{end+1} = classsectionchange(1, phi(i));
                config = classMPP_Circular_HL_bis.create_config(phi(i), t(i), d(i)/2);   
                list{end+1} = classMPP_Circular_HL_bis(config);
                list{end+1} = classsectionchange(phi(i), 1);
                list{end+1} = classcavity(D);    
            end

            E_HL = classelement(list, 'closed');

            for i = 1:length(dB)
                env.p = db2rms(dB(i));
                alpha_model_HL = E_HL.alpha(env);
                color = rand(1, 3);

                % importation des données de références
                data = csvread([path, num2str(dB(i)), 'dB.txt']);
                [x_data, y_data] = interpole_et_lisse(data(:, 1), data(:, 2), 1000, 0.05);
                plot(x_data, y_data, 'Color', color, 'Linestyle', '--', 'DisplayName', ['Référence : SPL = ', num2str(dB(i)), ' dB']);
                plot(env.w/(2*pi), alpha_model_HL, 'Color', color, 'DisplayName', ['SPL = ', num2str(dB(i)), 'dB'], 'LineWidth', 1.5);
            end

            % affichage des résultats
            xlabel("Fréquence (Hz)")
            ylabel("Coefficient d'Absorption")
            ylim([0,1])
            xlim([500 5000])
            subtitle("multi MPP + Cavité - fig. 7.12, p. 188")

            % plot(x_data, y_data, 'Color', 'g','LineWidth', 1, 'LineStyle', '--');
            legend()

            %% MPP + Cavité à différents niveaux de pression (Laly2017)
            % Données de référence : [6], fig. 7.11, p. 188
            path = ['C:\Users\Utilisateur\OneDrive - ETS\CRIAQ-REAR\Maitrise LB\' ...
                    'Classes\MPP_Classes\Validation\Laly2017\fig. 7.11\'];

            subplot(2, 3, 3)
            hold on

            % Paramètres de la configuration
            dB = [100 130 150]; % niveau de pression
            t = 1e-3; % épaisseur de la plaque
            d = 1.35e-3; % diamètre des perforations
            D = 32e-3; % épaisseur de la cavité arrière
            phi = 0.0672; % porosité de la plaque
            config = classMPP_Circular_HL_bis.create_config(phi, t, d/2);   
            % config = classMPP_Circular.create_config(phi, t, d/2);
            MPP_HL = classMPP_Circular_HL_bis(config);


            % création de l'environnement
            env = create_environnement(23, 100800, 22, 1, 5000, 200);

            % création de l'élement composé d'une plaque et d'une cavité
            SC1 = classsectionchange(1, phi);
            SC2 = classsectionchange(phi, 1);
            Cav = classcavity(D);
            E_HL = classelement({SC1, MPP_HL, SC2, Cav}, 'closed');
            % E_HL = classelement({MPP_HL, Cav}, 'closed');

            for i = 1:length(dB)
                env.p = db2rms(dB(i));
                alpha_model_HL = E_HL.alpha(env);
                color = rand(1, 3);

                % importation des données de références
                data = csvread([path, num2str(dB(i)), 'dB.txt']);
                [x_data, y_data] = interpole_et_lisse(data(:, 1), data(:, 2), 1000, 0.05);
                plot(x_data, y_data, 'Color', color, 'Linestyle', '--', 'DisplayName', ['Référence : SPL = ', num2str(dB(i)), ' dB']);
                plot(env.w/(2*pi), alpha_model_HL, 'Color', color, 'DisplayName', ['SPL = ', num2str(dB(i)), 'dB'], 'LineWidth', 1.5);
            end

            % affichage des résultats
            xlabel("Fréquence (Hz)")
            ylabel("Coefficient d'Absorption")
            ylim([0,1])
            xlim([0 5000])
            subtitle("MPP + Cavité - 7.11, p. 188")

            legend()

            %% MPP + Cavité à différents niveaux de pression (Laly2017)
            % Données de référence : [6], fig. 7.11, p. 188
            path = ['C:\Users\Utilisateur\OneDrive - ETS\CRIAQ-REAR\Maitrise LB\' ...
                    'Classes\MPP_Classes\Validation\Laly2017\fig. 7.11\'];

            subplot(2, 3, 5)
            hold on

            % Paramètres de la configuration
            dB = 143; % niveau de pression
            t = 0.8e-3; % épaisseur de la plaque
            d = 1.2e-3; % diamètre des perforations
            D = 28e-3; % épaisseur de la cavité arrière
            phi = 0.0523; % porosité de la plaque  
            config = classMPP_Circular_HL_bis.create_config(phi, t, d/2);
            MPP_HL = classMPP_Circular_HL_bis(config);


            % création de l'environnement
            env = create_environnement(23, 100800, 22, 1, 4000, 200);

            % création de l'élement composé d'une plaque et d'une cavité
            SC1 = classsectionchange(1, phi);
            SC2 = classsectionchange(phi, 1);
            Cav = classcavity(D);
            E_HL = classelement({SC1, MPP_HL, SC2, Cav}, 'closed');
            % E_HL = classelement({MPP_HL, Cav}, 'closed');

            for i = 1:length(dB)
                env.p = db2rms(dB(i));
                alpha_model_HL = E_HL.alpha(env);
                color = rand(1, 3);

                % importation des données de références
                % data = csvread([path, num2str(dB(i)), 'dB.txt']);
                % [x_data, y_data] = interpole_et_lisse(data(:, 1), data(:, 2), 1000, 0.05);
                % plot(x_data, y_data, 'Color', color, 'Linestyle', '--', 'DisplayName', ['Référence : SPL = ', num2str(dB(i)), ' dB']);
                plot(env.w/(2*pi), alpha_model_HL, 'Color', color, 'DisplayName', ['SPL = ', num2str(dB(i)), 'dB'], 'LineWidth', 1.5);
            end

            % affichage des résultats
            % xlabel("Fréquence (Hz)")
            % ylabel("Coefficient d'Absorption")
            % ylim([0,1])
            % xlim([0 5000])
            % subtitle("MPP + Cavité - 7.11, p. 188")

            % legend()
        end
    end
end