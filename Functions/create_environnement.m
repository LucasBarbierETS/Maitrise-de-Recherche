function env = create_environnement(root, temperature, static_pressure, relative_humidity, ...
                                    fmin, fmax, points, varargin)
    
    env.Root = root;
    air = classair(temperature, static_pressure, relative_humidity);
    env.air = air;

    step = (fmax-fmin) / (points-1);
    f = fmin : step : fmax;
    w = 2 * pi * f;
    env.w = w;

    % Pression de référence pour l'échelle des niveau de pression
    env.p_ref = 20e-6; 

    % Si l'utilisateur à indiqué un niveau de pression totale
    if nargin > 7
        p_rms = env.p_ref * 10.^(varargin{1}/20);
        env.p_rms = p_rms;
    end

    % Si l'utilisateur à indiqué un nombre de Mach moyen
    if nargin > 8
        env.M = varargin{2};
    end


end



