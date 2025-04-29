classdef classMTP < classelement

%% References

% [1] Hybrid composite meta-porous structure for improving and broadening sound absorption
% N. Gao, J. Wu, K. Lu and H. Zhong
% DOI: 10.1016/J.YMSSP.2020.107504

    % |                         |  
    % |                         |  --> m (épaisseur)
    % |                         | 
    % |+----------+             | 
    % || Plaque 1 |             |  --> a1 (longueur), l (épaisseur)
    % |+----------+             |  
    % |                         |  
    % |         Cavité          |  --> n - (m + l) (épaisseur)
    % |                         |  
    % |            +-----------+|  
    % |            | Plaque 2  ||  --> b1 (longueur), l (épaisseur)
    % |            +-----------+|  
    % |                         |  
    % |         Cavité          |  --> 2*m - n (épaisseur)
    % |                         |  
    % |+-------------+          | 
    % || Plaque 3    |          |  --> a1 + d (longueur), l (épaisseur)
    % |+-------------+          |  
    % |                         |  
    % |         Cavité          |  --> n - (m + l) (épaisseur)
    % |                         |  
    % |         +--------------+|  
    % |         |    Plaque 4  ||  --> b1 + d (longueur), l (épaisseur)
    % |         +--------------+|  
    % |                         |  
    % +- - - - - - - - - - - - -+  --> etc.


% Pour plus de précisions, décommenter (CTRL + T) et lancer (F9) les lignes de code suivantes: 
% imageData = imread('schéma metaporous.PNG');
% figure;
% imshow(imageData);

    properties

        % Configuration (Héritée)
        %              .MTPWidth
        %              .PlateThickness 
        %              .AddedLength 
        %              .LeftSpacing
        %              .RightSpacing
        %              .FirstLeftPlateLength
        %              .FirstRightPlateLength
        %              .PlatesLength
        %              .LayersThickness
        %              .PorousMaterial
    end 
    
    methods    

        function obj = classMTP(config)
            
            obj@classelement(config);
        end 

        function obj = launch_comsol_model(obj, env)

            model = ModelMTP(obj.Configuration, env.w);
            obj.Configuration.ComsolModel = model;
        end     
    end

    methods (Static, Access = public)
           
        function config = create_config(MTP_width, plates_thickness, added_length, left_spacing, right_spacing, ... 
                 first_left_plate_length, first_right_plate_length, nb_plates, input_section)

            % On crée la configuration d'appel et on renomme les variables
            config = struct();
            config.ListOfSubelements = {};
            config.EndStatus = 'closed';
            config.InputSection = input_section;
            
            config.MTPWidth = MTP_width;
            config.PlateThickness = plates_thickness; l = config.PlateThickness;
            config.AddedLength = added_length; d = added_length;
            config.LeftSpacing = left_spacing; m = left_spacing;
            config.RightSpacing = right_spacing; n = right_spacing;
            config.FirstLeftPlateLength = first_left_plate_length; a1 = first_left_plate_length;
            config.FirstRightPlateLength = first_right_plate_length; b1 = first_right_plate_length;
            config.NbPlates = nb_plates;
            
        
            % On créer les vecteurs d'épaisseur et de largeur de plaques associés au matériau multicouche
            % Le matériau multicouche est composé de couches lp (left w plate), l (left w/ plate), rp (right w plate) et r (right w/ plate)
            
            plates_length = zeros(1, nb_plates);
            layers_thickness = zeros(1, nb_plates*2 + 1); 
            
            % Première couche
            layers_thickness(1)  = m;
            
            for i = 1: nb_plates/2
                % On ajoute les épaisseurs pour les couches lp_i, l_i, rp_i, et r_i
                layers_thickness(4 * (i-1) + 2: 4*i + 1) = [l, n - (m+l), l, 2*m - n]; % indices successifs : (2: 5), (6: 9), (10, 13), ...

                % On ajoute les longueurs de plaque pour les couches lp_i et rp_i
                plates_length(2 * (i-1) + 1: 2*i) = [a1 + (i-1) * d, b1 + (i-1) * d]; % indices successifs : (1, 2), (3, 4), ...

            end

            config.PlatesLength = plates_length;
            config.LayersThickness = layers_thickness;
            config.Thickness = sum(config.LayersThickness);
         end
       
        function config = define_porous_media(config, porosity, tortuosity, resistivity, viscous_caracteristic_length, ...
                thermal_caracteristic_length, input_section)

            % On crée une fonction d'appel pour créer une couche de matériau poreux (fluide équivalent)
            config.PorousMaterial = @(thickness) classJCA_Rigid(classJCA_Rigid.create_config(porosity, tortuosity, resistivity, ...
            viscous_caracteristic_length, thermal_caracteristic_length, thickness, input_section));
         end
     end
end

