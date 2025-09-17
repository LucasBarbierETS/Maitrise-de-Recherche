function out = ModelMPPSBH_3D_ap(config, input_model, index, env)

% Cette fonction intègre la géométrie, la physique et le maillage d’une
% solution MPPSBH à un modèle 3D pour simulation en tube d’impédance
% avec la condition d’impédance de couche limite (sans phy_tv).

%% Extraction des variables
model = input_model;
pt   = config.PlatesThickness;
cavw = config.CavitiesWidth;
cavd = config.CavitiesDepth;
ct   = config.CavitiesThickness;
mpw  = config.MainPoresWidth;
mpd  = config.MainPoresDepth;
los  = config.ListOfSubelements;
N    = length(pt);

%% Paramètres
model.param.set(['sol' num2str(index) '_w'],  [num2str(cavw) '[m]'], 'largeur cavité');
model.param.set(['sol' num2str(index) '_d'],  [num2str(cavd) '[m]'], 'hauteur cavité');
model.param.set(['sol' num2str(index) '_xc'], ['sol' num2str(index) '_xl+sol' num2str(index) '_w/2'], 'centre');
model.param.set(['sol' num2str(index) '_xr'], ['sol' num2str(index) '_xl+sol' num2str(index) '_w'], 'bord droit');
model.param.set(['sol' num2str(index+1) '_xl'], ['sol' num2str(index) '_xl+sol' num2str(index) '_w+2[mm]'], 'bord gauche suivant');

%% Géométrie
geom = model.component('component').geom('geometry');
for i = 1:N
    % Bloc pour le pore i
    rp = geom.create(['sol' num2str(index) '_rp' num2str(i)], 'Block');
    rp.set('pos', {['sol' num2str(index) '_xc+' num2str(-mpw(i)/2)] ...
                   num2str(-mpd(i)/2) ...
                   num2str(-sum(pt(1:i)) - sum(ct(1:i-1)))});
    rp.set('size', {num2str(mpw(i)) num2str(mpd(i)) num2str(pt(i))});
    
    % Bloc pour la cavité i
    rc = geom.create(['sol' num2str(index) '_rc' num2str(i)], 'Block');
    rc.set('pos', {['sol' num2str(index) '_xc-sol' num2str(index) '_w/2'] ...
                   ['-sol' num2str(index) '_d/2'] ...
                   num2str(-sum(pt(1:i)) - sum(ct(1:i)))});
    rc.set('size', {['sol' num2str(index) '_w'] ...
                    ['sol' num2str(index) '_d'] ...
                    num2str(ct(i))});
end
geom.run;

%% Sélections

% Solution entière
box_mat = model.component('component').selection.create(['sol' num2str(index)], 'Box');
box_mat.set('entitydim', 3);
box_mat.set('zmax', '0.01[mm]');
box_mat.set('xmax', ['sol' num2str(index) '_xr+0.01[mm]']);
box_mat.set('xmin', ['sol' num2str(index) '_xl-0.01[mm]']);
box_mat.set('condition', 'inside');

% --- Plaques perforées (MPP) ---
for i = 1:N
    box_MPP = model.component('component').selection.create(['sol' num2str(index) '_MPP' num2str(i)], 'Box');
    box_MPP.set('entitydim', 3);
    box_MPP.set('zmax', num2str(1e-6 - sum(pt(1:i-1)) - sum(ct(1:i-1))));
    box_MPP.set('zmin', num2str(-1e-6 - sum(pt(1:i)) - sum(ct(1:i-1))));
    box_MPP.set('xmax', ['sol' num2str(index) '_xr+0.01[mm]']);
    box_MPP.set('xmin', ['sol' num2str(index) '_xl-0.01[mm]']);
    box_MPP.set('condition', 'inside');
end

% Union des plaques
box_all_MPPs = model.component('component').selection.create(['sol' num2str(index) '_all_MPPs'], 'Union');
box_all_MPPs.set('entitydim', 3);
box_all_MPPs.set('input', cellstr(['sol' num2str(index) '_MPP'] + string(1:N)));

% --- Cavités (volumes) + leurs frontières ---
for i = 1:N
    % Volume de cavité i
    box_cav = model.component('component').selection.create(['sol' num2str(index) '_cav' num2str(i)], 'Box');
    box_cav.set('entitydim', 3);
    box_cav.set('zmax', num2str(-(sum(pt(1:i)) + sum(ct(1:i-1))) + 0.01e-3));  % haut cavité (sous plaque i)
    box_cav.set('zmin', num2str(-(sum(pt(1:i)) + sum(ct(1:i))) - 0.01e-3));    % bas cavité
    box_cav.set('xmax', ['sol' num2str(index) '_xr+0.01[mm]']);
    box_cav.set('xmin', ['sol' num2str(index) '_xl-0.01[mm]']);
    box_cav.set('condition', 'inside');

    % Frontières de cavité i (parois air)
    box_cav_bnd = model.component('component').selection.create(['sol' num2str(index) '_cav_bnd' num2str(i)], 'Box');
    box_cav_bnd.set('entitydim', 2);
    box_cav_bnd.set('zmax', num2str(-(sum(pt(1:i)) + sum(ct(1:i-1))) + 0.01e-3));
    box_cav_bnd.set('zmin', num2str(-(sum(pt(1:i)) + sum(ct(1:i))) - 0.01e-3));
    box_cav_bnd.set('xmax', ['sol' num2str(index) '_xr+0.01[mm]']);
    box_cav_bnd.set('xmin', ['sol' num2str(index) '_xl-0.01[mm]']);
    box_cav_bnd.set('condition', 'inside');
end

% Union de toutes les cavités (3D)
box_all_cavs = model.component('component').selection.create(['sol' num2str(index) '_all_cavities'], 'Union');
box_all_cavs.set('entitydim', 3);
box_all_cavs.set('input', cellstr(['sol' num2str(index) '_cav'] + string(1:N)));

% Union de toutes les parois de cavités (2D)
box_all_cav_air_bnds = model.component('component').selection.create(['sol' num2str(index) '_bnd_air_only'], 'Union');
box_all_cav_air_bnds.set('entitydim', 2);
box_all_cav_air_bnds.set('input', cellstr(['sol' num2str(index) '_cav_bnd'] + string(1:N)));

%% Matériaux

for i = 1:N
    JCAconfig = los{4*(i-1)+1}.Configuration;
    name      = ['sol' num2str(index) '_mat' num2str(i)];
    JCAmat    = perso_create_JCA_material(model, name, JCAconfig, env);
    JCAmat.selection.named(['sol' num2str(index) '_MPP' num2str(i)]);
end



%% Physiques
ap = model.component('component').physics('phy_ap');

% Ajouter cavités et plaques à la physique acoustique
model = perso_add_selection_to_physics(model, 'phy_ap', ['sol' num2str(index) '_all_cavities']);
model = perso_add_selection_to_physics(model, 'phy_ap', ['sol' num2str(index) '_all_MPPs']);

% Modèle poro pour plaques perforées
pom = ap.create(['sol' num2str(index) '_phy_poro'], 'PoroacousticsModel', 3);
pom.selection.named(['sol' num2str(index) '_all_MPPs']);
pom.set('FluidModel', 'JohnsonChampouxAllard');

% Condition d’impédance de couche limite sur les parois d’air des cavités
tvb = ap.create(['sol' num2str(index) '_tvb'], 'ThermoviscousBoundaryLayerImpedance', 2);
tvb.selection.named(['sol' num2str(index) '_bnd_air_only']);
tvb.set('FluidMaterial', 'air_perso');

%% Maillage
mesh = model.component('component').mesh('mesh');
ftri = mesh.create(['sol' num2str(index) '_ftri'], 'FreeTet');
ftri.selection.named(['sol' num2str(index)]);
ftri_size = ftri.create('size1', 'Size');
ftri_size.set('hauto', 2);

% % Couche limite sur les parois d’air
% bl = mesh.create(['sol' num2str(index) 'bl'], 'BndLayer'); 
% bl.selection.named(['sol' num2str(index)]);
% bl.set('splitdivangle', 25);
% bl.set('smoothtransition', false);
% blp = bl.create('blp', 'BndLayerProp');  
% blp.selection.named(['sol' num2str(index) '_bnd_air_only']); 
% blp.set('blnlayers', 4);
% blp.set('blstretch', 1.1);
% blp.set('inittype', 'blhtot');
% blp.set('blhmin', 'd_visc');

mesh.run;

out = model;

end