classdef classcavity_cylindrical < classcavity
    
    methods 

        function obj = classcavity_cylindrical(config) 
            
            obj@classcavity(config);
        end
    end

    methods (Static, Access = public)

        function config = create_config(thickness, radius)

            config = struct();
            config.Radius = radius;
            config.Thickness = thickness; 
            [config.Section, config.Surface] = deal(pi*radius^2);
        end
    end

end