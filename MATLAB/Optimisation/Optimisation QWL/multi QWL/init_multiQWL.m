function QWL_init = init_multiQWL(n, total_surface, r_init, shape, f_peak, bandwidth, air)
    % Construit la configuration du multiQWL à partir des hyperparamètres en entrée

    f_min = f_peak - bandwidth/2;
    f_max = f_peak + bandwidth/2;

    param_air = air.parameters;
    c0 = param_air.c0; 
    
    % Construction de la configuration
    config = {};

    % Valeurs initiales des rayons principaux
    config.TotalSurface = total_surface;

    % Valeurs initiales du rayon
    r = repmat(r_init, 1, n);
    config.Radius = r;

    % Calcul des fréquences quart d'onde équiréparties
    freq_QWL = linspace(f_min, f_max, n);

    % Calcul des longueurs des résonateurs quart associées à chaque fréquence
    l = c0 ./ (4 * freq_QWL);
    config.Length = l;

    % Valeurs initiales des formes
    s = repmat({shape}, 1, n);
    config.Shape = s;

    % Construction de l'objet multi-QWL
    QWL_init = classmultiQWL(config);
end


