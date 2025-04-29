function [c, ceq] = perso_MPPSBHr_nonlconf(x, NV, NS, N, cavities_width, cavities_depth, eval_r)
    
    % Reshape pour obtenir les dimensions (N plaques, NV variables, NS solutions)
    x_mat = reshape(x, [N, NV, NS]);

    % Extraction des variables
    r = (x_mat(:, 1, :));           % index du rayon dans la liste
    dw  = (x_mat(:, 2, :));           % espace entre perfo
    pd  = (x_mat(:, 3, :));           % nb de perfo profondeur
    pw  = (x_mat(:, 4, :));           % nb de perfo largeur

    % Calcul des rayons réels
    r = eval_r(r)';

    % Contraintes non linéaires existantes :
    sw = pw .* dw;
    % c1 = 4*r - dw;                        % dw > 4r (espacement inter-perforations)
    c2 = sw - cavities_width;             % sw < cav_width
    c4 = pw - pd;                         % pd > pw
    c5 = vertcat(sw(2:end), 0) - sw;      % sw(i + 1) < sw(i) (monotonie des profils) 

    % Calcul de la porosité : (pi * r^2 * pd) /  dw
    porosity = (pi * r.^2 .* pd .* pw) / (cavities_depth * cavities_width);

    % Contraintes de porosité réelle entre 1% et 10% (contrainte mécanique)
    c6 = porosity - 0.10;   % porosité <= 10%
    c7 = 0.01 - porosity;   % porosité >= 1%

    % Largeur totale perforée ≤ cavities_width
    c8 = sw - cavities_width - 1e-3;

    % Combine toutes les contraintes d'inégalités
    c = [c2(:); c4(:); c5(:); c6(:); c7(:); c8(:)];

    % Pas de contrainte d'égalité
    ceq = [];
end