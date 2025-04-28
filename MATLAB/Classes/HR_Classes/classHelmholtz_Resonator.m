classdef classHelmholtz_Resonator < classelement

%% Références

% [1] K. Mahesh, R.S. Mini, Investigation on the Acoustic Performance of Multiple Helmholtz Resonator Configurations
% Lien Zotero : perso_ouvrir_lien_Zotero('zotero://open-pdf/library/items/UF5M6PI2')
    
    methods
        function obj = classHelmholtz_Resonator(config)

            % Appel du constructeur de la classe parente
            obj@classelement(classelement.create_config({}, 'opened'));

            % On transfert les champs de la structure d'appel vers ceux de la structure de classe
            obj.Configuration = perso_transfer_fields(config, obj.Configuration);

            nr = config.NeckRadius;
            nl = config.NeckLength;
            ns = pi*nr^2; % Neck Section
            cw = config.CavityWidth;
            cd = config.CavityDepth;
            cl = config.CavityLength;
            cs = cd*cw; % Cavity Section

            % On ajoute le col du résonateur
            phi = ns/cs;
            tc = 0.48 * sqrt(ns) * (1 - 1.14 * sqrt(phi)); % perso_ouvrir_lien_Zotero('zotero://open-pdf/library/items/UF5M6PI2?page=357&annotation=69ALD78C')
            sig = @(env) 8 * env.air.parameters.eta / (phi * nr^2); % perso_ouvrir_lien_Zotero('zotero://open-pdf/library/items/UF5M6PI2?page=357&annotation=6CBI54J6')
            tor = 1 + (2*tc/nl); % perso_ouvrir_lien_Zotero('zotero://open-pdf/library/items/UF5M6PI2?page=357&annotation=4QIE2UDU')
            obj.Configuration.ListOfSubelements{end+1} = classJCA_Rigid(classJCA_Rigid.create_config(phi, tor, sig, nr, nr, nl, ns));

            % On ajoute la cavité
            obj.Configuration.ListOfSubelements{end+1} = classcavity(classcavity.create_config(cl, cs));
        end    
    
        function output_model = set_COMSOL_2D_Model(obj, input_model, index, env)
            output_model = Model_HR_2D(obj.Configuration, input_model, index, env);
        end
        
        
        function output_model = set_COMSOL_3D_Model(obj, input_model, index, env)
            output_model = Model_HR_3D(obj.Configuration, input_model, index, env);
        end
    end


    methods (Static, Access = public)

        function config = create_config(neck_radius, neck_length, cavity_width, cavity_depth, cavity_length, input_section)

            config.NeckRadius = neck_radius;
            config.NeckLength = neck_length;
            config.CavityWidth = cavity_width;
            config.CavityDepth = cavity_depth;
            config.CavityLength = cavity_length;
            config.InputSection = input_section;
        end

        function validate()

            % close all 
            figure()
            title('Validation Helmholtz Resonator')
            
            % Données de référence : [1], fig. 4, p. 10
            
            % Paramètres de la configuration
            nr = 1.5e-3;
            nl = 8e-3;
            cl = 12e-3;
            cw = 22.15e-3; % section égale à un cylindre de 25 mm  de diamètre
            cd = 22.15e-3;
            
            % création de l'environnement
            env = create_environnement(23, 100800, 22, 1, 1000, 1000);

            alpha_model = classHelmholtz_Resonator(classHelmholtz_Resonator.create_config(nr, nl, cw, cd, cl, cd*cw)).alpha(env);

            % importation des données de références
            data = csvread('Mahesh, fig.4, p.6, blue.txt');
            [x_data, y_data] = interpole_et_lisse(data(:, 1), data(:, 2), 1000, 0.05);
            
            % affichage des résultats
            figure()
            hold on
            xlabel("Fréquence (Hz)")
            ylabel("Coefficient d'Absorption")
            ylim([0 1])
            subtitle("Mahesh2021 - fig. 4 - p. 6")
            
            plot(env.w / (2*pi), alpha_model, 'Color', 'b', 'LineWidth', 1);
            plot(x_data, y_data, 'Color', 'g','LineWidth', 1, 'LineStyle', '--');
            legend('Modèle', 'Données de références')
        end
    end
end

