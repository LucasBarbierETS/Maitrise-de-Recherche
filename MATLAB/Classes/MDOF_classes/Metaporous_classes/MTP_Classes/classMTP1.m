classdef classMTP1 < classMTP

% References

%           [1] Stinson & Champoux, Propagation of sound and the assignment of 
%               shape factors in model porous materials having simple pore geometries
%               http://asa.scitation.org/doi/10.1121/1.402530
%
%           [2] Hybrid composite meta-porous structure for improving and broadening sound absorption
%               N. Gao, J. Wu, K. Lu and H. Zhong
%               DOI: 10.1016/J.YMSSP.2020.107504   

    methods    
    
        function obj = classMTP1(config)
       
            % On appelle le superconstructueur. 'obj' hérite des propriétés .ListOfSubelements et .EndStatus
            obj@classMTP(config);

            % Dans cette méthode, on calcule le volume associé à la cellule plaque-cavité ainsi que le volume relatif de la plaque
            % pour modifier la compressibilité du milieu.

            % 1ère couche
            obj.Configuration.ListOfSubelements{end + 1} = config.PorousMaterial(config.LayersThickness(1));
            
            % On crée une fonction temporaire qui permet d'appeler et modifier la méthode .equivalentparameters des couches de plaque
            function  ep = modifiedequivalentparameters(obj, nui, env)
            
                ep = obj.equivalent_parameters(env);
                ep.Zeq = ep.Zeq / nui; % [2] eq.19
            end

            % On parcourt les plaques successives
            for i = 1:length(config.PlatesLength)

                % volume (2D) de la i-ème plaque
                plate_volume = config.PlatesLength(i) * config.LayersThickness(2*i);
                % épaisseur de la i-ème cellule plaque + cavité
                cell_thickness = sum(config.LayersThickness(2*i: 2*i + 1));
                % volume de la i-ème cellule plaque + cavité
                cell_volume = cell_thickness * config.MTPWidth;
                % volume relatif de la i-ème plaque 
                plate_relative_volume = plate_volume / cell_volume;

                % On crée une couche de matériau poreux de l'épaisseur de la couche courante
                porous_layer = config.PorousMaterial(cell_thickness);
                
                % On redéfinit manuellement les paramètres équivalents de la couche pour qu'ils soient utilisés dans la méthode transfermatrix
                nui = 1 - plate_relative_volume;
                porous_layer.EquivalentParameters = @(obj, env) modifiedequivalentparameters(obj, nui, env);
                obj.Configuration.ListOfSubelements{end + 1} = porous_layer;
            end
        end

        % Définition de la configuration à partir de la géomètrie concrète

        MTP_width, plates_thickness, added_length, left_spacing, right_spacing, ... 
                 first_left_plate_length, first_right_plate_length, nb_plates, input_section

        function config = create_explicit_config(number_of_plates, cavities_depth, cavities_width, slits_width, ...
            plates_holes_radius, plates_width_holes_distance, ...
            plates_depth_holes_number, plates_width_holes_number, ...
            plates_thickness, cavities_thickness) 

            config = {};
            config.NumberOfPlates = number_of_plates;
            config.EndStatus = 'closed';

            % Paramètres globaux
            config.CavitiesDepth = cavities_depth;
            config.CavitiesWidth = cavities_width;
            config.InputSection = cavities_width*cavities_depth;

            % Paramètres variables en fonction des cellules
            config.PlatesThickness = perso_interp_config(plates_thickness, number_of_plates);
            config.CavitiesThickness = perso_interp_config(cavities_thickness, number_of_plates);
            config.PlatesHolesRadius = perso_interp_config(plates_holes_radius, number_of_plates); % r
            config.PlatesDepthHolesNumber = perso_interp_config(plates_depth_holes_number, number_of_plates); % m
            config.PlatesWidthHolesNumber = perso_interp_config(plates_width_holes_number, number_of_plates); % n
            config.PlatesWidthHolesDistance = perso_interp_config(plates_width_holes_distance, number_of_plates); % d

            % Définition de la largeur de la fente en fonction du nombre de perforations en largeur et du rayon de perforation
            config.SlitsWidth = perso_interp_config({plates_width_holes_distance{:} .* plates_width_holes_number{:}}, number_of_plates+1);
            
            % Définition de la porosité à partir de la répartition des perforations
            plates_holes_number = plates_depth_holes_number{:} .* plates_width_holes_number{:};
            plates_perforated_surface = pi*plates_holes_radius{:}.^2 .* plates_holes_number;
            config.PlatesPerforatedPartPorosity = plates_perforated_surface ./ (slits_width{:} * cavities_depth);
            config.PlatesRealPorosity = plates_perforated_surface / (cavities_width * cavities_depth);
        end
    end
end