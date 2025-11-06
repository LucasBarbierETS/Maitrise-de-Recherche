classdef classcavity < classobject
   
    methods 

        function obj = classcavity(config) 
            
            obj@classobject(config);
        end
        
        function [TM, options] = transfer_matrix(obj, env, options)
            
            s = obj.Configuration.Section;
            w = env.w;
            air = env.air;
            param = air.parameters;
            c0 = param.c0;
            k0 = w ./ c0;
            Z0 = c0 * param.rho;
            H = obj.Configuration.Thickness;

            TM.T11 = cos(k0 * H);
            TM.T12 = 1j * Z0 / s * sin(k0 * H);
            TM.T21 = 1j * s / Z0 * sin(k0 * H);
            TM.T22 = cos(k0 * H);

            options = perso_propagate(TM, options);
        end
    end

    methods (Static, Access = public)
    
        function config = create_config(section, thickness)

            config = struct();
            config.Section = section;
            config.Thickness = thickness; 
        end
    end
end