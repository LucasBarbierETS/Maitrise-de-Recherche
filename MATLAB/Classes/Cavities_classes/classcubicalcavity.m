classdef classcubicalcavity < classsubelement

    methods

        function obj = classcubicalcavity(config)

            obj@classsubelement(config);
        end
        
        function Zsde = surface_impedance(obj, env)

            config = obj.Configuration;
            w = env.w;
            air = env.air;
            rho = air.parameters.rho;
            c0 = air.parameters.c0;
         
            mpw = config.MainPoreWidth;
            cw  = config.CavityWidth;
            cd = config.CavityDepth;
            ct = config.CavityThickness;
            Ca = config.CurtainArea;
                    
            % Calcul du volume de la cavité
            Vcav = ct * cd * (cw - mpw); % Différence des volumes de deux cubes
            
            k = w/c0;
            Z0 = rho * c0; 

            % Référence : perso_ouvrir_lien_Zotero('zotero://open-pdf/library/items/AH7QFLYS?page=4&annotation=34H3J6W6')
            
            % Si l'admittance est formulée selon la convention Pression - Vitesse
            Ycav = 1j * k/Z0 / Ca * Vcav;

            % % Si l'admittance est formulée selon la convention Pression - Débit
            % Ycav = 1j * k/Z0 * Vcav;   
        
            Zsde = 1 ./ Ycav;
        end
    end

    methods (Static, Access = public)

        function config = create_config(main_pore_width, cavity_width, cavity_depth, cavity_thickness)

            config = struct();
            config.MainPoreWidth = main_pore_width;
            config.CavityWidth = cavity_width;
            config.CavityDepth = cavity_depth;
            config.CavityThickness = cavity_thickness;
            config.CurtainArea = 2*cavity_thickness*cavity_depth;
        end

    end
end




