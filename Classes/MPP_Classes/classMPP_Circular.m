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

            phi = config.Porosity;
            pr = config.PerforationsRadius;
            t = config.Thickness;
            s = config.Section;
            S = config.Surface;

            % Si aucune correction de longueur n'est donnée dans la configuration d'appel, on considère une correction de longueur par défault
            
            if isfield(config, 'CorrectionLength')
                tc = config.ThicknessCorrection;
            else
                tc = 0.48 * sqrt(pi * pr^2) * (1 - 1.14 * sqrt(phi)); % Allard-Insgard ([1] après eq.9, p.4) phi < 0.2
                config.ThicknessCorrection = tc;
            end

            % Coefficient de perméabilité pour une perforation circulaire (Carman)
            k0 = 2; % [4] p.8 

            % Rayon Hydraulique (= rayon de perforation)
            rh = pr; % [4] p.8 

            % La classe n'a pas directement accès aux propriétés de l'air
            sig = @(env) 4 * k0 * env.air.parameters.eta / (phi * rh^2); % [1] p.5 entre eq. 11 et eq.12 

            % % On tient compte de la correction de longueur dans la tortuosité
            tor = 1 + 2 * tc / t; % proportionnel à sqrt(phi)
            % tor = 1;
            
            % On créer la configuration 
            config = perso_transfer_fields(classJCA_Rigid.create_config(s, t, phi, tor, sig, rh, rh), config);

            % On appelle le superconstructeur 
            obj@classJCA_Rigid(config);

            % On rétabit la surface
            obj.Configuration.Surface = S;
        end


        function output_model = set_COMSOL_2D_Model(obj, input_model, elem_index, sblm_index, env)
            output_model = ModelMPP(obj.Configuration, input_model, elem_index, sblm_index, env);
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
        end   

        function config = create_explicit_rectangular_plate_config(thickness, perforations_radius, ...
                width, depth, width_holes_number, depth_holes_number)
            
            % Cette méthode permet de créer une configuration d'appel
            % explicite dans le cas où la plaque est de forme rectangulaire
            
            config = struct();
            config.Thickness = thickness;
            [config.PerforationsRadius, pr] = deal(perforations_radius);
            [config.Width, w] = deal(width);
            [config.Depth, d] = deal(depth);
            [config.Surface, s] = deal(w*d);
            % [config.WidthHoleNumber, whn] = deal(width_holes_number);
            % [config.WidthHoleNumber, dhn] = deal(depth_holes_number);
            config.Section = width_holes_number*depth_holes_number*pi*pr^2;
            config.Porosity = config.Section / s;
        end 
       
        function validate(handle_env)

            % close all 
            perso_figure('Validation Circular MPP');

            % Données de référence : [1], fig. 3, 4 p. 9, 10

            % panel 1
            phi = 0.025; % porosité de la plaque
            d = 1e-3; % épaisseur de la plaque
            r = 0.5e-3; % diamètre des perforations
            c = 30e-3; % côté arbitraire
            s = c^2; % Section 
            MPP = classMPP_Circular(classMPP_Circular.create_config(s, d, r, phi));
            
            % Paramètres de la configuration

            D1 = 60e-3;
            cavity = classcavity(classcavity.create_config(s, D1));

            % foam 1
            phip1 = 0.99;
            torp1 = 1.02;
            sigp1 = 10900;
            vlp1 = 100e-6;
            tlp1 = 130e-6;
            
            % % foam 2
            % phip2 = 0.98;
            % torp2 = 1.5;
            % sigp2 = 50000;
            % vlp2 = 34e-6;
            % tlp2 = 130e-6;
            D2 = 20e-3; % épaisseur de la cavité arrière

            Porous1 = classJCA_Rigid(classJCA_Rigid.create_config(s, D2, phip1, torp1, sigp1, vlp1, tlp1));
            
            % Création des éléments
            E1 = classelement(classelement.create_config({MPP, cavity}, 'closed', s)); % fig.3
            E2 = classelement(classelement.create_config({MPP, Porous1}, 'closed', s)); % fig.4

            % importation des données de références
            data1 = readmatrix('Atalla2007_fig3_black_square.txt');
            data2 = readmatrix('Atalla2007_fig4_red.txt');
            [x_data1, y_data1] = perso_interpole_et_lisse(data1(:, 1), data1(:, 2), 1000, 0.05);
            [x_data2, y_data2] = perso_interpole_et_lisse(data2(:, 1), data2(:, 2), 1000, 0.05);

            env = handle_env(100, 0);
            
            % Tube = ImpedanceTube2D(ImpedanceTube2D.create_config({E1}));
            % Tube = Tube.launch_tube_measurement(env);
            
            % affichage des résultats
            subplot(1, 2, 1)
            hold on
            subtitle("Atalla2007 - fig. 3 - p. 9")
            plot(env.w / (2*pi), E1.alpha(env), 'Color', 'b', 'LineWidth', 1, 'DisplayName', 'Modèle analytique');
            % Tube.plot_alpha(env, 'Modèle numérique');
            plot(x_data1, y_data1, 'Color', 'g','LineWidth', 1, 'LineStyle', '--', 'DisplayName', 'Données de références');
            perso_configure_alpha_figure(5000);

            subplot(1, 2, 2)
            hold on
            subtitle("Atalla2007 - fig. 4 - p. 10")
            plot(env.w / (2*pi), E2.alpha(env), 'Color', 'b', 'LineWidth', 1, 'DisplayName', 'modèle foam 1');
            % plot(env.w / (2*pi), E2_2.alpha(env), 'Color', 'r',
            % 'LineWidth', 1, 'DisplayName', 'modèle foam 2'); % la référence s'est trompée de mousse
            plot(x_data2, y_data2, 'Color', 'g','LineWidth', 1, 'LineStyle', '--','DisplayName', 'Données de références');
            perso_configure_alpha_figure(5000);

            %% Temporaire - Validation de la contribution de la cavité jaune dans le module ETS
            % 
            % perso_figure('Validation numérique 2D - contribution cavité jaune - module ETS')
            % 
            % % panel 1
            % phi = 0.0812; % porosité de la plaque
            % t = 1e-3; % épaisseur de la plaque
            % r = 9.9219e-4; % diamètre des perforations
            % w = 0.012; % Largeur
            % d = 0.03; % Profondeur
            % s = w*d; % Section 
            % MPP = classMPP_Circular(classMPP_Circular.create_config(s, t, r, phi, w, d));
            % 
            % % Paramètres de la configuration
            % 
            % D1 = 115e-3; % 1e-3 + 114e-3
            % cavity = classcavity(classcavity_rectangular.create_config(D1, w, d));
            % 
            % % Création des éléments
            % E1 = classelement(classelement.create_config({MPP, cavity}, 'closed', s)); % fig.3
            % 
            % Tube = ImpedanceTube2D(ImpedanceTube2D.create_config({E1}));
            % Tube = Tube.launch_tube_measurement(env);
            % comsol_model = Tube.Configuration.ComsolModel;
            % folder_full_name = [env.Root, '\COMSOL\Optimisation\Optimisation REAR\Optimisations finales\optimisation_ETS_Poly_H1-4_08_25_06_14'];
            % mphsave(comsol_model, [folder_full_name, '\Validation numérique\Validation de la contribution de la cavité jaune de la cartouche ETS dans classMPP_Circular.mph']);
            % 
            % % affichage des résultats
            % hold on
            % subtitle("Atalla2007 - fig. 3 - p. 9")
            % plot(env.w / (2*pi), E1.alpha(env), 'Color', 'b', 'LineWidth', 1, 'DisplayName', 'Modèle analytique - classMPP_Circular');
            % Tube.plot_alpha(env, 'Modèle numérique - classMPP_Circular');

            %% Validation classMPP_Circular - TL avec écoulement

            % perso_figure('Validation classMPP_Circular - TL sans écoulement')
            % % Figures de réference 
            % % perso_ouvrir_lien_Zotero('zotero://open-pdf/library/items/CMZQ7B9B?page=257&annotation=DN9BHR8G')
            % 
            % Lx = 50.8e-3;
            % Lz = 254e-3;
            % w = Lz; % longueur de la zone traité
            % d = Lx; % tube carré
            % r = 0.6e-3;
            % t = 1.3e-3;
            % phi = 0.078;
            % D = 17.2e-3;
            % 
            % % création de l'environnement
            % env = create_environnement(23, 100800, 22, 1, 3000, 200, 100);
            % 
            % % création de l'objet de classe
            % E = classelement(classelement.create_config(...
            %     {classMPP_Circular(classMPP_Circular.create_config(w * d, t, r, phi, w, d)), ...
            %     classcavity(classcavity.create_config(D, w, d))}, 'closed', w * d));
            % 
            % TM_sb = E.side_branch_transfer_matrix(env, Lx, 0);
            % 
            % perso_plot_transfer_matrix(TM_sb, env, 'test', 3000);
        end
    end
end