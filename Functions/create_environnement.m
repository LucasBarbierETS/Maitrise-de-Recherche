function env = create_environnement(temperature, static_pressure, relative_humidity, ...
                                    fmin, fmax, points, options)
    
    arguments
        temperature
        static_pressure
        relative_humidity
        fmin
        fmax
        points
        options.Root = NaN
        options.SPL = 100
        options.M = 0
    end

    env.Root = options.Root;
    env.fmin = fmin;
    env.fmax = fmax;
    env.points = points;
    env.air = classair(temperature, static_pressure, relative_humidity);

    step = (fmax-fmin) / (points-1);
    f = fmin : step : fmax;
    w = 2 * pi * f;
    env.w = w;
    env.f = f;

    % Pression de référence pour l'échelle des niveau de pression
    env.p_ref = 20e-6; 

    env.SPL = options.SPL;
    env.pt_rms = env.p_ref * 10.^(env.SPL/20); 
    env.pt = sqrt(2) * env.p_ref * 10.^(env.SPL/20); % Dans Lopez : perso_ouvrir_lien_Zotero('zotero://open-pdf/library/items/UXM5QAPK?page=153&annotation=PTUY9E3V');

    env.M = options.M;
end



