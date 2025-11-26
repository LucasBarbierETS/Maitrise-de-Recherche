%% ========================================================================
%  MODULE D'OPTIMISATION: CONDITIONNEMENT DES CONFIGURATIONS OPTIMISEES
% =========================================================================

%% Conditionnement du vecteur d'optimisation

xopti_to_cell_array_of_alpha = @(x, env) arrayfun(@(i) vertcat(Objects.assembly(xopti(i, :)).absorption_coefficient(env, {})), ...
                                                       1:size(x, 1), 'UniformOutput', false);


xopti_to_cell_array_of_Zs = @(x, env) arrayfun(@(i) vertcat(Objects.assembly(xopti(i, :)).surface_impedance(env, {})/env.air.parameters.Z0), ...
                                                    1:size(x, 1), 'UniformOutput', false);

% On récupère les vecteurs d'absorption des meilleures configurations
[sorted_scores_opti, sorted_index_opti] = sort(fval);
sorted_xopti = xopti(sorted_index_opti(:, 1), :);
filtered_alpha = xopti_to_cell_array_of_alpha(sorted_xopti, env);
filtered_Zs = xopti_to_cell_array_of_Zs(sorted_xopti, env);

% Tracé interractif des meilleurs résultats de l'optimisation multi objectif
perso_interactive_multi_plot(env.w/(2*pi), filtered_alpha, filtered_Zs, 2000, Frequences);

% On rajoute des barres pour représenter les bandes d'optimisation
perso_plot_targetted_frequencies(Frequences, 1)