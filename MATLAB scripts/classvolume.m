classdef classvolume < classsubelement

    methods
        function obj = classvolume(config) 
            
            obj@classsubelement(config);
        end

        function Zs = surface_impedance(obj, env)

            config = obj.Configuration;
            Z0 = env.air.parameters.Z0;
            c0 = env.air.parameters.c0;
            k = env.w/c0;
            Ys = 1j * k * config.Volume / (Z0 * config.Surface);
            Zs = 1 ./ Ys;
        end
    end

    methods (Static, Access = public)

        function config = create_config(surface, volume)
            config = struct();
            config.Surface = surface;
            config.Volume = volume;
        end
    end
end