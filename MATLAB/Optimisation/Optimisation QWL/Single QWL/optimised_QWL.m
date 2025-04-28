function [R_opti, L_opti] = optimised_QWL(R, r_init, shape, f_peak, bandwidth, alpha_max, Air, w)

    % Fonction d'objectif pour l'optimisation
    objective = @(params) sum((classQWL(R, params(1), params(2), shape).alpha(Air, w) - gabarit_QWL(w, f_peak, bandwidth, alpha_max)).^2);

    % Valeurs initiales du rayon et de la longueur
    R_QW = r_init;
    param = Air.parameters;
    c0 = param.c0;
    L_QW = c0 / (4 * f_peak);

    % Utiliser fminsearch pour optimiser les valeurs du rayon et de la longueur
    options = optimset('Display', 'iter', 'TolFun', 1e-6, 'MaxFunEvals', 1000);
    optimized_params = fminsearch(objective, [R_QW, L_QW], options);

    % Extraire les paramètres optimisés
    R_opti = optimized_params(1);
    L_opti = optimized_params(2);

    % Afficher les résultats
    disp(['Rayon optimal : ' num2str(R_opti)]);
    disp(['Longueur optimale : ' num2str(L_opti)]);
end