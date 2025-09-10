classdef classQWL_Inlet < classJCA_Rigid

    % Référence:
    % perso_ouvrir_lien_Zotero('zotero://open-pdf/library/items/5REQJFAQ?page=4&annotation=YYS89E82');
   
    methods
        function obj = classQWL_Inlet(config)
            
            l = config.Length;
            s = config.Surface;
            rh = config.HydraulicRadius;
            
            Rs = @(env) 2*sqrt(2 * env.air.parameters.eta * env.w' * env.air.parameters.rho);
            resistivity = @(env) (2*l/rh+1)*4*Rs(env)/l;

            % Appeler le constructeur de la classe parent
            obj@classJCA_Rigid(classJCA_Rigid.create_config(s, l, 1, 1, resistivity, rh, rh));
    
            % On tranfert les paramètres de la configuration d'appel vers
            % la configuration de classe
            obj.Configuration = perso_transfer_fields(config, obj.Configuration);
        end
    end

    methods (Static, Access = public)

        function validate()

            %% Validation classQWL_Inlet - Coefficient d''absorption

            perso_figure('Validation classQWL_Inlet - Coefficient d''absorption')
            
            % Réference : 
            % perso_ouvrir_lien_Zotero('zotero://open-pdf/library/items/5REQJFAQ?page=8&annotation=XUWNKZ4E');
            
            D = 45e-3; % diamètre de la cellule élémentaire (unit cell)
            A_uc = pi*(D/2)^2; % Surface de la cellule élementaire
            l1 = 40e-3; % longueur de la cavité quart d'onde 1
            l_inlet = 1.7e-3; % longueur de l'embouchure
            d1 = 10e-3; % longueur du côté de la cavité (base carrée)
            A1 = d1^2; % surface de la cavité quart d'onde 1

            % création de l'environnement
            env = create_environnement(23, 100800, 22, 1, 5000, 200, 100);

            % création de l'objet de classe
            Inlet = classQWL_Inlet(classQWL_Square.create_config(l_inlet, d1));
            Cavity_inlet = classQWL_Square(classQWL_Square.create_config(l1, d1));

            Cavity = classQWL_Square(classQWL_Square.create_config(l1 + l_inlet, d1));

            % % Debog : Résistivité de l'embouchure et de la cavité
            % perso_figure('classQWL_Inlet - validate - Résistivité de l''embouchure et de la cavité');
            % hold on
            % plot(env.w/(2*pi), Inlet.Configuration.AirFlowResistivity(env));
            % yline(Cavity_inlet.Configuration.AirFlowResistivity(env));
            % close();

            E_inlet = classelement(classelement.create_config({Inlet, Cavity_inlet}, 'closed', A_uc));
            E = classelement(classelement.create_config({Cavity}, 'closed', A_uc));
            alpha_model_inlet = E_inlet.alpha(env);
            alpha_model = E.alpha(env);

            % Debog : Impédance de surface
            perso_figure('classQWL_Inlet - validate - Impédance de surface');
            hold on
            perso_plot_surface_impedance(E_inlet.surface_impedance(env), env, 'Modèle Analytique avec embouchure');
            perso_plot_surface_impedance(E.surface_impedance(env), env, 'Modèle Analytique sans embouchure');
            % close();

            % affichage des résultats
            hold on 
            plot(env.w / (2*pi), alpha_model_inlet, 'Color', 'b', 'LineWidth', 1, 'DisplayName', 'Modèle Analytique avec embouchure');
            plot(env.w / (2*pi), alpha_model, 'Color', 'g', 'LineWidth', 1, 'DisplayName', 'Modèle Analytique sans embouchure');
            % plot(x_data, y_data, 'Color', 'g','LineWidth', 1, 'LineStyle', '--', 'DisplayName', 'Données de références');
            legend()
            xlabel("Fréquence (Hz)")
            ylabel("Coefficient d'Absorption")
            ylim([0 1])
            % xlim([0 2000])
        end
    end
end

