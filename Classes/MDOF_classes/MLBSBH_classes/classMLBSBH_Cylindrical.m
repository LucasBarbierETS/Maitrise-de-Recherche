classdef classMLBSBH_Cylindrical < classMLPSBH_Cylindrical

% References
%
%           [1] Yunwei Chen, Modification of the transfer matrix method for the sonic black hole 
%           and broadening effective absorption band 

% Description 
%
% Cette classe permet de décrire les solutions multi-plaques annulaires non perforées telles que présentées dans [1].
% Dans cet article les plaques sont supposées d'épaisseur nulle, les pertes sont estimées en ajoutant virtuellement 
% une partie complexe à la célérité du son dans le matériau.
% La structure multicouche est constitutée d'un emplilement de cavités coniques dans lesquels des jonction toroidales sont intégrées
     
    methods    

        function obj = classMLBSBH_Cylindrical(config)
                                 
            % Appel du constructeur de la classe parente
            obj@classMLPSBH_Cylindrical();
            
            % Tranfert des champs de la configuration d'appel vers la configuration de classe
            obj.Configuration = transferFields(config, obj.Configuration);
            
            % Paramètres géométriques et physiques
            cavr = config.CavitiesRadius;
            ppar = config.PlatesPerforatedAreaRadius;
            pp = config.PlatesPorosity;
            hr = config.PlatesHolesRadius;
            pt = config.PlatesThickness;
            ct = config.CavitiesThickness;
            ptc = config.PlatesThicknessCorrection;
            
            % Modèles et options
            cm = config.CavitiesModel;
    
            % Initialisation des sous-éléments
            
            % Boucle sur les cavités et plaques
            for i = 1:length(ct) - 1
            
                % Cavité annulaire ou jonction cylindrique
                obj.Configuration.ListOfSubelements{end+1} = classannularcell(classannularcell.create_config(ppar(i), ppar(i+1), cavr, ct(i), cm));
            
            end
            
            % Traitement de la dernière cavité
            obj.Configuration.ListOfSubelements{end+1} = classcavity(classcavity.create_config(ct(end), ppar(end), 0));
            
            % Mise à jour de section d'entrée et de sortie
            obj.Configuration.InputSection = obj.Configuration.ListOfSubelements{1}.Configuration.InputSection;
            obj.Configuration.OutputSection = obj.Configuration.ListOfSubelements{end}.Configuration.OutputSection;
        end
    end
end


