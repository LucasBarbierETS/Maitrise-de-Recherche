classdef classmultiQWL < classelementassembly
    
    properties
        Configuration 

        % propriétés héritées de classelementassembly

        % ListOfElements 
        % ListOfSurfaceRatios
    
    end
    
    methods

        function obj = classmultiQWL(config)

            % 'config' est une structure (struct) qui contient :
            %                - les rayons des cavités quart d'onde (config.Radius)
            %                - les longueurs des résonateurs (config.Lengths)
            %                - la forme des sections des résonateurs (config.Shapes)

            % Attributs des cavités
            d = config.Dimensions;
            l = config.Lengths;
            s = config.Shapes;
  
            list_of_surfaces = zeros(1, length(l));
            list_of_elements = cell(1, length(l));

            % Construction de la première cellule ouverte
            QWL = classQWL(l(1), s(1), d(:, 1)); 
            list_of_surfaces(1) = QWL.section();
            list_of_elements{1} = classelement({QWL}, 'opened');

            % Construction de toutes les autres cellules (fermées)
            for i = 2:length(d)
                QWL = classQWL(l(i), s(i), d(:, 1));
                list_of_surfaces(i) = QWL.section();
                list_of_elements{i} = classelement({QWL}, 'closed');
            end

            % Définition des ratios de surface d'entrée
            list_of_surface_ratios = list_of_surfaces/sum(list_of_surfaces);

            obj@classelementassembly(list_of_elements, list_of_surface_ratios);
            obj.Configuration = config;
           
        end
    end

    methods (Static, Access = public)

        function  config = read_free_square_config(free_config)
        % Cette méthode permet de créer une configuration à partir d'un vecteur structuré
        % Le vecteur doit prendre la forme [side_1, ..., side_n, length_1, ..., length_n]
        
        config = struct();

        % fprintf('\nConfiguration pour le constructeur de la classe multiQWL : %s\n', mat2str(free_config));

        half_size = floor(size(free_config, 2) / 2);
        config.Dimensions = free_config(1, 1:half_size);
        config.Lengths = free_config(1, half_size + 1:end);
        config.Shapes = repmat("square", 1, half_size);
        
        end 
    end
end
