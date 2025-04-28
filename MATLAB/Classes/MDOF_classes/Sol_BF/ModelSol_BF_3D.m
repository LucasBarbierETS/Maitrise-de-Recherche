function out = ModelSol_BF_3D(config, env)

% Description
%
% w: angular frequency
% config.PlatesThickness (pt)
% config.SlitWidth (sw)
% config.CavitiesThickness (ct)

% Schéma 2D:             
%                      pt(1)
% `                                   ct(2)
%                       |-|         |-------|
% ______________________   _______   _______       -
%                       | |       | |       |      | 
%                       | |       | |       |      | 
%                       |_|       | |       |      |
%             -              1    |_|   2   |      |
%       sw(1) |                    _        | .... |  impedance_tube_height
%             -          _        | |       |      |
%                       | |       | |       |      |
%                       | |       | |       |      |
%_______________________| |_______| |_______|      -

import com.comsol.model.*
import com.comsol.model.util.*

model = ModelUtil.create('Model');
ModelUtil.showProgress(true)

model.modelPath('C:\Users\lucas.barbier\OneDrive - ETS\CRIAQ-REAR\Maitrise LB\MATLAB\Classes\MDOF_classes\Sol_BF');

% Définition des variables

pt = config.PlatesThickness;
cavw = config.CavitiesWidth;
cavd = config.CavitiesDepth;
ct = config.CavitiesThickness;
sw = config.SlitsWidth;
los = config.ListOfSubelements;
N = length(sw); % number of cells (slit backed by a cavity)
param = env.air.parameters;
w = env.w;

model.param.set('Wx', [num2str(cavw) '[m]'], 'largeur du tube (direction x)');
model.param.set('Wy', [num2str(cavd) '[m]'], 'largeur du tube (direction y)');

model.param.set('D12', '20[mm]', 'distance entre les deux microphones');
model.param.set('D23', '35[mm]', 'distance entre le deuxième microphone et le domaine thermo-visqueux');
model.param.set('D3S', '5[mm]', 'distance entre le domaine thermovisqueux et la solution');
model.param.set('t', num2str(pt(1)), 'épaisseur de la première plaque')

var = model.variable.create('var1');
var.set('co', num2str(param.c0), 'Vitesse du son');
var.set('cp', num2str(param.Cp), ['Capacit' native2unicode(hex2dec({'00' 'e9'}), 'unicode') ...
    ' thermique ' native2unicode(hex2dec({'00' 'e0'}), 'unicode') ' pression constante']);
var.set('kappa', num2str(param.kappa), ['Conductivit' native2unicode(hex2dec({'00' 'e9'}), ...
    'unicode') ' thermique']);
var.set('neta', num2str(param.eta), ['Viscosité' native2unicode(hex2dec({'00' 'e9'}), ...
    'unicode') ' dynamique']);
var.set('rho0', num2str(param.rho), 'Masse volumique de l''air');
var.set('gamma', num2str(param.gamma), 'Masse volumique de l''air');

%% Géométrie

comp = model.component.create('comp1', true);
geom = comp.geom.create('geom1', 3);

% Tube d'impédance

blk1 = geom.create('blk1', 'Block');
blk1.set('pos', {'-Wx/2', '-Wy/2', 'D23 + D3S'});
blk1.set('size', {'Wx', 'Wy', 'D12'});
blk2 = geom.create('blk2', 'Block');
blk2.set('pos', {'-Wx/2', '-Wy/2', 'D3S'});
blk2.set('size', {'Wx', 'Wy', 'D23'});

blk3 = geom.create('blk3', 'Block');
blk3.set('pos', {'-Wx/2', '-Wy/2', '0'});
blk3.set('size', {'Wx', 'Wy', 'D3S'});

% 1ère plaque

% La première plaque est constituée d'un juxtaposition de cylindres
% représentant les perforations. Ces cylindres sont disposés dans la zone
% centrale de la plaque et correspondent à l'effet diaphragme définit par la largeur
% de fente. Ensuite la repartition des perforations sur la plaques
% s'effectue de sorte à placer les trous de manières régulières sur la zone
% restante. Le nombre de trous et la distance entre ceux-ci dans les deux
% directions x et y dépendent des paramètres de la plaque

phi = config.TopPlatePorosity;
hr = config.TopPlateHolesRadius;
plate_surface = cavw * cavd;
perforated_surface = plate_surface*phi;
hole_surface = pi * hr^2;
holes_number = round(perforated_surface/hole_surface);

if holes_number > 1
    % On obtient le nombre de perforation dans les deux directions
    [nbx, nby] = perso_distribute_holes(sw(1), cavd, holes_number);
else
    nbx = 1;
    nby = 1;
end

% On définit la distance entre les trous dans les deux directions
dx = sw(1) / (nbx+1);
dy = cavd / (nby+1);

% On construit les cylindres
cyl1 = geom.create('cyl1', 'Cylinder');
cyl1.set('pos', {num2str(-sw(1)/2 + dx), ['-Wy/2 + ' num2str(dy)], num2str(-pt(1))});
cyl1.set('r', num2str(hr));
cyl1.set('h', num2str(pt(1)));

% On répète le cylindre suivant une grille
arr1 = comp.geom('geom1').create('arr1', 'Array');
arr1.selection('input').set({'blk1'});
arr1.selection('input').init;
arr1.selection('input').set({'cyl1'});
arr1.set('type', 'three-dimensional');
arr1.set('fullsize', [nbx nby 1]);
arr1.set('displ', {num2str(dx), num2str(dy), '0'});

% On ajoute la 1ère cavité
bc1 = geom.create('bc1', 'Block');
bc1.set('pos', {'-Wx/2', '-Wy/2', num2str(-ct(1)-pt(1))});
bc1.set('size', {'Wx', 'Wy', num2str(ct(1))});

% On ajoute successivement les cavités et fentes
for i = 2:N
    % Création d'un bloc pour la fente i
    bf = geom.create(['bf' num2str(i)], 'Block');
    bf.set('pos', {num2str(-sw(i)), num2str(-cavd/2), num2str(-sum(pt(1:i))-sum(ct(1:i-1)))});
    bf.set('size', {num2str(sw(i)), num2str(cavd), num2str(pt(i))});
    
    % Création d'un bloc pour la cavité i
    bc = geom.create(['bc' num2str(i+1)], 'Block');
    bc.set('pos', {num2str(-cavw/2), num2str(-cavd/2), num2str(-sum(pt(1:i))-sum(ct(1:i)))});
    bc.set('size', {num2str(cavw), num2str(cavd), num2str(ct(i))});
end

% Exécution de la géométrie
geom.run; 
% Exécution finale pour finaliser les opérations géométriques
geom.run('fin');

% Affichage de la géométrie dans le modèle
mphgeom(model);

%% Boites de sélection

% Sélections pour la physique

% Pour le tube d'impédance (acoustic pressure)
box_tube = comp.selection.create('box_tube', 'Box');
box_tube.set('entitydim', 3); % On sélectionne des objets 2D
box_tube.set('zmin', 'D3S - 0.01[mm]');
box_tube.set('condition', 'inside');

% Pour le matériau (thermo-viscous acoustic)
box_mat = comp.selection.create('box_mat', 'Box');
box_mat.set('entitydim', 3);
box_mat.set('zmax', 'D3S + 0.01[mm]');
box_mat.set('condition', 'inside');

% Pour la source acoustique
box_src = comp.selection.create('box_src', 'Box');
box_src.set('entitydim', 2);
box_src.set('zmin', 'D12+D23+D3S-0.01[mm]');
box_src.set('zmax', 'D12+D23+D3S+0.01[mm]');
box_src.set('condition', 'inside');

% Pour le microphone 2
box_mic = comp.selection.create('box_mic', 'Box');
box_mic.set('entitydim', 2); 
box_mic.set('zmin', 'D23+D3S-0.01[mm]');
box_mic.set('zmax', 'D23+D3S+0.01[mm]');
box_mic.set('condition', 'inside');

% Pour l'interface multiphysique
box_bnd_tva = comp.selection.create('box_bnd_tva', 'Box');
box_bnd_tva.set('entitydim', 2); 
box_bnd_tva.set('zmin', 'D3S-0.01[mm]');
box_bnd_tva.set('zmax', 'D3S+0.01[mm]');
box_mic.set('condition', 'inside');

% Pour les frontières du domaine visquo-thermique
box_bnd_lyr = comp.selection.create('box_bnd_lyr', 'Box');
box_bnd_lyr.set('entitydim', 2);
box_bnd_lyr.set('zmax', 'D3S + 0.01[mm]');
box_bnd_lyr.set('condition', 'inside');

% Sélections pour le maillage

% Sélection des perforations (volumes)
comp.selection.create('box3', 'Box');
comp.selection('box3').label('holes');
comp.selection('box3').set('xmin', '-Wx/2 + 0.01[mm]');
comp.selection('box3').set('zmin', '-(t + 0.01[mm])');
comp.selection('box3').set('zmax', '0.01[mm]');
comp.selection('box3').set('condition', 'inside');

% Sélection du matériau sans les perforations 
comp.selection.create('dif4', 'Difference');
comp.selection('dif4').label('material without holes');
comp.selection('dif4').set('entitydim', 3);
comp.selection('dif4').set('add', {'box_mat'});
comp.selection('dif4').set('subtract', {'box3'});

% Sélection des faces des perforations (surfaces)
comp.selection.create('box2', 'Box');
comp.selection('box2').label('holes faces');
comp.selection('box2').set('entitydim', 2);
comp.selection('box2').set('xmin', '-Wx/2 + 0.01[mm]');
comp.selection('box2').set('zmin', '-(t + 0.01[mm])');
comp.selection('box2').set('zmax', '0.01[mm]');
comp.selection('box2').set('condition', 'inside');

% Sélection des faces latérales des perforations
comp.selection.create('box1', 'Box');
comp.selection('box1').label('holes side faces');
comp.selection('box1').set('entitydim', 2);
comp.selection('box1').set('zmax', '-0.01[mm]');
comp.selection('box1').set('zmin', '-t + 0.01[mm]');
comp.selection('box1').set('condition', 'intersects');

% Sélection des faces supérieure et inférieure des perforations
comp.selection.create('dif1', 'Difference');
comp.selection('dif1').label('holes top and bottom faces');
comp.selection('dif1').set('entitydim', 2);
comp.selection('dif1').set('add', {'box2'});
comp.selection('dif1').set('subtract', {'box1'});

% Sélection des faces de la plaque MPP (perforations comprises)
comp.selection.create('box4', 'Box');
comp.selection('box4').label('MPP faces');
comp.selection('box4').set('entitydim', 2);
comp.selection('box4').set('zmin', '-(t + 0.01[mm])');
comp.selection('box4').set('zmax', '0.01[mm]');
comp.selection('box4').set('condition', 'inside');

% Sélection des faces supérieure et inférieure de la plaque seulement
comp.selection.create('dif2', 'Difference');
comp.selection('dif2').label('plate faces');
comp.selection('dif2').set('entitydim', 2);
comp.selection('dif2').set('add', {'box4'});
comp.selection('dif2').set('subtract', {'box2'});

% Sélection des arêtes longitudinales et annulaires des perforations
comp.selection.create('box5', 'Box');
comp.selection('box5').label('holes edges');
comp.selection('box5').set('entitydim', 1);
comp.selection('box5').set('xmin', '-Wx/2 + 0.01[mm]');
comp.selection('box5').set('ymin', '-Wy/2 + 0.01[mm]');
comp.selection('box5').set('zmin', '-(t + 0.01[mm])');
comp.selection('box5').set('zmax', '0.01[mm]');
comp.selection('box5').set('condition', 'inside');

% Sélection des arêtes longitudinales des perforations
comp.selection.create('box6', 'Box');
comp.selection('box6').label('holes side edges');
comp.selection('box6').set('entitydim', 1);
comp.selection('box6').set('zmin', '-t + 0.01[mm]');
comp.selection('box6').set('zmax', '-0.01[mm]');
comp.selection('box6').set('condition', 'intersects');

% Sélection des arêtes annulaires des perforations
comp.selection.create('dif3', 'Difference');
comp.selection('dif3').label('holes top and bottom edges');
comp.selection('dif3').set('entitydim', 1);
comp.selection('dif3').set('add', {'box5'});
comp.selection('dif3').set('subtract', {'box6'});

%% Matériau

mat = comp.material.create('mat1', 'Common');
mat.label('Air');
mat.set('family', 'air');
mat.materialType('nonSolid');

mat.propertyGroup('def').set('thermalexpansioncoefficient', '');
mat.propertyGroup('def').set('molarmass', '');
mat.propertyGroup('def').set('bulkviscosity', '');
mat.propertyGroup('def').set('thermalexpansioncoefficient', {'alpha_p(pA,T)' '0' '0' '0' 'alpha_p(pA,T)' '0' '0' '0' 'alpha_p(pA,T)'});
mat.propertyGroup('def').set('molarmass', '0.02897[kg/mol]');
mat.propertyGroup('def').set('bulkviscosity', 'muB(T)');
mat.propertyGroup('def').set('relpermeability', {'1' '0' '0' '0' '1' '0' '0' '0' '1'});
mat.propertyGroup('def').set('relpermittivity', {'1' '0' '0' '0' '1' '0' '0' '0' '1'});
mat.propertyGroup('def').set('dynamicviscosity', 'eta(T)');
mat.propertyGroup('def').set('ratioofspecificheat', '1.4');
mat.propertyGroup('def').set('electricconductivity', {'0[S/m]' '0' '0' '0' '0[S/m]' '0' '0' '0' '0[S/m]'});
mat.propertyGroup('def').set('heatcapacity', 'Cp(T)');
mat.propertyGroup('def').set('density', 'rho(pA,T)');
mat.propertyGroup('def').set('thermalconductivity', {'k(T)' '0' '0' '0' 'k(T)' '0' '0' '0' 'k(T)'});
mat.propertyGroup('def').set('soundspeed', 'cs(T)');
mat.propertyGroup('def').addInput('temperature');
mat.propertyGroup('def').addInput('pressure');

mat_eta = mat.propertyGroup('def').func.create('eta', 'Piecewise');
mat_eta.set('arg', 'T');
mat_eta.set('pieces', {'200.0' '1600.0' '-8.38278E-7+8.35717342E-8*T^1-7.69429583E-11*T^2+4.6437266E-14*T^3-1.06585607E-17*T^4'});
mat_eta.set('argunit', 'K');
mat_eta.set('fununit', 'Pa*s');

mat_Cp = mat.propertyGroup('def').func.create('Cp', 'Piecewise');
mat_Cp.set('arg', 'T');
mat_Cp.set('pieces', {'200.0' '1600.0' '1047.63657-0.372589265*T^1+9.45304214E-4*T^2-6.02409443E-7*T^3+1.2858961E-10*T^4'});
mat_Cp.set('argunit', 'K');
mat_Cp.set('fununit', 'J/(kg*K)');

mat_rho = mat.propertyGroup('def').func.create('rho', 'Analytic');
mat_rho.set('expr', 'pA*0.02897/R_const[K*mol/J]/T');
mat_rho.set('args', {'pA' 'T'});
mat_rho.set('fununit', 'kg/m^3');
mat_rho.set('argunit', {'Pa' 'K'});
mat_rho.set('plotargs', {'pA' '101325' '101325'; 'T' '273.15' '293.15'});

mat_k = mat.propertyGroup('def').func.create('k', 'Piecewise');
mat_k.set('arg', 'T');
mat_k.set('pieces', {'200.0' '1600.0' '-0.00227583562+1.15480022E-4*T^1-7.90252856E-8*T^2+4.11702505E-11*T^3-7.43864331E-15*T^4'});
mat_k.set('argunit', 'K');
mat_k.set('fununit', 'W/(m*K)');

mat_cs = mat.propertyGroup('def').func.create('cs', 'Analytic');
mat_cs.set('expr', 'sqrt(1.4*R_const[K*mol/J]/0.02897*T)');
mat_cs.set('args', {'T'});
mat_cs.set('fununit', 'm/s');
mat_cs.set('argunit', {'K'});
mat_cs.set('plotargs', {'T' '273.15' '373.15'});

mat_an1 = mat.propertyGroup('def').func.create('an1', 'Analytic');
mat_an1.set('funcname', 'alpha_p');
mat_an1.set('expr', '-1/rho(pA,T)*d(rho(pA,T),T)');
mat_an1.set('args', {'pA' 'T'});
mat_an1.set('fununit', '1/K');
mat_an1.set('argunit', {'Pa' 'K'});
mat_an1.set('plotargs', {'pA' '101325' '101325'; 'T' '273.15' '373.15'});

mat_an2 = mat.propertyGroup('def').func.create('an2', 'Analytic');
mat_an2.set('funcname', 'muB');
mat_an2.set('expr', '0.6*eta(T)');
mat_an2.set('args', {'T'});
mat_an2.set('fununit', 'Pa*s');
mat_an2.set('argunit', {'K'});

mat_an2.set('plotargs', {'T' '200' '1600'});

mat_refract = mat.propertyGroup.create('RefractiveIndex', 'Refractive index');
mat_refract.set('n', {'1' '0' '0' '0' '1' '0' '0' '0' '1'});

mat_nlm = mat.propertyGroup.create('NonlinearModel', 'Nonlinear model');
mat_nlm.set('BA', '(def.gamma+1)/2');

mat_idlg = mat.propertyGroup.create('idealGas', 'Ideal gas');
mat_idlg_Cp = mat_idlg.func.create('Cp', 'Piecewise');
mat_idlg_Cp.label('Piecewise 2');
mat_idlg_Cp.set('arg', 'T');
mat_idlg_Cp.set('pieces', {'200.0' '1600.0' '1047.63657-0.372589265*T^1+9.45304214E-4*T^2-6.02409443E-7*T^3+1.2858961E-10*T^4'});
mat_idlg_Cp.set('argunit', 'K');
mat_idlg_Cp.set('fununit', 'J/(kg*K)');
mat_idlg.set('Rs', 'R_const/Mn');
mat_idlg.set('heatcapacity', 'Cp(T)');
mat_idlg.set('ratioofspecificheat', '1.4');
mat_idlg.set('molarmass', '0.02897');
mat_idlg.addInput('temperature');
mat_idlg.addInput('pressure');

mat.propertyGroup('def').set('thermalexpansioncoefficient', '');
mat.propertyGroup('def').set('molarmass', '');
mat.propertyGroup('def').set('bulkviscosity', '');
mat.propertyGroup('def').set('thermalexpansioncoefficient', {'alpha_p(pA,T)' '0' '0' '0' 'alpha_p(pA,T)' '0' '0' '0' 'alpha_p(pA,T)'});
mat.propertyGroup('def').set('molarmass', '0.02897[kg/mol]');
mat.propertyGroup('def').set('bulkviscosity', 'muB(T)');
mat.propertyGroup('def').set('relpermeability', {'1' '0' '0' '0' '1' '0' '0' '0' '1'});
mat.propertyGroup('def').set('relpermittivity', {'1' '0' '0' '0' '1' '0' '0' '0' '1'});
mat.propertyGroup('def').set('dynamicviscosity', 'eta(T)');
mat.propertyGroup('def').set('ratioofspecificheat', '1.4');
mat.propertyGroup('def').set('electricconductivity', {'0[S/m]' '0' '0' '0' '0[S/m]' '0' '0' '0' '0[S/m]'});
mat.propertyGroup('def').set('heatcapacity', 'Cp(T)');
mat.propertyGroup('def').set('density', 'rho(pA,T)');
mat.propertyGroup('def').set('thermalconductivity', {'k(T)' '0' '0' '0' 'k(T)' '0' '0' '0' 'k(T)'});
mat.propertyGroup('def').set('soundspeed', 'cs(T)');
mat.propertyGroup('def').addInput('temperature');
mat.propertyGroup('def').addInput('pressure');

%% Physique 

% Création d'une physique acoustique de pression
comp.physics.create('acpr', 'PressureAcoustics', 'geom1'); 
comp.physics('acpr').selection.named('box_tube'); 

% Création d'une physique thermoacoustique
comp.physics.create('ta', 'ThermoacousticsSinglePhysics', 'geom1'); 
comp.physics('ta').selection.named('box_mat');  % Sélection du matériau

% Création d'une fonctionnalité de pression dans la physique acoustique
comp.physics('acpr').create('pr1', 'Pressure', 2); 
comp.physics('acpr').feature('pr1').selection.named('box_src');  % Sélection du plan de la source
comp.physics('acpr').feature('pr1').set('p0', 1);  % Définition de la pression initiale à 1 Pa

% Configuration des multiphysiques
comp.multiphysics.create('atb1', 'AcousticThermoacousticBoundary', 2); 
comp.multiphysics('atb1').selection.named('box_bnd_tva'); % Sélection de la frontière thermo-visqueuse

%% Maillage

mesh1 = comp.mesh.create('mesh1');  
mesh1.feature('size').set('hauto', 8); 

% Maillage du tube

ftet1 = mesh1.create('ftet1', 'FreeTet');
ftet1.label('Maillage tetraedrique du tube');
ftet1.selection.named('box_tube')

% Maillage de la couche limite au niveau des perforations

bl1 = mesh1.create('bl1', 'BndLayer');
bl1.label('Maillage annulaire dans les perforations');
bl1.selection.named('box3'); % perforations (volumes)
blp1 = bl1.create('blp', 'BndLayerProp');
blp1.selection.named('box1'); % faces latérales des perforations
blp1.set('blnlayers', 4) % nombre de couches
blp1.set('blhtot', '0.0005'); % épaisseur totale (m)

bl6 = mesh1.create('bl6', 'BndLayer');
bl6.label('Maillage longitudinale dans les perforations');
bl6.selection.named('box3'); % perforations (volumes)
blp6 = bl6.create('blp', 'BndLayerProp');
blp6.selection.named('dif1'); % faces supérieure et inférieure
blp6.set('blnlayers', 2); % nombre de couches
blp6.set('blhtot', '1[mm]'); % épaisseur totale (m)

bl3 = mesh1.create('bl3', 'BndLayer');
bl3.label('Mailllage annulaire autour des perforations');
bl3.selection.geom('geom1', 2); % On sélectionne des surfaces
bl3.selection.named('dif2'); % face inf et sup de la plaque
blp3 = bl3.create('blp', 'BndLayerProp');
blp3.selection.named('dif3'); % Arêtes annulaires des perforations
blp3.set('blnlayers', 4);
blp3.set('blhtot', '0.0005'); 

% Maillage volumique du matériau

ftet2 = mesh1.create('ftet2', 'FreeTet');
ftet2.label('Maillage tetraedrique du materiau');
ftet2.selection.named('dif4'); % Matériau sans les perforations

% Exécution du maillage
mesh1.run;  
mphmesh(model);  

%% Etude

std1 = model.study.create('std1');  
std1.create('freq', 'Frequency');  
std1.feature('freq').set('plist', num2str(w/2/pi));  

% Création d'une solution nommée 'sol1'
sol1 = model.sol.create('sol1');  
sol1.study('std1');  
sol1.attach('std1'); 

% Création d'une étape d'étude
st1 = sol1.create('st1', 'StudyStep');  
st1.label('Compile Equations: Frequency Domain');  

% Création d'une variable
v1 = sol1.create('v1', 'Variables');  
v1.label('Dependent Variables 1.1');  
v1.set('clistctrl', {'p1'});  
v1.set('cname', {'freq'});   
v1.set('clist',  cellstr(join(string(w/2/pi)+"[Hz]")));  

% Création d'un solveur stationnaire
s1 = sol1.create('s1', 'Stationary');  
s1.create('fc1', 'FullyCoupled');  
s1.feature.remove('fcDef');  
s1.label('Stationary Solver 1.1');  
s1.feature('dDef').label('Direct 2');  
s1.feature('aDef').label('Advanced 1');  
s1.feature('aDef').set('complexfun', true); 
s1.feature('fc1').label('Fully Coupled 1.1');  

p1 = s1.create('p1', 'Parametric');  
p1.label('Parametric 1.1');  
p1.set('pname', {'freq'});  
p1.set('plistarr', cellstr(num2str(w/2/pi)));  
p1.set('punit', {'Hz'});  
p1.set('pcontinuationmode', 'no');  
p1.set('preusesol', 'auto'); 

d1 = s1.create('d1', 'Direct');  
d1.label('Direct 1.1');
d1.set('linsolver', 'pardiso');  
d1.set('pivotperturb', 1.0E-13);

sol1.runAll;  

%% Résultat

% Création d'un objet de ligne d'évaluation nommé 'av1'
model.result.numerical.create('av1', 'AvSurface');  

% Sélection du microphone 2
model.result.numerical('av1').selection.named('box_mic');  
model.result.numerical('av1').set('probetag', 'box_mic');  

% création d'une table de résultats
model.result.table.create('tbl1', 'Table');
model.result.numerical('av1').set('table', 'tbl1');
model.result.table('tbl1').comments('acoustic indicators');
model.result.numerical('av1').label('acoustic indicators');

model.result.numerical('av1').set('expr', {['1-abs((exp(-j*ta.omega/acpr.c*D12)-acpr.p_t)' ...
    '/(acpr.p_t-exp(j*ta.omega/acpr.c*D12))*exp(2*j*ta.omega/acpr.c*(D23 + D3S+D12)))^2']});
model.result.numerical('av1').set('unit', {'1'});
model.result.numerical('av1').set('descr', {'Sound absorption'});

model.result.numerical('av1').setIndex('expr', ['real((exp(-j*ta.omega/acpr.c*D12)-acpr.p_t)' ...
    '/(acpr.p_t-exp(j*ta.omega/acpr.c*D12))*exp(2*j*ta.omega/acpr.c*(D23 + D3S+D12)))'], 1);
model.result.numerical('av1').setIndex('descr', 'Re(R)', 1);
model.result.numerical('av1').setIndex('unit', '1', 1);

model.result.numerical('av1').setIndex('expr', ['imag((exp(-j*ta.omega/acpr.c*D12)-acpr.p_t)' ...
    '/(acpr.p_t-exp(j*ta.omega/acpr.c*D12))*exp(2*j*ta.omega/acpr.c*(D23 + D3S+D12)))'], 2);
model.result.numerical('av1').setIndex('descr', 'Im(R)', 2);
model.result.numerical('av1').setIndex('unit', '1', 2);

model.result.numerical('av1').setIndex('expr', ['real((1+(exp(-j*ta.omega/acpr.c*D12)-acpr.p_t)' ...
    '/(acpr.p_t-exp(j*ta.omega/acpr.c*D12))*exp(2*j*ta.omega/acpr.c*(D23 + D3S+D12)))' ...
    '/(1-(exp(-j*ta.omega/acpr.c*D12)-acpr.p_t)/(acpr.p_t-exp(j*ta.omega/acpr.c*D12))' ...
    '*exp(2*j*ta.omega/acpr.c*(D23 + D3S+D12))))'], 3);
model.result.numerical('av1').setIndex('descr', 'Re(Zns)', 3);

model.result.numerical('av1').setIndex('expr', ['imag((1+(exp(-j*ta.omega/acpr.c*D12)-acpr.p_t)' ...
    '/(acpr.p_t-exp(j*ta.omega/acpr.c*D12))*exp(2*j*ta.omega/acpr.c*(D23 + D3S+D12)))' ...
    '/(1-(exp(-j*ta.omega/acpr.c*D12)-acpr.p_t)/(acpr.p_t-exp(j*ta.omega/acpr.c*D12))' ...
    '*exp(2*j*ta.omega/acpr.c*(D23 + D3S + D12))))'], 4);
model.result.numerical('av1').setIndex('descr', 'Im(Zns)', 4);

model.result.numerical('av1').setResult;

mphsave(model,'C:\Users\lucas.barbier\OneDrive - ETS\CRIAQ-REAR\Maitrise LB\MATLAB\Classes\MDOF_classes\Sol_BF\modèle3D')

out = model;
