function [c, ceq] = perso_MPPSBHr_nonlconf(x, NV, NS, N, cavities_width, cavities_depth) %, eval_r)
    
    % Reshape pour obtenir les dimensions (N plaques, NV variables, NS solutions)
    % x_mat = reshape(x, N, NV, NS);

    % Extraction des variables
    % r = fix(x_mat(:, 1, :));          % index du rayon dans la liste
    % dw  = x_mat(:, 2, :);             % espace entre les centres des perforations
    % dw  = x_mat(:, 1, :);
    dw  = x(:, :, 1);
    % pd  = fix(x_mat(:, 3, :));        % nb de perforations en profondeur
    % pd  = fix(x_mat(:, 2, :));
    pw  = x(:, :, 2);
    % pw  = fix(x_mat(:, 4, :));        % nb de perforation en largeur

    % pd  = fix(x_mat(:, 1, :));        % nb de perforations en profondeur
    % pw  = fix(x_mat(:, 2, :));        % nb de perforation en largeur

    % % Calcul des rayons réels
    % r = transpose(eval_r(r));
    % r = eval_r(r);

    % % Si la profondeur est 1, assure que la sortie reste 3D avec une profondeur de 1
    % if size(r, 3) == 1
    %     r = reshape(r, [size(r, 1), size(r, 2), 1]);
    % end
    % % r = repmat(eval_r(1), N, 1, NS);
    % % dw = repmat(3 * eval_r(1), N, 1, NS);
    
    % Contraintes non linéaires existantes :
    sw = pw .* dw;
    % c1 = 3*r - dw;                        % dw > 3r (espacement inter-perforations)
    
    c2 = sw - cavities_width;             % sw < cav_width
    % c4 = pw - pd;                         % pd > pw
    % c5 = cat(2, sw(:, 2:end, :), zeros(NS, 1, 1)) - sw;      % sw(i + 1) < sw(i) (monotonie des profils) 
    % c9 = cat(1, sw(2:end, :, :), zeros(1, 1, NS)) - sw + 1e-3;      % sw(i + 1) < sw(i) (monotonie des profils en profondeur) 

    % Calcul de la porosité : (pi * r^2 * pd) /  dw
    % porosity = (pi * r.^2 .* pd.^2) / (cavities_depth * cavities_width);
    porosity = (pi * 4.5e-4^2 .* pw * 8) / (cavities_depth * cavities_width);

    % Contraintes de porosité réelle entre 1% et 10% (contrainte mécanique)
    c6 = porosity - 0.15;   % porosité <= 15%
    c7 = 0.005 - porosity;   % porosité >= 0.5%

    % Largeur totale perforée ≤ cavities_width
    % c8 = sw - cavities_width - 1e-3;

    % Combine toutes les contraintes d'inégalités
    % c = [c1(:); c2(:); c5(:); c6(:); c8(:)];
    % c = [c2(:), c5(:), c6(:), c7(:)];
    c = [c2(:), c6(:), c7(:)];

    % % Debog : Affichage des contraintes de la populations
    % if ~isempty(find(c>0)')
    %     f = figure();
    %     r = sum(c>0, 1)/size(c, 1);
    %     bar(["largeur de fente", "monotonie des profils", "porosité >", "porosité<"], r);
    %     ylim([0 1])
    %     close(f);
    % end

    % Pas de contrainte d'égalité
    ceq = [];
end