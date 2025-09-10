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
      %            .JCAParameters.Porosity (ad. , 0 < phi < 1)
      %                          .AirFlowResistivity (Ns ./ m.^4)
      %                          .Tortuosity (adimensionnel, > 1)
      %                          .ViscousCararacteristicLength (m)
      %                          .ThermalCaracteristicLength (m)  
      %            .Thickness (m) 
      %            .InputSection (m^2)
      %            .OutputSection (m^2)

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

            JCA = obj.Configuration.JCAParameters;
            phi = JCA.Porosity;
            tor = JCA.Tortuosity;

            % On vérifie que la tortuosité à été évaluée lorsque elle a été définie
            if ~isnumeric(tor)
                tor = tor(env);
            end
            
            sig = JCA.AirFlowResistivity;

            % On vérifie que la resistivité à été évaluée lorsque elle a été définie 
            if ~isnumeric(sig)
                sig = sig(env);
            end



            vl = JCA.ViscousCaracteristicLength;
            tl = JCA.ThermalCaracteristicLength;
            
            %%%%%% Champoux-Allard model ([5] tableau p. 24) %%%%%%
            
            % densité effective (effets visqueux) 
            H = phi^2 * vl^2 * sig^2 / (4 * tor^2 * rho * eta); % fréquence caractéristique visqueuse
            G = sqrt(1 + 1j .* w./H); 
            ep.rhoeff = rho * tor .* (1 + (sig * phi .* G) ./ (1j  .*  w * rho * tor));

            % module d'incompressibilité (effets thermiques)
            Hp = 16 * eta / (Pr * tl^2 * rho); % fréquence caractéristique thermique ([5] tableau p. 24)
            Gp = sqrt(1 + 1j.* w./Hp);            
            ep.Keff = gam.* P./(gam - (gam-1)./(1 - 1j .* Hp .* Gp./(2 .* w) ));

            % Propriétés de la couche de fluide équivalent normalisée
            
            ep.rhoeq = ep.rhoeff ./ phi; % densité effective équivalente
            ep.rhoneq = ep.rhoeff ./ phi ./ rho; % densité effective équivalente normalisée
            ep.Keq = ep.Keff ./ phi; % module d'incompressibilité équivalent
            ep.Kneq = ep.Keff ./ phi ./ P; % module d'incompressibilité équivalement normalisé
            ep.ceq = sqrt(ep.Keq ./ ep.rhoeq); % célérité équivalente
            ep.Zeq = sqrt(ep.rhoeq .* ep.Keq); % impédance caractéristique équivalente
            ep.keq = w ./ ep.ceq; % nombre d'onde équivalent
        end 

        function TM = transfer_matrix(obj, env)
            
            % On gère les cas ou les paramètres équivalents ont été définis/ modifiées de l'extérieur (voir classMTP_with_slit_cavities par ex.)
            if isempty(obj.EquivalentParameters)
                ep = obj.equivalent_parameters(env);
            else 
                % ici une méthode différente de .equivalentparameters est encapsulée dans obj.EquivalentParameters
                ep = obj.EquivalentParameters(obj, env);
            end

            d = obj.Configuration.Thickness;
            S = obj.Configuration.InputSection;
            phi = obj.Configuration.JCAParameters.Porosity;
            kd = ep.keq * d;
            TM.T11 = cos(kd);
            TM.T12 = 1j * (ep.Zeq * phi) / S .* sin(kd);
            TM.T21 = 1j * S ./ (ep.Zeq * phi) .* sin(kd);
            TM.T22 = cos(kd);
        end   
    end

    methods (Static, Access = public)

        function config = create_config(porosity, tortuosity, air_flow_resistivity, ...
        viscous_caractersitic_length, thermal_caracteristic_length, thickness, input_section)
            
            % Cette méthode permet de créer une configuration d'appel pour le constructueur classJCA_Rigid
            config = struct();
            config.JCAParameters = struct();
            config.Thickness = NaN;
            config.InputSection = NaN;
            config.OutputSection = NaN;
            config.JCAParameters.Porosity = NaN;
            config.JCAParameters.Tortuosity = NaN;
            config.JCAParameters.AirFlowResistivity = NaN;
            config.JCAParameters.ViscousCaracteristicLength = NaN;
            config.JCAParameters.ThermalCaracteristicLength = NaN;
            
            % Si la méthode n'est pas appelée à vide
            if nargin > 0

                config.Thickness = thickness;
                config.InputSection = input_section;
                config.JCAParameters.Porosity = porosity;
                config.JCAParameters.Tortuosity = tortuosity;
                config.JCAParameters.AirFlowResistivity = air_flow_resistivity;
                config.JCAParameters.ViscousCaracteristicLength = viscous_caractersitic_length;
                config.JCAParameters.ThermalCaracteristicLength = thermal_caracteristic_length;
            end
        end
   
        function validate()

            close all
            figure()
 
            %% Poreux (Verdière2013)
            % Réference : Transfer matrix method applied to the parallel assembly 
            % of sound absorbing materials, fig 4.a, p. 5

            % Données : [1] Table 1, p.4

            s = 1; % section (arbitraire)
            phi = 0.958;
            tor = 1.94;
            sig = 11188;
            vl = 70e-6;
            tl = 209e-6;
            d = 50e-3;

            % création de l'environnement
            env = create_environnement(23, 100800, 22, 1, 3000, 200, 145);

            % création de l'objet de classe
            E = classJCA_Rigid(classJCA_Rigid.create_config(phi, tor, sig, vl, tl, d, s, s));
            alpha_model = E.alpha(env);

            % importation des données de références
            data = csvread('Verdière2013_fig4_E.txt');
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
            xlim([0 2000])
            subtitle("Validation JCA -  Verdière2013 - figure 4 - tracé E")
            
        end
    end
end
