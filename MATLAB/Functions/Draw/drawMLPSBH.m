function drawMLPSBH(Configuration)
    % Initialisation de la figure
    figure;
    hold on;
    
    % Couleurs pour les perforations (du noir au blanc)
    colormap(gray);
    
    % Facteur d'agrandissement pour l'épaisseur des plaques et les cercles
    thickness_multiplier = 1;
    hole_radius_multiplier = 1;
    
    % Coordonnées de départ pour la première couche
    y_current = 0;
    
    % Rayon total de la structure
    total_radius = Configuration.SBHRadius;
    
    % Parcourir les plaques et cavités
    numPlates = length(Configuration.PlatesThickness);
    numCavities = length(Configuration.CavitiesThickness);
    
    for i = 1:numPlates
        % Informations sur la plaque actuelle
        perforated_radius = Configuration.PlatesPerforatedAreaRadius(i);
        plate_thickness = Configuration.PlatesThickness(i) * thickness_multiplier;  
        plate_porosity = Configuration.PlatesPorosity(i);
        % hole_radius = Configuration.PlatesHolesRadius(i) * hole_radius_multiplier;  
        
        % Définir la couleur en fonction du taux de perforation
        % Utiliser une transformation pour éclaircir les couleurs
        color_value = sqrt(sqrt(plate_porosity));  % Racine carrée pour des couleurs plus claires
        
        % Dessiner les parties non perforées de la plaque
        if perforated_radius < total_radius
            % Partie gauche non perforée
            rectangle('Position', [-total_radius, y_current, total_radius - perforated_radius, plate_thickness], ...
                      'FaceColor', 'k', ...
                      'EdgeColor', 'k');
            
            % Partie droite non perforée
            rectangle('Position', [perforated_radius, y_current, total_radius - perforated_radius, plate_thickness], ...
                      'FaceColor', 'k', ...
                      'EdgeColor', 'k');
        end
        
        % Dessiner la partie perforée de la plaque
        rectangle('Position', [-perforated_radius, y_current, 2 * perforated_radius, plate_thickness], ...
                  'FaceColor', [color_value, color_value, color_value], ...
                  'EdgeColor', 'k');
        
        % % Dessiner le cercle blanc au centre de la plaque
        % rectangle('Position', [-hole_radius, y_current + plate_thickness/2 - hole_radius, 2 * hole_radius, 2 * hole_radius], ...
        %           'Curvature', [1, 1], ...
        %           'FaceColor', 'w', ...
        %           'EdgeColor', 'k');
        
        % Mettre à jour la coordonnée y pour la prochaine couche
        y_current = y_current + plate_thickness;
        
        % Informations sur la cavité actuelle
        if i <= numCavities
            cavity_thickness = Configuration.CavitiesThickness(i);  % Épaisseur non multipliée pour les cavités
            
            % Dessiner la cavité
            rectangle('Position', [-total_radius, y_current, 2 * total_radius, cavity_thickness], ...
                      'FaceColor', 'w', ...
                      'EdgeColor', 'k');
            
            % Mettre à jour la coordonnée y pour la prochaine couche
            y_current = y_current + cavity_thickness;
        end
    end
    
    % Ajuster les axes pour une meilleure visualisation
    axis equal;
    xlim([-total_radius, total_radius]);  % Ajuster les limites des x pour correspondre à la largeur de la structure
    ylim([0, y_current]);  % Ajuster les limites des y pour inclure toutes les couches
    title('Cross-Sectional View of the Structure');
    axis off
    hold off;
end
