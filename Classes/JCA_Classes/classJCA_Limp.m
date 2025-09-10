classdef classJCA_Limp
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Reference :  [1]  Dupont, T., et al. « Acoustic Properties of Air-Saturated 
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


%%%%%%%%%%%%%%%%%%%%%%%%% PUBLIC PROPERTIES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                          INPUT PARAMETERS
% - Porosity   :   porosity
% - AirflowResistivity   :   air flow resistivity (Ns ./ m.^4)
% - Tortuosity   :   tortuosity
% - ViscousCharacteristicLength    :   viscous characteristic length (m)
% - ThermalCharacteristicLength    :   thermal characteristic length (m)
% - Thickness     :   thickness (m)
% - Frame : "rigid" by default or "limp"
% - MaterialDensity : Density of the porous material (compulsory if obj.Frame = "limp")
%
%%%%%%%%%%%%%%%%%%%%%%%%%%% PUBLIC METHODS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                          OUTPUT PARAMETERS
% - obj.transferMatrix(Air, w) : coefficients of the equivalent fluid's transfer matrix
%                                 obj.transfermatrix(Air, w).Tij (where (i,j)∈{1,2}²)
% - obj.surfaceImpedance(Air, w)              : surface impedence of the equivalent fluid
    
    properties

      Configuration

      % Porosity
      % AirflowResistivity
      % Tortuosity
      % ViscousCharacteristicLength
      % ThermalCharacteristicLength
      % Thickness
      % Frame = "rigid";
      % MaterialDensity % different from air density2
    end
    
    methods
        function obj = classJCA_Limp(frame, porosity, resistivity, tortuosity, viscous_length, thermal_length, thickness, material_density)


        % phi   : porosity [0 1]
        % sig   : air flow resistivity (Ns ./ m.^4)
        % tor   : tortuosity
        % vl    : viscous characteristic length (m)
        % tl    : thermal characteristic length (m)
        % d     : thickness of the material (m)
        % frame : "rigid" (by default) or "limp"
        % rho1  : density of the material (kg/m3) (compulsory if frame = "limp")

            

            obj.Configuration = config;

            porosity = obj.Configuration.Porosity;
            resistivity = obj.Configuration.Resistivity;
            tortuosity = obj.Configuration.Tortuosity;
            viscous_length = obj.Configuration.CaracteristicViscousLength;
            thermal_length  = obj.Configuration.CaracteristicThermalLength;
            thickness = obj.Configuration.SampleThickness;

            

            obj.Tortuosity = tortuosity;
            obj.ViscousCharacteristicLength = viscous_length;
            obj.ThermalCharacteristicLength = thermal_length;
            obj.Thickness = thickness;
            obj.Frame = frame;

            if nargin > 7
                    obj.MaterialDensity = material_density;
            end
        end
    end
    methods
        function ep = equivalent_parameters(obj, air, w)
            
            param = air.parameters; 
            gam = param.gamma;
            P = air.StaticPressure;
            Pr = param.Pr; % Nombre de Prandt
            eta = param.eta; % viscosité de l'air
            rho = param.rho; % densité de l'air
            phi = obj.Configuration.Porosity; % so [0 1]
            tl = obj.Configuration.ThermalCharacteristicLength;
            tor = obj.Configuration.Tortuosity;
            sig = obj.Configuration.AirflowResistivity;
            vl = obj.Configuration.ViscousCharacteristicLength;
    
            
     %%%%%% Champoux-Allard model ([5] tableau p. 24) %%%%%%
            
            % densité effective (effets visqueux) 
            H = phi^2 * vl^2 * sig^2/(4 * tor^2 * rho * eta); % fréquence caractéristique visqueuse
            G = sqrt(1 + 1j .* w ./ H); 
            ep.rhoeff = rho * tor .* (1 + (sig * phi .* G) ./ (1j  .*  w * rho * tor));

            % module d'incompressibilité (effets thermiques)
            Hp = 16*eta/(Pr*tl^2*rho); % fréquence caractéristique thermique ([5] tableau p. 24)
            Gp = sqrt(1 + 1j.* w ./ Hp);            
            ep.Keff = gam.* P ./ (gam - (gam-1) ./ (1 - 1j.*Hp.*Gp ./ (2.*w) ));
        

            % Case if the frame is considered as limp instead of rigid

            if strcmp(obj.Configuration.Frame, 'limp')
                    rhos = obj.Configuration.MaterialDensity + phi .* rho .* (s1-rho ./ ep.rhoeq);
                    gamma = phi .* rho ./ ep.rhoeq-1;
                    ep.rhoeq = 1 ./ (1 ./ ep.rhoeq + gamma.^2 ./ phi ./ rhos);
            end

            % Propriétés de la couche de fluide équivalent normalisée
            
            
            ep.rhoeq = ep.rhoeff ./ phi; % densité effective équivalente
            ep.rhoneq = ep.rhoeff ./ phi ./ rho; % densité effective équivalente normalisée
            ep.Keq = ep.Keff ./ phi; % module d'incompressibilité équivalent
            ep.Kneq = ep.Keff ./ phi ./ P; % module d'incompressibilité équivalement normalisé
            ep.ceq = sqrt(ep.Keq ./ ep.rhoeq); % célérité 
            ep.Zeq = sqrt(ep.rhoeq .* ep.Keq); % impédance caractéristique équivalente
            ep.keq = w ./ ep.ceq; % nombre d'onde 
        end 

        function TM = transfermatrix(obj, air, w)
            ep = obj.equivalent_parameters(air,w);
            d = obj.Configuration.Thickness;
            phi = obj.Configuration.Porosity;
            kd = ep.keq*d;
            TM.T11 = cos(kd);
            TM.T12 = 1j*(ep.Zeq*phi) .* sin(kd);
            TM.T21 = 1j ./ (ep.Zeq*phi) .* sin(kd);
            TM.T22 = cos(kd);
        end


        function Zs = surfaceimpedance(obj, Air, w)
            TM = obj.transfermatrix(Air, w);
            Zs = TM.T11 ./ TM.T21; % rigid wall
        end

        function alpha = alpha(obj, Air, w) % retourne le vecteur coefficient d'absorption
            Zs = obj.surfaceimpedance(Air, w);
            phi = obj.Configuration.Porosity;
            param = Air.parameters;
            Z0 = param.rho * param.c0;
            alpha = 1 - abs((Zs/phi-Z0) ./ (Zs/phi + Z0)).^2;
        end

        function fpeak = alpha_peak(obj, Air, w) % retourne la frequence et l'amplitude du pic d'absorption
            a = obj.alpha(Air, w);
            maxFunction = @max;
            m = a == maxFunction(a);
            fpeak = w(m)/(2 * pi);

        end 
    end
end
