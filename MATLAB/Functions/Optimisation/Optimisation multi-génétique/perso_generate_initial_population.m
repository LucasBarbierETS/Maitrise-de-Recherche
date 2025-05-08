function initial_population = perso_generate_initial_population(N_points, N_solutions, N_variables, N_plates, lb, ub, intcon)

    % On crée une matrice de dimension 4 pour stocker les points de départs à construire
    initial_population = zeros(N_plates, N_variables, N_solutions, N_points);

    % On crée alétoirement les points de départs souhaités à partir d'un
    % tirage uniforme entre les limites inférieures et supérieurs de chaque variable
    for i = 1:N_points
        x0 = lb + (ub - lb) .* rand(N_plates, N_variables, N_solutions);

        % On arrondit les variables alétoires contraintes à être des
        % nombres entiers
        x0(intcon) = round(x0(intcon));

        % On ajoute le point de départ à la liste
        initial_population(:, :, :, i) = x0;
    end
end