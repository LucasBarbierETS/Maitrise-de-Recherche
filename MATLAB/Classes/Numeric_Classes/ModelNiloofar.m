function output_model = ModelNiloofar(config, input_model, elem_index, sblm_index, ~)

% Cette fonction permet d'intégrer la géométrie, la physique et le maillage de la solution appelée sol_bf à
% un modèle préexistant permettant de réaliser des calculs numériques sur tube d'impédance

model = input_model;

%% Extraction des variables 

w = config.Width;
L = config.SolutionLength;
l = config.PlatesThickness; 
d = config.Increment;
flt = config.FirstLayerThickness;
m = config.LeftCavitiesThickness;
n = config.RightCavitiesThickness;
a1 = config.FirstLeftPlateLength;
b1 = config.FirstRightPlateLength;
N = config.NumberOfLeftPlates; 

%% Création des variables et paramètres du modèle 

% paramètres de placement
model.param.set(['sol' num2str(elem_index) '_L'], [num2str(L) '[m]'], 'longueur');

if elem_index == 1
    model.param.set(['sol' num2str(elem_index) '_xl'], '0', 'ligne d''accotement horizontal à gauche');
else
    model.param.set(['sol' num2str(elem_index) '_xl'], ['sol' num2str(elem_index - 1) '_xr+1e-3'], 'ligne d''accotement horizontal à gauche');
end

if sblm_index == 1
    model.param.set(['sol' num2str(elem_index) '_sblm' num2str(sblm_index) '_yt'], '0', 'ligne d''accotement verticale en haut');
    model.param.set(['sol' num2str(elem_index) '_w'], num2str(w), 'ligne d''accotement horizontal à gauche');
    model.param.set(['sol' num2str(elem_index) '_xc'], ['sol' num2str(elem_index) '_xl+' num2str(w/2)], 'ligne centrale');
    model.param.set(['sol' num2str(elem_index) '_xr'], ['sol' num2str(elem_index) '_xl+' num2str(w)], 'ligne d''acotement horizontal à droite');
else
    model.param.set(['sol' num2str(elem_index) '_sblm' num2str(sblm_index) '_yt'], ['sol' num2str(elem_index) '_sblm' num2str(sblm_index-1) '_yb'], 'ligne d''accotement horizontal à gauche');
end

% Paramètres de la géométrie
model.param.set(['sol' num2str(elem_index) '_l'], num2str(l), 'épaisseur des plaques');
model.param.set(['sol' num2str(elem_index) '_d'], num2str(d), 'incrément');
model.param.set(['sol' num2str(elem_index) '_flt'], num2str(flt), 'épaisseur de la première couche');
model.param.set(['sol' num2str(elem_index) '_m'], num2str(m), 'espace avant 1ère plaque à gauche');
model.param.set(['sol' num2str(elem_index) '_n'], num2str(n), 'espace avant 1ère plaque à droite');
model.param.set(['sol' num2str(elem_index) '_a1'], num2str(a1), 'longueur de la 1ère plaque gauche');
model.param.set(['sol' num2str(elem_index) '_b1'], num2str(b1), 'longueur de la 1ère plaque droite');

%% Géométrie

geom = model.component('component').geom('geometry');

% Première cavité
frc = geom.create(['sol' num2str(elem_index) '_sblm' num2str(sblm_index) '_frc'], 'Rectangle');
frc.set('pos', {['sol' num2str(elem_index) '_xl'], ['sol' num2str(elem_index) '_sblm' num2str(sblm_index) '_yt-sol' num2str(elem_index) '_flt']});
frc.set('size', {['sol' num2str(elem_index) '_w'], ['sol' num2str(elem_index) '_flt']});

% geom.run;
% mphgeom(model)

for i = 1:N
    % Création d'un rectangle pour la ième plaque gauche - couche d'air à droite
    lp = geom.create(['sol' num2str(elem_index) '_sblm' num2str(sblm_index) '_lp' num2str(i)], 'Rectangle');
    lp.set('pos', {['sol' num2str(elem_index) '_xl+sol' num2str(elem_index) '_a1+' num2str(i-1) '*sol' num2str(elem_index) '_d'], ... xl + a1 + (i-1)*d
                   ['sol' num2str(elem_index) '_sblm' num2str(sblm_index) '_yt-sol' num2str(elem_index) '_flt-' num2str(i-1) '*sol' num2str(elem_index) '_m-' num2str(i) '*sol' num2str(elem_index) '_l']}); % -flt - (i-1)*m - i*l

    lp.set('size', {['sol' num2str(elem_index) '_w-(sol' num2str(elem_index) '_a1+' num2str(i-1) '*sol' num2str(elem_index) '_d)'], ... w - a1 + (i-1)*d
                   ['sol' num2str(elem_index) '_l']}); % l
    
    % geom.run;
    % mphgeom(model)

    % Création pour la cavité i-1
    lc1 = geom.create(['sol' num2str(elem_index) '_sblm' num2str(sblm_index) '_lc' num2str(i)], 'Rectangle');
    lc1.set('pos', {['sol' num2str(elem_index) '_xl'], ... xl
                    ['sol' num2str(elem_index) '_sblm' num2str(sblm_index) '_yt-sol' num2str(elem_index) '_flt-' num2str(i-2) '*sol' num2str(elem_index) '_m-' num2str(i-1) '*sol' num2str(elem_index) '_l-sol' num2str(elem_index) '_n']}); % -flt -(i-2)*m -(i-1)*l) - n

    lc1.set('size', {['sol' num2str(elem_index) '_w'], ... w 
                     ['sol' num2str(elem_index) '_n-sol' num2str(elem_index) '_m-sol' num2str(elem_index) '_l']}); % n-m-l

    % geom.run;
    % mphgeom(model)

    % Création d'un rectangle pour la plaque droite i
    rp = geom.create(['sol' num2str(elem_index) '_sblm' num2str(sblm_index) '_rp' num2str(i)], 'Rectangle');
    rp.set('pos', {['sol' num2str(elem_index) '_xl'], ... xl
                   ['sol' num2str(elem_index) '_sblm' num2str(sblm_index) '_yt-sol' num2str(elem_index) '_flt-' ... -flt
                   num2str(i-2) '*sol' num2str(elem_index) '_m-' ... -(i-2)*m
                   num2str(i-1) '*sol' num2str(elem_index) '_l-' ... -(i-1)*l
                   'sol' num2str(elem_index) '_n-sol' num2str(elem_index) '_l']}); % -(n+l)

    rp.set('size', {['sol' num2str(elem_index) '_w-(sol' num2str(elem_index) '_b1+' num2str(i-1) '*sol' num2str(elem_index) '_d)'], ... w - b1 + (i-1)*d
                    ['sol' num2str(elem_index) '_l']}); % l

    % geom.run;
    % mphgeom(model)

    % Création pour la cavité i-2
    rc2 = geom.create(['sol' num2str(elem_index) '_sblm' num2str(sblm_index) '_rc' num2str(i)], 'Rectangle');
    rc2.set('pos', {['sol' num2str(elem_index) '_xl'] ... xl
                    ['sol' num2str(elem_index) '_sblm' num2str(sblm_index) '_yt-sol' num2str(elem_index) '_flt' ... -flt
                    '-' num2str(i) '*sol' num2str(elem_index) '_m' ... -i*m
                    '-' num2str(i+1) '*sol' num2str(elem_index) '_l' ... -(i+1)*l
                    '+sol' num2str(elem_index) '_l']}); % + l

    rc2.set('size', {['sol' num2str(elem_index) '_w'] ... w
                     ['2*sol' num2str(elem_index) '_m-sol' num2str(elem_index) '_n']}); % 2m-n
    
    % geom.run;
    % mphgeom(model)
end

geom.run;
% mphgeom(model)

model.param.set(['sol' num2str(elem_index) '_sblm' num2str(sblm_index) '_yb'], ...
                ['sol' num2str(elem_index) '_sblm' num2str(sblm_index) '_yt-sol' num2str(elem_index) '_flt' ... -flt
                '-' num2str(i) '*sol' num2str(elem_index) '_m' ... -i*m
                '-' num2str(i+1) '*sol' num2str(elem_index) '_l' ... -(i+1)*l
                '+sol' num2str(elem_index) '_l'], 'ligne d''accotement vertical en bas');


% On créer une liste de tous les géométries associés à ['sol' num2str(elem_index) '_sblm' num2str(sblm_index)]
list_obj_names = {};
obj_names = cell(geom.objectNames);
for i = 1:length(obj_names)
    if contains(obj_names{i}, ['sol' num2str(elem_index) '_sblm' num2str(sblm_index)])
        list_obj_names{end+1} = obj_names{i};
    end
end

% On crée l'union des objets de la solution
uni = geom.create(['sol' num2str(elem_index) '_sblm' num2str(sblm_index), '_union'], 'Union');
uni.selection('input').set(list_obj_names);
uni.set('intbnd', false);

% geom.run;
% mphgeom(model)

%% Sélection des boites

% On crée des boites pour sélectionner facilement des contours, des
% surfaces, et leur appliquer des propriétés physiques.

% Pour la solution entière
box_mat = model.component('component').selection.create(['sol' num2str(elem_index) '_sblm' num2str(sblm_index)], 'Box');
box_mat.set('entitydim', 2); % On sélectionne des objets 2D
box_mat.set('ymax', ['sol' num2str(elem_index) '_sblm' num2str(sblm_index) '_yt+0.01[mm]']);
box_mat.set('ymin', ['sol' num2str(elem_index) '_sblm' num2str(sblm_index) '_yb-0.01[mm]']);
box_mat.set('xmax', ['sol' num2str(elem_index) '_xr+0.01[mm]']);
box_mat.set('xmin', ['sol' num2str(elem_index) '_xl-0.01[mm]']);
box_mat.set('condition', 'inside');

% Pour la frontière multiphysique
box_bnd_cont_ap = model.component('component').selection.create(['sol' num2str(elem_index) '_sblm' num2str(sblm_index) '_bnd_ap_tv'], 'Box');
box_bnd_cont_ap.set('entitydim', 1); % On sélectionne les arêtes
box_bnd_cont_ap.set('ymax', ['sol' num2str(elem_index) '_sblm' num2str(sblm_index) '_yt+0.01[mm]']);
box_mat.set('ymin', ['sol' num2str(elem_index) '_sblm' num2str(sblm_index) '_yb-0.01[mm]']);
box_bnd_cont_ap.set('xmax', ['sol' num2str(elem_index) '_xr+0.01[mm]']);
box_bnd_cont_ap.set('xmin', ['sol' num2str(elem_index) '_xl-0.01[mm]']);
box_bnd_cont_ap.set('condition', 'inside');

% Pour les frontières du domaine visquo-thermique
box_bnd_lyr_tv = model.component('component').selection.create(['sol' num2str(elem_index) '_sblm' num2str(sblm_index) '_bnd_lyr_tv'], 'Box');
box_bnd_lyr_tv.set('entitydim', 1); % On sélectionne les arêtes
box_bnd_lyr_tv.set('ymax', ['sol' num2str(elem_index) '_sblm' num2str(sblm_index) '_yt+0.01[mm]']);
box_mat.set('ymin', ['sol' num2str(elem_index) '_sblm' num2str(sblm_index) '_yb-0.01[mm]']);
box_bnd_lyr_tv.set('xmax', ['sol' num2str(elem_index) '_xr+0.01[mm]']);
box_bnd_lyr_tv.set('xmin', ['sol' num2str(elem_index) '_xl-0.01[mm]']);

%% Physique 

% On ajoute la solution à la physique thermo-visqueuse
model = perso_add_selection_to_physics(model, 'phy_tv', ['sol' num2str(elem_index) '_sblm' num2str(sblm_index)]);

%% Maillage

mesh = model.component('component').mesh('mesh');  

% Création d'un maillage triangulaire libre
ftri_mat = mesh.create(['sol' num2str(elem_index) '_sblm' num2str(sblm_index) '_ftri'], 'FreeTri');
ftri_mat.selection.named(['sol' num2str(elem_index) '_sblm' num2str(sblm_index)]);
ftri_size = ftri_mat.create('size1', 'Size');
ftri_size.set('hauto', 2); % Maillage très fin
mesh.run;

% Création d'une couche de bord dans le maillage
bl = mesh.create(['sol' num2str(elem_index) '_sblm' num2str(sblm_index) 'bl'], 'BndLayer'); 
bl.selection.named(['sol' num2str(elem_index) '_sblm' num2str(sblm_index)]);
bl.set('splitdivangle', 75);
bl.set('smoothtransition', false);
blp = bl.create('blp', 'BndLayerProp'); 
% On sélectionne toutes les frontières et le serveur se charge d'appliquer
% la condition partout à elle est applicable
blp.selection.named(['sol' num2str(elem_index) '_sblm' num2str(sblm_index) '_bnd_lyr_tv']); 
blp.set('blnlayers', 3);
blp.set('blstretch', 1.2);
blp.set('inittype', 'blhtot');
blp.set('blhmin', 'd_visc');
mesh.run;

output_model = model;