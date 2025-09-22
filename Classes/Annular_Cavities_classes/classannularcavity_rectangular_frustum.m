classdef classannularcavity_rectangular_frustum < annularcavity_cubical

    methods

        function obj = classannularcavity_rectangular_frustum(config)

            obj@annularcavity_cubical(config);
        end
        
    end

    methods (Static, Access = public)

        function config = create_config(main_pore_width_in, main_pore_depth_in, ...
                                main_pore_width_out, main_pore_depth_out, ...
                                cavity_width, cavity_depth, ...
                                cavity_thickness)

            config = struct();
        
            % Pore dimensions (deal pour avoir variables locales en plus)
            [config.MainPoreWidthIn,  wi_in]  = deal(main_pore_width_in);
            [config.MainPoreDepthIn,  di_in]  = deal(main_pore_depth_in);
            [config.MainPoreWidthOut, wi_out] = deal(main_pore_width_out);
            [config.MainPoreDepthOut, di_out] = deal(main_pore_depth_out);
        
            % Cavity dimensions
            [config.CavityWidth, w]  = deal(cavity_width);
            [config.CavityDepth, d]  = deal(cavity_depth);
            config.Section = w * d;
            config.CavityThickness = cavity_thickness;
        
            % ---- Surface latérale du frustum rectangulaire (pore central) ----
            ha = sqrt(cavity_thickness^2 + ((di_out - di_in)/2)^2);  % inclinaison suivant profondeur
            hb = sqrt(cavity_thickness^2 + ((wi_out - wi_in)/2)^2);  % inclinaison suivant largeur
        
            Sa = (wi_in + wi_out) * ha;   % deux faces longitudinales
            Sb = (di_in + di_out) * hb;   % deux faces transversales
        
            config.CurtainArea = Sa + Sb;
            
            config.CavityModel = 'Lumped Volume';
        end
    end
end




