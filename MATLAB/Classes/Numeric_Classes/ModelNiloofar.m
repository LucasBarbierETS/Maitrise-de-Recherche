function output_model = ModelNiloofar(config, input_model, index, env)

% Cette fonction permet d'intégrer la géométrie, la physique et le maillage de la solution appelée sol_bf à
% un modèle préexistant permettant de réaliser des calculs numériques sur tube d'impédance

model = input_model;

%% Extraction des variables 

cavw = config.CavitiesWidth;
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
model.param.set(['sol' num2str(index) '_w'], [num2str(cavw) '[m]'], 'largeur');
model.param.set(['sol' num2str(index) '_L'], [num2str(L) '[m]'], 'longueur');
model.param.set(['sol' num2str(index) '_xc'], ['sol' num2str(index) '_xl+sol' num2str(index) '_w/2'], 'ligne centrale');
model.param.set(['sol' num2str(index) '_xr'], ['sol' num2str(index) '_xl+sol' num2str(index) '_w'], 'ligne d''acotement à droite');
model.param.set(['sol' num2str(index+1) '_xl'], ['sol' num2str(index) '_xl+sol' num2str(index) '_w+2[mm]'], 'ligne d''acotement à gauche');

% Paramètres de la géométrie
model.param.set(['sol' num2str(index) '_l'], num2str(l), 'épaisseur des plaques');
model.param.set(['sol' num2str(index) '_d'], num2str(d), 'incrément');
model.param.set(['sol' num2str(index) '_flt'], num2str(flt), 'épaisseur de la première couche');
model.param.set(['sol' num2str(index) '_m'], num2str(m), 'espace avant 1ère plaque à gauche');
model.param.set(['sol' num2str(index) '_n'], num2str(n), 'espace avant 1ère plaque à droite');
model.param.set(['sol' num2str(index) '_a1'], num2str(a1), 'longueur de la 1ère plaque gauche');
model.param.set(['sol' num2str(index) '_b1'], num2str(b1), 'longueur de la 1ère plaque droite');

%% Géométrie

geom = model.component('component').geom('geometry');

% Première cavité
frc = geom.create(['sol' num2str(index) '_frc'], 'Rectangle');
frc.set('pos', {['sol' num2str(index) '_xl'], ['-sol' num2str(index) '_flt']});
frc.set('size', {['sol' num2str(index) '_w'], ['sol' num2str(index) '_flt']});

for i = 1:N
    % Création d'un rectangle pour la plaque gauche i
    lp = geom.create(['sol' num2str(index) '_lp' num2str(i)], 'Rectangle');
    lp.set('pos', {['sol' num2str(index) '_xl+sol' num2str(index) '_a1+' num2str(i-1) '*sol' num2str(index) '_d'], ['-sol' num2str(index) '_flt-' num2str(i-1) '*sol' num2str(index) '_m-' num2str(i) '*sol' num2str(index) '_l']}); % {xl+a1, -i*(m+l)}
    lp.set('size', {['sol' num2str(index) '_w-(sol' num2str(index) '_a1+' num2str(i-1) '*sol' num2str(index) '_d)'], ['sol' num2str(index) '_l']}); % {w-a1, l}
    
    % Création pour la cavité i-1
    lc1 = geom.create(['sol' num2str(index) '_lc' num2str(i)], 'Rectangle');
    lc1.set('pos', {['sol' num2str(index) '_xl'], ['-sol' num2str(index) '_flt-' num2str(i-2) '*sol' num2str(index) '_m-' num2str(i-1) '*sol' num2str(index) '_l-sol' num2str(index) '_n']}); % {xl, -(i-1)*(m+l)-n}
    lc1.set('size', {['sol' num2str(index) '_w'] ['sol' num2str(index) '_n-sol' num2str(index) '_m-sol' num2str(index) '_l']}); % {w, n-m-l}

    % Création d'un rectangle pour la plaque droite i
    rp = geom.create(['sol' num2str(index) '_rp' num2str(i)], 'Rectangle');
    rp.set('pos', {['sol' num2str(index) '_xl'], ['-sol' num2str(index) '_flt-' num2str(i-2) '*sol' num2str(index) '_m-' num2str(i-1) '*sol' num2str(index) '_l-sol' num2str(index) '_n-sol' num2str(index) '_l']}); % {xl, -(i-1)*(m+l)-(n+l)}
    rp.set('size', {['sol' num2str(index) '_w-(sol' num2str(index) '_b1+' num2str(i-1) '*sol' num2str(index) '_d)'], ['sol' num2str(index) '_l']}); % {w-b1, l}

    % Création pour la cavité i-2
    lc2 = geom.create(['sol' num2str(index) '_rc' num2str(i)], 'Rectangle');
    lc2.set('pos', {['sol' num2str(index) '_xl'] ['-sol' num2str(index) '_flt-' num2str(i) '*sol' num2str(index) '_m-' num2str(i+1) '*sol' num2str(index) '_l+sol' num2str(index) '_l']}); % {xl, -(i+1)*(m+l) + l}
    lc2.set('size', {['sol' num2str(index) '_w'] ['2*sol' num2str(index) '_m-sol' num2str(index) '_n']}); % {w, 2m-n}
end

% Création pour le fond de la cavité
lc2 = geom.create(['sol' num2str(index) '_lrc'], 'Rectangle');
lc2.set('pos', {['sol' num2str(index) '_xl'] ['-sol' num2str(index) '_L']});
lc2.set('size', {['sol' num2str(index) '_w'] ['-sol' num2str(index) '_flt-' num2str(N) '*sol' num2str(index) '_m-' num2str(N+1) '*sol' num2str(index) '_l+sol' num2str(index) '_l+sol' num2str(index) '_L']}); % {w, 2m-n}


geom.run;

% On créer une liste de tous les géométries associés à ['sol', num2str(index)]
list_obj_names = {};
obj_names = cell(geom.objectNames);
for i = 1:length(obj_names)
    if contains(obj_names{i}, ['sol', num2str(index)])
        list_obj_names{end+1} = obj_names{i};
    end
end

% On crée l'union des objets de la solution
uni = geom.create(['sol', num2str(index), '_union'], 'Union');
uni.selection('input').set(list_obj_names);
uni.set('intbnd', false);

geom.run;

%% Sélection des boites

% On crée des boites pour sélectionner facilement des contours, des
% surfaces, et leur appliquer des propriétés physiques.

% Pour la solution entière
box_mat = model.component('component').selection.create(['sol' num2str(index)], 'Box');
box_mat.set('entitydim', 2); % On sélectionne des objets 2D
box_mat.set('ymax', '0.01[mm]');
box_mat.set('xmax', ['sol' num2str(index) '_xr+0.01[mm]']);
box_mat.set('xmin', ['sol' num2str(index) '_xl-0.01[mm]']);
box_mat.set('condition', 'inside');

% Pour la frontière multiphysique
box_bnd_cont_ap = model.component('component').selection.create(['sol' num2str(index) '_bnd_ap_tv'], 'Box');
box_bnd_cont_ap.set('entitydim', 1); % On sélectionne les arêtes
box_bnd_cont_ap.set('ymax', '0.01[mm]');
box_bnd_cont_ap.set('ymin', '-0.01[mm]');
box_bnd_cont_ap.set('xmax', ['sol' num2str(index) '_xr+0.01[mm]']);
box_bnd_cont_ap.set('xmin', ['sol' num2str(index) '_xl-0.01[mm]']);
box_bnd_cont_ap.set('condition', 'inside');

% Pour les frontières du domaine visquo-thermique
box_bnd_lyr_tv = model.component('component').selection.create(['sol' num2str(index) '_bnd_lyr_tv'], 'Box');
box_bnd_lyr_tv.set('entitydim', 1); % On sélectionne les arêtes
box_bnd_lyr_tv.set('ymax', '-0.01[mm]');
box_bnd_lyr_tv.set('xmax', ['sol' num2str(index) '_xr+0.01[mm]']);
box_bnd_lyr_tv.set('xmin', ['sol' num2str(index) '_xl-0.01[mm]']);

% %% Définition des matériaux (1ère plaque)
% 
% JCAfirstplate = model.component('component').material.create(['sol' num2str(index) '_JCAfirstplate'], 'Common');
% JCAfirstplate.propertyGroup.create('PoroacousticsModel', 'Poroacoustics_model');
% JCAfirstplate.propertyGroup('def').set('density', 'rho0');
% JCAfirstplate.propertyGroup('def').set('soundspeed', 'co');
% JCAfirstplate.propertyGroup('def').set('dynamicviscosity', 'neta');
% JCAfirstplate.propertyGroup('def').set('thermalconductivity', {'kappa' '0' '0' '0' 'kappa' '0' '0' '0' 'kappa'});
% JCAfirstplate.propertyGroup('def').set('heatcapacity', 'cp');
% % JCAfirstplate.propertyGroup('def').set('ratioofspecificheat', 'gamma');
% JCAfirstplate.propertyGroup('def').set('ratioofspecificheat', '1.4');
% % JCAfirstplate.propertyGroup('def').set('gamma', 'gamma');
% 
% JCAparam = los{1}.Configuration.ListOfSubelements{1}.Configuration.JCAParameters;
% 
% % Porosité
% JCAfirstplate.propertyGroup('def').set('porosity', num2str(JCAparam.Porosity));
% % Longueur caractéristique visqueuse      
% JCAfirstplate.propertyGroup('PoroacousticsModel').set('Lv', num2str(JCAparam.ViscousCaracteristicLength));
% % Longueur caractéristiques thermique
% JCAfirstplate.propertyGroup('PoroacousticsModel').set('Lth', num2str(JCAparam.ThermalCaracteristicLength));
% 
% % Tortuosité
% if strcmp(config.HighLevel, 'false')
%     JCAfirstplate.propertyGroup('PoroacousticsModel').set('tau', num2str(JCAparam.Tortuosity));
% elseif strcmp(config.HighLevel, 'true')
%     JCAfirstplate.propertyGroup('PoroacousticsModel').set('tau', num2str(JCAparam.Tortuosity(env)));
% end
% 
% % Résistivité
% JCAfirstplate.propertyGroup('PoroacousticsModel').set('Rf', num2str(JCAparam.AirFlowResistivity(env)));
% % Application du matériau i+1 à la i-ème plaque
% JCAfirstplate.selection.named(['sol' num2str(index) '_MPP1']);


%% Physique 

% On ajoute la solution à la physique thermo-visqueuse
model = perso_add_selection_to_physics(model, 'phy_tv', ['sol' num2str(index)]);

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
bl.set('splitdivangle', 75);
bl.set('smoothtransition', false);
blp = bl.create('blp', 'BndLayerProp'); 
% On sélectionne toutes les frontières et le serveur se charge d'appliquer
% la condition partout à elle est applicable
blp.selection.named(['sol' num2str(index) '_bnd_lyr_tv']); 
blp.set('blnlayers', 4);
blp.set('blstretch', 1.1);
blp.set('inittype', 'blhtot');
blp.set('blhmin', 'd_visc');
mesh.run;

output_model = model;