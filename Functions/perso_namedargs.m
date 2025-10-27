function c = perso_namedargs(namedargs)
% perso_namedargs  Supprime les champs vides ou NaN d'une structure d'options
%
%   c = perso_namedargs(namedargs)
%
%   - Supprime les NaN scalaires
%   - Supprime les tableaux uniquement composés de NaN
%   - Supprime les structures dont tous les champs sont invalides
%   - Supprime les champs vides ([] ou '')

    if isempty(namedargs)
        c = {};
        return
    end

    allArgs = namedargs2cell(namedargs);
    c = {};

    for k = 1:2:numel(allArgs)
        name = allArgs{k};
        value = allArgs{k+1};

        if is_valid_value(value)
            c = [c, {name, value}]; %#ok<AGROW>
        end
    end
end


function tf = is_valid_value(val)
% Retourne true si la valeur est "valide"

    % Cas vide
    if isempty(val)
        tf = false;
        return
    end

    % Cas numérique (réel ou complexe)
    if isnumeric(val)
        % Si c’est un seul NaN → invalide
        if isscalar(val) && isnan(val)
            tf = false;
            return
        end
        % Si c’est un tableau et tous les éléments sont NaN → invalide
        if all(isnan(real(val(:))) & isnan(imag(val(:))))
            tf = false;
            return
        end
        tf = true;
        return
    end

    % Cas structure : valide si au moins un champ valide
    if isstruct(val)
        if isempty(fieldnames(val))
            tf = false;
            return
        end
        tf = any(structfun(@is_valid_value, val));
        return
    end

    % Autres types (char, logical, etc.)
    tf = true;
end
