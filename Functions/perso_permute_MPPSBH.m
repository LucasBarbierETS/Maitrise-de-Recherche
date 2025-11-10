function MPPSBH_permuted = perso_permute_MPPSBH(MPPSBH_base, order)
%% ========================================================================
%  Crée un nouvel objet MPPSBH_Rectangular à partir d’un autre
%  en permutant simplement l’ordre des plaques selon un vecteur donné.
%
%  Les champs de longueur > Np (par ex. Np+1 à cause de la terminaison)
%  sont tronqués à Np avant permutation.
%
%  INPUTS :
%   - MPPSBH_base : objet existant de type classMPPSBH_Rectangular
%   - order       : vecteur d’indices (ex. [10 9 8 ... 1])
%
%  OUTPUT :
%   - MPPSBH_permuted : nouvel objet avec plaques réordonnées
%
%  Auteur : Lucas Barbier / GPT-5
% ========================================================================

    % --- Vérification de base ---
    if ~isstruct(MPPSBH_base.Configuration)
        error('L''objet fourni ne contient pas de champ .Configuration structuré.');
    end
    config = MPPSBH_base.Configuration;

    Np = config.NumberOfPlates;
    if length(order) ~= Np
        error('La taille du vecteur d''ordre (%d) doit correspondre au nombre de plaques (%d).', length(order), Np);
    end

    % --- Copie de base ---
    new_config = config;

    % ==========================
    % Champs associés aux plaques
    % ==========================
    fields_plate = { ...
        'PlatesThickness', ...
        'PlatesHolesRadius', ...
        'PlatesPorosity', ...
        'CavitiesThickness', ...
        'MainPoresWidth', ...
        'MainPoresDepth'};

    for f = 1:numel(fields_plate)
        field = fields_plate{f};
        if isfield(config, field)
            vals = config.(field);
            nvals = numel(vals);

            % Tronquer si plus de valeurs que de plaques
            if nvals > Np
                vals = vals(1:Np);
            end

            % Étendre si jamais il en manque
            if nvals < Np
                vals(end+1:Np) = vals(end);
            end

            % Appliquer permutation
            new_config.(field) = vals(order);
        end
    end

    % ==========================
    % Sous-éléments éventuels
    % ==========================
    if isfield(config, 'ListOfObjects') && numel(config.ListOfObjects) >= Np
        new_config.ListOfObjects(1:Np) = config.ListOfObjects(order);
    end

    % ==========================
    % Création du nouvel objet permuté
    % ==========================
    MPPSBH_permuted = classMPPSBH_Rectangular(new_config);

    fprintf('[perso_permute_MPPSBH] Permutation appliquée : %s\n', mat2str(order));
end