classdef classannularcavity_rectangular_frustum < classannularcavity_cubical

    methods

        function obj = classannularcavity_rectangular_frustum(config)

            obj@classannularcavity_cubical(config);
        end
        
    end

    methods (Static, Access = public)

        function config = create_config(main_pore_width_in, main_pore_depth_in, ...
                                main_pore_width_out, main_pore_depth_out, ...
                                cavity_width, cavity_depth, ...
                                cavity_thickness)

            config = struct();
        
            % Pore dimensions (deal pour avoir variables locales en plus)
            [config.MainPoreWidthIn,  wi]  = deal(main_pore_width_in);
            [config.MainPoreDepthIn,  di]  = deal(main_pore_depth_in);
            [config.MainPoreWidthOut, wo] = deal(main_pore_width_out);
            [config.MainPoreDepthOut, do] = deal(main_pore_depth_out);
        
            % Cavity dimensions
            [config.CavityWidth, w]  = deal(cavity_width);
            [config.CavityDepth, d]  = deal(cavity_depth);
            config.Section = w * d;
            [config.CavityThickness, ct] = deal(cavity_thickness);
        
            % % ---- Surface latérale du frustum rectangulaire (pore central) ----
            % ha = sqrt(cavity_thickness^2 + ((di_out - di_in)/2)^2);  % inclinaison suivant profondeur
            % hb = sqrt(cavity_thickness^2 + ((wi_out - wi_in)/2)^2);  % inclinaison suivant largeur
            % 
            % Sa = (wi_in + wi_out) * ha;   % deux faces longitudinales
            % Sb = (di_in + di_out) * hb;   % deux faces transversales
        
            % config.CurtainArea = Sa + Sb;
            config.CurtainArea = 1; % Surface de jonction arbitraire
            Si = wi * di;
            So = wo * do;
            config.CavityVolume = w * d * ct - 1/3 * ct * (Si + sqrt(Si*So) + So);
            config.CavityModel = 'Lumped Volume';
        end
    end
end




