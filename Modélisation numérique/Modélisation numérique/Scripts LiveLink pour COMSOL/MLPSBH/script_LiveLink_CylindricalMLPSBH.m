import com.comsol.model.*
import com.comsol.model.util.*

% mphstart;

% Générer un nom unique pour le modèle
uniqueName = ['Model_' char(java.util.UUID.randomUUID.toString)];

% Créer un nouveau modèle avec un nom unique
model = ModelUtil.create(uniqueName);

% Générer un nom unique pour la géométrie
uniqueGeomName = ['geom1_' char(java.util.UUID.randomUUID.toString)];
% Créer une nouvelle géométrie avec un nom unique
geom1 = model.geom.create(uniqueGeomName, 3);
model.geom(uniqueGeomName).lengthUnit('mm');

% Nombre de couches
numLayers = length(config.PlatesThickness);

% Dimensions de la surface perforée (supposons une grille régulière pour simplifier)
Nx = 5; % Nombre de perforations en X
Ny = 5; % Nombre de perforations en Y
spacingX = 10; % Espacement entre les perforations en X
spacingY = 10; % Espacement entre les perforations en Y
surfaceWidth = Nx * spacingX;
surfaceHeight = Ny * spacingY;

% Créer les plaques perforées et les cavités
for k = 1:numLayers
    % Créer une plaque perforée
    uniquePlateName = ['plate_' num2str(k) '_' char(java.util.UUID.randomUUID.toString)];
    plate = geom1.feature.create(uniquePlateName, 'Block');
    plate.set('size', [surfaceWidth, surfaceHeight, config.PlatesThickness(k)]);
    plate.set('pos', [0, 0, sum(config.PlatesThickness(1:k-1)) + sum(config.CavitiesThickness(1:k-1))]);

    % Ajouter les perforations
    for i = 0:Nx-1
        for j = 0:Ny-1
            centerX = i * spacingX;
            centerY = j * spacingY;
            uniqueHoleName = ['hole_' num2str(k) '_' num2str(i) '_' num2str(j) '_' char(java.util.UUID.randomUUID.toString)];
            hole = geom1.feature.create(uniqueHoleName, 'Cylinder');
            hole.set('r', config.PlatesHolesRadius(k));
            hole.set('h', config.PlatesThickness(k));
            hole.set('pos', [centerX, centerY, sum(config.PlatesThickness(1:k-1)) + sum(config.CavitiesThickness(1:k-1))]);
        end
    end

    % Créer une cavité si ce n'est pas la dernière couche
    if k < numLayers
        uniqueCavityName = ['cavity_' num2str(k) '_' char(java.util.UUID.randomUUID.toString)];
        cavity = geom1.feature.create(uniqueCavityName, 'Block');
        cavity.set('size', [surfaceWidth, surfaceHeight, config.CavitiesThickness(k)]);
        cavity.set('pos', [0, 0, sum(config.PlatesThickness(1:k)) + sum(config.CavitiesThickness(1:k-1))]);
    end
end

% Finaliser la géométrie
geom1.run;

% Générer un nom unique pour la vue
uniqueViewName = ['view1_' char(java.util.UUID.randomUUID.toString)];
% Créer une vue pour visualiser la géométrie
model.view.create(uniqueViewName, 3);
model.view(uniqueViewName).axis.set('xmin', 0);
model.view(uniqueViewName).axis.set('xmax', surfaceWidth);
model.view(uniqueViewName).axis.set('ymin', 0);
model.view(uniqueViewName).axis.set('ymax', surfaceHeight);
model.view(uniqueViewName).axis.set('zmin', 0);
model.view(uniqueViewName).axis.set('zmax', sum(config.PlatesThickness) + sum(config.CavitiesThickness));

% Afficher le modèle dans MATLAB
mphgeom(model);

% Spécifiez un répertoire pour le fichier temporaire
tempDir = tempdir;
tempSubDir = fullfile(tempDir, 'TempCOMSOL');
if ~exist(tempSubDir, 'dir')
    mkdir(tempSubDir);
end
tempFileName = fullfile(tempSubDir, [tempname, '.mph']);

% Sauvegarder le modèle
mphsave(model, tempFileName);

% Ouvrir le modèle dans COMSOL
ModelUtil.open(tempFileName);
