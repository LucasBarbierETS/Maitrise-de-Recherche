classdef classMPPSBH_Rectangular_HL_first_plate < classMPPSBH_Rectangular

    methods
        function obj = classMPPSBH_Rectangular_HL_first_plate(config)
        
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

            obj.Configuration.ListOfSubelements{1} = Cell_MPPSBHr_HL(Cell_MPPSBHr.create_config(pppp(1), phr(1), pt(1), ...
            ct(1), cavd, cavw, mpw(1), mpw(2), mpd(1), mpd(2), cm{1}));

            % obj.Configuration.ListOfSubelements{1} = Cell_MPPSBHr_HL(Cell_MPPSBHr.create_config(prp(1), phr(1), pt(1), ...
            % ct(1), cavd, cavw, mpw(1), mpw(2), mpd(1), mpd(2), cm{1}));
        end
    end
end