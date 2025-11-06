function tf = perso_isnan(obj)

    if isempty(obj)
        tf = true; % Vide -> considéré comme "tout NaN"
        return;
    end

    % Cas numériques (double, single, etc.)
    if isnumeric(obj)
        tf = all(isnan(obj), 'all');
        return;
    end

    % Cas logiques : jamais NaN
    if islogical(obj)
        tf = false;
        return;
    end

    % Cas cell array : appliquer récursivement
    if iscell(obj)
        tf = all(cellfun(@(x) perso_isnan(x), obj));
        return;
    end

    % Cas struct : appliquer récursivement sur chaque champ
    if isstruct(obj)
        fields = fieldnames(obj);
        tf = true;
        for k = 1:numel(obj)
            for f = 1:numel(fields)
                if ~perso_isnan(obj(k).(fields{f}))
                    tf = false;
                    return;
                end
            end
        end
        return;
    end

    % Cas objets avec propriété ou méthode isnan
    if isobject(obj)
        % Si methode isnan dispo
        if ismethod(obj, 'isnan')
            tf = all(isnan(obj), 'all');
            return;
        end
        % Sinon tente les propriétés publiques si tableau d’objets
        props = properties(obj);
        if ~isempty(props)
            tf = true;
            for k = 1:numel(obj)
                for p = 1:numel(props)
                    if ~perso_isnan(obj(k).(props{p}))
                        tf = false;
                        return;
                    end
                end
            end
            return;
        end
    end
    
    tf = false;
end
