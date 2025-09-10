classdef classMPPSBH_Rectangular_HL_iter < classMPPSBH_Rectangular

    methods
        function obj = classMPPSBH_Rectangular_HL_iter(config)
        
            % Appel du constructeur de la classe parente
            obj@classMPPSBH_Rectangular(classelement.create_config({}, 'closed', []));
               
            if nargin > 0    
                % Transfert des champs de la configuration d'appel vers la configuration de classe
                obj.Configuration = perso_transfer_fields(config, obj.Configuration);
    
                cavw = config.CavitiesWidth;
                cavd = config.CavitiesDepth;
                mpw = config.MainPoresWidth;
                mpd = config.MainPoresDepth;
                pp = config.PlatesPorosity;
                phr = config.PlatesHolesRadius;
                pt = config.PlatesThickness;
                ct = config.CavitiesThickness;

                % On ajoute péridiquement la cellule plaque + cavité
                for i = 1:length(pp)

                    % Plaque perforée
                    obj.Configuration.ListOfSubelements{end+1} = @(u_rms) classMPP_Circular_HL_iter(classMPP_Circular.create_config(mpw(i)*mpd(i), pt(i), phr(i), pp(i), mpw(i), mpd(i)));
        
                    % Cavité cylindrique
                    wc = (mpw(i) + mpw(i+1))/2;
                    dc = (mpd(i) + mpd(i+1))/2;
                    % obj.Configuration.ListOfSubelements{end+1} = classcavity(classcavity.create_config(ct(i)/2, mpw(i), mpd(i)));
                    obj.Configuration.ListOfSubelements{end+1} = classcavity_trapezoidal(classcavity_trapezoidal.create_config(ct(i)/2, mpw(i), mpd(i), wc, dc));
    
                    % Cavité cubique en parallèle
                    annular_cavity = classannularcavity_cubical(classannularcavity_cubical.create_config(wc, dc, cavw, cavd, ct(i)));
                    obj.Configuration.ListOfSubelements{end+1} = classjunction(classjunction.create_config(annular_cavity, wc, dc));
        
                    % Cavité cylindrique
                    % obj.Configuration.ListOfSubelements{end+1} = classcavity(classcavity.create_config(ct(i)/2, wc, dc));
                    obj.Configuration.ListOfSubelements{end+1} = classcavity_trapezoidal(classcavity_trapezoidal.create_config(ct(i)/2, wc, dc, mpw(i+1), mpd(i+1)));
                end 
            end
        end
    end
end
