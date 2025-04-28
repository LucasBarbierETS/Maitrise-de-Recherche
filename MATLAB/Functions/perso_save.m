function perso_save(dossier)
    % Vérifie si le dossier existe, sinon le crée
    if ~exist(dossier, 'dir')
        mkdir(dossier);
    end
    
    % Obtient les noms de toutes les variables de l'espace de travail
    vars = who;
    
    % Parcours de chaque variable
    for i = 1:length(vars)
        varName = vars{i};  % Nom de la variable
        varValue = eval(varName);  % Valeur de la variable
        
        % Vérification si la variable est un objet de classe
        if isobject(varValue)
            % Si c'est un objet, on enregistre avec le type d'objet
            className = class(varValue);
            save(fullfile(dossier, [varName, '_', className, '.mat']), 'varValue');
            fprintf('Objet de la classe "%s" sauvegardé sous "%s_%s.mat".\n', ...
                    className, varName, className);
        else
            % Si ce n'est pas un objet, on enregistre normalement
            save(fullfile(dossier, [varName, '.mat']), 'varValue');
            fprintf('Variable "%s" sauvegardée sous "%s.mat".\n', varName, varName);
        end
    end
end
