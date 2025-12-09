function model = ImpedanceTube3DModel_ap(list_of_solutions, env)

    import com.comsol.model.*
    import com.comsol.model.util.*
    
    model = ModelUtil.create('Model');
    ModelUtil.showProgress(true);

    %% Paramètres géométriques du tube
    model.param.set('d12', '20e-3', 'distance inter-microphone');
    model.param.set('d2s', '80e-3', 'distance microphone 2 - solution');
    model.param.set('sol1_xl', '0', 'ligne d''acotement à gauche de la solution courante');
    model.param.set('Td', '30e-3', 'profondeur du tube d''impédance');
   
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
    var.set('gamma', num2str(param.gamma), 'Rapport des chaleurs spécifiques');

    %% Composant et géométrie
    model.component.create('component', true);
    model.component('component').geom.create('geometry', 3);

    % Matériau air
    model = perso_add_air_to_model(model);
    
    %% Physiques
    % --- AVANT ---
    % ap = model.component('component').physics.create('phy_ap', 'PressureAcoustics', 'geometry');
    % ap.selection.set([]);
    % tv = model.component('component').physics.create('phy_tv', 'ThermoacousticsSinglePhysics', 'geometry');
    % tv.selection.set([]);
    % multiphy_bnd = model.component('component').multiphysics.create('multiphy_bnd', 'AcousticThermoacousticBoundary', 2);
    % multiphy_bnd.selection.set([]);

    % --- MAINTENANT ---
    ap = model.component('component').physics.create('phy_ap', 'PressureAcoustics', 'geometry');
    ap.selection.set([]);

    % % Ajout direct d’une condition de couche limite visco-thermique
    % tvb1 = ap.create('tvb1', 'ThermoviscousBoundaryLayerImpedance', 2);
    % % Sélection automatique des parois du tube (ou remplacer par IDs explicites)
    % bnd_walls = model.component('component').selection.create('walls', 'Adjacent');
    % bnd_walls.set('entitydim', 2);
    % bnd_walls.selection('input').named('tube');
    % tvb1.selection.named('walls');

    %% Maillage
    mesh = model.component('component').mesh.create('mesh');

    %% Géométrie : solutions + tube
    for i = 1:length(list_of_solutions)
        model = list_of_solutions{i}.set_COMSOL_3D_Model_ap(model, i, env);
    end

    blkt1 = model.component('component').geom('geometry').create('blkt1', 'Block');
    blkt1.set('pos', {'0' '-Td/2' 'd2s'});
    blkt1.set('size', {['sol' num2str(length(list_of_solutions)) '_xr'] 'Td' 'd12'});

    blkt2 = model.component('component').geom('geometry').create('blkt2', 'Block');
    blkt2.set('pos', {'0' '-Td/2' '0'});
    blkt2.set('size', {['sol' num2str(length(list_of_solutions)) '_xr'] 'Td' 'd2s'});

    model.component('component').geom('geometry').run('fin');
    model.component('component').geom('geometry').runAll;

    %% Sélections
    box_tube = model.component('component').selection.create('tube', 'Box');
    box_tube.set('entitydim', 3);
    box_tube.set('zmax', 'd12+d2s+0.01[mm]');
    box_tube.set('zmin', '-0.01[mm]');
    box_tube.set('condition', 'inside');

    box_src = model.component('component').selection.create('src', 'Box');
    box_src.set('entitydim', 2);
    box_src.set('zmax', 'd12+d2s+0.01[mm]');
    box_src.set('zmin', 'd12+d2s-0.01[mm]');
    box_src.set('condition', 'inside');

    box_mic = model.component('component').selection.create('microphone2', 'Box');
    box_mic.set('entitydim', 2);
    box_mic.set('zmax', 'd2s+0.01[mm]');
    box_mic.set('zmin', 'd2s-0.01[mm]');
    box_mic.set('condition', 'inside');

    %% Physique
    % Ajout du tube dans Pressure Acoustics
    model = perso_add_selection_to_physics(model, 'phy_ap', 'tube');

    % Source plane
    pr1 = ap.create('pr1', 'Pressure', 2); 
    pr1.selection.named('src');  
    pr1.set('p0', 1);  

    % --- AVANT ---
    % model = perso_add_selection_to_multiphysics(model, 'multiphy_bnd', 'all_bnds_ap_tv');
    % --- SUPPRIMÉ car plus de multiphysique ---

    %% Maillage
    ftri_tube = mesh.create('ftri_tet', 'FreeTet');  
    ftri_tube.selection.named('tube');  
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

    %% Sauvergarde en cas d'échec

    mphsave(model, 'C:\Users\lucas.barbier\Documents\Maitrise ETS\Modélisation numérique\dernier modèle numérique 3D-AP crée.mph');

    sol1.runAll;   

    %% Résultats
    model = perso_create_results_table_3D(model);

end
