classdef classHelmholtz_Resonator < classelement

%% Références

% [1] K. Mahesh, R.S. Mini, Investigation on the Acoustic Performance of Multiple Helmholtz Resonator Configurations
% Lien Zotero : perso_ouvrir_lien_Zotero('zotero://open-pdf/library/items/UF5M6PI2')
    
    methods
        function obj = classHelmholtz_Resonator(config)

            % Appel du constructeur de la classe parente
            obj@classelement(classelement.create_config({}, 'opened', 0));

            % On transfert les champs de la structure d'appel vers ceux de la structure de classe
            obj.Configuration = perso_transfer_fields(config, obj.Configuration);

            nr = config.NeckRadius;
            nl = config.NeckLength;
            ns = config.Section;
            cr = config.CavityRadius;
            cl = config.CavityLength;
            cs = config.Surface;

            % On ajoute le col du résonateur
            phi = ns/cs;
            
            obj.Configuration.ListOfObjects{end+1} = classMPP_Circular(classMPP_Circular.create_config(cs, nl, nr, phi));
            obj.Configuration.ListOfObjects{end+1} = classcavity(classcavity_cylindrical.create_config(cl, cr));


        end    
    
        function output_model = set_COMSOL_2D_Model(obj, input_model, index, env)
            output_model = Model_HR_2D(obj.Configuration, input_model, index, env);
        end
        
        function output_model = set_COMSOL_3D_Model(obj, input_model, index, env)
            output_model = Model_HR_3D(obj.Configuration, input_model, index, env);
        end
    end


    methods (Static, Access = public)

        function config = create_config(neck_radius, neck_length, cavity_radius, cavity_length)


            [config.NeckRadius, nr] = deal(neck_radius);
            config.NeckLength = neck_length;
            [config.CavityRadius, cr] = deal(cavity_radius);
            config.CavityLength = cavity_length;
            config.Section = pi * nr^2;
            config.Surface = pi * cr^2;
        end

        function validate()

            %% Coefficient d'absorption

            perso_figure('Validation classHelmholtz_Resonator - Coefficient d''absorption')
            hold on
            
            % Données de référence : [1], fig. 4, p. 10
            
            % Paramètres de la configuration
            nr = 1.5e-3;
            nl = 8e-3;
            cl = 12e-3;
            cr = 25e-3;
            
            % création de l'environnement
            env = create_environnement(23, 100800, 22, 1, 1000, 1000);

            alpha_model = classHelmholtz_Resonator(classHelmholtz_Resonator.create_config(nr, nl, cr, cl)).alpha(env);

            % importation des données de références
            data = csvread('Mahesh, fig.4, p.6, blue.txt');
            [x_data, y_data] = perso_interpole_et_lisse(data(:, 1), data(:, 2), 1000, 0.05);
            
            % affichage des résultats
            plot(env.w / (2*pi), alpha_model, 'Color', 'b', 'LineWidth', 1, 'DisplayName', 'Modèle');
            plot(x_data, y_data, 'Color', 'g','LineWidth', 1, 'LineStyle', '--', 'DisplayName', 'Données de références');
            perso_configure_alpha_figure(1000);
        end
    end
end

