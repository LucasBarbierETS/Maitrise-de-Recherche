function fig = perso_figure(figID)

% Crée ou récupère une figure identifiée par un nom ou tag
% figID : string ou char (nom ou tag de la figure)
% Retourne le handle de la figure

    % Vérifie si une figure avec le Tag existe déjà
    fig = findall(0, 'Type', 'figure', 'Tag', figID);
    
    if isempty(fig) || ~isvalid(fig)
        % Crée une nouvelle figure
        fig = figure('Name', figID, 'Tag', figID);
    else
        % Réutilise la figure existante
        figure(fig);  % Met la figure au premier plan
        hold on
        % clf(fig);     % Vide le contenu si tu veux un nouvel affichage
    end
end