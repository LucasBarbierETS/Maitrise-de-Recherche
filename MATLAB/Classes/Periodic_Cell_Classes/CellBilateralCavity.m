classdef CellBilateralCavity < classelement
    
    % Cette cellule comprend : 
    %   - un demi-pore principal (classQWL_Slit)
    %   - une jonction constituée de 2 cavités latérales de type fente quart d'onde (classjunction-rectangular)
    %   - un demi-pore principal (classQWL_Slit
    
    methods
        function obj = CellBilateralCavity(config)

            % Appel du constructeur de la classe parente
            obj@classelement(classelement.create_config({}, 'opened'));

            % On transfert les champs de la structure d'appel vers ceux de
            % a structure de classe
            perso_transfer_fields(config, obj.Configuration);

            ct = config.CavityThickness;
            cd = config.CavityDepth;
            cw = config.CavityWidth;
            ciw = config.CellInnerWidth;
            cow = config.CellOuterWidth;
            cmw = (ciw + cow) / 2; % Cell Mean width

            % Demi pore principal
            obj.Configuration.ListOfSubelements{end+1} = classQWL_Slit( ...
                classQWL_Slit.create_config(ct/2, ciw, cd*ciw));
    
            % % Jonction
            % QWLSlit = classQWL_Slit( ...
            %     classQWL_Slit.create_config((cw-cmw)/ 2, ct, 1)); % section d'entrée unitaire (arbitraire)
            % obj.Configuration.ListOfSubelements{end+1} = classjunction_rectangular( ...
            %     classjunction_rectangular.create_config(QWLSlit, cd, ct));

            % Demi pore principal
            obj.Configuration.ListOfSubelements{end+1} = classQWL_Slit( ...
                classQWL_Slit.create_config(ct/2, cmw, cd*cmw));
        end
        
    end
    methods (Static)

        function config = create_config(cavity_thickness, cavity_depth, cavity_width, ...
                cell_inner_width, cell_outer_width)

            config = struct();
            config.CavityThickness = cavity_thickness;
            config.CavityDepth = cavity_depth;
            config.CavityWidth = cavity_width;
            config.CellInnerWidth = cell_inner_width;
            config.CellOuterWidth = cell_outer_width;
        end
    end
end

