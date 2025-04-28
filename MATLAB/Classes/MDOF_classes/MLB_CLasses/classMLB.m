classdef classMLB < classelement

%% References

% [1] Design and performance of ultra-broadband composite meta-absorber in the 200Hz-20kHz range, Nansha Gao
% DOI : 10.1016/j.jsv.2023.118229

    properties

         % Configuration (Héritée)
         %              .Width
         %              .PlateThickness 
         %              .AddedLength 
         %              .LeftSpacing
         %              .RightSpacing
         %              .FirstLeftPlateLength
         %              .FirstRightPlateLength
         %              .PlatesLength
         %              .LayersThickness
         %
         %              .PorousMaterial
    end 
    
    methods    

        function obj = classMLB(config)
            
            % On appelle le supeconstructueur. obj hérite des propriétés .ListOfSubelements et .EndStatus
            obj@classelement({}, 'closed');
            
            if nargin > 0
                obj.Configuration = config;    
            end  
         end 
    end

    methods (Static, Access = public)
           
        function config = create_config(length, plates_thickness, added_length, spacing, ... 
                 first_plate_length, number_of_plates, cavity_thickness)

            % On crée la configuration d'appel et on renomme les variables
            config = struct();
            config.Length = length; W = length;
            config.PlatesThickness = plates_thickness; l = config.PlatesThickness;
            config.LayersThickness = layers_thickness; H = layers_thickness;
            config.AddedLength = added_length; d = added_length;
            config.FirstPlateLength = first_plate_length; L = first_plate_length;
            config.NumberOfPlates = number_of_plates; N = number_of_plates;
            config.BackingCavityThickness = cavity_thickness; Ha = cavity_thickness; 
        
            % On créer les vecteurs d'épaisseur et de largeur de plaques associés au matériau multicouche
            % Le matériau multicouche est composé de couches lp (left w plate), l (left w/ plate), rp (right w plate) et r (right w/ plate)
            
            plates_length = zeros(1, N);
            layers_thickness = repmat(H, 1, N); 
            
            % première couche
            
            for i = 1: nb_plates/2
                % On ajoute les épaisseurs pour les couches lp_i, l_i, rp_i, et r_i
                layers_thickness(4 * (i-1) + 2: 4*i + 1) = [l, n - (m+l), l, 2*m - n]; % indices successifs : (2: 5), (6: 9), (10, 13), ...

                % On ajoute les longueurs de plaque pour les couches lp_i et rp_i
                plates_length(2 * (i-1) + 1: 2*i) = [L + (i-1) * d, b1 + (i-1) * d]; % indices successifs : (1, 2), (3, 4), ...

            end

            config.PlatesLength = plates_length;
            config.LayersThickness = layers_thickness;

            % Par défault on considère que le milieu est de l'air. On crée une fonction d'appel permettant de créer une cavité d'air
            config.PorousMaterial = @(thickness) classcavity(thickness);

         end

         
        function config = define_porous_media(config, porosity, tortuosity, resistivity, viscous_caracteristic_length, thermal_caracteristic_length)

            % On crée une fonction d'appel pour créer une couche de matériau poreux (fluide équivalent)
            config.PorousMaterial = @(thickness) classJCA_Rigid(classJCA_Rigid.create_config(porosity, tortuosity, resistivity, ...
            viscous_caracteristic_length, thermal_caracteristic_length, thickness));
         
         end
     
        function plan()
        % Cette fonction permet de visualiser la solution MLB
            imageData = imread('schéma MLB.PNG');
            figure;
            imshow(imageData);

        end
    end
end


