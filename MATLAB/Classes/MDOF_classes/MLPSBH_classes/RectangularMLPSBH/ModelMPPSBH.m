function out = ModelMPPSBH(config, input_model, elem_index, sblm_index, env)

% Cette fonction permet d'intégrer la géométrie, la physique et le maillage de la solution appelée classMPPSBH_Rectangluar à
% un modèle préexistant permettant de réaliser des calculs numériques sur tube d'impédance

model = input_model;

%% Extraction des variables 

pt = config.PlatesThickness;
cavw = config.CavitiesWidth;
ct = config.CavitiesThickness;
sw = config.MainPoresWidth;
los = config.ListOfSubelements;
N = length(pt); % number of cells (slit backed by a cavity)

%% Création des variables et paramètres du modèle 

%% Création des variables et paramètres du modèle 

if elem_index == 1
    model.param.set(['sol' num2str(elem_index) '_xl'], '0', 'ligne d''accotement horizontal à gauche');
else
    model.param.set(['sol' num2str(elem_index) '_xl'], ['sol' num2str(elem_index - 1) '_xr+1e-3'], 'ligne d''accotement horizontal à gauche');
end

if sblm_index == 1
    model.param.set(['sol' num2str(elem_index) '_sblm' num2str(sblm_index) '_yt'], '0', 'ligne d''accotement verticale en haut');
    model.param.set(['sol' num2str(elem_index) '_w'], num2str(cavw), 'ligne d''accotement horizontal à gauche');
    model.param.set(['sol' num2str(elem_index) '_xc'], ['sol' num2str(elem_index) '_xl+sol' num2str(elem_index) '_w/2'], 'ligne centrale');
    model.param.set(['sol' num2str(elem_index) '_xr'], ['sol' num2str(elem_index) '_xl+sol' num2str(elem_index) '_w'], 'ligne d''acotement horizontal à droite');
else
    model.param.set(['sol' num2str(elem_index) '_sblm' num2str(sblm_index) '_yt'], ['sol' num2str(elem_index) '_sblm' num2str(sblm_index-1) '_yb'], 'ligne d''accotement horizontal à gauche');
end

%% Géométrie

geom = model.component('component').geom('geometry');

for i = 1:N
    % Création d'un rectangle pour le pore i
    rp = geom.create(['sol' num2str(elem_index) '_sblm' num2str(sblm_index) '_rp' num2str(i)], 'Rectangle');
    rp.set('pos', {['sol' num2str(elem_index) '_xc+' num2str(-sw(i)/2)] ['sol' num2str(elem_index) '_sblm' num2str(sblm_index) '_yt+' num2str(-sum(pt(1:i)) - sum(ct(1:i-1)))]});
    rp.set('size', {num2str(sw(i)) num2str(pt(i))});
    
    % Création d'un rectangle pour la cavité i
    rc = geom.create(['sol' num2str(elem_index) '_sblm' num2str(sblm_index) '_rc' num2str(i)], 'Rectangle');
    rc.set('pos', {['sol' num2str(elem_index) '_xc-sol' num2str(elem_index) '_w/2'] ['sol' num2str(elem_index) '_sblm' num2str(sblm_index) '_yt+' num2str(-sum(pt(1:i)) - sum(ct(1:i)))]});
    rc.set('size', {['sol' num2str(elem_index) '_w'] num2str(ct(i))});
end

geom.run;

%% Sélection des boites

% Pour la solution entière
box_mat = model.component('component').selection.create(['sol' num2str(elem_index) '_sblm' num2str(sblm_index)], 'Box');
box_mat.set('entitydim', 2); 
box_mat.set('ymax', ['sol' num2str(elem_index) '_sblm' num2str(sblm_index) '_yt+0.01[mm]']);
box_mat.set('xmax', ['sol' num2str(elem_index) '_xr+0.01[mm]']);
box_mat.set('xmin', ['sol' num2str(elem_index) '_xl-0.01[mm]']);
box_mat.set('condition', 'inside');

% Pour les arètes de la solution entière
box_mat_bnds = model.component('component').selection.create(['sol' num2str(elem_index) '_sblm' num2str(sblm_index) '_bnds'], 'Box');
box_mat_bnds.set('entitydim', 1);
box_mat_bnds.set('ymax', ['sol' num2str(elem_index) '_sblm' num2str(sblm_index) '_yt+0.01[mm]']);
box_mat_bnds.set('xmax', ['sol' num2str(elem_index) '_xr+0.01[mm]']);
box_mat_bnds.set('xmin', ['sol' num2str(elem_index) '_xl-0.01[mm]']);
box_mat_bnds.set('condition', 'inside');

% Pour chaque plaque perforée
for i = 1:N
    box_MPP = model.component('component').selection.create(['sol' num2str(elem_index) '_sblm' num2str(sblm_index) '_MPP', num2str(i)], 'Box');
    box_MPP.set('entitydim', 2);
    box_MPP.set('ymax', ['sol' num2str(elem_index) '_sblm' num2str(sblm_index) '_yt+' num2str(1e-6 - sum(pt(1:i-1)) - sum(ct(1:i-1)))]);
    box_MPP.set('ymin', ['sol' num2str(elem_index) '_sblm' num2str(sblm_index) '_yt+' num2str(-1e-6 - sum(pt(1:i)) - sum(ct(1:i-1)))]);
    box_MPP.set('xmax', ['sol' num2str(elem_index) '_xr+0.01[mm]']);
    box_MPP.set('xmin', ['sol' num2str(elem_index) '_xl-0.01[mm]']);
    box_MPP.set('condition', 'inside');

    % On récupère les arêtes latérales de chaque zone perforée
    box_MPP_bnd = model.component('component').selection.create(['sol' num2str(elem_index) '_sblm' num2str(sblm_index) '_MPP_bnd', num2str(i)], 'Box');
    box_MPP_bnd.set('entitydim', 1);
    box_MPP_bnd.set('ymax', ['sol' num2str(elem_index) '_sblm' num2str(sblm_index) '_yt+' num2str(-1e-5 - sum(pt(1:i-1)) - sum(ct(1:i-1)))]);
    box_MPP_bnd.set('ymin', ['sol' num2str(elem_index) '_sblm' num2str(sblm_index) '_yt+' num2str(+1e-5 - sum(pt(1:i)) - sum(ct(1:i-1)))]);
    box_MPP_bnd.set('xmax', ['sol' num2str(elem_index) '_xr+0.01[mm]']);
    box_MPP_bnd.set('xmin', ['sol' num2str(elem_index) '_xl-0.01[mm]']);
    box_MPP_bnd.set('condition', 'intersects');
end

% Pour toutes les plaques perforées
box_MPPs = model.component('component').selection.create(['sol' num2str(elem_index) '_sblm' num2str(sblm_index) '_all_MPPs'], 'Box');
box_MPPs.set('inputent', 'selections');
box_MPPs.set('input', cellstr(['sol' num2str(elem_index) '_sblm' num2str(sblm_index) '_MPP'] + string(1:N))); 

% Pour chaque cavité
for i = 1:N
    box_cav = model.component('component').selection.create(['sol' num2str(elem_index) '_sblm' num2str(sblm_index) '_cav', num2str(i)], 'Box');
    box_cav.set('entitydim', 2);
    box_cav.set('ymax', ['sol' num2str(elem_index) '_sblm' num2str(sblm_index) '_yt+' num2str(1e-5- sum(pt(1:i)) - sum(ct(1:i-1)))]);
    box_cav.set('ymin', ['sol' num2str(elem_index) '_sblm' num2str(sblm_index) '_yt+' num2str(-1e-5 - sum(pt(1:i)) - sum(ct(1:i)))]);
    box_cav.set('xmax', ['sol' num2str(elem_index) '_xr+0.01[mm]']);
    box_cav.set('xmin', ['sol' num2str(elem_index) '_xl-0.01[mm]']);
    box_cav.set('condition', 'inside');
    % box_cav.set('condition', 'intersects');
end

% Pour toutes les cavités
box_MPPs_bnds = model.component('component').selection.create(['sol' num2str(elem_index) '_sblm' num2str(sblm_index) '_all_cavities'], 'Box');
box_MPPs_bnds.set('inputent', 'selections');
box_MPPs_bnds.set('input', cellstr(['sol' num2str(elem_index) '_sblm' num2str(sblm_index) '_cav'] + string(1:N))); 

% Pour les frontière thermo-visqueuses entre les domaines thermo-visqueux et acoustiques
box_bnd_ap_tv = model.component('component').selection.create(['sol' num2str(elem_index) '_sblm' num2str(sblm_index) '_bnd_ap_tv'], 'Box');
box_bnd_ap_tv.set('entitydim', 1);
box_bnd_ap_tv.set('ymax', ['sol' num2str(elem_index) '_sblm' num2str(sblm_index) '_yt-0.01[mm]']);
box_bnd_ap_tv.set('xmax', ['sol' num2str(elem_index) '_xr+0.01[mm]']);
box_bnd_ap_tv.set('xmin', ['sol' num2str(elem_index) '_xl-0.01[mm]']);
box_bnd_ap_tv.set('condition', 'inside');

%% Matériaux

for i = 1:N
    JCAconfig = los{4*(i-1)+1}.Configuration;
    name = ['sol' num2str(elem_index) '_sblm' num2str(sblm_index) '_mat' num2str(i)];
    JCAmat = perso_create_JCA_material(model, name, JCAconfig, env);

    % Application du matériau i+1 à la i-ème plaque
    JCAmat.selection.named(['sol' num2str(elem_index) '_sblm' num2str(sblm_index) '_MPP' num2str(i)]);
end

%% Physique 

% On ajoute le reste de la solution à la Physique Thermo-Viscous Acoustic
model = perso_add_selection_to_physics(model, 'phy_tv', ['sol' num2str(elem_index) '_sblm' num2str(sblm_index) '_all_cavities']);

% Pressure acoustic
ap = model.component('component').physics('phy_ap');
model = perso_add_selection_to_physics(model, 'phy_ap', ['sol' num2str(elem_index) '_sblm' num2str(sblm_index) '_all_MPPs']);

% Poroacoustic
pom = ap.create(['sol' num2str(elem_index) '_sblm' num2str(sblm_index), 'phy_poro'], 'PoroacousticsModel', 2);
pom.selection.named(['sol' num2str(elem_index) '_sblm' num2str(sblm_index) '_all_MPPs']);
pom.set('FluidModel', 'JohnsonChampouxAllard');

%% Maillage

mesh = model.component('component').mesh('mesh');  

% Création d'un maillage triangulaire libre pour les plaques perforées
ftri_MPPs = mesh.create(['sol' num2str(elem_index) '_sblm' num2str(sblm_index) '_ftri'], 'FreeTri');
ftri_MPPs.selection.named(['sol' num2str(elem_index) '_sblm' num2str(sblm_index) '_all_MPPs']);
ftri_size = ftri_MPPs.create('size1', 'Size');
ftri_size.set('hauto', 2); 

% Création d'un maillage triangulaire libre pour les cavités
ftri_cavs = mesh.create(['sol' num2str(elem_index) '_sblm' num2str(sblm_index) '_ftri_cavities'], 'FreeTri');
ftri_cavs.selection.named(['sol' num2str(elem_index) '_sblm' num2str(sblm_index) '_all_cavities']);
ftri_size = ftri_cavs.create('size1', 'Size');
ftri_size.set('hauto', 2); 

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
mesh.run;

out = model;

end
