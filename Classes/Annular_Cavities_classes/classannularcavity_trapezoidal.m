classdef classannularcavity_trapezoidal < classannularcavity_cubical

    methods

        function obj = classannularcavity_trapezoidal(config)

            obj@classannularcavity_cubical(config);
        end
    end

    methods (Static, Access = public)

        function config = create_config(main_pore_width_in, main_pore_width_out, ...
                cavity_width, cavity_depth, cavity_thickness, varargin)

            config = struct();
            [config.MainPoreWidthIn,  wi]  = deal(main_pore_width_in);
            [config.MainPoreWidthOut, wo] = deal(main_pore_width_out);
            % config.MainPoreWidth = (wi + wo)/2;
            config.MainPoreWidth = min(wi, wo);
            [config.CavityWidth, w] = deal(cavity_width);
            [config.CavityDepth, d] = deal(cavity_depth);
            [config.CavityThickness, ct] = deal(cavity_thickness);
            config.CurtainArea = 2 * d * sqrt(ct^2 + ((wo-wi)/2)^2); % deux fentes obliques
            config.CavityVolume = w * d * ct - (wo+wi)/2 * d * ct;

            if nargin > 5
                config.CavityModel = varargin{1};
            else
                config.CavityModel = 'Lumped Volume';
            end
        end
    end
end
