classdef classMDOF < classelementassembly

    properties
        % propriétés héritées de classelementassembly

        % ListOfElements 
        % ListOfSurfaceRatios
    end
    
    methods
        function obj = classMDOF(config)

            % Ajout du chemin où se trouvent les classes nécessaires
            addpath 'C:\Users\Utilisateur\OneDrive - ETS\CRIAQ-REAR\Maitrise LB\Classes'
           
            % Attributs des cavités
            cd = config.cavities_dimensions;
            cl = config.cavities_length;
            cs = config.cavities_shape;

            % Calcul de la surface des plaques
            csurf = zeros(1, length(cl));
            for i = 1:length(cl)
                if cs(i) == "rectangle"
                    csurf(i) = cd(1) * cd(2); % longueur * largeur
                end
            end 
            
            list_of_surface_ratios = csurf / sum(csurf);

            % Attributs des plaques
            pd = cd; % plate dimensions
            pps = config.plates_perforations_shape;
            pp = config.plates_porosity;
            pt = config.plates_thickness;
            pcl = config.plates_correction_length;
            ppd = config.plates_perforations_dimensions;

            % Construction des sous-structures
            subconfigs = repmat(struct(), 1, length(cl));
            for i = 1:length(cl)
                subconfigs(i).cavity_dimensions = cd(:,i);
                subconfigs(i).cavity_length = cl(i);
                subconfigs(i).cavity_shape = cs(i);
                subconfigs(i).plate_dimensions = pd(:,i);
                subconfigs(i).plate_perforations_shape = pps(i);
                subconfigs(i).plate_porosity = pp(i);
                subconfigs(i).plate_thickness = pt(i);
                subconfigs(i).plate_correction_length = pcl(i);
                subconfigs(i).plate_perforations_dimensions = ppd(i);
            end 

            list_of_elements = cell(1, length(cl));

            % Construction de la première cellule ouverte
            SDOF = classSDOF(subconfigs(1), 'opened');
            list_of_elements{1} = SDOF;

            % Construction de toutes les autres cellules (fermées)
            for i = 2:length(cl)
                SDOF = classSDOF(subconfigs(i), 'closed');
                list_of_elements{i} = SDOF;
            end 
            
            % Appel du constructeur de la classe parent avec une liste vide
            obj@classelementassembly(list_of_elements, list_of_surface_ratios);

        end
    end
end
