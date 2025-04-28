function out = ModelMLBSBH(config, env)

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
%
%
% Model_TVA_ABH_slits.m
%
% Model exported on Oct 25 2024, 14:22 by COMSOL 6.1.0.357.

import com.comsol.model.*
import com.comsol.model.util.*

model = ModelUtil.create('Model');

pt = config.PlatesThickness;
MLBw = config.MLBWidth;
ct = config.CavitiesThickness;
sw = config.SlitsWidth;
N = length(sw); % number of cells (slit backed by a cavity)
w = env.w;

model.param.set('W', [num2str(MLBw) '[m]'], 'impedance tube height');
model.param.set('D12', '20[mm]', 'distance between microphones 1 and 2');
model.param.set('D2S', '40[mm]', 'distance between microphones 2 and sample');

%% Géométrie

% Création d'un nouveau composant dans le modèle
model.component.create('comp1', true);

% Création d'une géométrie 2D pour le composant
model.component('comp1').geom.create('geom1', 2);

% Création d'un rectangle pour représenter le tube d'impédance
model.component('comp1').geom('geom1').create('r1', 'Rectangle');
% Positionnement du rectangle r1 dans le plan
model.component('comp1').geom('geom1').feature('r1').set('pos', {'-D12-D2S' '-W/2'}); 
% Définition des dimensions du rectangle r1
model.component('comp1').geom('geom1').feature('r1').set('size', {'D12' 'W'}); 

% Création d'un autre rectangle pour le tube d'impédance
model.component('comp1').geom('geom1').create('r2', 'Rectangle');
% Positionnement du rectangle r2
model.component('comp1').geom('geom1').feature('r2').set('pos', {'-D2S' '-W/2'}); 
% Définition des dimensions du rectangle r2
model.component('comp1').geom('geom1').feature('r2').set('size', {'D2S' 'W'}); 

% Boucle pour créer plusieurs rectangles représentant les pores
for i = 1:N
    % Création d'un rectangle pour le pore i
    model.component('comp1').geom('geom1').create(['rp' num2str(i)], 'Rectangle');

    % Positionnement du rectangle représentant le pore i
    model.component('comp1').geom('geom1').feature(['rp' num2str(i)]).set('pos', {num2str(sum(pt(1:i-1))+sum(ct(1:i-1)))  num2str(-sw(i)/2)});
    % Définition des dimensions du rectangle représentant le pore i
    model.component('comp1').geom('geom1').feature(['rp' num2str(i)]).set('size', {num2str(pt(i)) num2str(sw(i))});
    
    % Création d'un rectangle pour la cavité i
    model.component('comp1').geom('geom1').create(['rc' num2str(i)], 'Rectangle');
    % Positionnement du rectangle représentant la cavité i
    model.component('comp1').geom('geom1').feature(['rc' num2str(i)]).set('pos', {num2str(sum(pt(1:i))+sum(ct(1:i-1)))  '-W/2'});
    % Définition des dimensions du rectangle représentant la cavité i
    model.component('comp1').geom('geom1').feature(['rc' num2str(i)]).set('size', {num2str(ct(i)) 'W'});
end

% Les lignes ci-dessous sont commentées et représentent une création
% potentielle de rectangles supplémentaires qui pourraient être décommentés
% et utilisés si nécessaire.
% model.component('comp1').geom('geom1').create('r9', 'Rectangle');
% model.component('comp1').geom('geom1').feature('r9').set('pos', {'w1+W1' '-h2/2'});
% model.component('comp1').geom('geom1').feature('r9').set('size', {'w2' 'h2'});
% model.component('comp1').geom('geom1').create('r10', 'Rectangle');
% model.component('comp1').geom('geom1').feature('r10').set('pos', {'w1+W1+w2' '-W/2'});
% model.component('comp1').geom('geom1').feature('r10').set('size', {'W2' 'W'});

% Création d'une union géométrique pour regrouper tous les éléments
model.component('comp1').geom('geom1').create('uni1', 'Union');
model.component('comp1').geom('geom1').feature('uni1').set('intbnd', false);
% Sélection des éléments à unir, en utilisant des chaînes de caractères
model.component('comp1').geom('geom1').feature('uni1').selection('input').set(cellstr(["rp"+string(1:N) "rc"+string(1:N)]));

% Exécution de la géométrie
model.component('comp1').geom('geom1').run; 
% Exécution finale pour finaliser les opérations géométriques
model.component('comp1').geom('geom1').run('fin');

% % Affichage de la géométrie dans le modèle
mphgeom(model)

%% Sélection des boites

% On crée des boites pour sélectionner facilement des contours, des
% surfaces, et leur appliquer des propriétés physiques.

% Pour le tube d'impédance
model.component('comp1').selection.create('box1', 'Box');
model.component('comp1').selection('box1').label('Tube d''impédance');
model.component('comp1').selection('box1').set('entitydim', 2); % On sélectionne des objets 2D
model.component('comp1').selection('box1').set('xmin', '-D12-D2S');
model.component('comp1').selection('box1').set('xmax', 0);
model.component('comp1').selection('box1').set('condition', 'inside');

% Pour le matériau
model.component('comp1').selection.create('box2', 'Box');
model.component('comp1').selection('box2').label('Matériau');
model.component('comp1').selection('box2').set('entitydim', 2); % On sélectionne des objets 2D
model.component('comp1').selection('box2').set('xmin', 0);
model.component('comp1').selection('box2').set('condition', 'inside');

% Pour le plan de la source acoustique
model.component('comp1').selection.create('box3', 'Box');
model.component('comp1').selection('box3').label('Source acoustique');
model.component('comp1').selection('box3').set('entitydim', 1); % On sélectionne les arêtes
model.component('comp1').selection('box3').set('xmin', '-D12-D2S-0.01[mm]');
model.component('comp1').selection('box3').set('xmax', '-D12-D2S+0.01[mm]');
model.component('comp1').selection('box3').set('condition', 'inside');

% Pour le 2nd microphone
model.component('comp1').selection.create('box4', 'Box');
model.component('comp1').selection('box4').label('Microhpone 2');
model.component('comp1').selection('box4').set('entitydim', 1); % On sélectionne les arêtes
model.component('comp1').selection('box4').set('xmin', '-D2S-0.01[mm]');
model.component('comp1').selection('box4').set('xmax', '-D2S+0.01[mm]');
model.component('comp1').selection('box4').set('condition', 'inside');

% Pour la frontière thermo-visqueuse entre les domaines thermo-visqueux et
% acoustiques
model.component('comp1').selection.create('box5', 'Box');
model.component('comp1').selection('box5').label('Frontière thermo-visqueuse');
model.component('comp1').selection('box5').set('entitydim', 1); % On sélectionne les arêtes
model.component('comp1').selection('box5').set('xmin', '-0.01[mm]');
model.component('comp1').selection('box5').set('xmax', '+0.01[mm]');

% Pour les frontières du domaine visquo-thermique
model.component('comp1').selection.create('box6', 'Box');
model.component('comp1').selection('box6').label('Couche limite visqueuse');
model.component('comp1').selection('box6').set('entitydim', 1); % On sélectionne les arêtes
model.component('comp1').selection('box6').set('xmin', '+0.01[mm]');

%% Définition du matériau

model.component('comp1').material.create('mat1', 'Common');
model.component('comp1').material('mat1').propertyGroup('def').func.create('eta', 'Piecewise');
model.component('comp1').material('mat1').propertyGroup('def').func.create('Cp', 'Piecewise');
model.component('comp1').material('mat1').propertyGroup('def').func.create('rho', 'Analytic');
model.component('comp1').material('mat1').propertyGroup('def').func.create('k', 'Piecewise');
model.component('comp1').material('mat1').propertyGroup('def').func.create('cs', 'Analytic');
model.component('comp1').material('mat1').propertyGroup('def').func.create('an1', 'Analytic');
model.component('comp1').material('mat1').propertyGroup('def').func.create('an2', 'Analytic');
model.component('comp1').material('mat1').propertyGroup.create('RefractiveIndex', 'Refractive index');
model.component('comp1').material('mat1').propertyGroup.create('NonlinearModel', 'Nonlinear model');
model.component('comp1').material('mat1').propertyGroup.create('idealGas', 'Ideal gas');
model.component('comp1').material('mat1').propertyGroup('idealGas').func.create('Cp', 'Piecewise');
model.component('comp1').material('mat1').label('Air');
model.component('comp1').material('mat1').set('family', 'air');
model.component('comp1').material('mat1').propertyGroup('def').func('eta').set('arg', 'T');
model.component('comp1').material('mat1').propertyGroup('def').func('eta').set('pieces', {'200.0' '1600.0' '-8.38278E-7+8.35717342E-8*T^1-7.69429583E-11*T^2+4.6437266E-14*T^3-1.06585607E-17*T^4'});
model.component('comp1').material('mat1').propertyGroup('def').func('eta').set('argunit', 'K');
model.component('comp1').material('mat1').propertyGroup('def').func('eta').set('fununit', 'Pa*s');
model.component('comp1').material('mat1').propertyGroup('def').func('Cp').set('arg', 'T');
model.component('comp1').material('mat1').propertyGroup('def').func('Cp').set('pieces', {'200.0' '1600.0' '1047.63657-0.372589265*T^1+9.45304214E-4*T^2-6.02409443E-7*T^3+1.2858961E-10*T^4'});
model.component('comp1').material('mat1').propertyGroup('def').func('Cp').set('argunit', 'K');
model.component('comp1').material('mat1').propertyGroup('def').func('Cp').set('fununit', 'J/(kg*K)');
model.component('comp1').material('mat1').propertyGroup('def').func('rho').set('expr', 'pA*0.02897/R_const[K*mol/J]/T');
model.component('comp1').material('mat1').propertyGroup('def').func('rho').set('args', {'pA' 'T'});
model.component('comp1').material('mat1').propertyGroup('def').func('rho').set('fununit', 'kg/m^3');
model.component('comp1').material('mat1').propertyGroup('def').func('rho').set('argunit', {'Pa' 'K'});
model.component('comp1').material('mat1').propertyGroup('def').func('rho').set('plotargs', {'pA' '101325' '101325'; 'T' '273.15' '293.15'});
model.component('comp1').material('mat1').propertyGroup('def').func('k').set('arg', 'T');
model.component('comp1').material('mat1').propertyGroup('def').func('k').set('pieces', {'200.0' '1600.0' '-0.00227583562+1.15480022E-4*T^1-7.90252856E-8*T^2+4.11702505E-11*T^3-7.43864331E-15*T^4'});
model.component('comp1').material('mat1').propertyGroup('def').func('k').set('argunit', 'K');
model.component('comp1').material('mat1').propertyGroup('def').func('k').set('fununit', 'W/(m*K)');
model.component('comp1').material('mat1').propertyGroup('def').func('cs').set('expr', 'sqrt(1.4*R_const[K*mol/J]/0.02897*T)');
model.component('comp1').material('mat1').propertyGroup('def').func('cs').set('args', {'T'});
model.component('comp1').material('mat1').propertyGroup('def').func('cs').set('fununit', 'm/s');
model.component('comp1').material('mat1').propertyGroup('def').func('cs').set('argunit', {'K'});
model.component('comp1').material('mat1').propertyGroup('def').func('cs').set('plotargs', {'T' '273.15' '373.15'});
model.component('comp1').material('mat1').propertyGroup('def').func('an1').set('funcname', 'alpha_p');
model.component('comp1').material('mat1').propertyGroup('def').func('an1').set('expr', '-1/rho(pA,T)*d(rho(pA,T),T)');
model.component('comp1').material('mat1').propertyGroup('def').func('an1').set('args', {'pA' 'T'});
model.component('comp1').material('mat1').propertyGroup('def').func('an1').set('fununit', '1/K');
model.component('comp1').material('mat1').propertyGroup('def').func('an1').set('argunit', {'Pa' 'K'});
model.component('comp1').material('mat1').propertyGroup('def').func('an1').set('plotargs', {'pA' '101325' '101325'; 'T' '273.15' '373.15'});
model.component('comp1').material('mat1').propertyGroup('def').func('an2').set('funcname', 'muB');
model.component('comp1').material('mat1').propertyGroup('def').func('an2').set('expr', '0.6*eta(T)');
model.component('comp1').material('mat1').propertyGroup('def').func('an2').set('args', {'T'});
model.component('comp1').material('mat1').propertyGroup('def').func('an2').set('fununit', 'Pa*s');
model.component('comp1').material('mat1').propertyGroup('def').func('an2').set('argunit', {'K'});
model.component('comp1').material('mat1').propertyGroup('def').func('an2').set('plotargs', {'T' '200' '1600'});
model.component('comp1').material('mat1').propertyGroup('def').set('thermalexpansioncoefficient', '');
model.component('comp1').material('mat1').propertyGroup('def').set('molarmass', '');
model.component('comp1').material('mat1').propertyGroup('def').set('bulkviscosity', '');
model.component('comp1').material('mat1').propertyGroup('def').set('thermalexpansioncoefficient', {'alpha_p(pA,T)' '0' '0' '0' 'alpha_p(pA,T)' '0' '0' '0' 'alpha_p(pA,T)'});
model.component('comp1').material('mat1').propertyGroup('def').set('molarmass', '0.02897[kg/mol]');
model.component('comp1').material('mat1').propertyGroup('def').set('bulkviscosity', 'muB(T)');
model.component('comp1').material('mat1').propertyGroup('def').set('relpermeability', {'1' '0' '0' '0' '1' '0' '0' '0' '1'});
model.component('comp1').material('mat1').propertyGroup('def').set('relpermittivity', {'1' '0' '0' '0' '1' '0' '0' '0' '1'});
model.component('comp1').material('mat1').propertyGroup('def').set('dynamicviscosity', 'eta(T)');
model.component('comp1').material('mat1').propertyGroup('def').set('ratioofspecificheat', '1.4');
model.component('comp1').material('mat1').propertyGroup('def').set('electricconductivity', {'0[S/m]' '0' '0' '0' '0[S/m]' '0' '0' '0' '0[S/m]'});
model.component('comp1').material('mat1').propertyGroup('def').set('heatcapacity', 'Cp(T)');
model.component('comp1').material('mat1').propertyGroup('def').set('density', 'rho(pA,T)');
model.component('comp1').material('mat1').propertyGroup('def').set('thermalconductivity', {'k(T)' '0' '0' '0' 'k(T)' '0' '0' '0' 'k(T)'});
model.component('comp1').material('mat1').propertyGroup('def').set('soundspeed', 'cs(T)');
model.component('comp1').material('mat1').propertyGroup('def').addInput('temperature');
model.component('comp1').material('mat1').propertyGroup('def').addInput('pressure');
model.component('comp1').material('mat1').propertyGroup('RefractiveIndex').set('n', {'1' '0' '0' '0' '1' '0' '0' '0' '1'});
model.component('comp1').material('mat1').propertyGroup('NonlinearModel').set('BA', '(def.gamma+1)/2');
model.component('comp1').material('mat1').propertyGroup('idealGas').func('Cp').label('Piecewise 2');
model.component('comp1').material('mat1').propertyGroup('idealGas').func('Cp').set('arg', 'T');
model.component('comp1').material('mat1').propertyGroup('idealGas').func('Cp').set('pieces', {'200.0' '1600.0' '1047.63657-0.372589265*T^1+9.45304214E-4*T^2-6.02409443E-7*T^3+1.2858961E-10*T^4'});
model.component('comp1').material('mat1').propertyGroup('idealGas').func('Cp').set('argunit', 'K');
model.component('comp1').material('mat1').propertyGroup('idealGas').func('Cp').set('fununit', 'J/(kg*K)');
model.component('comp1').material('mat1').propertyGroup('idealGas').set('Rs', 'R_const/Mn');
model.component('comp1').material('mat1').propertyGroup('idealGas').set('heatcapacity', 'Cp(T)');
model.component('comp1').material('mat1').propertyGroup('idealGas').set('ratioofspecificheat', '1.4');
model.component('comp1').material('mat1').propertyGroup('idealGas').set('molarmass', '0.02897');
model.component('comp1').material('mat1').propertyGroup('idealGas').addInput('temperature');
model.component('comp1').material('mat1').propertyGroup('idealGas').addInput('pressure');
model.component('comp1').material('mat1').materialType('nonSolid');

%% Physique 

% Création d'une physique acoustique de pression
model.component('comp1').physics.create('acpr', 'PressureAcoustics', 'geom1'); 
model.component('comp1').physics('acpr').selection.named('box1'); % Sélection du tube d'impédance

% Création d'une physique thermoacoustique
model.component('comp1').physics.create('ta', 'ThermoacousticsSinglePhysics', 'geom1'); 
model.component('comp1').physics('ta').selection.named('box2'); % Sélection du matériau

% Création d'une fonctionnalité de pression dans la physique acoustique
model.component('comp1').physics('acpr').create('pr1', 'Pressure', 1); 
model.component('comp1').physics('acpr').feature('pr1').selection.named('box3'); % Sélection du plan de la source
model.component('comp1').physics('acpr').feature('pr1').set('p0', 1); % Définition de la pression initiale à 1 Pa

% Configuration des multiphysiques
model.component('comp1').multiphysics.create('atb1', 'AcousticThermoacousticBoundary', 1); 
model.component('comp1').multiphysics('atb1').selection.named('box5'); % Sélection de la frontière thermo-visqueuse

%% Maillage

% Création d'un maillage nommé 'mesh1'
model.component('comp1').mesh.create('mesh1');  

% Création d'une couche de bord dans le maillage
model.component('comp1').mesh('mesh1').create('bl1', 'BndLayer');  
% Création d'un maillage triangulaire libre
model.component('comp1').mesh('mesh1').create('ftri1', 'FreeTri');  

% Sélection de la boîte pour la couche de bord
model.component('comp1').mesh('mesh1').feature('bl1').selection.named('box2');  
% Création des propriétés de la couche de bord

model.component('comp1').mesh('mesh1').feature('bl1').create('blp', 'BndLayerProp');  
% Sélection de la boîte pour les propriétés de la couche de bord
model.component('comp1').mesh('mesh1').feature('bl1').feature('blp').selection.named('box6'); 

% Sélection de la boîte pour le maillage triangulaire libre
model.component('comp1').mesh('mesh1').feature('ftri1').selection.named('box1');  
% Création d'une taille pour le maillage triangulaire
model.component('comp1').mesh('mesh1').feature('ftri1').create('size1', 'Size');  

% Définition de l'automatisation de la taille du maillage
model.component('comp1').mesh('mesh1').feature('size').set('hauto', 2);  
% Définition de l'angle de division pour la couche de bord
model.component('comp1').mesh('mesh1').feature('bl1').set('splitdivangle', 25);  
% Définition du nombre de couches dans la couche de bord
model.component('comp1').mesh('mesh1').feature('bl1').feature('blp').set('blnlayers', 3);  
% Définition de l'étirement de la couche de bord
model.component('comp1').mesh('mesh1').feature('bl1').feature('blp').set('blstretch', 2);  

% Exécution du maillage
model.component('comp1').mesh('mesh1').run;  
% Appel de la fonction mphmesh pour générer le maillage
figure()
mphmesh(model);  

%% Etude

% Création d'une étude nommée 'std1'
model.study.create('std1');  
% Création d'un type d'étude de fréquence
model.study('std1').create('freq', 'Frequency');  
% Définition de la liste des fréquences à partir des valeurs de w
model.study('std1').feature('freq').set('plist', num2str(w/2/pi));  

% Création d'une solution nommée 'sol1'
model.sol.create('sol1');  
% Attachement de l'étude 'std1' à la solution 'sol1'
model.sol('sol1').study('std1');  
model.sol('sol1').attach('std1');  
% Création d'une étape d'étude
model.sol('sol1').create('st1', 'StudyStep');  
% Création d'une variable
model.sol('sol1').create('v1', 'Variables');  
% Création d'un solveur stationnaire
model.sol('sol1').create('s1', 'Stationary');  
% Création d'un pas paramétrique dans le solveur stationnaire
model.sol('sol1').feature('s1').create('p1', 'Parametric');  
% Création d'un solveur entièrement couplé
model.sol('sol1').feature('s1').create('fc1', 'FullyCoupled');  
% Création d'un solveur direct
model.sol('sol1').feature('s1').create('d1', 'Direct');  
% Suppression de la définition du couplage
model.sol('sol1').feature('s1').feature.remove('fcDef');  

% Réattachement de l'étude 'std1' à la solution 'sol1'
model.sol('sol1').attach('std1');  
% Étiquetage de l'étape d'étude
model.sol('sol1').feature('st1').label('Compile Equations: Frequency Domain');  
% Étiquetage des variables dépendantes
model.sol('sol1').feature('v1').label('Dependent Variables 1.1');  
% Définition du contrôle de la liste des variables
model.sol('sol1').feature('v1').set('clistctrl', {'p1'});  
% Nom de la variable
model.sol('sol1').feature('v1').set('cname', {'freq'});   
% Définition de la liste des fréquences avec unités
model.sol('sol1').feature('v1').set('clist',  cellstr(join(string(w/2/pi)+"[Hz]")));  

% Étiquetage du solveur stationnaire
model.sol('sol1').feature('s1').label('Stationary Solver 1.1');  
% Étiquetage de la définition du solveur direct
model.sol('sol1').feature('s1').feature('dDef').label('Direct 2');  
% Étiquetage de la définition avancée
model.sol('sol1').feature('s1').feature('aDef').label('Advanced 1');  
% Activation du traitement complexe
model.sol('sol1').feature('s1').feature('aDef').set('complexfun', true);  
% Étiquetage du pas paramétrique
model.sol('sol1').feature('s1').feature('p1').label('Parametric 1.1');  
% Définition du nom du paramètre
model.sol('sol1').feature('s1').feature('p1').set('pname', {'freq'});  
% Définition de la liste des paramètres
model.sol('sol1').feature('s1').feature('p1').set('plistarr', cellstr(num2str(w/2/pi)));  

% Définition des unités du paramètre
model.sol('sol1').feature('s1').feature('p1').set('punit', {'Hz'});  
% Définition du mode de continuation du paramètre
model.sol('sol1').feature('s1').feature('p1').set('pcontinuationmode', 'no');  
% Définition de l'utilisation automatique des solutions précédentes
model.sol('sol1').feature('s1').feature('p1').set('preusesol', 'auto');  
% Étiquetage du couplage entièrement couplé
model.sol('sol1').feature('s1').feature('fc1').label('Fully Coupled 1.1');  
% Étiquetage du solveur direct
model.sol('sol1').feature('s1').feature('d1').label('Direct 1.1');  
% Définition du solveur de système linéaire
model.sol('sol1').feature('s1').feature('d1').set('linsolver', 'pardiso');  
% Définition du paramètre de perturbation du pivot
model.sol('sol1').feature('s1').feature('d1').set('pivotperturb', 1.0E-13);  



% Exécution de toutes les étapes de la solution
model.sol('sol1').runAll;  


%% Résultat

% Création d'un objet de ligne d'évaluation nommé 'av1'
model.result.numerical.create('av1', 'AvLine');  

% Sélection du microphone 2
model.result.numerical('av1').selection.named('box4');  
model.result.numerical('av1').set('probetag', 'Microphone 2');  

% création d'une table de résultats
model.result.table.create('tbl1', 'Table');
model.result.numerical('av1').set('table', 'tbl1');
model.result.table('tbl1').comments('acoustic indicators');
model.result.numerical('av1').label('acoustic indicators');

model.result.numerical('av1').set('expr', {['1-abs((exp(-j*ta.omega/acpr.c*D12)-acpr.p_t)' ...
    '/(acpr.p_t-exp(j*ta.omega/acpr.c*D12))*exp(2*j*ta.omega/acpr.c*(D2S+D12)))^2']});
model.result.numerical('av1').set('unit', {'1'});
model.result.numerical('av1').set('descr', {'Sound absorption'});

model.result.numerical('av1').setIndex('expr', ['real((exp(-j*ta.omega/acpr.c*D12)-acpr.p_t)' ...
    '/(acpr.p_t-exp(j*ta.omega/acpr.c*D12))*exp(2*j*ta.omega/acpr.c*(D2S+D12)))'], 1);
model.result.numerical('av1').setIndex('descr', 'Re(R)', 1);
model.result.numerical('av1').setIndex('unit', '1', 1);

model.result.numerical('av1').setIndex('expr', ['imag((exp(-j*ta.omega/acpr.c*D12)-acpr.p_t)' ...
    '/(acpr.p_t-exp(j*ta.omega/acpr.c*D12))*exp(2*j*ta.omega/acpr.c*(D2S+D12)))'], 2);
model.result.numerical('av1').setIndex('descr', 'Im(R)', 2);
model.result.numerical('av1').setIndex('unit', '1', 2);

model.result.numerical('av1').setIndex('expr', ['real((1+(exp(-j*ta.omega/acpr.c*D12)-acpr.p_t)' ...
    '/(acpr.p_t-exp(j*ta.omega/acpr.c*D12))*exp(2*j*ta.omega/acpr.c*(D2S+D12)))' ...
    '/(1-(exp(-j*ta.omega/acpr.c*D12)-acpr.p_t)/(acpr.p_t-exp(j*ta.omega/acpr.c*D12))' ...
    '*exp(2*j*ta.omega/acpr.c*(D2S+D12))))'], 3);
model.result.numerical('av1').setIndex('descr', 'Re(Zns)', 3);

model.result.numerical('av1').setIndex('expr', ['imag((1+(exp(-j*ta.omega/acpr.c*D12)-acpr.p_t)' ...
    '/(acpr.p_t-exp(j*ta.omega/acpr.c*D12))*exp(2*j*ta.omega/acpr.c*(D2S+D12)))' ...
    '/(1-(exp(-j*ta.omega/acpr.c*D12)-acpr.p_t)/(acpr.p_t-exp(j*ta.omega/acpr.c*D12))' ...
    '*exp(2*j*ta.omega/acpr.c*(D2S+D12))))'], 4);
model.result.numerical('av1').setIndex('descr', 'Im(Zns)', 4);

model.result.numerical('av1').setResult; 

out = model;
