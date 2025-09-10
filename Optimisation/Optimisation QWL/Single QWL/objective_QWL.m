function cost = objective_QWL(params, R, gabarit, air, w, f_peak, bandwidth)
    % Extrait les paramètres
    n = numel(params) / 2;
    r = params(1:n);
    L = params(n+1:end);
    f_min = f_peak - bandwidth/2;
    f_max = f_peak + bandwidth/2;
    w_min = f_min*2*pi;
    w_max = f_max*2*pi;

    % Calcul du modèle avec les paramètres
    alpha_model = multiQWL(R, r, L, 'circle').alpha(air, w);

    % Sélectionne la partie du modèle dans la plage de fréquences spécifiée
    % valid_indices = (w >= w_min) & (w <= w_max);

    % Calcul de la somme des écarts au carré entre le modèle et le gabarit
    % cost = sum((alpha_model(valid_indices) - gabarit(valid_indices)).^2);
    cost = sum((alpha_model- gabarit).^2);
end