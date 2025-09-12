function [c, ceq] = perso_nonlconf_1_solution(config, depth_holes_number, cavities_width, cavities_depth) %, phi_min, phi_max)
    
    r = config(1, :, 1);
    dw  = config(1, :, 2);
    pw  = config(1, :, 3);
    sw = (pw - 1) .* dw + 2 .* r;
    porosity = (pi * r.^2 .* pw * depth_holes_number) / (sw * cavities_depth);
    
    c1 = sw - cavities_width; 
    % c2 = porosity - phi_max; 
    % c3 = phi_min - porosity; 

    % Combine toutes les contraintes d'inégalités
    % c = [c1(:)', c2(:)', c3(:)'];
    c = c1(:)';
    % histogram(find(c>0), 20);

    % % Debog : Affichage des contraintes de la populations
    % if ~isempty(find(c>0)')
    %     f = figure();
    %     r = sum(c>0, 1)/size(c, 1);
    %     % bar(["largeur de fente", "monotonie des profils", "porosité >", "porosité<"], r);
    %     bar(["largeur de fente", "porosité >", "porosité<"], r);
    %     ylim([0 1])
    %     close(f);
    % end

    % Pas de contrainte d'égalité
    ceq = [];
end