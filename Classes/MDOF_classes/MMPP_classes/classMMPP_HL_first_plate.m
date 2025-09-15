classdef classMMPP_HL_first_plate < classMMPP

    methods

        function obj = classMMPP_HL_first_plate(config)
        
            % Appel du constructeur de la classe parente
            obj@classMMPP(config)
               
            if nargin > 0  && ~isempty(config) && length(fields(config)) > 3
                % Transfert des champs de la configuration d'appel vers la configuration de classe
                obj.Configuration = perso_transfer_fields(config, obj.Configuration);
    
                s = config.Surface;
                pp = config.PlatesPorosity;
                phr = config.PlatesHolesRadius;
                pt = config.PlatesThickness;
                obj.Configuration.ListOfSubelements{1} = classMPP_Circular_HL(classMPP_Circular_HL.create_config(s, pt(1), phr(1), pp(1)));
            end
        end
    end
end
