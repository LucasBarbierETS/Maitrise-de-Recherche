function out = ModelCavity(config, input_model, elem_index, sblm_index, env)

% Cette fonction permet d'intégrer la géométrie, la physique et le maillage de la solution appelée classMPPSBH_Rectangluar à
% un modèle préexistant permettant de réaliser des calculs numériques sur tube d'impédance

model = input_model;

%% Extraction des variables 

l = config.Thickness;
w = config.Width;

%% Création des variables et paramètres du modèle 

if elem_index == 1
    model.param.set(['sol' num2str(elem_index) '_xl'], '0', 'ligne d''accotement horizontal à gauche');
else
    model.param.set(['sol' num2str(elem_index) '_xl'], ['sol' num2str(elem_index - 1) '_xr+1e-3'], 'ligne d''accotement horizontal à gauche');
end

if sblm_index == 1
    model.param.set(['sol' num2str(elem_index) '_sblm' num2str(sblm_index) '_yt'], '0', 'ligne d''accotement verticale en haut');
    model.param.set(['sol' num2str(elem_index) '_w'], num2str(w), 'ligne d''accotement horizontal à gauche');
    model.param.set(['sol' num2str(elem_index) '_xc'], ['sol' num2str(elem_index) '_xl+sol' num2str(elem_index) '_w/2'], 'ligne centrale');
    model.param.set(['sol' num2str(elem_index) '_xr'], ['sol' num2str(elem_index) '_xl+sol' num2str(elem_index) '_w'], 'ligne d''acotement horizontal à droite');
else
    model.param.set(['sol' num2str(elem_index) '_sblm' num2str(sblm_index) '_yt'], ['sol' num2str(elem_index) '_sblm' num2str(sblm_index-1) '_yb'], 'ligne d''accotement horizontal à gauche');
end

%% Géométrie

comp = model.component('component');
geom = model.component('component').geom('geometry');

cav = geom.create(['sol' num2str(elem_index) '_sblm' num2str(sblm_index) '_cav'], 'Rectangle');
cav.set('pos', {['sol' num2str(elem_index) '_xl'] ['sol' num2str(elem_index) '_sblm' num2str(sblm_index) '_yt-' num2str(l)]});
cav.set('size', {num2str(w) num2str(l)});

% Définition de la ligne de fond du sous-élement
model.param.set(['sol' num2str(elem_index) '_sblm' num2str(sblm_index) '_yb'], ['sol' num2str(elem_index) '_sblm' num2str(sblm_index) '_yt-' num2str(l)], 'ligne d''accotement horizontal à gauche');

geom.run;

%% Sélection des boites

% Pour la solution entière
box_mat = model.component('component').selection.create(['sol' num2str(elem_index) '_sblm' num2str(sblm_index)], 'Box');
box_mat.set('entitydim', 2); 
box_mat.set('ymax', ['sol' num2str(elem_index) '_sblm' num2str(sblm_index) '_yt+0.01[mm]']);
box_mat.set('ymin', ['sol' num2str(elem_index) '_sblm' num2str(sblm_index) '_yb-0.01[mm]']);
box_mat.set('xmax', ['sol' num2str(elem_index) '_xr+0.01[mm]']);
box_mat.set('xmin', ['sol' num2str(elem_index) '_xl-0.01[mm]']);
box_mat.set('condition', 'inside');

% Pour les arètes de la solution entière
box_mat_bnds = model.component('component').selection.create(['sol' num2str(elem_index) '_sblm' num2str(sblm_index) '_bnds'], 'Box');
box_mat_bnds.set('entitydim', 1);
box_mat_bnds.set('ymax', ['sol' num2str(elem_index) '_sblm' num2str(sblm_index) '_yt+0.01[mm]']);
box_mat_bnds.set('ymin', ['sol' num2str(elem_index) '_sblm' num2str(sblm_index) '_yb-0.01[mm]']);
box_mat_bnds.set('xmax', ['sol' num2str(elem_index) '_xr+0.01[mm]']);
box_mat_bnds.set('xmin', ['sol' num2str(elem_index) '_xl-0.01[mm]']);
box_mat_bnds.set('condition', 'inside');

%% Physique 

% On ajoute la solution à la physique thermo-visqueuse
model = perso_add_selection_to_physics(model, 'phy_tv', ['sol' num2str(elem_index) '_sblm' num2str(sblm_index)]);

%% Maillage

mesh = model.component('component').mesh('mesh');  

% Création d'un maillage triangulaire libre pour les plaques perforées
ftri = mesh.create(['sol' num2str(elem_index) '_sblm' num2str(sblm_index) '_ftri'], 'FreeTri');
ftri.selection.named(['sol' num2str(elem_index) '_sblm' num2str(sblm_index)]);
ftri_size = ftri.create('size1', 'Size');
ftri_size.set('hauto', 2); % Maillage très fin;
mesh.run;

% Création d'une couche de bord dans le maillage
bl = mesh.create(['sol' num2str(elem_index) '_sblm' num2str(sblm_index) '_bl'], 'BndLayer'); 
bl.selection.named(['sol' num2str(elem_index) '_sblm' num2str(sblm_index)]);
bl.set('splitdivangle', 25);
bl.set('smoothtransition', false);
blp = bl.create('blp', 'BndLayerProp');  

% blp.selection.named(['sol' num2str(elem_index) '_sblm' num2str(sblm_index) '_bnd_lyr_tv']);
blp.selection.named(['sol' num2str(elem_index) '_sblm' num2str(sblm_index) '_bnds']);
blp.set('blnlayers', 3);
blp.set('blstretch', 1.2);
blp.set('inittype', 'blhtot');
blp.set('blhmin', 'd_visc');

out = model;

end
