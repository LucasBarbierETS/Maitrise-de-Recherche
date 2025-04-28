classdef classMPP_Maa 

%% Description

% Cette classe donne une formulation directe de l'impédance de surface
% d'un plaque microperforée donnée par la théorie de Maa. En supposant la
% plaque suffisemment fine, on peut ensuite retrouver la matrice de
% transfert de la plaque qui s'exprime comme une fonction de l'impédance de
% surface. 

    properties

        Configuration
    end

                 
%% Constructeur de classe

    methods

        function obj = classMPP_Maa(config)
            
            if nargin > 0
                obj.Configuration = config;
            end
        end
    
        function Zs = surface_impedance(obj, env)

            % Paramètres de l'air
            param = env.air.parameters;
            rho = param.rho; % densité
            eta = param.eta; % viscosité dynamique
            nu = eta/rho; % viscoisité cinématique

            % Paramètres de la plaque
            phi = obj.Configuration.PlatePorosity;
            d = obj.Configuration.PerforationsRadius*2;
            t = obj.Configuration.PlateThickness;
            K = d/2*sqrt(env.w/nu);
            
            %% Résistance de la plaque

            % Référence : perso_ouvrir_lien_Zotero('zotero://open-pdf/library/items/AH7QFLYS?page=3&annotation=WGL2L4WL')
            
            RMPP = (32 * rho * nu * t) / (phi * d^2) * (sqrt(1 + (K.^2) / 32) + (sqrt(2) * K / 8) * (d / t));

            %% Réactance de la plaque

            % Référence : perso_ouvrir_lien_Zotero('zotero://open-pdf/library/items/AH7QFLYS?page=3&annotation=7AIN4ANH')
            MMPP = (rho * t) / phi * (1 + 1 ./ sqrt(9 + (K.^2) / 2) + 0.85 * (d / t));

            %% Impédance de surface de la plaque
            Zs = RMPP + 1j*env.w .* MMPP;
        end

        function TM = transfer_matrix(obj, env)

            % La matrice est formulée en convention Pression - Débit 
            % Référence : perso_ouvrir_lien_Zotero('zotero://open-pdf/library/items/AH7QFLYS?page=4&annotation=URKF239P')

            S = obj.Configuration.PlateSection;

            TM.T11 = ones(1, length(env.w));
            TM.T12 = obj.surface_impedance(env)/S;
            TM.T21 = zeros(1, length(env.w));
            TM.T22 = ones(1, length(env.w));
        end
    end

    
    methods (Static, Access = public)

        function config = create_config(plate_porosity, perforations_radius, plate_thickness, plate_section)
            
            config = struct();
            config.PlatePorosity = plate_porosity;
            config.PerforationsRadius = perforations_radius;
            config.PlateThickness = plate_thickness;
            config.PlateSection = plate_section;
        end   
    end
end