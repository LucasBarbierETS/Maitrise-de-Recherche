classdef CellSlit < classelement
    
    % Cette classe constitue une cellule périodique comprenant : 
    %   - une plaque microperforée (classMPP_Circular)
    %   - une cellule comprenant le pore principale et une cavité bilatérale (CellBilateralCavity)
    
    methods
        function obj = CellSlit(config)
            
            % Appel du constructeur de la classe parente
            obj@classelement(classelement.create_config({}, 'opened'));

            % On transfert les champs de la structure d'appel vers ceux de
            % a structure de classe
            perso_transfer_fields(config, obj.Configuration);

            % Paramètres de la fente
            st = config.SlitThickness;
            
            % Paramètres de la cellule
            ct = config.CavityThickness;
            cd = config.CavityDepth;
            cw = config.CavityWidth;
            ciw = config.CellInnerWidth;
            cow = config.CellOuterWidth;

            obj.Configuration.ListOfSubelements{end+1} = classQWL_Slit( ...
            classQWL_Slit.create_config(st, ciw, cd*ciw));

            obj.Configuration.ListOfSubelements{end+1} = CellBilateralCavity( ...
            CellBilateralCavity.create_config(ct, cd, cw, ciw, cow));
        end
    end

    methods (Static)

        function config = create_config(slit_thickness, ...
                cavity_thickness, cavity_depth, cavity_width, cell_inner_width, cell_outer_width)

            config = struct();

            % Paramètres de la fente
            config.SlitThickness = slit_thickness;
            config.CellInnerWidth = cell_inner_width;

            % Paramètres de la cellule
            config.CavityThickness = cavity_thickness;
            config.CavityDepth = cavity_depth;
            config.CavityWidth = cavity_width;
            config.CellOuterWidth = cell_outer_width;
        end
    end
end

