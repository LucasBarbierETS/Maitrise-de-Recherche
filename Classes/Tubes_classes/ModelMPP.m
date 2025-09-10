function out = ModelMPP(config, input_model, elem_index, sblm_index, env)

% Cette fonction permet d'intégrer la géométrie, la physique et le maillage de la solution appelée classMPPSBH_Rectangluar à
% un modèle préexistant permettant de réaliser des calculs numériques sur tube d'impédance

model = input_model;

%% Extraction des variables 

l = config.Thickness;
w = config.Width;

%% Création des variables et paramètres du modèle 

if elem_index == 1
    model.param.set(['sol' num2str(elem_index) '_xl'], '0', 'ligne d''accotement horizontal à gauche');
    model.param.set(['sol' num2str(elem_index) '_w'], num2str(w), 'ligne d''accotement horizontal à gauche');
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

MPP = geom.create(['sol' num2str(elem_index) '_sblm' num2str(sblm_index) '_MPP'], 'Rectangle');
MPP.set('pos', {['sol' num2str(elem_index) '_xl'] ['sol' num2str(elem_index) '_sblm' num2str(sblm_index) '_yt-' num2str(l)]});
MPP.set('size', {num2str(w) num2str(l)});

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

%% Matériaux

name = ['sol' num2str(elem_index) '_sblm' num2str(sblm_index) '_JCAmat'];
JCAmat = perso_create_JCA_material(model, name, config, env);

% Application du matériau i+1 à la i-ème plaque
JCAmat.selection.named(['sol' num2str(elem_index) '_sblm' num2str(sblm_index)]);

%% Physique 

% On ajoute la solution à la physique thermo-visqueuse
model = perso_add_selection_to_physics(model, 'phy_ap', ['sol' num2str(elem_index) '_sblm' num2str(sblm_index)]);

% On créer une physique poroacoustique
pom = comp.physics('phy_ap').create(['sol' num2str(elem_index) '_sblm' num2str(sblm_index) 'phy_poro'], 'PoroacousticsModel', 2);
pom.selection.named(['sol' num2str(elem_index) '_sblm' num2str(sblm_index)]);
pom.set('FluidModel', 'JohnsonChampouxAllard');

%% Maillage

mesh = model.component('component').mesh('mesh');  

% Création d'un maillage triangulaire libre pour les plaques perforées
ftri = mesh.create(['sol' num2str(elem_index) '_sblm' num2str(sblm_index) '_ftri'], 'FreeTri');
ftri.selection.named(['sol' num2str(elem_index) '_sblm' num2str(sblm_index)]);
ftri_size = ftri.create('size1', 'Size');
ftri_size.set('hauto', 2); % Maillage très fin;
out = model;

end
