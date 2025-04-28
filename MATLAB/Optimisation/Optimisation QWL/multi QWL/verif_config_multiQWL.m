function correlation = verif_config_multiQWL(params, shape, air, w)
    % a revoir
    
    n = length(params)/3;
    R = params(1:n);
    r = params(n+1:2*n);
    L = params(2*n+1:end);
    main_radius = sqrt(sum(R.^2));

    % Calcul du coefficient alpha pour la configuration de base
    config_base = multiQWL(params, shape);
    alpha_base = config_base.alpha(air, w);

    % Préallocation des tableaux pour stocker les coefficients
    num_resonators = length(r);
    alphas_configs = zeros(length(w), num_resonators);

    % Calcul et stockage des coefficients pour chaque configuration dérivée
    for i = 1:num_resonators
        % Configuration en retirant le i-ème résonateur
        R_sans_resonateur = [R(1:i-1), R(i+1:end)];
        r_sans_resonateur = [r(1:i-1), r(i+1:end)];
        L_sans_resonateur = [L(1:i-1), L(i+1:end)];
        params_sans_resonateur = horzcat(R_sans_resonateur,r_sans_resonateur,L_sans_resonateur);

        config_sans_resonateur = classmultiQWL(params_sans_resonateur);
        alphas_configs(:, i) = config_sans_resonateur.alpha(air, w);
    end

    % Calcul de la corrélation avec la configuration de base
    correlation = corrcoef([alpha_base', alphas_configs], 'Rows', 'complete');

    % Tracer les résultats dans un graphique
    plot(w/(2*pi),alphas_configs - alpha_base');
    xlabel('Fréquence (Hz)');
    ylabel('Coefficient d''absorption (\alpha)');
    title('Ecart à la configuration initiale');

    % Création des légendes formatées
    legend_str = cell(1, num_resonators);
    for i = 1:num_resonators
        legend_str{i} = sprintf('%d-%d', num_resonators, i);
    end
    legend(legend_str);
    grid on;
end