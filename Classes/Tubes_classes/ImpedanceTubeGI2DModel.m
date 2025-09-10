function [model, data] = ImpedanceTubeGI2DModel(list_of_solutions, env)
    
% Cette fonction permet de lancer un calcul numérique afin de déterminer la matrice
% de transfert acoustique de la cavité d'air qui surplombe un échantillon acoustique 
% placé en parallèle du tube et excité en incidence rasante.
% Ce calcul se base sur une approche à 1 sources, 3 microphones et 1 charge
% et permet par suite d'obtenir le TL de la section traitée du tube

%% Schéma descriptif de la mesure
% perso_ouvrir_lien_Zotero('zotero://open-pdf/library/items/GRHV7VCR?page=217&annotation=YTJGLXQZ');

import com.comsol.model.*
import com.comsol.model.util.*

model = ModelUtil.create('Model');
ModelUtil.showProgress(true);

%% Création/ Mise à jour des variables et paramètres du modèle 

% Paramètres géométriques du tube
model.param.set('ht', '30e-3', 'hauteur du tube');
model.param.set('d12', '20e-3', 'distance inter-microphone');
model.param.set('d2s', '80e-3', 'distance microphone 2 - solution');
model.param.set('xl1', '0', 'ligne d''acotement à gauche de la première solution');
model.param.set('D', '100e-3', 'longueur de la terminaison rigide après les solutions');

% Paramètres du maillage
model.param.set('nu', '1.81e-05[Pa*s]');
model.param.set('rho', '1.2 [kg/m^3]');
model.param.set('omega0', '2*pi*3000');
model.param.set('d_visc', 'sqrt(2*nu/(omega0*rho))');

% Variables
param = env.air.parameters;
var = model.variable.create('var1');
var.set('co', num2str(param.c0), 'Vitesse du son');
var.set('cp', num2str(param.Cp), 'Capacite thermique a pression constante');
var.set('kappa', num2str(param.kappa), 'Conductivite thermique');
var.set('neta', num2str(param.eta), 'Viscosite dynamique');
var.set('rho0', num2str(param.rho), 'Masse volumique de l''air');
var.set('gamma', num2str(param.gamma), 'Masse volumique de l''air');
var.set('Z0' , num2str(param.Z0), 'Impédance caractéristique de l''air');

%% Création des objets du modèle

% On crée un composant et une géométrie
model.component.create('component', true);
model.component('component').geom.create('geometry', 2);

% On crée un matériau "air_perso" qui sera appliqué automatiquement à
% toutes les géométries implémentées
model = perso_add_air_to_model(model);

% On crée deux physiques et une frontière multiphysique
ap = model.component('component').physics.create('phy_ap', 'PressureAcoustics', 'geometry');
ap.selection.set([]);
tv = model.component('component').physics.create('phy_tv', 'ThermoacousticsSinglePhysics', 'geometry');
tv.selection.set([]);
multiphy_bnd = model.component('component').multiphysics.create('multiphy_bnd', 'AcousticThermoacousticBoundary', 1);
multiphy_bnd.selection.set([]);

% On crée un maillage
mesh = model.component('component').mesh.create('mesh');

%% Géométrie

% Mise en place des solutions

for i = 1:length(list_of_solutions)
    model = list_of_solutions{i}.set_COMSOL_2D_Model(model, i, env);
end

% Création de la géométrie du tube en amont de l'échantillon
rt1 = model.component('component').geom('geometry').create('rt1', 'Rectangle');
rt1.set('pos', {'-d12-d2s' '0'});
rt1.set('size', {'d12', 'ht'});

rt2 = model.component('component').geom('geometry').create('rt2', 'Rectangle');
rt2.set('pos', {'-d2s' '0'});
rt2.set('size', {'d2s' 'ht'});

% Création de la section du tube au dessus de l'échantillon
if ~isempty(list_of_solutions)
    rt3 = model.component('component').geom('geometry').create('rt3', 'Rectangle');
    rt3.set('pos', {'0', '0'});
    rt3.set('size', {['xr' num2str(length(list_of_solutions))], 'ht'});
end

 
% Création de la géométrie du tube en aval
rt4 = model.component('component').geom('geometry').create('rt4', 'Rectangle');
if ~isempty(list_of_solutions)
    rt4.set('pos', {['xr' num2str(length(list_of_solutions))], '0'});
else
    rt4.set('pos', {'0', '0'});
end
rt4.set('size', {'D', 'ht'});

model.component('component').geom('geometry').run('fin');

%% Sélection des boites

% Pour le tube d'impédance
box_tube = model.component('component').selection.create('tube', 'Box');
box_tube.set('entitydim', 2); % On sélectionne les domaines
box_tube.set('ymin', '-0.01[mm]');
box_tube.set('condition', 'inside');

% Pour le plan de la source acoustique
box_src = model.component('component').selection.create('src', 'Box');
box_src.set('entitydim', 1); % On sélectionne les arêtes
box_src.set('xmax', '-d12-d2s+0.01[mm]');
box_src.set('xmin', '-d12-d2s-0.01[mm]');
box_src.set('condition', 'inside');

% Pour le 2ème microphone
box_mic2 = model.component('component').selection.create('mic2', 'Box');
box_mic2.set('entitydim', 1); % On sélectionne les arêtes
box_mic2.set('xmax', '-d2s+0.01[mm]');
box_mic2.set('xmin', '-d2s-0.01[mm]');
box_mic2.set('condition', 'inside');

% Pour le 3ème microphone
box_mic3 = model.component('component').selection.create('mic3', 'Box');
box_mic3.set('entitydim', 1); % On sélectionne les arêtes
if ~isempty(list_of_solutions)
    box_mic3.set('xmax', ['xr' num2str(length(list_of_solutions)) '+D+0.01[mm]']);
    box_mic3.set('xmin', ['xr' num2str(length(list_of_solutions)) '+D-0.01[mm]']);
else
    box_mic3.set('xmax', 'D+0.01[mm]');
    box_mic3.set('xmin', 'D-0.01[mm]');
end
box_mic3.set('condition', 'inside');

% Pour les sections d'entrée et de sortie de l'échantillon
if ~isempty(list_of_solutions)
    box_input = model.component('component').selection.create('input', 'Box');
    box_input.set('entitydim', 1); % On sélectionne les arêtes
    box_input.set('xmax', 'xl1+0.01[mm]');
    box_input.set('xmin', 'xl1-0.01[mm]');
    box_input.set('ymin', '-0.01[mm]');
    box_input.set('condition', 'inside');
end

if ~isempty(list_of_solutions)
    box_output = model.component('component').selection.create('output', 'Box');
    box_output.set('entitydim', 1); % On sélectionne les arêtes
    box_output.set('xmax', ['xr' num2str(length(list_of_solutions)) '+0.01[mm]']);
    box_output.set('xmin', ['xr' num2str(length(list_of_solutions)) '-0.01[mm]']);
    box_output.set('ymin', '-0.01[mm]');
    box_output.set('condition', 'inside');
end

% % Pour l'air
% all_MPPs_selection = {};
% selection_list = cell(model.selection.tags);
% for i = 1:length(selection_list)
%     selection_name = selection_list{i};
%     if contains(selection_name, 'MPP')
%         all_MPPs_selection{end+1} = selection_name;
%     end
% end
% 
% box_all_MPPs = model.component('component').selection.create('all_MPPs', 'Union');
% box_all_MPPs.set('input', all_MPPs_selection);
% 
% box_air = model.component('component').selection.create('air', 'Difference');
% box_air.set('entitydim', 2);
% box_air.set('add', 'all');
% box_air.set('subtract', 'all_MPPs');

% % Pour les frontières non définies entre les domaines
% visco-thermique et acoustique
all_bnds_ap_tv_selection = {};
selection_list = cell(model.selection.tags);
for i = 1:length(selection_list)
    selection_name = selection_list{i};
    if contains(selection_name, 'bnd_ap_tv')
        all_bnds_ap_tv_selection{end+1} = selection_name;
    end
end

box_all_bnds_cont_ap = model.component('component').selection.create('all_bnds_ap_tv', 'Union');
box_all_bnds_cont_ap.set('entitydim', 1);
if ~isempty(all_bnds_ap_tv_selection)
    box_all_bnds_cont_ap.set('input', all_bnds_ap_tv_selection);
end

%% Physique

% On ajoute le tube à la physique Acoustic Pressure
model = perso_add_selection_to_physics(model, 'phy_ap', 'tube');

% Création d'une fonctionnalité de pression dans la physique acoustique
pr1 = ap.create('pr1', 'Pressure', 1); 
pr1.selection.named('src');  % Sélection du plan de la source
pr1.set('p0', 1);  % Définition de la pression initiale à 1 Pa

% On ajoute les frontières visco-thermiques à la multiphysique
model = perso_add_selection_to_multiphysics(model, 'multiphy_bnd', 'all_bnds_ap_tv');

%% Maillage

% Création d'un maillage triangulaire libre
ftri_tube = mesh.create('ftri_tube', 'FreeTri');  
% Sélection de la boîte pour le maillage triangulaire libre
ftri_tube.selection.named('tube');  
% Création d'une taille pour le maillage triangulaire
ftri_tube.create('size1', 'Size');  

mesh.run;

%% Etude

std1 = model.study.create('std1');  
std1.create('freq', 'Frequency');  
std1.feature('freq').set('plist', num2str(env.w/2/pi));  

sol1 = model.sol.create('sol1');  
sol1.study('std1');  
sol1.attach('std1');  
sts1 = sol1.create('st1', 'StudyStep');
sts1.label('Compile Equations: Frequency Domain');  

v1 = sol1.create('v1', 'Variables');  
v1.label('Dependent Variables 1.1');  
v1.set('clistctrl', {'p1'});  
v1.set('cname', {'freq'});   
v1.set('clist',  cellstr(join(string(env.w/2/pi)+"[Hz]")));  

s1 = sol1.create('s1', 'Stationary');  
s1.label('Stationary Solver 1.1'); 
s1.feature('dDef').label('Direct 2');  
s1.feature('aDef').label('Advanced 1');  
s1.feature('aDef').set('complexfun', true);  

s1.create('p1', 'Parametric');  
s1.feature('p1').label('Parametric 1.1');  
s1.feature('p1').set('pname', {'freq'});  
s1.feature('p1').set('plistarr', cellstr(num2str(env.w/2/pi)));  
s1.feature('p1').set('punit', {'Hz'});  
s1.feature('p1').set('pcontinuationmode', 'no');  
s1.feature('p1').set('preusesol', 'auto');

s1.create('fc1', 'FullyCoupled');  
s1.feature('fc1').label('Fully Coupled 1.1'); 
  
s1.create('d1', 'Direct'); 
s1.feature('d1').label('Direct 1.1');  
s1.feature('d1').set('linsolver', 'pardiso');  
s1.feature('d1').set('pivotperturb', 1.0E-13); 

sol1.runAll;   

% % % % % % % % % % % % % % % RESULTATS % % % % % % % % % % % % % % % % % %

%% Récupération des mesures directes

p1 = mphint2(model, 'acpr.p_t', 'line', 'selection', box_src.entities);

% Création d'un objet de ligne d'évaluation au niveau du microphone 2
p2 = mphint2(model, 'acpr.p_t', 'line', 'selection', box_mic2.entities);

p3 = mphint2(model, 'acpr.p_t', 'line', 'selection', box_mic3.entities);

p_in = mphint2(model, 'acpr.p_t', 'line', 'selection', box_input.entities);
v_in = mphint2(model, 'acpr.v_inst', 'line', 'selection', box_input.entities);

p_out = mphint2(model, 'acpr.p_t', 'line', 'selection', box_output.entities);
v_out = mphint2(model, 'acpr.v_inst', 'line', 'selection', box_output.entities);

%% Calcul des quantités indirectes

H12 = p1./p2;
H13 = p1./p3;

% On récupère les données nécessaires sous formes de variables numériques
k = env.w/param.c0; % nombre d'onde
Z0 = str2double(var.get('Z0')); % impédance caractéristique de l'air
s = model.param.evaluate('d12'); % distance inter-microphone
l = model.param.evaluate('d2s'); % distance microphone 2 - échantillon
D = model.param.evaluate('D'); % longueur de la terminaison rigide après l'échantillon

%% Détermination (indirecte) des pressions et vitesses à l'entrée et sortie de l'échantillon

% perso_ouvrir_lien_Zotero('zotero://open-pdf/library/items/GRHV7VCR?page=218&annotation=IDZ6NPBX');

% Expressions pour la pression et la vitesse au niveau de la section d'entrée
p0 = -2*1i*exp(1i*k*l) .* H12 .* (sin(k*(l + s)) - sin(k*l)) ./ (H12.*exp(-1i*k*s) - 1);
u0 = (2*exp(1i*k*l) .* H12 .* (cos(k*(l + s)) - cos(k*l))) ./ (Z0 * (H12.*exp(-1i*k*s) - 1));

% Expressions pour la pression et la vitesse au niveau de la section de sortie
pd = -2*1i*exp(1i*k*l) .* H13 .* sin(k*s) .* cos(k*D) ./ (H12.*exp(-1i*k*s) - 1);
ud = (2*exp(1i*k*l) .* H13 .* sin(k*s) .* sin(k*D)) ./ (Z0 * (H12.*exp(-1i*k*s) - 1));

%% Définition (indirecte) de la matrice de transfert de l'échantillon (symétrique) 

% perso_ouvrir_lien_Zotero('zotero://open-pdf/library/items/GRHV7VCR?page=218&annotation=CGHN67XR');

T11i = (1 ./ p0.*ud + u0.*pd) .* (pd.*ud + p0.*u0);
T12i = (1 ./ p0.*ud + u0.*pd) .* (p0.^2 - pd.^2); 
T21i = (1 ./ p0.*ud + u0.*pd) .* (u0.^2 - ud.^2);
T22i = (1 ./ p0.*ud + u0.*pd) .* (pd.*ud + p0.*u0);

T11d = (1 ./ p_in.*v_out + v_in.*p_out) .* (p_out.*v_out + p_in.*v_in);
T12d = (1 ./ p_in.*v_out + v_in.*p_out) .* (p_in.^2 - p_out.^2); 
T21d = (1 ./ p_in.*v_out + v_in.*p_out) .* (v_in.^2 - v_out.^2);
T22d = (1 ./ p_in.*v_out + v_in.*p_out) .* (p_out.*v_out + p_in.*v_in);

%% Définition du Transmission Loss

% perso_ouvrir_lien_Zotero('zotero://open-pdf/library/items/SILBC2MK?page=7&annotation=JW5XM5FY');

% TL indirect
TLi = 20 * log10(abs(0.5 * (T11i + T12i/Z0 + Z0*T21i + T22i)));

% TL direct
TLd = 20 * log10(abs(0.5 * (T11d + T12d/Z0 + Z0*T21d + T22d)));

data = struct('f', env.w/(2*pi), 'p1', p1, 'p2', p2, 'p3', p3, ...
              'H12', H12, 'H13', H13, ...
              'p0', p0, 'u0', u0, 'pd', pd, 'ud', ud, ...
              'T11', T11i, 'T12', T12i, 'T21', T21i, 'T22', T22i, 'TLi', TLi, 'TLd', TLd);

end