classdef classJCA_Rigid < classsubelement

% Reference 
%
%              [1]  Dupont, T., et al. « Acoustic Properties of Air-Saturated 
%                   Porous Materials Containing Dead-End Porosity ». Journal 
%                   of Applied Physics, vol. 110, no 9, novembre 2011, p. 094903. 
%                   DOI.org (Crossref), https://doi.org/10.1063/1.3646556.
% 
%              [2]  R. Panneton, "Comments on the limp frame equivalent fluid model 
%                   for porous media," J. Acoust. Soc. Am. 122(6), EL217-222 (2007).
%
%              [3]  Atalla, Sgard, Modeling of perforated plates and
%                   screens using rigid frame porous models
%
%              [4]   Atalla, Sgard, Propagation of sound in porous media, second edition
% 
%              [5]   Panneton Modélisation numérique tridimensionnelle par éléments finis 
%                    des milieux poroélastiques, 1996

% Description
%
% Ce constructeur de classe modélise le comportement acoustique d'une matrice poreuse rigide.
% En se basant sur les paramètres JCA (Johnson-Champoux-Allard), la classe détermine le modèle 
% de fluide équivalent associé


    properties

      % Configuration (héritée) 
      % Contenu : 
      %            .Porosity (ad. , 0 < phi < 1)
      %            .AirFlowResistivity (Ns ./ m.^4)
      %            .Tortuosity (adimensionnel, > 1)
      %            .ViscousCararacteristicLength (m)
      %            .ThermalCaracteristicLength (m)  
      %            .Thickness (m) 
      %            .InputSection (m^2)
      EquivalentParameters % (si défini, fhandle) (voir classMTP_with_slit_cavities par ex.)

    end

    methods (Access = public)

        function obj = classJCA_Rigid(config)

            % On appelle le superconstructeur à vide.
            obj@classsubelement(config)
        end

        function ep = equivalent_parameters(obj, env)

            w = env.w;
            air = env.air;
            param = air.parameters; 
            P = air.StaticPressure; % Pression Statique
            gam = param.gamma; % Indice Adiabatique de l'air
            Pr = param.Pr; % Nombre de Prandt de l'air
            eta = param.eta; % Viscosité de l'air
            rho = param.rho; % Densité de l'air

            config = obj.Configuration;
            phi = config.Porosity;
            tor = config.Tortuosity; 

            % On vérifie que la tortuosité à été évaluée lorsque elle a été définie
            if ~isnumeric(tor)
                tor = tor(env);
            end

            % % Debog : Tortuosité
            % perso_figure('Tortuosité dans classJCA_Rigid/equivalent_parameters')
            % % clf;
            % plot(env.w/(2*pi), tor); 

            sig = config.AirFlowResistivity; % proportionnel à 1/phi

            % On vérifie que la resistivité à été évaluée lorsque elle a été définie 
            if ~isnumeric(sig)
                sig = sig(env);
            end

            % % Debog : Résistivité
            % perso_figure('Résistivité dans classJCA_Rigid/equivalent_parameters')
            % clf;
            % plot(env.w/(2*pi), sig); 

            vl = config.ViscousCaracteristicLength;
            tl = config.ThermalCaracteristicLength;
            
            %%%%%% Champoux-Allard model ([5] tableau p. 24) %%%%%%
            
            % densité effective (effets visqueux) 
            try 
                H = phi^2 * vl^2 * sig.*conj(sig) ./ (4 * tor.*conj(tor) * rho .* eta); % fréquence caractéristique visqueuse
            catch
                sprintf('pause!');
            end

            G = sqrt(1 + 1j .* w./H); 
            ep.rhoeff = rho .* tor .* (1 + (sig .* phi .* G) ./ (1j  .*  w .* rho .* tor));

            % module d'incompressibilité (effets thermiques)
            Hp = 16 * eta / (Pr * tl^2 .* rho); % fréquence caractéristique thermique ([5] tableau p. 24)
            Gp = sqrt(1 + 1j.* w ./ Hp);            
            ep.Keff = gam.* P./(gam - (gam-1)./(1 - 1j .* Hp .* Gp./(2 .* w) ));

            % Propriétés de la couche de fluide équivalent normalisée
            
            % ep.rhoeq = ep.rhoeff ./ phi; % densité effective équivalente
            ep.rhoeq = ep.rhoeff; % densité effective équivalente

            % ep.rhoneq = ep.rhoeff ./ phi ./ rho; % densité effective équivalente normalisée
            ep.rhoneq = ep.rhoeff ./ rho; % densité effective équivalente normalisée

            % ep.Keq = ep.Keff ./ phi; % module d'incompressibilité équivalent
            ep.Keq = ep.Keff; % module d'incompressibilité équivalent

            % ep.Kneq = ep.Keff ./ phi ./ P; % module d'incompressibilité équivalement normalisé
            ep.Kneq = ep.Keff ./ P; % module d'incompressibilité équivalement normalisé

            ep.ceq = sqrt(ep.Keq ./ ep.rhoeq); % célérité équivalente
            ep.Zeq = sqrt(ep.rhoeq .* ep.Keq); % impédance caractéristique équivalente
            ep.keq = w ./ ep.ceq; % nombre d'onde équivalent
        end 

        function TM = transfer_matrix(obj, env, varargin)
            
            % On gère les cas ou les paramètres équivalents ont été définis/ modifiées de l'extérieur (voir classMTP_with_slit_cavities par ex.)
            if isempty(obj.EquivalentParameters)
                ep = obj.equivalent_parameters(env);
            else 
                % ici une méthode différente de .equivalentparameters est encapsulée dans obj.EquivalentParameters
                ep = obj.EquivalentParameters(obj, env);
            end

            d = obj.Configuration.Thickness;
            S = obj.Configuration.Section; 
            % phi = obj.Configuration.JCAParameters.Porosity;
            kd = ep.keq * d;
            TM.T11 = cos(kd);
            % TM.T12 = 1j * (ep.Zeq * phi) / S .* sin(kd);
            TM.T12 = 1j * ep.Zeq / S .* sin(kd);
            % TM.T21 = 1j * S ./ (ep.Zeq * phi) .* sin(kd);
            TM.T21 = 1j * S ./ ep.Zeq .* sin(kd);
            TM.T22 = cos(kd);

            % % Debog : Matrice de transfert inverse
            % perso_figure('nombre d''onde d''un sous-élement dans classJCA_Rigid/transfer_matrix')
            % clf;
            % sgtitle(class(obj))
            % plot(env.w/(2*pi), ep.keq) 

            % % Debog : Matrice de transfert inverse
            % perso_figure('Impédance caractéristique d''un sous-élement dans classJCA_Rigid/transfer_matrix')
            % clf;
            % sgtitle(class(obj))
            % plot(env.w/(2*pi), ep.Zeq) 

            % % Debog : Matrice de transfert inverse
            % perso_figure('TM d''un sous-élement dans classJCA_Rigid/transfer_matrix')
            % clf;
            % sgtitle(class(obj))
            % perso_plot_transfer_matrix(TM, env, 'TM'); 
        end   
    
        function output_model = set_COMSOL_2D_Model(obj, input_model, elem_index, sblm_index, env)
            output_model = ModelJCA(obj.Configuration, input_model, elem_index, sblm_index, env);
        end
    end

    methods (Static, Access = public)

        function config = create_config(section, thickness, porosity, tortuosity, air_flow_resistivity, ...
        viscous_caractersitic_length, thermal_caracteristic_length, options)

            arguments
                section
                thickness
                porosity
                tortuosity
                air_flow_resistivity
                viscous_caractersitic_length
                thermal_caracteristic_length
                options.Width = NaN
                options.Depth = NaN
            end

                config.Section = section;
                config.Surface = section;
                config.Thickness = thickness;
                config.Porosity = porosity;
                config.Tortuosity = tortuosity;
                config.AirFlowResistivity = air_flow_resistivity;
                config.ViscousCaracteristicLength = viscous_caractersitic_length;
                config.ThermalCaracteristicLength = thermal_caracteristic_length;
                config.Width = options.Width;
                config.Depth = options.Depth;
        end
   
        function validate()
            
            %% Poreux (Verdière2013)

            perso_figure('Validation classJCA_Rigid - Coefficient d''absorption')
            
            % Réference : Transfer matrix method applied to the parallel assembly 
            % of sound absorbing materials, fig 4.a, p. 5

            % Données : [1] Table 1, p.4

            s = 1; % section (arbitraire)
            w = 1;
            d = 1;
            phi = 0.958;
            tor = 1.94;
            sig = 11188;
            vl = 70e-6;
            tl = 209e-6;
            t = 50e-3;

            % création de l'environnement
            env = create_environnement(23, 100800, 22, 1, 2000, 200, 145);

            % création de l'objet de classe
            E = classJCA_Rigid(classJCA_Rigid.create_config(s, t, phi, tor, sig, vl, tl, w, d));
            alpha_model = E.alpha(env);

            % importation des données de références
            data = csvread('Verdière2013_fig4_E.txt');
            [x_data, y_data] = perso_interpole_et_lisse(data(:, 1), data(:, 2), 1000, 0.05);

            % JCAelement = classelement(classelement.create_config({E}, 'closed', s));
            % Tube_JCA = ImpedanceTube2D(ImpedanceTube2D.create_config({JCAelement}));
            % Tube_JCA = Tube_JCA.lauch_tube_measurement(env);
            % Tube_JCA.plot_alpha(env, 'Modèle numérique');

            % affichage des résultats
            hold on 
            plot(env.w / (2*pi), alpha_model, 'Color', 'b', 'LineWidth', 1, 'DisplayName', 'Modèle JCA' );
            plot(x_data, y_data, 'Color', 'g','LineWidth', 1, 'LineStyle', '--', 'DisplayName', 'Données de références');
            legend()
            xlabel("Fréquence (Hz)")
            ylabel("Coefficient d'Absorption")
            ylim([0 1])
            % xlim([0 2000])
            subtitle("Validation JCA -  Verdière2013 - figure 4 - tracé E")
 
            %% Validation classJCA_Rigid - TM sans écoulement
            perso_figure('Validation classJCA_Rigid - TM sans écoulement')
            % Figures de réference 
            % perso_ouvrir_lien_Zotero('zotero://open-pdf/library/items/CMZQ7B9B?page=257&annotation=DN9BHR8G')

            Lx = 50.8e-3;
            Lz = 254e-3;
            w = Lz; % longueur de la zone traité
            d = Lx; % tube carré (résultat indépendant de la profondeur)
            phi = 0.98;
            tor = 1.07;
            sig = 31255;
            vl = 135e-6;
            tl = 280e-6;
            t = 17.5e-3;

            % création de l'environnement
            env = create_environnement(23, 100800, 22, 1, 3000, 200, 100);

            % création de l'objet de classe
            E = classelement(classelement.create_config(...
                {classJCA_Rigid(classJCA_Rigid.create_config(w * d, t, phi, tor, sig, vl, tl, w, d))}, 'closed', w * d));

            TM_sb = E.side_branch_transfer_matrix(env, Lx);

            perso_plot_transfer_matrix(TM_sb, env, 'test', 3000);

            perso_figure('Validation classJCA_Rigid - TM sans écoulement')

            % % importation des données de références
            % data = csvread('Verdière2013_fig4_E.txt');
            % [x_data, y_data] = perso_interpole_et_lisse(data(:, 1), data(:, 2), 1000, 0.05);

            % JCAelement = classelement(classelement.create_config({E}, 'closed', s));
            % Tube_JCA = ImpedanceTube2D(ImpedanceTube2D.create_config({JCAelement}));
            % Tube_JCA = Tube_JCA.lauch_tube_measurement(env);
            % Tube_JCA.plot_alpha(env, 'Modèle numérique');

            % % affichage des résultats
            % subplot(1, 1, 1)
            % hold on 
            % plot(env.w / (2*pi), alpha_model, 'Color', 'b', 'LineWidth', 1, 'DisplayName', 'Modèle JCA' );
            % plot(x_data, y_data, 'Color', 'g','LineWidth', 1, 'LineStyle', '--', 'DisplayName', 'Données de références');
            % legend()
            % xlabel("Fréquence (Hz)")
            % ylabel("Coefficient d'Absorption")
            % ylim([0 1])
            % % xlim([0 2000])
            % subtitle("Validation JCA -  Verdière2013 - figure 4 - tracé E")
        end
    end
end
