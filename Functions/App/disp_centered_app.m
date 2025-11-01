function disp_centered_app(app)
    % Récupère la taille de l'écran
    screenSize = get(0, 'ScreenSize');  % [x y width height]
    
    % Taille de la fenêtre de l'app
    appWidth = app.UIFigure.Position(3);
    appHeight = app.UIFigure.Position(4);
    
    % Calcul des coordonnées centrées
    app.UIFigure.Position(1) = (screenSize(3) - appWidth) / 2;
    app.UIFigure.Position(2) = (screenSize(4) - appHeight) / 2;
end