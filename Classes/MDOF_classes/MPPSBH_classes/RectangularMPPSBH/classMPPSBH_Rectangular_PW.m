classdef classMPPSBH_Rectangular_PW < classMPPSBH_Rectangular

    methods
        function obj = classMPPSBH_Rectangular_PW(config)
        
            % Appel du constructeur de la classe parente
            obj@classMPPSBH_Rectangular();
               
            if nargin > 0  && ~isempty(config) && length(fields(config)) > 3
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
                    obj.Configuration.ListOfObjects{end+1} = classMPP_Circular(classMPP_Circular.create_config(mpw(i)*mpd(i), pt(i), phr(i), pp(i), ...
                        'PerforatedAreaWidth', mpw(i), 'PerforatedAreaDepth', mpd(i)));
        
                    % Cavité trapezoidale
                    wc = (mpw(i) + mpw(i+1))/2;
                    dc = (mpd(i) + mpd(i+1))/2;

                    % Cavité trapezoidale
                    obj.Configuration.ListOfObjects{end+1} = classcavity_trapezoidal_subdiv(classcavity_trapezoidal_subdiv.create_config(ct(i)/2, mpw(i), mpd(i), wc, dc));
    
                    % Cavité cubique en parallèle
                    annular_cavity = classannularcavity_cubical(classannularcavity_rectangular_frustum.create_config(mpw(i), mpd(i), mpw(i+1), mpd(i+1), cavw, cavd, ct(i), 'Plane Wave'));
                    obj.Configuration.ListOfObjects{end+1} = classjunction(classjunction.create_config(annular_cavity, wc * dc));
        
                    % Cavité trapezoidale
                    obj.Configuration.ListOfObjects{end+1} = classcavity_trapezoidal_subdiv(classcavity_trapezoidal_subdiv.create_config(ct(i)/2, wc, dc, mpw(i+1), mpd(i+1)));
                end 
            end
        end
    end
end