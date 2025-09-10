% Définir une fonction de sortie pour collecter les valeurs des générations
function perso_track_population_values(options, state, flag)
    persistent allGenerations;  % Variable persistante pour stocker les données à travers les générations
    
    % Collecter la population de la génération actuelle
    if isempty(allGenerations)
        allGenerations = [];  % Initialiser le tableau si c'est la première itération
    end
    
    % Ajouter les valeurs de la population actuelle aux données collectées
    allGenerations = [allGenerations; state.Population];
    
    % Si l'optimisation est terminée, afficher la distribution des valeurs
    if strcmp(flag, 'done')
        figure;
        % Afficher un histogramme pour chaque variable
        numVars = size(allGenerations, 2);
        for i = 1:numVars
            subplot(numVars, 1, i);
            histogram(allGenerations(:, i), 'Normalization', 'probability');
            title(['Distribution des valeurs de la variable ', num2str(i)]);
        end
    end
end
