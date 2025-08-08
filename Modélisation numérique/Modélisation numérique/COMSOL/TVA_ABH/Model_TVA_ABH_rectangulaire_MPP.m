function out = ModelMPPSBH(config, w)

% (w,matrix_MPP_properties,list_hp,list_wp,list_wc,impedance_tube_height,PathName,FileName,mesh_size)
% Arguments: 
%     w: angular frequency
%     list_h : perforation heights
%     list_wp : perforation widths/thicknesses
%     list_wc  : cavity widths/thicknesses
%     impedance_tube_height : 
%     Pathname for save the mph and the export files
%     FileName : file name  
%     mesh_size = [max_mesh_size,min_mesh_size]
% 
% 
% %2D:             
%                   list_wp(1)
% `                                 list_wc(2)
%                       |-|         |-------|
% ______________________   _______   _______       -
%                       | |       | |       |      | 
%                       | |       | |       |      | 
%                       |_|       | |       |      |
%             -              1    |_|   2   |      |
%  list_hp(1) |                    _        | .... |  impedance_tube_height
%             -          _        | |       |      |
%                       | |       | |       |      |
%                       | |       | |       |      |
%_______________________| |_______| |_______|      -
% 
% 
% 
%---------------------------------------------------- 
% Programmed by Maël Lopez
% 
% 
% 
% Model_TVA_ABH_slits.m
%
% Model exported on Oct 25 2024, 14:22 by COMSOL 6.1.0.357.

import com.comsol.model.*
import com.comsol.model.util.*

model = ModelUtil.create('Model');

model.modelPath('C:\Users\AQ99270\Documents\COMSOL\Projet_bell');

model.label('Model_TVA_ABH_rectangulaire.mph');

% param
model.param.set('H', [num2str(impedance_tube_height) '[m]'], 'impedance tube height');
model.param.set('e12', '20[mm]', 'distance between microphones 1 and 2');
model.param.set('e2s', [num2str(3*impedance_tube_height),'[m]'], 'distance between microphones 2 and sample');

N = length(list_hp); %number of cells (slit backed by a cavity)


% dans l'idéal à supprimer et à mettre en fonction e ta classe air
model.variable.create('var1');
model.variable('var1').set('co', 'sqrt(gam*po/rho0)', 'Vitesse du son');
model.variable('var1').set('cp', '4168.8*(2.4968E-1[J/kg/K]-7.5518E-5[J/kg/K^2]*T+1.6919E-7[J/kg/K^3]*T^2-6.4613E-11[J/kg/K^4]*T^3)', ['Capacit' native2unicode(hex2dec({'00' 'e9'}), 'unicode') ' thermique ' native2unicode(hex2dec({'00' 'e0'}), 'unicode') ' pression constante']);
model.variable('var1').set('cv', 'cp-Rair', ['Capacit' native2unicode(hex2dec({'00' 'e9'}), 'unicode') ' thermique ' native2unicode(hex2dec({'00' 'e0'}), 'unicode') ' volume constant']);
model.variable('var1').set('f', 'freq');
model.variable('var1').set('gam', 'cp/cv');
model.variable('var1').set('HR', '50');
model.variable('var1').set('k', 'omega/co', 'Nombre d''onde');
model.variable('var1').set('kappa', '9.65E-5[W/m/K^2]*T-9.96E-9[W/m/K^3]*T^2-9.31E-11[W/m/K^4]*T^3+8.88E-14[W/m/K^5]*T^4', ['Conductivit' native2unicode(hex2dec({'00' 'e9'}), 'unicode') ' thermique']);
model.variable('var1').set('neta', '7.72E-8[Pa*s/K]*T-5.95E-11[Pa*s/K^2]*T^2+2.71E-14[Pa*s/K^3]*T^3', ['Viscosit' native2unicode(hex2dec({'00' 'e9'}), 'unicode') ' dynamique']);
model.variable('var1').set('omega', '2*pi*freq');
model.variable('var1').set('po', '1[atm]', 'Pression ambiante');
model.variable('var1').set('pvp', '6.58E-2[Pa/K^3]*T^3-5.38E1[Pa/K^2]*T^2+1.47E4[Pa/K]*T-1345485', 'Pression de vapeur saturante');
model.variable('var1').set('Rair', '287.031[J/kg/K]');
model.variable('var1').set('rho0', 'po/(Rair*T)-(1/Rair-1/Rvp)*HR/100*pvp/T', 'Masse volumique de l''air');
model.variable('var1').set('Rvp', '461.521[J/kg/K]');
model.variable('var1').set('T', '293.15[K]', ['Temp' native2unicode(hex2dec({'00' 'e9'}), 'unicode') 'rature ambiante']);




model.result.table.create('tbl1', 'Table');





% Geometry
model.component.create('comp1', true);

model.component('comp1').geom.create('geom1', 2);
% impedance tube
model.component('comp1').geom('geom1').create('r1', 'Rectangle');
model.component('comp1').geom('geom1').feature('r1').set('pos', {'-e12-e2s' '-H/2'});
model.component('comp1').geom('geom1').feature('r1').set('size', {'e12' 'H'});
model.component('comp1').geom('geom1').create('r2', 'Rectangle');
model.component('comp1').geom('geom1').feature('r2').set('pos', {'-e2s' '-H/2'});
model.component('comp1').geom('geom1').feature('r2').set('size', {'e2s' 'H'});

for i = 1:N
    % material: pore
    model.component('comp1').geom('geom1').create(['rp' num2str(i)], 'Rectangle');

    model.component('comp1').geom('geom1').feature(['rp' num2str(i)]).set('pos', {num2str(sum(list_wp(1:i-1))+sum(list_wc(1:i-1)))  num2str(-list_hp(i)/2)});
    model.component('comp1').geom('geom1').feature(['rp' num2str(i)]).set('size', {num2str(list_wp(i)) num2str(list_hp(i))});
    % material: cavity

    model.component('comp1').geom('geom1').create(['rc' num2str(i)], 'Rectangle');
    model.component('comp1').geom('geom1').feature(['rc' num2str(i)]).set('pos', {num2str(sum(list_wp(1:i))+sum(list_wc(1:i-1)))  '-H/2'});
    model.component('comp1').geom('geom1').feature(['rc' num2str(i)]).set('size', {num2str(list_wc(i)) 'H'});
end

% model.component('comp1').geom('geom1').create('r9', 'Rectangle');
% model.component('comp1').geom('geom1').feature('r9').set('pos', {'w1+W1' '-h2/2'});
% model.component('comp1').geom('geom1').feature('r9').set('size', {'w2' 'h2'});
% model.component('comp1').geom('geom1').create('r10', 'Rectangle');
% model.component('comp1').geom('geom1').feature('r10').set('pos', {'w1+W1+w2' '-H/2'});
% model.component('comp1').geom('geom1').feature('r10').set('size', {'W2' 'H'});
% model.component('comp1').geom('geom1').create('uni1', 'Union');
% model.component('comp1').geom('geom1').feature('uni1').set('intbnd', false);
% model.component('comp1').geom('geom1').feature('uni1').selection('input').set(cellstr(["rp"+string(1:N) "rc"+string(1:N) ]));
model.component('comp1').geom('geom1').run;
model.component('comp1').geom('geom1').run('fin');

% mphgeom(model)
s
% <box selection

model.component('comp1').selection.create('box1', 'Box'); % Impedance tube
model.component('comp1').selection.create('box2', 'Box');

model.component('comp1').selection.create('box3', 'Box'); % Source
model.component('comp1').selection('box3').set('entitydim', 1);



model.component('comp1').selection.create('box4', 'Box');
model.component('comp1').selection('box4').set('entitydim', 1);
model.component('comp1').selection.create('box5', 'Box');
model.component('comp1').selection('box5').set('entitydim', 1);
model.component('comp1').selection.create('box7', 'Box');
model.component('comp1').selection.create('box8', 'Box');
model.component('comp1').selection('box8').set('entitydim', 1);
model.component('comp1').selection.create('box9', 'Box');
model.component('comp1').selection('box9').set('entitydim', 1);
model.component('comp1').selection.create('box6', 'Box');
model.component('comp1').selection('box6').set('entitydim', 1);

model.component('comp1').selection('box1').label('Impedance tube'); % Impedance tube
model.component('comp1').selection('box1').set('xmin', '-e12-e2s');
model.component('comp1').selection('box1').set('xmax', 0);
model.component('comp1').selection('box1').set('condition', 'inside');
model.component('comp1').selection('box2').label('Material'); % Material
model.component('comp1').selection('box2').set('xmin', 0);
model.component('comp1').selection('box2').set('condition', 'inside');
model.component('comp1').selection('box3').label('Input');
model.component('comp1').selection('box3').set('xmin', '-e12-e2s-1[mm]');
model.component('comp1').selection('box3').set('xmax', '-e12-e2s+1[mm]');
model.component('comp1').selection('box3').set('condition', 'inside');
model.component('comp1').selection('box4').label('microhpone 2');
model.component('comp1').selection('box4').set('xmin', '-e2s-1[mm]');
model.component('comp1').selection('box4').set('xmax', '-e2s+1[mm]');
model.component('comp1').selection('box4').set('condition', 'inside');
model.component('comp1').selection('box5').label('boundary to supress');
model.component('comp1').selection('box5').set('xmin', '0.01[mm]');
model.component('comp1').selection('box5').set('xmax', [num2str(sum(list_wc+ list_wp)) '[mm]']);
model.component('comp1').selection('box5').set('ymin', '-0.01[mm]');
model.component('comp1').selection('box5').set('ymax', '0.01[mm]');
model.component('comp1').selection('box7').label('cavities');
model.component('comp1').selection('box7').set('xmin', '0.01[mm]');
model.component('comp1').selection('box7').set('ymin', 'H/2');
model.component('comp1').selection('box7').set('condition', 'somevertex');
model.component('comp1').selection('box8').label('thermal and viscous boundaries1');
model.component('comp1').selection('box8').set('xmin', '0.01[mm]');
model.component('comp1').selection('box8').set('ymin', 'H/2');
model.component('comp1').selection('box8').set('condition', 'somevertex');
model.component('comp1').selection('box9').label('thermal and viscous boundarie2');
model.component('comp1').selection('box9').set('xmin', '0.01[mm]');
model.component('comp1').selection('box9').set('ymin', '-inf');
model.component('comp1').selection('box9').set('ymax', '-H/2');
model.component('comp1').selection('box9').set('condition', 'somevertex');
model.component('comp1').selection('box6').label('thermal and viscous boundaries');
model.component('comp1').selection('box6').set('inputent', 'selections');
model.component('comp1').selection('box6').set('input', {'box8' 'box9'});
model.component('comp1').selection('box6').set('xmin', '0.01[mm]');
model.component('comp1').selection('box6').set('inputent', 'all');

% Création des boites pour les plaques perforées
for i =1:N

    box_name = ['box_MPP',num2str(i)];
    box_sel = model.component('comp1').selection.create(box_name, 'Box');
    box_sel.label(['MPP',num2str(i)]);
    box_sel.set('xmin', num2str(-1e-6+sum(list_wp(1:i-1))+sum(list_wc(1:i-1))));
    box_sel.set('xmax', num2str(1e-6+sum(list_wp(1:i))+sum(list_wc(1:i-1))));
    box_sel.set('condition', 'inside');
end

% On sélectionne chaque plaque perforées
box_MPPs = model.component('comp1').selection.create('box_MPPS', 'Box');
box_MPPs.label('box MPPS');
box_MPPs.set('inputent', 'selections');
box_MPPs.set('input', cellstr('box_MPP'+string(1:N))); % 

% La zone PA est la somme de la selection du tube et box_MPP
PA_dom = model.component('comp1').selection.create('box_PA_Domain', 'Box');
PA_dom.label('PA Domain');
PA_dom.set('inputent', 'selections');
PA_dom.set('input', cellstr(['box1' 'box_MPP'+string(1:N)])); % Impedance tube



% Medium

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

% TVA
model.component('comp1').physics.create('ta', 'ThermoacousticsSinglePhysics', 'geom1');
model.component('comp1').physics('ta').selection.named('box7');

% Pressure acoustic
model.component('comp1').physics.create('acpr', 'PressureAcoustics', 'geom1');
model.component('comp1').physics('acpr').selection.named('box_PA_Domain');
model.component('comp1').physics('acpr').create('pr1', 'Pressure', 1);
model.component('comp1').physics('acpr').feature('pr1').selection.named('box3');
model.component('comp1').physics('acpr').feature('pr1').set('p0', 1);

% Poroacoustic
model.component('comp1').physics('acpr').create('pom1', 'PoroacousticsModel', 2);
model.component('comp1').physics('acpr').feature('pom1').selection.named('box_MPPS');
model.component('comp1').physics('acpr').feature('pom1').set('FluidModel', 'JohnsonChampouxAllard');


% JCA : Plates
for i =1:N
    model.component('comp1').material.create(['mat',num2str(i+1)], 'Common');
    model.component('comp1').material(['mat',num2str(i+1)]).propertyGroup('def').set('density', 'rho0');
    model.component('comp1').material(['mat',num2str(i+1)]).propertyGroup('def').set('soundspeed', 'co');
    model.component('comp1').material(['mat',num2str(i+1)]).propertyGroup('def').set('dynamicviscosity', 'neta');
    model.component('comp1').material(['mat',num2str(i+1)]).propertyGroup('def').set('thermalconductivity', {'kappa' '0' '0' '0' 'kappa' '0' '0' '0' 'kappa'});
    model.component('comp1').material(['mat',num2str(i+1)]).propertyGroup('def').set('heatcapacity', 'cp');
    model.component('comp1').material(['mat',num2str(i+1)]).propertyGroup('def').set('ratioofspecificheat', 'gam');
    model.component('comp1').material(['mat',num2str(i+1)]).propertyGroup.create('PoroacousticsModel', 'Poroacoustics_model');

    % Porosité
    model.component('comp1').material(['mat',num2str(i+1)]).propertyGroup('def').set('porosity', num2str(matrix_MPP_properties(i,1)));
    % Longueur caractéristique visqueuse      
    model.component('comp1').material(['mat',num2str(i+1)]).propertyGroup('PoroacousticsModel').set('Lv', {num2str(matrix_MPP_properties(i,4))});
    % Longueur caractéristiques thermique
    model.component('comp1').material(['mat',num2str(i+1)]).propertyGroup('PoroacousticsModel').set('Lth', {num2str(matrix_MPP_properties(i,5))});
    % Tortuosité
    model.component('comp1').material(['mat',num2str(i+1)]).propertyGroup('PoroacousticsModel').set('tau', {num2str(matrix_MPP_properties(i,3))});
    % Résistivité
    model.component('comp1').material(['mat',num2str(i+1)]).propertyGroup('PoroacousticsModel').set('Rf', {num2str(matrix_MPP_properties(i,2))});%
    
    model.component('comp1').material(['mat',num2str(i+1)]).selection.named(['box_MPP',num2str(i)]);
end

% Multiphysics
model.component('comp1').multiphysics.create('atb1', 'AcousticThermoacousticBoundary', 1);
model.component('comp1').multiphysics('atb1').selection.all;

model.component('comp1').view('view1').axis.set('xmin', -0.019948810338974);
model.component('comp1').view('view1').axis.set('xmax', 0.007174098864197731);
model.component('comp1').view('view1').axis.set('ymin', -0.012892574071884155);
model.component('comp1').view('view1').axis.set('ymax', 0.007195575162768364);
% model.component('comp1').view('view1').hideObjects('hide1').init(1);



% Mesh
model.component('comp1').mesh.create('mesh1');

model.component('comp1').mesh('mesh1').create('bl1', 'BndLayer');
model.component('comp1').mesh('mesh1').create('ftri1', 'FreeTri');
model.component('comp1').mesh('mesh1').feature('bl1').selection.named('box7');
model.component('comp1').mesh('mesh1').feature('bl1').create('blp', 'BndLayerProp');
model.component('comp1').mesh('mesh1').feature('bl1').feature('blp').selection.named('box6');
model.component('comp1').mesh('mesh1').feature('ftri1').selection.named('box1'); % Impedance tube
model.component('comp1').mesh('mesh1').feature('ftri1').create('size1', 'Size');

model.component('comp1').mesh('mesh1').feature('size').set('hauto', 1);
model.component('comp1').mesh('mesh1').feature('bl1').set('splitdivangle', 25);
model.component('comp1').mesh('mesh1').feature('bl1').feature('blp').set('blnlayers', 6);
model.component('comp1').mesh('mesh1').feature('bl1').feature('blp').set('blstretch', 1.1);

% mesh size global
if nargin >= 8
    model.component('comp1').mesh('mesh1').feature('size').set('custom', true);
    model.component('comp1').mesh('mesh1').feature('size').set('hmax', num2str(mesh_size(1)));
    if length(mesh_size)>1
        model.component('comp1').mesh('mesh1').feature('size').set('hmin', num2str(mesh_size(2)));
    end
end

% Maillage du milieu poroacoustique
model.component('comp1').mesh('mesh1').create('ftri2', 'FreeTri');
model.component('comp1').mesh('mesh1').feature('ftri2').selection.geom('geom1', 2);
model.component('comp1').mesh('mesh1').feature('ftri2').selection.named('box_MPPS');
model.component('comp1').mesh('mesh1').feature('ftri2').create('size1', 'Size');
model.component('comp1').mesh('mesh1').feature('ftri2').feature('size1').set('hauto', 1);
model.component('comp1').mesh('mesh1').feature('ftri2').feature('size1').set('custom', true);
model.component('comp1').mesh('mesh1').feature('ftri2').feature('size1').set('hmaxactive', true);
model.component('comp1').mesh('mesh1').feature('ftri2').feature('size1').set('hminactive', true);
model.component('comp1').mesh('mesh1').feature('ftri2').feature('size1').set('hmin',  num2str(mesh_size(2)));
model.component('comp1').mesh('mesh1').feature('ftri2').feature('size1').set('hmax', num2str(mesh_size(1)));


model.component('comp1').mesh('mesh1').run;

% Show mesh and geometry
mphmesh(model)
pause(0.1)
model.save([PathName,'\',FileName])

% Study
model.study.create('std1');
model.study('std1').create('freq', 'Frequency');
% model.study('std1').feature('freq').set('plist', 'range(1,20,8000)');
model.study('std1').feature('freq').set('plist', num2str(w/2/pi));


model.sol.create('sol1');
model.sol('sol1').study('std1');
model.sol('sol1').attach('std1');
model.sol('sol1').create('st1', 'StudyStep');
model.sol('sol1').create('v1', 'Variables');
model.sol('sol1').create('s1', 'Stationary');
model.sol('sol1').feature('s1').create('p1', 'Parametric');
model.sol('sol1').feature('s1').create('fc1', 'FullyCoupled');
model.sol('sol1').feature('s1').create('d1', 'Direct');
model.sol('sol1').feature('s1').feature.remove('fcDef');


model.sol('sol1').attach('std1');
model.sol('sol1').feature('st1').label('Compile Equations: Frequency Domain');
model.sol('sol1').feature('v1').label('Dependent Variables 1.1');
model.sol('sol1').feature('v1').set('clistctrl', {'p1'});
model.sol('sol1').feature('v1').set('cname', {'freq'});
% model.sol('sol1').feature('v1').set('clist', {'range(1,20,8000)[Hz]'});
model.sol('sol1').feature('v1').set('clist',  cellstr(join(string(w/2/pi)+"[Hz]")));

model.sol('sol1').feature('s1').label('Stationary Solver 1.1');
model.sol('sol1').feature('s1').feature('dDef').label('Direct 2');
model.sol('sol1').feature('s1').feature('aDef').label('Advanced 1');
model.sol('sol1').feature('s1').feature('aDef').set('complexfun', true);
model.sol('sol1').feature('s1').feature('p1').label('Parametric 1.1');
model.sol('sol1').feature('s1').feature('p1').set('pname', {'freq'});
% model.sol('sol1').feature('s1').feature('p1').set('plistarr', {'range(1,20,8000)'});
model.sol('sol1').feature('s1').feature('p1').set('plistarr', cellstr(num2str(w/2/pi)));

model.sol('sol1').feature('s1').feature('p1').set('punit', {'Hz'});
model.sol('sol1').feature('s1').feature('p1').set('pcontinuationmode', 'no');
model.sol('sol1').feature('s1').feature('p1').set('preusesol', 'auto');
model.sol('sol1').feature('s1').feature('fc1').label('Fully Coupled 1.1');
model.sol('sol1').feature('s1').feature('d1').label('Direct 1.1');
model.sol('sol1').feature('s1').feature('d1').set('linsolver', 'pardiso');
model.sol('sol1').feature('s1').feature('d1').set('pivotperturb', 1.0E-13);
model.sol('sol1').runAll;


model.result.numerical.create('av1', 'AvLine');
model.result.numerical('av1').selection.named('box4');
model.result.numerical('av1').set('probetag', 'none');
model.result.create('pg1', 'PlotGroup2D');
model.result.create('pg2', 'PlotGroup2D');
model.result.create('pg3', 'PlotGroup2D');
model.result.create('pg4', 'PlotGroup2D');
model.result.create('pg5', 'PlotGroup2D');
model.result.create('pg6', 'PlotGroup1D');
model.result.create('pg7', 'PlotGroup1D');
model.result.create('pg8', 'PlotGroup1D');
model.result('pg1').create('surf1', 'Surface');
model.result('pg1').create('surf2', 'Surface');
model.result('pg1').feature('surf2').set('expr', 'acpr.p_t');
model.result('pg2').create('surf1', 'Surface');
model.result('pg2').create('surf2', 'Surface');
model.result('pg2').feature('surf1').set('expr', 'ta.v_inst');
model.result('pg2').feature('surf2').set('expr', 'acpr.v_inst');
model.result('pg3').create('surf1', 'Surface');
model.result('pg3').feature('surf1').set('expr', 'ta.T_t');
model.result('pg4').create('surf1', 'Surface');
model.result('pg4').feature('surf1').set('expr', 'acpr.p_t');
model.result('pg5').create('surf1', 'Surface');
model.result('pg5').feature('surf1').set('expr', 'acpr.Lp_t');
model.result('pg6').create('tblp1', 'Table');
model.result('pg7').create('tblp1', 'Table');
model.result('pg8').create('tblp1', 'Table');


model.result.table('tbl1').comments('acoustic indicators');
model.result.numerical('av1').label('acoustic indicators');
model.result.numerical('av1').set('table', 'tbl1');
model.result.numerical('av1').set('expr', {'1-abs((exp(-j*ta.omega/acpr.c*e12)-acpr.p_t)/(acpr.p_t-exp(j*ta.omega/acpr.c*e12))*exp(2*j*ta.omega/acpr.c*(e2s+e12)))^2'});
model.result.numerical('av1').set('unit', {'1'});
model.result.numerical('av1').set('descr', {'Sound absorption'});
model.result.numerical('av1').setIndex('expr', 'real((exp(-j*ta.omega/acpr.c*e12)-acpr.p_t)/(acpr.p_t-exp(j*ta.omega/acpr.c*e12))*exp(2*j*ta.omega/acpr.c*(e2s+e12)))', 1);
model.result.numerical('av1').setIndex('descr', 'Re(R)', 1);
model.result.numerical('av1').setIndex('unit', '1', 1);
model.result.numerical('av1').setIndex('expr', 'imag((exp(-j*ta.omega/acpr.c*e12)-acpr.p_t)/(acpr.p_t-exp(j*ta.omega/acpr.c*e12))*exp(2*j*ta.omega/acpr.c*(e2s+e12)))', 2);
model.result.numerical('av1').setIndex('descr', 'Im(R)', 2);
model.result.numerical('av1').setIndex('unit', '1', 2);
model.result.numerical('av1').setIndex('expr', 'real((1+(exp(-j*ta.omega/acpr.c*e12)-acpr.p_t)/(acpr.p_t-exp(j*ta.omega/acpr.c*e12))*exp(2*j*ta.omega/acpr.c*(e2s+e12)))/(1-(exp(-j*ta.omega/acpr.c*e12)-acpr.p_t)/(acpr.p_t-exp(j*ta.omega/acpr.c*e12))*exp(2*j*ta.omega/acpr.c*(e2s+e12))))', 3);
model.result.numerical('av1').setIndex('descr', 'Re(Zns)', 3);
model.result.numerical('av1').setIndex('expr', 'imag((1+(exp(-j*ta.omega/acpr.c*e12)-acpr.p_t)/(acpr.p_t-exp(j*ta.omega/acpr.c*e12))*exp(2*j*ta.omega/acpr.c*(e2s+e12)))/(1-(exp(-j*ta.omega/acpr.c*e12)-acpr.p_t)/(acpr.p_t-exp(j*ta.omega/acpr.c*e12))*exp(2*j*ta.omega/acpr.c*(e2s+e12))))', 4);
model.result.numerical('av1').setIndex('descr', 'Im(Zns)', 4);
model.result.numerical('av1').setResult;

model.result.table('tbl1').save([PathName,'\indicators_',FileName,'.txt']);

model.result('pg1').label('Acoustic Pressure (ta)');
% model.result('pg1').set('looplevel', [50]);
model.result('pg1').set('showlegendsunit', true);
model.result('pg1').feature('surf1').label('Surface');
model.result('pg1').feature('surf1').set('colortable', 'Wave');
model.result('pg1').feature('surf1').set('colorscalemode', 'linearsymmetric');
model.result('pg1').feature('surf1').set('smooth', 'internal');
model.result('pg1').feature('surf1').set('resolution', 'normal');
model.result('pg1').feature('surf2').set('colortable', 'Wave');
model.result('pg1').feature('surf2').set('colorscalemode', 'linearsymmetric');
model.result('pg1').feature('surf2').set('smooth', 'internal');
model.result('pg1').feature('surf2').set('inheritplot', 'surf1');
model.result('pg1').feature('surf2').set('resolution', 'normal');
model.result('pg2').label('Acoustic Velocity (ta)');
% model.result('pg2').set('looplevel', [50]);
model.result('pg2').set('showlegendsunit', true);
model.result('pg2').feature('surf1').label('Surface');
model.result('pg2').feature('surf1').set('smooth', 'internal');
model.result('pg2').feature('surf1').set('resolution', 'normal');
model.result('pg2').feature('surf2').set('inheritplot', 'surf1');
model.result('pg2').feature('surf2').set('resolution', 'normal');
model.result('pg3').label('Temperature Variation (ta)');
% model.result('pg3').set('looplevel', [50]);
model.result('pg3').set('showlegendsunit', true);
model.result('pg3').feature('surf1').label('Surface');
model.result('pg3').feature('surf1').set('colortable', 'ThermalWave');
model.result('pg3').feature('surf1').set('colorscalemode', 'linearsymmetric');
model.result('pg3').feature('surf1').set('smooth', 'internal');
model.result('pg3').feature('surf1').set('resolution', 'normal');
model.result('pg4').label('Acoustic Pressure (acpr)');
% model.result('pg4').set('looplevel', [50]);
model.result('pg4').set('showlegendsunit', true);
model.result('pg4').feature('surf1').set('colortable', 'Wave');
model.result('pg4').feature('surf1').set('colorscalemode', 'linearsymmetric');
model.result('pg4').feature('surf1').set('resolution', 'normal');
model.result('pg5').label('Sound Pressure Level (acpr)');
% model.result('pg5').set('looplevel', [50]);
model.result('pg5').set('showlegendsunit', true);
model.result('pg5').feature('surf1').set('resolution', 'normal');
model.result('pg6').set('data', 'none');
model.result('pg6').set('xlabel', 'freq (Hz)');
model.result('pg6').set('xlabelactive', false);
model.result('pg6').feature('tblp1').set('linewidth', 'preference');

model.result('pg7').set('data', 'none');
model.result('pg7').set('xlabel', 'freq (Hz)');
model.result('pg7').set('ylabel', '1-abs((exp(-j*ta.omega/acpr.c*e12)-acpr.p_t)/(acpr.p_t-exp(j*ta.omega/acpr.c*e12))*exp(2*j*ta.omega/acpr.c*(e2s+e12)))<sup>2</sup> (1)');
model.result('pg7').set('xlabelactive', false);
model.result('pg7').set('ylabelactive', false);
model.result('pg7').feature('tblp1').set('table', 'tbl1');
model.result('pg7').feature('tblp1').set('linewidth', 'preference');

model.save([PathName,'\',FileName])

out = model;
