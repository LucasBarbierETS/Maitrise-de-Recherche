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

                % volume de la i-ème plaque
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
    end
end