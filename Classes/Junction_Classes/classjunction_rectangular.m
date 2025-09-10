classdef classjunction_rectangular < classjunction

%% References: 

            % [1] Dupont, Thomas, et al. "A Microstructure Material Design for
            % Low Frequency Sound Absorption." Applied Acoustics, vol. 136,
            % July 2018, pp. 86-93. 
            % DOI: 10.1016/j.apacoust.2018.02.016.

%% Description

            % 'classjunction' is a way to add a parallel grazing incidence waveguide called 'junction' in a main wave guide 
            % called 'wave guide' by considering the surface impedance of the junction, the curtain area thats is the surface 
            % of connexion between the junction and the wave guide and the average cross section area of the wave guide at 
            % the place where the connexion takes place.
            % for more explanation, see [1] fig.4

%% Utilisation 

% classMTP_with_slit_cavities

%% Properties
  
 properties

        % Configuration (Héritée)
        %              .JunctionElement   
        %              .JunctionThickness
        %              .JunctionDepth
        %              .CurtainArea
    end
    
    methods

        function obj = classjunction_rectangular(config)

            obj@classjunction(config)
        end
    end

    methods (Static, Access = public)

        function config = create_config(junctio_element, junction_depth, junction_thickness)
            
            config = struct();
            config.JunctionElement = junctio_element;
            config.JunctionDepth = junction_depth;
            config.JunctionThickness = junction_thickness;
            config.CurtainArea = classjunction_rectangular.curtain_area(config);
        end
    
        function Ca = curtain_area(config)
        % La jonction rectangulaire est une jonction dans laquelle les
        % surfaces de jonction sont les deux rectangles latéraux de même
        % dimensions qui bordent la jonction

            t = config.JunctionThickness;
            d = config.JunctionDepth;
            Ca = 2 * t * d;
            % Ca = t * d;
        end
    end      
end
