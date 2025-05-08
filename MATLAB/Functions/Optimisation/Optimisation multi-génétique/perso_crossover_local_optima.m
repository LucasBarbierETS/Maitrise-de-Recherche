function [childs, crossover_possible] = perso_crossover_local_optima(parents, N, NV, NS, lb, ub, crossover_threshold)
    
    % On définit une matrice vide pour recevoir la nouvelle génération engendrée
    childs = [];

    % On récupère le nombre de parents sélectionnés
    num_optima = size(parents, 1);

    % On définit la matrice des distances entre les parents
    
    distance_matrix = perso_distance_metric(parents, lb, ub);
    50compatible_parents = distance_matrix < crossover_threshold;
    
    % On récupère

    % On définit le nombre d'enfant que l'on veut obtenir à partir d'une
    % population de parents
    for i = 1:N_points

        % On sélectionne aléatoirement un parent...
        parent1 = local_optima(randi(num_optima), :);

        % Puis un autre
        parent2 = local_optima(randi(num_optima), :);

        % Croisement des parents : on créer un croisement en prenant le
        % début du parent 1 et la fin du parent 2 (autres options possibles)
        crossover_point = randi([1, N * NV * NS]);
        offspring = [parent1(1:crossover_point), parent2(crossover_point+1:end)];
        
        % Mutation aléatoire : On choisit un paramètre alétoire de
        % l'individu croisé et on le mute avec un bruit gaussien
        mutation_idx = randi([1, N * NV * NS]);
        offspring(mutation_idx) = offspring(mutation_idx) + 0.01 * randn;
        
        new_populations{i} = reshape(offspring, N, NV, NS);
    end
end
