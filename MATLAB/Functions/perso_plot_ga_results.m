function perso_plot_ga_results(fval, output, population, scores)
    
% Affichage de la valeur de la fonction objectif à chaque génération
    figure;
    subplot(2, 2, 1);
    plot(fval, 'LineWidth', 2);
    title('Convergence de la fonction objectif');
    xlabel('Générations');
    ylabel('Valeur de la fonction objectif');
    
    % Affichage de l'état de la population au fil des générations
    subplot(2, 2, 2);
    plot(population');
    title('Évolution de la population');
    xlabel('Générations');
    ylabel('Valeur des individus');
    
    % Affichage des scores de la population
    subplot(2, 2, 3);
    plot(scores');
    title('Scores de la population');
    xlabel('Générations');
    ylabel('Score de chaque individu');
    
    % Informations sur l'exécution de l'algorithme
    subplot(2, 2, 4);
    text(0.1, 0.8, ['Message: ', output.message], 'FontSize', 10);
    text(0.1, 0.6, ['Nombre de générations: ', num2str(output.generations)], 'FontSize', 10);
    text(0.1, 0.4, ['Nombre d''évaluations de la fonction: ', num2str(output.funccount)], 'FontSize', 10);
    text(0.1, 0.2, ['Contrainte maximale: ', num2str(output.maxconstraint)], 'FontSize', 10);
    title('Informations sur l''optimisation');
end
