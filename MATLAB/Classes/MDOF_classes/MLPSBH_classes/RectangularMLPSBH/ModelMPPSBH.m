function out = ModelMPPSBH(config, input_model, index, env)

% Cette fonction permet d'intégrer la géométrie, la physique et le maillage de la solution appelée classMPPSBH_Rectangluar à
% un modèle préexistant permettant de réaliser des calculs numériques sur tube d'impédance

model = input_model;

%% Extraction des variables 

pt = config.PlatesThickness;
cavw = config.CavitiesWidth;
ct = config.CavitiesThickness;
sw = config.SlitsWidth;
los = config.ListOfSubelements;
N = length(pt); % number of cells (slit backed by a cavity)

%% Création des variables et paramètres du modèle 

% paramètres
model.param.set(['sol' num2str(index) '_w'], [num2str(cavw) '[m]'], 'largeur');
model.param.set(['sol' num2str(index) '_xc'], ['sol' num2str(index) '_xl+sol' num2str(index) '_w/2'], 'ligne centrale');
model.param.set(['sol' num2str(index) '_xr'], ['sol' num2str(index) '_xl+sol' num2str(index) '_w'], 'ligne d''acotement à droite');
model.param.set(['sol' num2str(index+1) '_xl'], ['sol' num2str(index) '_xl+sol' num2str(index) '_w+2[mm]'], 'ligne d''acotement à gauche');

%% Géométrie

geom = model.component('component').geom('geometry');

for i = 1:N
    % Création d'un rectangle pour le pore i
    rp = geom.create(['sol' num2str(index) '_rp' num2str(i)], 'Rectangle');
    rp.set('pos', {['sol' num2str(index) '_xc+' num2str(-sw(i)/2)] num2str(-sum(pt(1:i)) - sum(ct(1:i-1)))});
    rp.set('size', {num2str(sw(i)) num2str(pt(i))});
    
    % Création d'un rectangle pour la cavité i
    rc = geom.create(['sol' num2str(index) '_rc' num2str(i)], 'Rectangle');
    rc.set('pos', {['sol' num2str(index) '_xc-sol' num2str(index) '_w/2'] num2str(-sum(pt(1:i)) - sum(ct(1:i)))});
    rc.set('size', {['sol' num2str(index) '_w'] num2str(ct(i))});
end

geom.run;

%% Sélection des boites

% Pour la solution entière
box_mat = model.component('component').selection.create(['sol' num2str(index)], 'Box');
box_mat.set('entitydim', 2); % On sélectionne des objets 2D
box_mat.set('ymax', '0.01[mm]');
box_mat.set('xmax', ['sol' num2str(index) '_xr+0.01[mm]']);
box_mat.set('xmin', ['sol' num2str(index) '_xl-0.01[mm]']);
box_mat.set('condition', 'inside');

% Pour chaque plaque perforée
for i = 1:N
    box_MPP = model.component('component').selection.create(['sol' num2str(index) '_MPP', num2str(i)], 'Box');
    box_MPP.set('entitydim', 2);
    box_MPP.set('ymax', num2str(1e-6 - sum(pt(1:i-1)) - sum(ct(1:i-1))));
    box_MPP.set('ymin', num2str(-1e-6 - sum(pt(1:i)) - sum(ct(1:i-1))));
    box_MPP.set('xmax', ['sol' num2str(index) '_xr+0.01[mm]']);
    box_MPP.set('xmin', ['sol' num2str(index) '_xl-0.01[mm]']);
    box_MPP.set('condition', 'inside');

    % On récupère les arêtes latérales de chaque zone perforée
    box_MPP_bnd = model.component('component').selection.create(['sol' num2str(index) '_MPP_bnd', num2str(i)], 'Box');
    box_MPP_bnd.set('entitydim', 1);
    box_MPP_bnd.set('ymax', num2str(-1e-5 - sum(pt(1:i-1)) - sum(ct(1:i-1))));
    box_MPP_bnd.set('ymin', num2str(+1e-5 - sum(pt(1:i)) - sum(ct(1:i-1))));
    box_MPP_bnd.set('xmax', ['sol' num2str(index) '_xr+0.01[mm]']);
    box_MPP_bnd.set('xmin', ['sol' num2str(index) '_xl-0.01[mm]']);
    box_MPP_bnd.set('condition', 'intersects');
end

% Pour toutes les plaques perforées
box_MPPs = model.component('component').selection.create(['sol' num2str(index) '_all_MPPs'], 'Box');
box_MPPs.set('inputent', 'selections');
box_MPPs.set('input', cellstr(['sol' num2str(index) '_MPP'] + string(1:N))); 

% Pour chaque cavité
for i = 1:N
    box_cav = model.component('component').selection.create(['sol' num2str(index) '_cav', num2str(i)], 'Box');
    box_cav.set('entitydim', 2);
    box_cav.set('ymax', num2str(1e-5- sum(pt(1:i)) - sum(ct(1:i-1))));
    box_cav.set('ymin', num2str(-1e-5 - sum(pt(1:i)) - sum(ct(1:i))));
    box_cav.set('xmax', ['sol' num2str(index) '_xr+0.01[mm]']);
    box_cav.set('xmin', ['sol' num2str(index) '_xl-0.01[mm]']);
    box_cav.set('condition', 'inside');
    % box_cav.set('condition', 'intersects');
end

% Pour les arètes des cavités (côté gauche)
box_cav_left_bnds = model.component('component').selection.create(['sol' num2str(index) '_cav_bnd_left'], 'Box');
box_cav_left_bnds.set('entitydim', 1);
box_cav_left_bnds.set('ymax', '-0.01[mm]');
box_cav_left_bnds.set('xmax', ['sol' num2str(index) '_xr+0.01[mm]']);
box_cav_left_bnds.set('xmin', ['sol' num2str(index) '_xl-0.01[mm]']);
box_cav_left_bnds.set('condition', 'intersects');

% Pour les arètes des cavités (côté droit)
box_cav_right_bnds = model.component('component').selection.create(['sol' num2str(index) '_cav_bnd_right'], 'Box');
box_cav_right_bnds.set('entitydim', 1);
box_cav_right_bnds.set('ymax', '-0.01[mm]');
box_cav_right_bnds.set('xmax', ['sol' num2str(index) '_xr+0.01[mm]']);
box_cav_right_bnds.set('xmin', ['sol' num2str(index) '_xl-0.01[mm]']);
box_cav_right_bnds.set('condition', 'intersects');

% Pour toutes les arêtes des cavités
box_all_cav_bnds = model.component('component').selection.create(['sol' num2str(index) '_bnd_lyr_tv'], 'Box');
box_all_cav_bnds.set('inputent', 'selections');
box_all_cav_bnds.set('entitydim', 1);
box_all_cav_bnds.set('input', {['sol' num2str(index) '_cav_bnd_left'], ['sol' num2str(index) '_cav_bnd_right']}); 

% Pour toutes les cavités
box_MPPs_bnds = model.component('component').selection.create(['sol' num2str(index) '_all_cavities'], 'Box');
box_MPPs_bnds.set('inputent', 'selections');
box_MPPs_bnds.set('input', cellstr(['sol' num2str(index) '_cav'] + string(1:N))); 

% Pour les frontière thermo-visqueuses entre les domaines thermo-visqueux et acoustiques
box_bnd_ap_tv = model.component('component').selection.create(['sol' num2str(index) '_bnd_ap_tv'], 'Box');
box_bnd_ap_tv.set('entitydim', 1);
box_bnd_ap_tv.set('ymax', '-0.01[mm]');
box_bnd_ap_tv.set('xmax', ['sol' num2str(index) '_xr+0.01[mm]']);
box_bnd_ap_tv.set('xmin', ['sol' num2str(index) '_xl-0.01[mm]']);
box_bnd_ap_tv.set('condition', 'inside');

%% Matériaux

% JCA : Plates

for i = 1:N
    JCAmat = model.component('component').material.create(['sol' num2str(index) '_mat' num2str(i)], 'Common');
    JCAmat.propertyGroup.create('PoroacousticsModel', 'Poroacoustics_model');
    JCAmat.propertyGroup('def').set('density', 'rho0');
    JCAmat.propertyGroup('def').set('soundspeed', 'co');
    JCAmat.propertyGroup('def').set('dynamicviscosity', 'neta');
    JCAmat.propertyGroup('def').set('thermalconductivity', {'kappa' '0' '0' '0' 'kappa' '0' '0' '0' 'kappa'});
    JCAmat.propertyGroup('def').set('heatcapacity', 'cp');
    % JCAmat.propertyGroup('def').set('ratioofspecificheat', 'gamma');
    JCAmat.propertyGroup('def').set('ratioofspecificheat', '1.4');
    % JCAmat.propertyGroup('def').set('gamma', 'gamma');

    JCAparam = los{i}.Configuration.ListOfSubelements{1}.Configuration.JCAParameters;

    % Porosité
    JCAmat.propertyGroup('def').set('porosity', num2str(JCAparam.Porosity));
    % Longueur caractéristique visqueuse      
    JCAmat.propertyGroup('PoroacousticsModel').set('Lv', num2str(JCAparam.ViscousCaracteristicLength));
    % Longueur caractéristiques thermique
    JCAmat.propertyGroup('PoroacousticsModel').set('Lth', num2str(JCAparam.ThermalCaracteristicLength));
    % Tortuosité
    if isscalar(JCAparam.Tortuosity)
        JCAmat.propertyGroup('PoroacousticsModel').set('tau', num2str(JCAparam.Tortuosity));
    else
        JCAmat.propertyGroup('PoroacousticsModel').set('tau', num2str(JCAparam.Tortuosity(env)));
    end
    % Résistivité
    JCAmat.propertyGroup('PoroacousticsModel').set('Rf', num2str(JCAparam.AirFlowResistivity(env)));
    % Application du matériau i+1 à la i-ème plaque
    JCAmat.selection.named(['sol' num2str(index) '_MPP' num2str(i)]);
end

%% Physique 


% On ajoute le reste de la solution à la Physique Thermo-Viscous Acoustic
model = perso_add_selection_to_physics(model, 'phy_tv', ['sol' num2str(index) '_all_cavities']);

% Pressure acoustic
ap = model.component('component').physics('phy_ap');
model = perso_add_selection_to_physics(model, 'phy_ap', ['sol' num2str(index) '_all_MPPs']);

% Poroacoustic
pom = ap.create(['sol' num2str(index), 'phy_poro'], 'PoroacousticsModel', 2);
pom.selection.named(['sol' num2str(index) '_all_MPPs']);
pom.set('FluidModel', 'JohnsonChampouxAllard');

%% Maillage

mesh = model.component('component').mesh('mesh');  

% Création d'un maillage triangulaire libre pour les plaques perforées
ftri = mesh.create(['sol' num2str(index) '_ftri'], 'FreeTri');
ftri.selection.named(['sol' num2str(index)]);
ftri_size = ftri.create('size1', 'Size');
ftri_size.set('hauto', 2); % Maillage très fin;

% Création d'une couche de bord dans le maillage
bl = mesh.create(['sol' num2str(index) 'bl'], 'BndLayer'); 
bl.selection.named(['sol' num2str(index)]);
bl.set('splitdivangle', 25);
bl.set('smoothtransition', false);
blp = bl.create('blp', 'BndLayerProp');  

blp.selection.named(['sol' num2str(index) '_bnd_lyr_tv']); 
blp.set('blnlayers', 4);
blp.set('blstretch', 1.1);
blp.set('inittype', 'blhtot');
blp.set('blhmin', 'd_visc');
mesh.run;

out = model;
