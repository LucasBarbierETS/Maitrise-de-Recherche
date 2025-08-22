function [c, ceq] = perso_nonlconf(x_ETS, N, NS, top_plate1, top_plate2, cavities_width, cavities_depth, phi_min, phi_max, radius) %, eval_r) % top_plate3, top_plate4,
    
    % Reshape pour obtenir les dimensions (N plaques, NV variables, NS solutions)
    % x_mat = reshape(x, N, NV, NS);

    ctp1_1 = phi_min - top_plate1.Configuration.Porosity;
    ctp1_2 = top_plate1.Configuration.Porosity - phi_max;
    ctp2_1 = phi_min - top_plate2.Configuration.Porosity;
    ctp2_2 = top_plate2.Configuration.Porosity - phi_max;
    % ctp3_1 = phi_min - top_plate3.Configuration.Porosity;
    % ctp3_2 = top_plate3.Configuration.Porosity - phi_max;
    % ctp4_1 = phi_min - top_plate4.Configuration.Porosity;
    % ctp4_2 = top_plate4.Configuration.Porosity - phi_max;
    
    % r = radius_mm(x_ETS(:, :, 1, :))*1e-3;
    r = radius;
    % histogram(r, 20);
    % Extraction des variables
    % r = fix(x_mat(:, 1, :));          % index du rayon dans la liste
    % dw  = x_mat(:, 2, :);             % espace entre les centres des perforations
    % dw  = x_mat(:, 1, :);
    dw  = x_ETS(:, :, 1, :);
    % histogram(dw, 20);
    % pd  = fix(x_mat(:, 3, :));        % nb de perforations en profondeur
    % pd  = fix(x_mat(:, 2, :));
    pw  = x_ETS(:, :, 2, :);
    % histogram(pw, 20);
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
    sw = (pw - 1).* dw + 2 .* r;
    % histogram(sw);
    % c1 = 3*r - dw;                        % dw > 3r (espacement inter-perforations)
    
    c2 = sw - cavities_width;             % sw < cav_width
    % histogram(c2, 20);
    % c4 = pw - pd;                         % pd > pw
    % c5 = cat(2, sw(:, 2:end, :), zeros(NS, 1, 1)) - sw;      % sw(i + 1) < sw(i) (monotonie des profils) 
    % c9 = cat(1, sw(2:end, :, :), zeros(1, 1, NS)) - sw + 1e-3;      % sw(i + 1) < sw(i) (monotonie des profils en profondeur) 

    % Calcul de la porosité : (pi * r^2 * pd) /  dw
    % porosity = (pi * r.^2 .* pd.^2) / (cavities_depth * cavities_width);
    porosity = (pi * r.^2 .* pw * 8) / (cavities_depth * cavities_width);
    % histogram(porosity);
    % Contraintes de porosité réelle entre 1% et 10% (contrainte mécanique)
    c6 = porosity - phi_max;   % porosité <= 15%
    % histogram(c6, 20);
    c7 = phi_min - porosity;   % porosité >= 0.5%
    % histogram(c7, 20);

    % Largeur totale perforée ≤ cavities_width
    % c8 = sw - cavities_width - 1e-3;

    % Combine toutes les contraintes d'inégalités
    % c = [c1(:); c2(:); c5(:); c6(:); c8(:)];
    % c = [c2(:), c5(:), c6(:), c7(:)];
    c = [ctp1_1, ctp1_2, ctp2_1, ctp2_2, c2(:)', c6(:)', c6(:)'];
    % c = [ctp1_1, ctp1_2, ctp2_1, ctp2_2, ctp3_1, ctp3_2, ctp4_1, ctp4_2, c2(:)', c6(:)', c6(:)'];
    % c = [reshape(c2, N*NS, [])', reshape(c6, N*NS, [])', reshape(c7, N*NS, [])'];
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