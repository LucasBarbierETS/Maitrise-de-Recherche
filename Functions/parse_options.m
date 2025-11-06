function options = parse_options(user_options, default_options, valid_choices)
    if nargin < 2 || isempty(user_options)
        user_options = struct();
    end
    if nargin < 4
        valid_choices = struct(); % Par défaut, aucune contrainte
    end

    % 1. Commence par les valeurs par défaut
    options = default_options;

    % 2. Surcharge avec les valeurs fournies par l’utilisateur
    user_fields = fieldnames(user_options);
    for i = 1:numel(user_fields)
        options.(user_fields{i}) = user_options.(user_fields{i});
    end

    % 3. Valide uniquement si nécessaire
    validated_fields = fieldnames(valid_choices);
    for i = 1:numel(validated_fields)
        field = validated_fields{i};
        if isfield(options, field)  % si jamais l'utilisateur l'a fourni
            valid_values = valid_choices.(field);
            if ~any(strcmp(options.(field), valid_values))
                warning('Option "%s" invalide (%s). Replacée par valeur par défaut (%s).', ...
                    field, string(options.(field)), string(default_options.(field)));
                options.(field) = default_options.(field);
            end
        end
    end
end
