classdef classMPP_Circular < classJCA_Rigid

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

%% Description

% Ce constructeur de classe permet de créer une plaque microperforée à perforations circulaires
% Il se base sur le modèle de fluide équivalent (JCA) développé dans 'classJCA_Rigid'

                 
%% Constructeur de classe

    methods

        function obj = classMPP_Circular(config)

            phi = config.PlatePorosity;
            pr = config.PerforationsRadius;
            t = config.PlateThickness;
            s = config.PlateSection;

            % Si aucune correction de longueur n'est donnée dans la configuration d'appel, on considère une correction de longueur par défault
            
            if isfield(config, 'CorrectionLength')
                tc = config.ThicknessCorrection;
            else
                tc = 2 * 0.48 * sqrt(pi * pr^2) * (1 - 1.14 * sqrt(phi)); % Allard-Insgard ([1] après eq.9, p.4)
                config.ThicknessCorrection = tc;
            end

            % Coefficient de perméabilité pour une perforation circulaire (Carman)
            k0 = 2; % [4] p.8 

            % Rayon Hydraulique (= rayon de perforation)
            rh = pr; % [4] p.8 

            % La classe n'a pas directement accès aux propriétés de l'air
            sig = @(env) 4 * k0 * env.air.parameters.eta / (phi * rh^2); % [1] p.5 entre eq. 11 et eq.12 

            % On tient compte de la correction de longueur dans la tortuosité
            tor = 1 + tc / t;

            % Utilisé pour définir la section d'entrée réelle de la matrice de transfert
            perforations_section = s * phi; 

            % On créer la configuration 
            config = perso_transfer_fields(classJCA_Rigid.create_config(phi, tor, sig, rh, rh, t, perforations_section), config);

            % On appelle le superconstructeur 
            obj@classJCA_Rigid(config);
        end
    end

    methods (Static, Access = public)

        function config = create_config(plate_porosity, perforations_radius, plate_thickness, plate_section, varargin)
            % Cette méthode permet de créer une configuration d'appel spéciale dans le cas ou les perforations de la MPP sont cylindriques
            
            config = struct();
            config.PlatePorosity = plate_porosity;
            config.PerforationsRadius = perforations_radius;
            config.PlateThickness = plate_thickness;
            config.PlateSection = plate_section;

            % Si une longueur de correction est donnée 
            if nargin > 4
                config.ThicknessCorrection = varargin{1};
            end
        end   
     
        function validate()

            % close all 
            figure()
            title('Validation Circular MPP')

            % Données de référence : [1], fig. 3, 4 p. 9, 10

            % panel 1
            phi = 0.025; % porosité de la plaque
            d = 1e-3; % épaisseur de la plaque
            r = 0.5e-3; % diamètre des perforations
            s = 1; % section arbitraire
            MPP = classMPP_Circular(classMPP_Circular.create_config(phi, r, d, s));
            
            % Paramètres de la configuration

            D1 = 60e-3;
            cavity = classcavity(classcavity.create_config(D1, s));

            % foam 1
            phip1 = 0.99;
            torp1 = 1.02;
            sigp1 = 10900;
            vlp1 = 100e-6;
            tlp1 = 130e-6;
            
            % foam 2
            phip2 = 0.98;
            torp2 = 1.5;
            sigp2 = 50000;
            vlp2 = 34e-6;
            tlp2 = 130e-6;
            D2 = 20e-3; % épaisseur de la cavité arrière

            Porous1 = classJCA_Rigid(classJCA_Rigid.create_config(phip1, torp1, sigp1, vlp1, tlp1, D2, s));
            Porous2 = classJCA_Rigid(classJCA_Rigid.create_config(phip2, torp2, sigp2, vlp2, tlp2, D2, s));

            % création de l'environnement
            env = create_environnement(23, 100800, 22, 1, 5000, 5000);
            
            % Création des éléments
            E1 = classelement(classelement.create_config({MPP, cavity}, 'closed', s)); % fig.3
            E2 = classelement(classelement.create_config({MPP, Porous1}, 'closed', s)); % fig.4
            E2_2 = classelement(classelement.create_config({MPP, Porous2}, 'closed', s)); % fig.4

            % importation des données de références
            data1 = csvread('Atalla2007_fig3_black_square.txt');
            data2 = csvread('Atalla2007_fig4_red.txt');
            [x_data1, y_data1] = interpole_et_lisse(data1(:, 1), data1(:, 2), 1000, 0.05);
            [x_data2, y_data2] = interpole_et_lisse(data2(:, 1), data2(:, 2), 1000, 0.05);
            
            % affichage des résultats
            figure()
            subplot(1, 2, 1)
            hold on
            xlabel("Fréquence (Hz)")
            ylabel("Coefficient d'Absorption")
            ylim([0 1])
            subtitle("Atalla2007 - fig. 3 - p. 9")

            plot(env.w / (2*pi), E1.alpha(env), 'Color', 'b', 'LineWidth', 1, 'DisplayName', 'modèle');
            plot(x_data1, y_data1, 'Color', 'g','LineWidth', 1, 'LineStyle', '--', 'DisplayName', 'Données de références');
            legend()

            subplot(1, 2, 2)
            hold on
            xlabel("Fréquence (Hz)")
            ylabel("Coefficient d'Absorption")
            ylim([0 1])
            subtitle("Atalla2007 - fig. 4 - p. 10")

            plot(env.w / (2*pi), E2.alpha(env), 'Color', 'b', 'LineWidth', 1, 'DisplayName', 'modèle foam 1');
            % plot(env.w / (2*pi), E2_2.alpha(env), 'Color', 'r',
            % 'LineWidth', 1, 'DisplayName', 'modèle foam 2'); % la référence s'est trompée de mousse
            plot(x_data2, y_data2, 'Color', 'g','LineWidth', 1, 'LineStyle', '--','DisplayName', 'Données de références');
            legend()
        end
    end
end