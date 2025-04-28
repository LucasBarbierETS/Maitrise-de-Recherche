function multi_QWL_opti = optimise_multiQWL(config, params, gabarit, air, w, num_starts)

    %% Description

    % 'config' est une structure de géométrie quelconque. Ses attributs sont associés à des valeurs (scalaires) ou des variables 
    % muettes (chaine de caractères).

    % 'params' est une structure contenant les variables muettes de l'optimisation
    % Le vecteur associé à chaque variable est de la forme : [valeur initiale, borne inférieur, borne supérieur]
 
    addpath ("C:\Users\Utilisateur\OneDrive - ETS\CRIAQ-REAR\Maitrise LB\Classes")
    addpath ("C:\Users\Utilisateur\OneDrive - ETS\CRIAQ-REAR\Maitrise LB\Functions\Optimisation")
    addpath ("C:\Users\Utilisateur\OneDrive - ETS\CRIAQ-REAR\Maitrise LB\Classes\QWL_classes");

    %% Valeurs initiales, bornes inf et sup

    [~, x0, lb, ub] = decon_struct(params);

    %% Contraintes non linéaires

    function [c, ceq] = nonlcon_fun(config, params, values)
    % Cette fonction évalue les contraintes non-linéaires d'une configuration donnée

        % On adresse les valeurs courantes stockées dans le vecteur 'values' dans la structure 'params' 
        % pour les mettre à jour
        params = update_params_values(params, values);

        % On remplace les variables muettes présentes dans la structure par leur valeurs courantes 
        config = replace_fields(config, params);

        % On calcule la valeur des contraintes non-linéaires avec la configuration réévaluée
        c1 = config.Radius .* 2 - config.Length;
        c2 = sum(pi * config.Radius.^2) - config.TotalSurface;
        c3 = [-config.Radius, -config.Length];
        c = [c1(:)', c2(:)', c3(:)'];
        ceq = [];
    end

    % On définit au départ la configuration sur laquelle on travaille et elle ne sera jamais mise a jour en tant que tel.
    % La mise a jour se produira sur une copie de la configuration au cours de la méthode d'optimisation pour fournir 
    % les contraintes non linéaires 
    nonlcon = @(values) nonlcon_fun(config, params, values);

    %% Fonction cout pour l'optimisation globale

    function ojective = objective_multiQWL(config, params, values, gabarit, air, w)
    % Cette fonction évalue la fonction coût pour une configuration et un gabarit données

        % On adresse les valeurs courantes stockées dans le vecteur 'values' dans la structure 'params' 
        % pour les mettre à jour
        params = update_params_values(params, values);
    
        % On remplace les variables muettes présentes dans la structure par leur valeurs courantes 
        config = replace_fields(config, params);
        
        % On calcule la fonction coût pour la configuration réévaluée. Ici on calcule la somme des écarts au carré entre la réponse 
        % et le gabarit
        alpha_model = classmultiQWL(config).alpha(air, w);
        ojective = sum((alpha_model - gabarit).^2);

    end

    objective = @(values) objective_multiQWL(config, params, values, gabarit, air, w);

    %% Structure du problème

    % Créer un problème pour MultiStart
    problem = createOptimProblem('fmincon', 'objective', objective, 'x0', x0, 'lb', lb, 'ub', ub, 'nonlcon', nonlcon);

    % Créer un objet MultiStart
    ms = MultiStart('UseParallel', true, 'Display', 'iter');

    % Effectuer l'optimisation avec MultiStart
    [values_opti, ~] = run(ms, problem, num_starts);

    % Reconstituer le vecteur des paramètres contenant les paramètres
    % optimisés
    params = update_params_values(params, values_opti);
    config_opti = replace_fields(config, params);
    multi_QWL_opti = classmultiQWL(config_opti);

    % Affichage des paramètres de la configuration
    % plot_figures_multi_QWL(multi_QWL_opti, config_opti, gabarit, air, w);
    % parametres_config_multi_QWL(config, n, shape);

end