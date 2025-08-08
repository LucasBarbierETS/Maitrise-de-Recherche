classdef classMPPSBH_Rectangular_HL_iter_without_first_plate < classMPPSBH_Rectangular

    methods
        function obj = classMPPSBH_Rectangular_HL_iter_without_first_plate(config)
        
            % Appel du constructeur de la classe parente
            obj@classMPPSBH_Rectangular(config);

            config = obj.Configuration;
            cavw = config.CavitiesWidth;
            cavd = config.CavitiesDepth;
            mpw = config.MainPoresWidth;
            mpd = config.MainPoresDepth;
            pppp = config.PlatesPerforatedPartPorosity;
            % prp = config.PlatesRealPorosity;
            phr = config.PlatesHolesRadius;
            pt = config.PlatesThickness;
            ct = config.CavitiesThickness;
            cm = config.CavitiesMethod;

            % On ajoute la première cellule avec une dépendance à 

            % On ajoute péridiquement la cellule plaque + cavité
            for i = 1:length(pppp)
                obj.Configuration.ListOfSubelements{i} = Cell_MPPSBHr_HL_iter(Cell_MPPSBHr.create_config(pppp(i), phr(i), pt(i), ...
                ct(i), cavd, cavw, mpw(i), mpw(i+1), mpd(i), mpd(i+1), cm{i}));

                % obj.Configuration.ListOfSubelements{i} = Cell_MPPSBHr_HL_iter(Cell_MPPSBHr.create_config(prp(i), phr(i), pt(i), ...
                % ct(i), cavd, cavw, mpw(i), mpw(i+1), mpd(i), mpd(i+1), cm(i))); 
            end 
        end
    end
end
