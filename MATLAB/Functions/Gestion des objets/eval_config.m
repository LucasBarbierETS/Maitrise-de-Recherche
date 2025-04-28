function config = eval_config(config, env)
    % Evalue les handles de fonction dans une structure de configuration.
    % 
    % Arguments :
    % config - Structure de configuration à évaluer.
    % env - Variable d'environnement à passer aux handles de fonction.
    %
    % Retourne :
    % config - Structure de configuration avec les handles de fonction évalués.

    fields = fieldnames(config);

    for i = 1:numel(fields)
        field = fields{i};
        value = config.(field);

        if isa(value, 'function_handle')
            % Si la valeur est un handle de fonction, l'évaluer avec env.
            config.(field) = value(env);
        elseif isstruct(value)
            % Si la valeur est une structure, appeler récursivement eval_config.
            config.(field) = eval_config(value, env);
        end
    end
end
