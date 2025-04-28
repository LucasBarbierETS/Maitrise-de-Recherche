function targetStruct = perso_transfer_fields(sourceStruct, targetStruct)
    % Transfère les champs de sourceStruct à targetStruct.
    %
    % Args:
    %     sourceStruct : structure source contenant les champs à transférer
    %     targetStruct : structure cible recevant les champs de la source
    %
    % Returns:
    %     targetStruct : structure cible mise à jour

    % Obtenir les noms de champs de la structure source
    fields = fieldnames(sourceStruct);

    % Boucle sur chaque champ pour le transférer dans la structure cible
    for i = 1:numel(fields)
        field = fields{i};
        targetStruct.(field) = sourceStruct.(field);
    end
end
