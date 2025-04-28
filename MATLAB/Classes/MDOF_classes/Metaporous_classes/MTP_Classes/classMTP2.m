classdef classMTP2 < classMTP


% References

%           [1] Stinson & Champoux, Propagation of sound and the assignment of 
%               shape factors in model porous materials having simple pore geometries
%               http://asa.scitation.org/doi/10.1121/1.402530

%           [2] Hybrid composite meta-porous structure for improving and broadening sound absorption
%               N. Gao, J. Wu, K. Lu and H. Zhong
%               DOI: 10.1016/J.YMSSP.2020.107504   

     methods    

         function obj = classMTP2(config)
            
            % On appelle le superconstructueur. 'obj' hérite des propriétés .ListOfSubelements et .EndStatus
            obj@classMTP(config);
            
            % Dans cette méthode on implémente indépendement les couches cavités et plaques en considérant un ratio de 
            % largeur dans la correction de la compressobilité pour les couches de plaques

            % 1ère couche
            obj.ListOfSubelements{end + 1} = config.PorousMaterial(config.LayersThickness(1));

            % On crée une fonction temporaire qui permet d'appeler et modifier la méthode .equivalentparameters des couches de plaque
            function  ep = modifiedequivalentparameters(obj, nui, env)
            
                ep = obj.equivalent_parameters(env);
                ep.Zeq = ep.Zeq / nui; % [2] eq.19
            end

            % On parcourt les plaques successives
            for i = 1:length(obj.Configuration.PlatesLength)

                % On crée une couche de matériau poreux pour la plaque courante
                porous_layer = config.PorousMaterial(config.LayersThickness(i));
                nui = 1 - config.PlatesLength(i) / config.Width;

                % On redéfinie manuellement les paramètres équivalents de la couche pour qu'ils soient utilisés dans la méthode transfermatrix
                porous_layer.EquivalentParameters = @(obj, env) modifiedequivalentparameters(obj, nui, env);
                obj.ListOfSubelements{end + 1} = porous_layer;

                % On rajoute ensuite la couche cavité derrière la plaque
                obj.ListOfSubelements{end + 1} = config.PorousMaterial(config.LayersThickness(2*i + 1));
            end

         end
     end
end

