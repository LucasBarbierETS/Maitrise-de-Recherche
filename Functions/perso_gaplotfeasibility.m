function [state, options, optchanged] = perso_gaplotfeasibility(nonlcon, options, state, flag)
    persistent hFig hAx hLine feasibilityHistory

    optchanged = false; % pas de changement d'options

    % <<< À personnaliser ici selon ton problème
    tol_constraints = 1e-6; % tolérance sur les contraintes nonlin
    % >>>

    switch flag
        case 'init'
            hFig = figure('Name', 'Taux de viabilité de la population', 'NumberTitle', 'off');
            hAx = axes('Parent', hFig);
            hold(hAx, 'on');
            grid(hAx, 'on');
            xlabel(hAx, 'Génération');
            ylabel(hAx, 'Taux de viabilité (%)');
            title(hAx, 'Évolution du taux d''individus admissibles');
            hLine = plot(hAx, NaN, NaN, 'b-o', 'LineWidth', 1.5);
            feasibilityHistory = [];

        case 'iter'
            pop = state.Population;
            numIndiv = size(pop,1);
            is_feasible = false(numIndiv,1);

            for i = 1:numIndiv
                x = pop(i,:);
                
                % Vérif uniquement des contraintes non linéaires
                if ~isempty(nonlcon)
                    [c, ceq] = nonlcon(x);
                    c_ok = all(c <= tol_constraints);
                    ceq_ok = all(abs(ceq) <= tol_constraints);
                else
                    c_ok = true;
                    ceq_ok = true;
                end

                % Résultat global
                is_feasible(i) = c_ok && ceq_ok;
            end

            % Calcul du taux
            rate = sum(is_feasible) / numIndiv * 100;

            % Historique
            feasibilityHistory(end+1) = rate;

            % Update plot
            set(hLine, 'XData', 0:(length(feasibilityHistory)-1), 'YData', feasibilityHistory);
            ylim(hAx, [0 100]);
            drawnow;

        case 'done'
            % Rien
    end
end