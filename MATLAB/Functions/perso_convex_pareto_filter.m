function [pareto_points, index] = perso_convex_pareto_filter(scores)
    % scores : Matrice Nx2 avec chaque ligne [score1, score2]
    % pareto_points : Les points qui dessinent le contour convexe
    
    % Étape 1 : Trier les points selon le premier objectif
    sorted_scores = sortrows(scores, 1);  % Tri croissant selon score1
    
    % Initialiser les points Pareto avec le premier point trié
    pareto_points = sorted_scores(1, :);
    current_best = sorted_scores(1, 2);   % Meilleur score2 actuel
    index = 1;

    % Parcourir les points triés
    for i = 2:size(sorted_scores, 1)
        % Si le score2 du point courant est strictement inférieur au meilleur précédent
        if sorted_scores(i, 2) < current_best
            % Ajouter ce point à la liste des points du contour convexe
            pareto_points = [pareto_points; sorted_scores(i, :)];
            % Mettre à jour le meilleur score2
            current_best = sorted_scores(i, 2);
            index = [index, i];
        end
    end
end
