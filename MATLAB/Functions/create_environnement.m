function env = create_environnement(temperature, static_pressure, relative_humidity, ...
                                    fmin, fmax, points, varargin)
    
    air = classair(temperature, static_pressure, relative_humidity);
    env.air = air;

    step = (fmax-fmin) / (points-1);
    f = fmin : step : fmax;
    w = 2 * pi * f;
    env.w = w;

    % Si l'utilisateur à indiqué un niveau de pression sonore
    if nargin > 6
        pref = 20e-6;
        p = pref * 10^(varargin{1}/20);
        env.p = p;
    end
end



