function displayStructureFields(structure, prefix)
    if nargin < 2
        prefix = '';
    end

    fields = fieldnames(structure);
    for i = 1:numel(fields)
        field = fields{i};
        value = structure.(field);
        if isstruct(value)
            % Si le champ est une structure, appeler récursivement
            displayStructureFields(value, [prefix field '.']);
        else
            % Sinon, afficher le champ et sa valeur
            fprintf('%s%s: %s\n', prefix, field, mat2str(value));
        end
    end
end