classdef classMMPP_HL < classMMPP_HL_first_plate

    methods

        function obj = classMMPP_HL(config)
        
            obj@classMMPP_HL_first_plate({});
               
            if nargin > 0  && ~isempty(config)
                % Transfert des champs de la configuration d'appel vers la configuration de classe
                obj.Configuration = perso_transfer_fields(config, obj.Configuration);
    
                S = config.Surface;
                pp = config.PlatesPorosity;
                phr = config.PlatesHolesRadius;
                pt = config.PlatesThickness;
                ct = config.CavitiesThickness;
                N = config.NumberOfPlates;

                % On ajoute péridiquement la cellule plaque + cavité
                for i = 1:N

                    % Plaque perforée
                    obj.Configuration.ListOfSubelements{end+1} = classMPP_Circular_HL(classMPP_Circular.create_config(S, pt(i), phr(i), pp(i)));
        
                    % Cavité 
                    obj.Configuration.ListOfSubelements{end+1} = classcavity(classcavity.create_config(S, ct(i)));
                end 
            end
        end
    end
end
