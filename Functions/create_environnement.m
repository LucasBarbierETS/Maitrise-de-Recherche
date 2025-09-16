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

    % Si l'utilisateur à indiqué un niveau de pression (total ou incident)
    if nargin > 7
        env.SPL = varargin{1};
        % env.pt_rms = env.p_ref * 10.^(env.SPL/20); Dans Laly
        env.pt_rms = repmat(sqrt(2) * env.p_ref * 10.^(env.SPL/20), 1, length(env.w)); % Dans Lopez : perso_ouvrir_lien_Zotero('zotero://open-pdf/library/items/UXM5QAPK?page=153&annotation=PTUY9E3V');
        env.pi_rms = env.pt_rms;
    end

    % Si l'utilisateur à indiqué un nombre de Mach moyen
    if nargin > 8
        env.M = varargin{2};
    end
end



