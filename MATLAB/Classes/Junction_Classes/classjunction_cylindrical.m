classdef classjunction_cylindrical < classjunction

% References: 
%
% [1] Dupont, Thomas, et al. "A Microstructure Material Design for
% Low Frequency Sound Absorption." Applied Acoustics, vol. 136,
% July 2018, pp. 86-93. 
% DOI: 10.1016/j.apacoust.2018.02.016.

% Description
%
% 'classjunction' is a way to add a parallel grazing incidence waveguide called 'junction' in a main wave guide 
% called 'wave guide' by considering the surface impedance of the junction, the curtain area thats is the surface 
% of connexion between the junction and the wave guide and the average cross section area of the wave guide at 
% the place where the connexion takes place.
% for more explanation, see [1] fig.4
  
    properties

        % Configuration (Héritée)
        %              .JunctionElement   
        %              .JunctionThickness
        %              .MainPoreRadius
        %              .CurtainArea
    end
    
    methods

        function obj = classjunction_cylindrical(config)

            obj@classjunction(config)
        end
    end

    methods (Static, Access = public)

        function config = create_config(junction_element, junction_radius, junction_thickness)
            
            config = struct();
            config.JunctionElement = junction_element;
            config.MainPoreRadius = junction_radius;
            config.JunctionThickness = junction_thickness;
            config.CurtainArea = classjunction_cylindrical.curtain_area(config);
            config.JunctionElement.Configuration.CurtainArea = config.CurtainArea;
        end
    
        function Ca = curtain_area(config)

            t = config.JunctionThickness;
            rmean = config.MainPoreRadius;
            Ca = pi * 2 * rmean * t;
        end
    end      
end
