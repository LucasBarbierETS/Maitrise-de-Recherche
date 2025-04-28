function perf = multiQWL_cost_function(X_actual, Y_pred, air, w)
    % Cette fonction de perte est utilisée dans le cadre de l'apprentissage supervisé d'un réseau de neurone avec python.
    % A chaque appel de la fonction de perte : 
    % X_actual correspond au donnée d'entrée de réseau soit les points de la courbe d'absorption cible
    % Y_pred correspond aux jeux de configurations prédits par le réseau en association avec les données de X_actual
            
    % fprintf('\nType d''objet associé au vecteur des données d''entrée : %s\n', mat2str(class(X_actual)));
    % fprintf('\nDimensions du vecteur des données d''entrée  : %s\n', mat2str(size(X_actual)));
    % fprintf_struct(air.parameters);

    % On vérifie que la fonction est appelée
    fprintf('La fonction MATLAB a été appelée.\n');

    % Initialisation
    num_samples = size(X_actual, 1);
    X_computed = zeros(size(X_actual));
    penality = 0;

    % Calcul des sorties à partir des prédictions des entrées
    for k = 1:num_samples
        % On vérifie qu'il est possible de déterminer une réponse acoustique pour la configuration prédite
        if all(Y_pred(k, :) > 0)
            config = classmultiQWL.read_free_square_config(Y_pred(k, :));
            
            % fprintf_struct(config);

            X_computed(k, :) = classmultiQWL(config).alpha(air, w);
        else
            % Si ce n'est pas le cas on ajoute une pénalité
            penality = penality + 10;
            X_computed(k, :) = X_actual(k, :);
        end
    end

    % On calcule n'erreur quadratique sur les données valides AUTRES FACONS POSSIBLES DE CALCULER LE COUT
    diff = X_actual - X_computed;
    mse = mean(sum(diff.^2, 2));

    % On ajoute la pénalité à la performance finale
    perf = mse + penality;

    disp(perf)

end
