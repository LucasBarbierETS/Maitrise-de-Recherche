function output_model = ModelSDOF(config, input_model, index, env)

% Cette fonction permet d'intégrer la géométrie, la physique et le maillage de la solution appelée sol_bf à
% un modèle préexistant permettant de réaliser des calculs numériques sur tube d'impédance

%% Extraction des variables 
model = input_model;
pt = config.PlateThickness;
cavw = config.CavityWidth;
ct = config.CavityThickness;
los = config.ListOfSubelements;

%% Création des variables et paramètres du modèle 

% paramètres
model.param.set(['w', num2str(index)], [num2str(cavw) '[m]'], 'largeur');
model.param.set(['xc' num2str(index)], ['xl' num2str(index) '+w' num2str(index) '/2'], 'ligne centrale');
model.param.set(['xr' num2str(index)], ['xl' num2str(index) '+w' num2str(index)], 'ligne d''acotement à droite');
model.param.set(['xl' num2str(index+1)], ['xl' num2str(index) '+w' num2str(index) '+2[mm]'], 'ligne d''acotement à gauche');

%% Géométrie

geom = model.component('component').geom('geometry');


% Création d'un rectangle pour le pore
rp = geom.create(['sol' num2str(index) '_rp'], 'Rectangle');
rp.set('pos', {['xl' num2str(index)] num2str(-pt)});
rp.set('size', {['w', num2str(index)] num2str(pt)});

% Création d'un rectangle pour la cavité i
rc = geom.create(['sol' num2str(index) '_rc'], 'Rectangle');
rc.set('pos', {['xl' num2str(index)]  num2str(-pt-ct)});
rc.set('size', {['w' num2str(index)] num2str(ct)});


geom.run;

%% Sélection des boites

% On crée des boites pour sélectionner facilement des contours, des
% surfaces, et leur appliquer des propriétés physiques.

% Pour la solution entière
box_mat = model.component('component').selection.create(['sol' num2str(index)], 'Box');
box_mat.set('entitydim', 2); % On sélectionne des objets 2D
box_mat.set('ymax', '0.01[mm]');
box_mat.set('xmax', ['xr' num2str(index) '+0.01[mm]']);
box_mat.set('xmin', ['xl' num2str(index) '-0.01[mm]']);
box_mat.set('condition', 'inside');

% Pour la première plaque
box_MPP = model.component('component').selection.create(['sol' num2str(index) '_MPP'], 'Box');
box_MPP.set('entitydim', 2); % On sélectionne des objets 2D
box_MPP.set('ymax', '0.01[mm]');
box_MPP.set('ymin', num2str(-pt - 1e-5));
box_MPP.set('xmax', ['xr' num2str(index) '+0.01[mm]']);
box_MPP.set('xmin', ['xl' num2str(index) '-0.01[mm]']);
box_MPP.set('condition', 'inside');

% Pour le matériau sauf la première plaque
box_wt1p = model.component('component').selection.create(['sol' num2str(index) '_cav'], 'Box');
box_wt1p.set('entitydim', 2); % On sélectionne des objets 2D
box_wt1p.set('ymax', num2str(-pt + 1e-5));
box_wt1p.set('xmax', ['xr' num2str(index) '+0.01[mm]']);
box_wt1p.set('xmin', ['xl' num2str(index) '-0.01[mm]']);
box_wt1p.set('condition', 'inside');

% Pour la frontière thermo-visqueuse entre les domaines thermo-visqueux et acoustiques
box_bnd_ap_tv = model.component('component').selection.create(['sol' num2str(index) '_bnd_ap_tv'], 'Box');
box_bnd_ap_tv.set('entitydim', 1); % On sélectionne les arêtes
box_bnd_ap_tv.set('ymax', num2str(-pt + 1e-5));
box_bnd_ap_tv.set('ymin', num2str(-pt - 1e-5));
box_bnd_ap_tv.set('xmax', ['xr' num2str(index) '+0.01[mm]']);
box_bnd_ap_tv.set('xmin', ['xl' num2str(index) '-0.01[mm]']);
box_bnd_ap_tv.set('condition', 'inside');

% % Pour la condition de continuité
% box_bnd_cont_ap = model.component('component').selection.create(['sol' num2str(index) '_bnd_cont_ap'], 'Box');
% box_bnd_cont_ap.set('entitydim', 1); % On sélectionne les arêtes
% box_bnd_cont_ap.set('ymax', '0.01[mm]');
% box_bnd_cont_ap.set('ymin', '-0.01[mm]');
% box_bnd_cont_ap.set('xmax', ['xc' num2str(index) '+' num2str(sw(1)/2) '+0.01[mm]']);
% box_bnd_cont_ap.set('xmin', ['xc' num2str(index) '-' num2str(sw(1)/2) '-0.01[mm]']);
% box_bnd_cont_ap.set('condition', 'inside');

% Pour les frontières du domaine visquo-thermique
box_bnd_lyr_tv = model.component('component').selection.create(['sol' num2str(index) '_bnd_lyr_tv'], 'Box');
box_bnd_lyr_tv.set('entitydim', 1); % On sélectionne les arêtes
box_bnd_lyr_tv.set('ymax', '-0.01[mm]');
box_bnd_lyr_tv.set('xmax', ['xr' num2str(index) '+0.01[mm]']);
box_bnd_lyr_tv.set('xmin', ['xl' num2str(index) '-0.01[mm]']);

%% Définition des matériaux (1ère plaque)

JCAplate = model.component('component').material.create(['sol' num2str(index) '_JCAfirstplate'], 'Common');
JCAplate.propertyGroup.create('PoroacousticsModel', 'Poroacoustics_model');
JCAplate.propertyGroup('def').set('density', 'rho0');
JCAplate.propertyGroup('def').set('soundspeed', 'co');
JCAplate.propertyGroup('def').set('dynamicviscosity', 'neta');
JCAplate.propertyGroup('def').set('thermalconductivity', {'kappa' '0' '0' '0' 'kappa' '0' '0' '0' 'kappa'});
JCAplate.propertyGroup('def').set('heatcapacity', 'cp');
% JCAfirstplate.propertyGroup('def').set('ratioofspecificheat', 'gamma');
JCAplate.propertyGroup('def').set('ratioofspecificheat', '1.4');
% JCAfirstplate.propertyGroup('def').set('gamma', 'gamma');

JCAparam = los{1}.Configuration.JCAParameters;

% Porosité
JCAplate.propertyGroup('def').set('porosity', num2str(JCAparam.Porosity));
% Longueur caractéristique visqueuse      
JCAplate.propertyGroup('PoroacousticsModel').set('Lv', num2str(JCAparam.ViscousCaracteristicLength));
% Longueur caractéristiques thermique
JCAplate.propertyGroup('PoroacousticsModel').set('Lth', num2str(JCAparam.ThermalCaracteristicLength));

% Tortuosité
if strcmp(config.HighLevel, 'false')
    JCAplate.propertyGroup('PoroacousticsModel').set('tau', num2str(JCAparam.Tortuosity));
elseif strcmp(config.HighLevel, 'true')
    JCAplate.propertyGroup('PoroacousticsModel').set('tau', num2str(JCAparam.Tortuosity(env)));
end

% Résistivité
JCAplate.propertyGroup('PoroacousticsModel').set('Rf', num2str(JCAparam.AirFlowResistivity(env)));
% Application du matériau i+1 à la i-ème plaque
JCAplate.selection.named(['sol' num2str(index) '_MPP']);

%% Physique 

% Pression acoustique 
ap = model.component('component').physics('phy_ap');
model = perso_add_selection_to_physics(model, 'phy_ap', ['sol' num2str(index) '_MPP']);

% Création d'une physique poroacoustique
pom = ap.create(['pom' num2str(index)], 'PoroacousticsModel', 2);
pom.selection.named(['sol' num2str(index) '_MPP']);
pom.set('FluidModel', 'JohnsonChampouxAllard');

% On ajoute le reste de la solution à la Physique Thermo-Viscous Acoustic
model = perso_add_selection_to_physics(model, 'phy_tv', ['sol' num2str(index) '_cav']);

%% Maillage

mesh = model.component('component').mesh('mesh');  

% Création d'un maillage triangulaire libre
ftri_mat = mesh.create(['sol' num2str(index) '_ftri'], 'FreeTri');
ftri_mat.selection.named(['sol' num2str(index)]);
ftri_size = ftri_mat.create('size1', 'Size');
ftri_size.set('hauto', 2); % Maillage très fin
mesh.run;

% Création d'une couche de bord dans le maillage
bl = mesh.create(['sol' num2str(index) 'bl'], 'BndLayer'); 
bl.selection.named(['sol' num2str(index)]);
bl.set('splitdivangle', 25);
bl.set('smoothtransition', false);
blp = bl.create('blp', 'BndLayerProp');  
% On sélectionne toutes les frontières et le serveur se charge d'appliquer
% la condition partout à elle est applicable
blp.selection.named(['sol' num2str(index) '_bnd_lyr_tv']); 
blp.set('blnlayers', 4);
blp.set('blstretch', 1.1);
blp.set('inittype', 'blhtot');
blp.set('blhmin', 'd_visc');

output_model = model;

