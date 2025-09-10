classdef perso_classViolationPlotFunction
    
    properties
        Axes  % Axe sur lequel le graphique sera tracé
        IsSupported = 1  % Indique si la fonction est supportée pour l'optimisation
        Plot_I  % L'objet graphique de type scatter (ou autre)
        IsAvailableForUpdate = 1  % Permet de vérifier si le graphique est prêt à être mis à jour
        EmptyData = NaN  % Valeurs vides pour initialiser
    end
    
    methods

        % Constructeur
        function obj = perso_classViolationPlotFunction()
            % Créer un axe et un graphique vide au début
            obj.Axes = axes;
            hold on;
            obj.Plot_I = scatter(NaN, NaN, 'MarkerEdgeColor', 'r');  % Initialiser avec un scatter vide
            title('Évolution des violations des contraintes');
            xlabel('Itérations');
            ylabel('Nombre total de violations');
            grid on;
        end
        
        % Méthode pour mettre à jour les données du graphique
        function obj = updatePlot(obj, iterationCount, violationHistory)
            % Mise à jour des données sur le graphique
            set(obj.Plot_I, 'XData', 1:iterationCount, 'YData', violationHistory);
            drawnow;  % Met à jour l'affichage
        end
    end
end