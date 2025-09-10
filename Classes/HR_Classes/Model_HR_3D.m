function output_model = Model_HR_3D(config, input_model, index, env)

% Cette fonction permet d'intégrer la géométrie, la physique et le maillage de la solution appelée sol_bf à
% un modèle préexistant permettant de réaliser des calculs numériques sur tube d'impédance

%% Extraction des variables 

model = input_model;
nr = config.NeckRadius;
nl = config.NeckLength;
cw = config.CavityWidth;
cd = config.CavityDepth;
cl = config.CavityLength;

%% Création des variables et paramètres du modèle 

% paramètres
model.param.set(['w', num2str(index)], [num2str(cw) '[m]'], 'largeur');
model.param.set(['xc' num2str(index)], ['xl' num2str(index) '+w' num2str(index) '/2'], 'ligne centrale');
model.param.set(['xr' num2str(index)], ['xl' num2str(index) '+w' num2str(index)], 'ligne d''acotement à droite');
model.param.set(['xl' num2str(index+1)], ['xl' num2str(index) '+w' num2str(index) '+2[mm]'], 'ligne d''acotement à gauche');

%% Géométrie

geom = model.component('component').geom('geometry');

% Création du col du résonateur
cn = geom.create(['sol' num2str(index) 'cn'], 'Cylinder');
cn.set('pos', {['xc' num2str(index)] '0' num2str(-nl)});
cn.set('r', num2str(nr));
cn.set('h', num2str(nl));

% Création de la cavité
bc = geom.create(['sol' num2str(index) 'bc'], 'Block');
bc.set('pos', {['xl' num2str(index)] num2str(-cd/2) num2str(-(nl+cl))});
bc.set('size', {num2str(cw) num2str(cd) num2str(cl)});

geom.run;

%% Sélection des boites

% On crée des boites pour sélectionner facilement des contours, des
% surfaces, et leur appliquer des propriétés physiques.

% Pour la solution entière
box_mat = model.component('component').selection.create(['sol' num2str(index)], 'Box');
box_mat.set('entitydim', 3); % On sélectionne des objets 2D
box_mat.set('zmax', '0.01[mm]');
box_mat.set('xmax', ['xr' num2str(index) '+0.01[mm]']);
box_mat.set('xmin', ['xl' num2str(index) '-0.01[mm]']);
box_mat.set('condition', 'inside');

% Pour la frontière thermo-visqueuse entre les domaines thermo-visqueux et acoustiques
box_bnd_ap_tv = model.component('component').selection.create(['sol' num2str(index) '_bnd_ap_tv'], 'Box');
box_bnd_ap_tv.set('entitydim', 2); % On sélectionne les arêtes
box_bnd_ap_tv.set('zmax', '-0.01[mm]');
box_bnd_ap_tv.set('zmin', '+0.01[mm]');
box_bnd_ap_tv.set('xmax', ['xr' num2str(index) '-0.01[mm]']);
box_bnd_ap_tv.set('xmin', ['xl' num2str(index) '+0.01[mm]']);
box_bnd_ap_tv.set('condition', 'inside');

% Pour les frontières du domaine visquo-thermique
box_bnd_lyr_tv = model.component('component').selection.create(['sol' num2str(index) '_bnd_lyr_tv'], 'Box');
box_bnd_lyr_tv.set('entitydim', 2); % On sélectionne les arêtes
box_bnd_lyr_tv.set('zmax', '-0.01[mm]');
box_bnd_lyr_tv.set('xmax', ['xr' num2str(index) '+0.01[mm]']);
box_bnd_lyr_tv.set('xmin', ['xl' num2str(index) '-0.01[mm]']);

%% Physique 

% On ajoute la frontière thermovisqueuse à la multiphysique
model = perso_add_selection_to_multiphysics(model, 'multiphy_bnd', ['sol' num2str(index) '_bnd_ap_tv']);

% On ajoute le reste de la solution à la physique Thermo-Viscous Acoustic
model = perso_add_selection_to_physics(model, 'phy_tv', ['sol' num2str(index)]);

%% Maillage

mesh = model.component('component').mesh('mesh');  

% Création d'un maillage triangulaire libre
ftet_mat = mesh.create(['sol' num2str(index) '_ftet'], 'FreeTet');
ftet_mat.selection.named(['sol' num2str(index)]);

% Création d'une couche de bord dans le maillage
bl = mesh.create(['sol' num2str(index) 'bl'], 'BndLayer'); 
bl.selection.named(['sol' num2str(index)]);
blp = bl.create('blp', 'BndLayerProp');

% On sélectionne toutes les frontières et le serveur se charge d'appliquer
% la condition partout à elle est applicable
blp.selection.named(['sol' num2str(index) '_bnd_lyr_tv']); 

blp.set('blnlayers', 4); % nombre de couches
blp.set('blhtot', '0.1[mm]'); % épaisseur totale (m)

% Définition de l'angle de division pour la couche de bord
bl.set('splitdivangle', 25);    
blp.set('blstretch', 2);  

output_model = model;

end