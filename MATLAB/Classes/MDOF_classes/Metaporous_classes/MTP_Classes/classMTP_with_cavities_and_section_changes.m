classdef classMTP_with_cavities_and_section_changes < classMTP

%% References

%           [1] Stinson & Champoux, Propagation of sound and the assignment of 
%               shape factors in model porous materials having simple pore geometries
%               http://asa.scitation.org/doi/10.1121/1.402530

%           [2] Hybrid composite meta-porous structure for improving and broadening sound absorption
%               N. Gao, J. Wu, K. Lu and H. Zhong
%               DOI: 10.1016/J.YMSSP.2020.107504   

%% Description 

% Dans cette méthode, on ajoute une 

     methods    

         function obj = classMTP_with_cavities_and_section_changes(config)
            
            % On appelle le superconstructueur. 'obj' hérite des propriétés .ListOfSubelements et .EndStatus
            obj@classMTP(config);
            
            obj.Configuration = config; 
            
            % Dans cette méthode on implémente indépendement les couches cavités et plaques en considérant un ratio de 
            % largeur dans la correction de la compressibilité pour les couches de plaques

            % 1ère couche
            obj.ListOfSubelements{end + 1} = config.PorousMaterial(config.LayersThickness(1));

            % On parcourt les plaques successives
            for i = 1:length(config.PlatesLength) - 1

                % On crée un changement de section de la couche prédente (poreux i-1) à la couche courante (partie libre dans la couche plaque i)
                obj.ListOfSubelements{end + 1} = classsectionchange(config.Width, config.Width - config.PlatesLength(i));

                % On crée une couche de poreux de l'épaisseur de la couche plaque + cavité courante 
                obj.ListOfSubelements{end + 1} = config.PorousMaterial(config.LayersThickness(2*i) + config.LayersThickness(2*i + 1));

                % On rajoute une cavité de type "fente" en parallèle 
                PSCi = classQWL(config.Width - config.PlatesLength(i), 'rectangle', [config.LayersThickness(2*i), config.Width]); % A modifier : variables implémentées au hasard
                obj.ListOfSubelements{end + 1} = classjunction_rectangular(PSCi, config.Width - PSCi.Length, ...
                    config.Width, config.Width - PSCi.Length, config.Width, ...
                    config.LayersThickness(2*i));

                % On crée un changement de section du pore commun (partie libre de la couche plaque i) vers la vavité suivante (partie libre de la couche plaque i + 1) 
                obj.ListOfSubelements{end + 1} = classsectionchange(config.Width - config.PlatesLength(i), config.Width - config.PlatesLength(i+1));
            end

            % Dernière plaque

            % On crée un pore commun de l'épaisseur de la dernière couche de plaque + poreux
             obj.ListOfSubelements{end + 1} = config.PorousMaterial(config.LayersThickness(end-1) + config.LayersThickness(end));

            % On créer un cavité en parallèle de l'épaiseur de la dernière couche de poreux (on aurait pu aussi rajouter un quart d'onde à la fin)
            PSCi = classQWL(config.Width - config.PlatesLength(end), 'rectangle', [config.LayersThickness(end) config.Width]); % A modifier : variables implémentées au hasard
            obj.ListOfSubelements{end + 1} = classjunction_rectangular(PSCi, config.Width - PSCi.Length, ...
                config.Width, config.Width - PSCi.Length, config.Width, ...
                config.LayersThickness(end));

        end
    end
end

