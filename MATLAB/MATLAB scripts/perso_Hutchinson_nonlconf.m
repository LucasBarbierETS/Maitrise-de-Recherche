function [c, ceq] = perso_Hutchinson_nonlconf(x, top_plate, phi_max)

    c = top_plate(x).Configuration.Porosity - phi_max;

    % % Debog : Affichage des contraintes de la populations
    % if ~isempty(find(c>0)')
    %     f = figure();
    %     r = sum(c>0, 1)/size(c, 1);
    %     bar("porosité >", r);
    %     ylim([0 1])
    %     close(f);
    % end

    ceq = [];
end