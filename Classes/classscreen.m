classdef classscreen
    
    properties
        Configuration
    end
    
    methods
        function obj = classscreen(config)
            obj.Configuration = config;
        end 
        
        function Zs = surface_impedance(obj, env)
            % Référence : perso_ouvrir_lien_Zotero('zotero://open-pdf/library/items/WJN4AENC?page=201&annotation=QSJ8GIKM');
            Zs = repmat(obj.Configuration.FlowResistivity*obj.Configuration.ScreenThickness, 1, length(env.w));
        end

        function TM = transfer_matrix(obj, env)
            % Référence : perso_ouvrir_lien_Zotero('zotero://open-pdf/library/items/CMZQ7B9B?page=179&annotation=DYDM3PP2');
            TM.T11 = ones(1, length(env.w));
            TM.T12 = obj.surface_impedance(env) / obj.Configuration.InputSection;
            TM.T21 = zeros(1, length(env.w));
            TM.T22 = ones(1, length(env.w));
        end
    end

    methods (Static, Access = public)
        
        function config = create_config(flow_resistivity, screen_thickness, input_section)

            config = struct();
            config.FlowResistivity = flow_resistivity;
            config.ScreenThickness = screen_thickness;
            config.InputSection = input_section;
        end

        function validate()
            % Référence : perso_ouvrir_lien_Zotero('zotero://open-pdf/library/items/CMZQ7B9B?page=181&annotation=9JC7HMXB');
            
            % close all
            figure()

            % création de l'environnement
            env = create_environnement(23, 100800, 22, 1, 3500, 200, 145);
            
            s = 1; % section (arbitraire)
            
            % Paramètres écranlaunch
            sig = 345; 
            st = 25e-5;
            screen = classscreen(classscreen.create_config(sig, st, s));
           
            % Paramètres cavité
            ct = 11e-3;
            cavity = classcavity(classcavity.create_config(ct, s));
         
            % Création de l'élement 
            alpha_model = classelement(classelement.create_config({screen, cavity}, 'closed', s)).alpha(env);

            % importation des données de références
            data = csvread('Laly2017, fig.6.3, blue.txt');
            [x_data, y_data] = interpole_et_lisse(data(:, 1), data(:, 2), 1000, 0.05);

            % affichage des résultats
            subplot(1, 1, 1)
            hold on 
            plot(env.w / (2*pi), alpha_model, 'Color', 'b', 'LineWidth', 1, 'DisplayName', 'Modèle JCA' );
            plot(x_data, y_data, 'Color', 'g','LineWidth', 1, 'LineStyle', '--', 'DisplayName', 'Données de références');
            legend()
            xlabel("Fréquence (Hz)")
            ylabel("Coefficient d'Absorption")
            ylim([0 1])
            % xlim([0 2000])
            subtitle("Validation JCA -  Verdière2013 - figure 4 - tracé E") 
        end
    end
end

