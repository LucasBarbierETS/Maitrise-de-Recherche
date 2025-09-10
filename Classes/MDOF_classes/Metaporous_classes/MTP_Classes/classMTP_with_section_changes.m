classdef classMTP_with_section_changes < classMTP

%% References

%           [1] Stinson & Champoux, Propagation of sound and the assignment of 
%               shape factors in model porous materials having simple pore geometries
%               http://asa.scitation.org/doi/10.1121/1.402530

%           [2] Hybrid composite meta-porous structure for improving and broadening sound absorption
%               N. Gao, J. Wu, K. Lu and H. Zhong
%               DOI: 10.1016/J.YMSSP.2020.107504   

%% Description 

% Dans cette méthode, on tient compte des cavités en considérant chaque changement de couche comme un changement de section
% La couche courante est considérée comme la partie ouverte (air) 

     methods    

         function obj = classMTP_with_section_changes(config)
            
            % On appelle le superconstructueur. 'obj' hérite des propriétés .ListOfSubelements et .EndStatus
            obj@classMTP(config);
            
            obj.Configuration = config; 
            
            % Dans cette méthode on implémente indépendement les couches cavités et plaques en considérant un ratio de 
            % largeur dans la correction de la compressobilité pour les couches de plaques

            % 1ère couche
            obj.ListOfSubelements{end + 1} = config.PorousMaterial(config.LayersThickness(1));

            % On parcourt les plaques successives
            for i = 1:length(config.PlatesLength)

                % On crée un changement de section de la couche prédente (poreux i-1) à la couche courante (plaque i)
                obj.ListOfSubelements{end + 1} = classsectionchange(config.Width, config.Width - config.PlatesLength(i));

                % On crée une couche de poreux de l'épaisseur de la plaque courante
                obj.ListOfSubelements{end + 1} = config.PorousMaterial(config.LayersThickness(2*i));

                % On crée un changement de section de la couche courante (plaque i) à la couche suivante (poreux i)
                obj.ListOfSubelements{end + 1} = classsectionchange(config.Width - config.PlatesLength(i), config.Width);

                % On crée une couche de poreux de l'épaisseur de la couche poreux courante
                obj.ListOfSubelements{end + 1} = config.PorousMaterial(config.LayersThickness(2*i + 1));

            end
        end
    end
end

