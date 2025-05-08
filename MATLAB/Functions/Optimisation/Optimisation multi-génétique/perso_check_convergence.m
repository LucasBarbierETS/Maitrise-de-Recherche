function is_converged = perso_check_convergence(new_solution, local_optima, threshold)
    if isempty(local_optima)
        is_converged = false;
        return;
    end
    
    % Calcul de la distance par rapport aux optima locaux déjà enregistrés
    distances = arrayfun(@(i) perso_distance_metric(new_solution, local_optima(i, :)), 1:size(local_optima, 1));
    is_converged = any(distances < threshold);
end
