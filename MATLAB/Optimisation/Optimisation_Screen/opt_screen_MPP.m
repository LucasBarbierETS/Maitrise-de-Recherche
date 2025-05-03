% Cette fonction a pour but d'optimiser les paramètres d'un écran résistif rigide perforé, 
% modélisé à l'aide du modèle de fluide équivalent (JCA) appliqué au cas des plaques microperforées (MPP)
% Cette fonction cherche à trouver le(s) groupe(s) de paramètres qui
% "neutralise(nt)" l'effet d'un écran résistif placé à une certaine distance de la solution

function x_opti = opt_screen_MPP(solution, distance, screen_thickness, env, screen_handle, x0, lb, ub)

    arguments
        solution 
        distance double
        screen_thickness double
        env
        screen_handle function_handle = @(phi, r, t, s) classMPP_Circular(classMPP_Circular.create_config(phi, r, t, s))
        x0 double = [5e-2, 2e-3]
        lb double = [1e-2 5e-3]
        ub double = [20e-2 1e-2]
    end

    % Définition de la fréquence max en fonction de la taille de la cellule
    air_parameters = env.air.parameters;
    c0 = air_parameters.c0;
    % fmax = c0/(2*sqrt(solution.Configuration.InputSection));
    fmax = 2000;

    input_section = solution.Configuration.InputSection;
    serial_handle_assembly = @(params) classelement(classelement.create_config( ...
                                                        {screen_handle(params{:}, screen_thickness, input_section), ...
                                                        classcavity(classcavity.create_config(distance, input_section)), ...
                                                        solution}, ...
                                                    'closed', input_section));

    % On définit l'intervale fréquenciel d'évaluation de la fonction coût
    g = @(env) (env.w / (2*pi) > 150 & env.w / (2*pi) < fmax);

    % On calcule la différence entre le coefficient d'absorption avec et sans l'écran
    cost_function = @(params, env) sum(((serial_handle_assembly(num2cell(params)).alpha(env) ... % avec
                                         - solution.alpha(env)) ... % sans
                                            .* (g(env) > 0.1)) ... % filtrage de la bande de fréquence d'interêt
                                                .^2);

    objective = @(params) cost_function(params, env);

    % On optimise à l'aide de l'algorithme génétique
    options = optimoptions('ga', 'Display', 'iter', 'MaxGenerations', 5, 'InitialPopulationMatrix', x0);
    [x_opti, ~] = ga(objective, length(x0), [], [], [], [], lb, ub, [], [], options);

    % Résultats
    figure()
    hold on
    plot(env.w/(2*pi), solution.alpha(env), 'DisplayName', 'sans écran résistif');
    plot(env.w/(2*pi), serial_handle_assembly(num2cell(x_opti)).alpha(env), 'DisplayName', 'avec écran résistif optimisé');
    legend();
end
