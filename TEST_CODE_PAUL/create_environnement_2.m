function env = create_environnement_2(temperature, static_pressure, relative_humidity, ...
                                    freqs, options)
    
    arguments
        temperature
        static_pressure
        relative_humidity
        freqs
        options.Root = NaN
        options.SPL = 100
        options.M = 0
    end

    env.Root = options.Root;
    env.air = classair(temperature, static_pressure, relative_humidity);

    % Fréquences et pulsations
    env.f = freqs(:)';  % vecteur colonne
    env.w = 2 * pi * env.f;

    % Pression de référence pour l'échelle des niveau de pression
    env.p_ref = 20e-6; 

    env.SPL = options.SPL;
    env.pt_rms = env.p_ref * 10.^(env.SPL/20); 
    env.pt = sqrt(2) * env.p_ref * 10.^(env.SPL/20); % Dans Lopez : perso_ouvrir_lien_Zotero('zotero://open-pdf/library/items/UXM5QAPK?page=153&annotation=PTUY9E3V');

    env.M = options.M;
end



