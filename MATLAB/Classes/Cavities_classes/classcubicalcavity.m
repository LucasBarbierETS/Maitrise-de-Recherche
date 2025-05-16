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
                    
            % Calcul du volume de la cavité :
            Vcav = ct * cd * (cw - mpw); % Différence des volumes de deux cubes
            % Si on considère que la surface ou s'applique l'admittance
            % voit a chaque fois la moitié du volume seulement, il faut
            % alors divise ce volume par 2.
             % Vcav = ct * cd * (cw - mpw)/2

            k = w/c0;
            Z0 = rho * c0; 

            % Référence : perso_ouvrir_lien_Zotero('zotero://open-pdf/library/items/AH7QFLYS?page=4&annotation=34H3J6W6')
            
            % Explications : 
            % Dans l'article, l'admittance est formulée telle qu'elle est utilisée dans la matrice de transfert 
            % de la jonction en convention pression - débit. Comme la convention adoptée est de fournir les impédances 
            % de surface en convention pression - vitesse, il faut diviser ici l'admittance par Ca puisqu'elle sera 
            % multipliée par la suite par la même valeur dans la classe jonction
            
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




