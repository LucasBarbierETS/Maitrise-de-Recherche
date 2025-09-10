classdef classMPPSBH_Rectangular_HL_first_plate < classMPPSBH_Rectangular

    methods
        function obj = classMPPSBH_Rectangular_HL_first_plate(config)
        
            % Appel du constructeur de la classe parente
            obj@classMPPSBH_Rectangular(config);
  
            % Transfert des champs de la configuration d'appel vers la configuration de classe
            obj.Configuration = perso_transfer_fields(config, obj.Configuration);

            mpw = config.MainPoresWidth;
            mpd = config.MainPoresDepth;
            pp = config.PlatesPorosity;
            phr = config.PlatesHolesRadius;
            pt = config.PlatesThickness;

            % Modification de la première plaque perforée
            obj.Configuration.ListOfSubelements{1} = classMPP_Circular_HL(classMPP_Circular.create_config(mpw(1)*mpd(1), pt(1), phr(1), pp(1), mpw(1), mpd(1)));
        end
    end
end