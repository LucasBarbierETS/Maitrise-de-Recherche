function debug_panels(app) 

    % Cette fonction permet d'afficher l'état de visibilité de tous les tableaux présents dans l'interface de l'application

    % Récupérer tous les uipanel dans la figure
    panels = findall(app.UIFigure, 'Type', 'uipanel');
    
    for i = 1:length(panels)
        panel = panels(i);
        panelTitle = get(panel, 'Title');
        
        if isempty(panelTitle)
            panelTitle = 'Sans Titre';
        end
        
        % Vérifier la visibilité
        isVisible = get(panel, 'Visible');
        parentVisible = get(panel.Parent, 'Visible');
        
        % Afficher les informations avec les Handles
        fprintf('Panel "%s" (Handle: %f) est %s (Parent visible: %s)\n', ...
            panelTitle, double(panel), isVisible, parentVisible);
    end

end