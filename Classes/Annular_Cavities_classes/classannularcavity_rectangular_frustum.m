classdef classannularcavity_rectangular_frustum < classsubelement

    methods

        function obj = classannularcavity_rectangular_frustum(config)

            obj@classsubelement(config);
        end
        
        function Zsde = surface_impedance(obj, env)

            config = obj.Configuration;
            w = env.w;
            air = env.air;
            rho = air.parameters.rho;

            % c0 = air.parameters.c0;
            c0 = air.parameters.c0 * (1+0.05*1j); % perso_ouvrir_lien_Zotero('zotero://open-pdf/library/items/233HZ8GN?page=7&annotation=QLW3FP87')
            % c0 = air.parameters.c0 * (1+0.01*1j); % perso_ouvrir_lien_Zotero('zotero://open-pdf/library/items/233HZ8GN?page=7&annotation=QLW3FP87')
         
            mpwi = config.MainPoreWidthIn;
            mpwo = config.MainPoreWidthOut;
            mpdi = config.MainPoreDepthIn;
            mpdo = config.MainPoreDepthOut;
            cw  = config.CavityWidth;
            cd = config.CavityDepth;
            ct = config.CavityThickness;
            Ca = config.CurtainArea;

            switch config.CavityModel 

                case 'Lumped Volume'

                    % Volume externe (parallélépipède)
                    Vext = ct * cd * cw;
                
                    % Volume interne (frustum rectangulaire du pore central)
                    Vint = ct/6 * ( ...
                          2*mpwi*mpdi ...
                        + 2*mpwo*mpdo ...
                        + mpwi*mpdo ...
                        + mpwo*mpdi );
                
                    % Demi-Volume de la cavité autour du frustum 
                    % Vcav = (Vext - Vint)/2;
                    Vcav = Vext - Vint;

                    k  = w/c0;
                    Z0 = rho * c0; 
                
                    % Admittance (Pression - Vitesse convention)
                    Ycav = 1j * k / Z0 / Ca * Vcav;
                
                    % Impédance équivalente
                    Zsde = 1 ./ Ycav;
            end
        end
    end

    methods (Static, Access = public)

        function config = create_config(main_pore_width_in, main_pore_depth_in, ...
                                main_pore_width_out, main_pore_depth_out, ...
                                cavity_width, cavity_depth, ...
                                cavity_thickness, varargin)

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
        
            % Modèle associé
            if nargin > 7
                config.CavityModel = varargin{1};
            else
                config.CavityModel = 'Lumped Volume';
            end
        end
    end
end




