function [c, ceq] = perso_top_plate_nonlconf(top_plate, phi_min, phi_max)

    c1 = phi_min - top_plate.Configuration.Porosity;
    c2 = top_plate.Configuration.Porosity - phi_max;
    c = [c1, c2];

    % % Debog : Affichage des contraintes de la populations
    % if ~isempty(find(c>0)')
    %     f = figure();
    %     r1 = sum(c1>0, 1)/size(c1, 1);
    %     r2 = sum(c2>0, 1)/size(c2, 1);
    %     bar(["porosité < min", "porosité > max"], [r1, r2]);
    %     ylim([0 1])
    %     close(f);
    % end
    ceq = [];
end