classdef classMLBSBH < classelement

% References
%
%           [1] Stinson & Champoux, Propagation of sound and the assignment of 
%               shape factors in model porous materials having simple pore geometries
%               http://asa.scitation.org/doi/10.1121/1.402530
%
%           [2] Hybrid composite meta-porous structure for improving and broadening sound absorption
%               N. Gao, J. Wu, K. Lu and H. Zhong
%               DOI: 10.1016/J.YMSSP.2020.107504   

% Description 
%
% Cette classe permet de décrire les solutions multi couche à base de de bi-plaques latéral.
% La fente au milieu des plaques rétrecit avec la profondeur, on implémente des main pores coniques 
% et deux cavités quart d'onde en parallèle au niveau de chaque cavités (ring)
     
    methods    

         function obj = classMLBSBH(config)
        
            % Appel du constructeur de la classe parente
            obj@classelement(classelement.create_config({}, 'closed'));
               
            if nargin > 0    
                % Tranfert des champs de la configuration d'appel vers la configuration de classe
                obj.Configuration = perso_transfer_fields(config, obj.Configuration);
    
                % Paramètres géométriques et physiques
                SBHw = config.MLBWidth;
                cavw = config.CavitiesWidth;
                sw = config.SlitsWidth;
                pt = config.PlatesThickness;
                ct = config.CavitiesThickness;
                % ptc = config.PlatesThicknessCorrection;
                
                % Modèles et options
                % cm = config.CavitiesModel;
                
                % Mise à jour de section d'entrée et de sortie
                obj.Configuration.InputSection = SBHw^2;
                
                % Plaque perforée centrale (première MPP circulaire)
                % obj.Configuration.ListOfSubelements{end+1} = classMPP_Circular(classMPP_Circular.create_config(pp(1), hr(1), pt(1), cavw*sw(1), ptc(1)));
                % obj.Configuration.ListOfSubelements{end+1} = classMPP_Circular(classMPP_Circular.create_config(pp(1), hr(1), pt(1), cavw*sw(1)));
                obj.Configuration.ListOfSubelements{end+1} = classQWL_Slit(classQWL_Slit.create_config(pt(1), sw(1), cavw*sw(1)));
                
                % Boucle sur les cavités et plaques
                for i = 1:length(ct) - 1
    
                    mpw = (sw(i) + sw(i+1)) / 2;
    
                    % Cavité parallèle
    
                    % Demi pore principal
                    obj.Configuration.ListOfSubelements{end+1} = classQWL_Slit(classQWL_Slit.create_config(ct(i)/2, sw(i+1), cavw*sw(i+1)));
    
                    % Jonction
                    QWLSlit = classQWL_Slit(classQWL_Slit.create_config((cavw-mpw)/ 2, ct(i), 1)); % section d'entrée unitaire (arbitraire)
                    obj.Configuration.ListOfSubelements{end+1} = classjunction_rectangular(classjunction_rectangular.create_config(QWLSlit, cavw, ct(i)));
    
                    % Demi pore principal
                    obj.Configuration.ListOfSubelements{end+1} = classQWL_Slit(classQWL_Slit.create_config(ct(i)/2, mpw, cavw*mpw));
    
                    % % Cavité annulaire ou jonction cylindrique
                    % obj.Configuration.ListOfSubelements{end+1} = classannularcell(classannularcell.create_config(ppar(i), ppar(i+1), cavr, ct(i), cm));
 
                    % MPP suivante
                    % obj.Configuration.ListOfSubelements{end+1} = classMPP_Circular(classMPP_Circular.create_config(pp(i+1), hr(i+1), pt(i+1), pi*ppar(i+1)^2, ptc(i+1)));
                    % obj.Configuration.ListOfSubelements{end+1} = classMPP_Circular(classMPP_Circular.create_config(pp(i+1), hr(i+1), pt(i+1), cavw*sw(i+1)));
                    obj.Configuration.ListOfSubelements{end+1} = classQWL_Slit(classQWL_Slit.create_config(pt(i+1), sw(i+1), cavw*sw(i+1)));
                end
                
                % Traitement de la dernière cavité
                obj.Configuration.ListOfSubelements{end+1} = classcavity(classcavity.create_config(ct(end), cavw^2)); 
            end 
        end
   
        function obj = launch_comsol_model(obj)

             env = create_environnement(28, 108000, 50, 1, 5000, 200, 130);
             model = ModelMLBSBH(obj.Configuration, env);
             obj.Configuration.ComsolModel = model;

        end
    end

     methods (Static, Access = public)
           
        function config = create_config(MLB_width, cavities_width, slits_width, ...
                plates_thickness, cavities_thickness, N, input_section)
            
            % Code
            config = {};
            config.MLBWidth = MLB_width;
            config.CavitiesWidth = cavities_width; 
            config.N = N;
            config.InputSection = input_section;
            
            % Epaisseurs des plaques
            if isscalar(plates_thickness)
                config.PlatesThickness = repmat(plates_thickness, 1, N);
            else 
                config.PlatesThickness = plates_thickness;
            end
            
            % Epaisseurs des cavités
            if isscalar(cavities_thickness)
                config.CavitiesThickness = repmat(cavities_thickness, 1, N);
            else 
                config.CavitiesThickness = cavities_thickness;
            end
            
            % Rayon des plaques perforées
            L = sum(config.PlatesThickness) + sum(config.CavitiesThickness); % Longueur totale de SBH
            
            if iscell(slits_width)  % Cas 2 : Profil variable selon l'épaisseur
                config.SlitsWidth = [slits_width{1}]; % x_position = 0
                r = profilMLPSBH(L, slits_width{1}, slits_width{2}, slits_width{3});
                for i = 1: N-1 
                    x_position = sum(config.PlatesThickness(1:i)) + sum(config.CavitiesThickness(1:i));
                    config.SlitsWidth =  [config.SlitsWidth r(x_position)];
                end 
            elseif isscalar(slits_width) % Cas 1 : Largeur commune pour chaque plaque
                config.SlitsWidth = repmat(slits_width, 1, N);    
            else % Cas 3 : Largeur spécifiée pour chaque plaque
                config.SlitsWidth = slits_width;
            end       
        
        end
    end
end


