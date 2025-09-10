function stop = perso_plotMaxDistancePlotFcn(options, state, flag)
    stop = false;

    persistent hFig hAx

    switch flag
        case 'init'
            % Nouvelle figure dédiée à la distance max
            hFig = figure('Name','Distance max entre individus','NumberTitle','off');
            hAx = axes('Parent', hFig);
            hold(hAx, 'on');
            xlabel(hAx, 'Génération');
            ylabel(hAx, 'Distance max');
            title(hAx, 'Évolution de la diversité dans la population');

        case 'iter'
            pop = state.Population;

            if size(pop, 1) > 1
                D = pdist(pop);           % distances paires
                maxDist = max(D);         % distance max
            else
                maxDist = 0;
            end

            plot(hAx, state.Generation, maxDist, 'ro');

        case 'done'
            % Rien à faire ici
    end
end
