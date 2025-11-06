classdef classannularcavity_cubical < classobject

    methods

        function obj = classannularcavity_cubical(config)

            obj@classobject(config);
        end
        
        function Zsde = surface_impedance(obj, env)

            config = obj.Configuration;
            w = env.w;
            air = env.air;
            rho = air.parameters.rho;
            c0 = air.parameters.c0;

            switch config.CavityModel 
                    
                case 'Plane Wave'

                    mpw = config.MainPoreWidth;
                    cw  = config.CavityWidth;
                    cd = config.CavityDepth;
                    ct = config.CavityThickness;
                    
                    % Fente pour un des deux côtés
                    QWL_Slit = classQWL_Slit(classQWL_Slit.create_config((cw - mpw)/2, ct, cd));
                    % QWL_Slit = classQWL_Slit(classQWL_Slit.create_config(cw/2, ct, cd));
                    Zsde = 2 * QWL_Slit.surface_impedance(env);

                case 'Plane Wave Corrected'

                    mpw = config.MainPoreWidth;
                    mpwi = config.MainPoreWidthIn;
                    mpwo = config.MainPoreWidthOut;
                    cw  = config.CavityWidth;
                    cd = config.CavityDepth;
                    ct = config.CavityThickness;
                    
                    % On corrige le modèle en considérant la longueur
                    % réelle pour la reflexion des ondes transversales
                    l_corr = sqrt(((cw - mpwi)/2)^2+(ct/2)^2) + sqrt(((cw - mpwo)/2)^2+(ct/2)^2);
                    QWL_Slit = classQWL_Slit(classQWL_Slit.create_config(l_corr/2, ct, cd));
                    % QWL_Slit = classQWL_Slit(classQWL_Slit.create_config(cw/2, ct, cd));
                    Zsde = 2 * QWL_Slit.surface_impedance(env);

                case 'Lumped Volume'

                    Ca = config.CurtainArea;
                    Vcav = config.CavityVolume;
                      
                    k = w/c0;
                    Z0 = rho * c0; 
                       
                    % L'admittance est formulée selon la convention Pression - Vitesse
                    Ycav = 1j * k/Z0 / Ca .* Vcav;
    
                    Zsde = 1 ./ Ycav;  
            end
        end
    end

    methods (Static, Access = public)

        function config = create_config(main_pore_width, main_pore_depth, cavity_width, cavity_depth, cavity_thickness, varargin)

            config = struct();
            [config.MainPoreWidth, mpw] = deal(main_pore_width);
            [config.MainPoreDepth, mpd] = deal(main_pore_depth);
            [config.CavityWidth, w] = deal(cavity_width);
            [config.CavityDepth, d] = deal(cavity_depth);
            [config.CavityThickness, ct] = deal(cavity_thickness);
            config.CurtainArea = 2 * ct * (mpd + mpw); % Faces du parallèlépipèdes
            config.CavityVolume = w * d * ct - mpw * mpd * ct; % Différences des deux parallèlépipèdes

            if nargin > 5
                config.CavityModel = varargin{1};
            else
                config.CavityModel = 'Lumped Volume';
            end
        end
    end
end




