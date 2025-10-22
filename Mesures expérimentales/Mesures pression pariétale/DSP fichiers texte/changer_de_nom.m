% Sélectionner les fichiers à renommer
[files, path] = uigetfile('*.*', 'Sélectionner les fichiers à renommer', 'MultiSelect', 'on');

% Vérifie si plusieurs fichiers sont sélectionnés
if isequal(files, 0)
    disp('Aucun fichier sélectionné.');
    return;
elseif ischar(files)
    files = {files};  % Convertir en cellule si un seul fichier est sélectionné
end

% Parcourir les fichiers et renommer
for i = 1:length(files)
    oldName = files{i};
    newName = strrep(oldName, '_', '');  % Supprime tous les underscores

    % Si le nom a changé
    if ~strcmp(oldName, newName)
        oldPath = fullfile(path, oldName);
        newPath = fullfile(path, newName);
        
        % Renommer le fichier
        movefile(oldPath, newPath);
        fprintf('Renommé : %s → %s\n', oldName, newName);
    else
        fprintf('Pas de changement pour : %s\n', oldName);
    end
end
