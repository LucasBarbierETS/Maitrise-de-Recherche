function model = ImpedanceTube3DModel(list_of_solutions, env)

    % Cette fonction prend en entrée une liste de solutions acoustiques.
    % Elle a pour but de modéliser à l'aide de Comsol un test d'impédance
    % en incidence normale pour plusieurs solutions juxtaposées.

    % La fonction commence par construire les solutions ainsi que leurs
    % physiques respectives puis construit le tube auquel elle sont toutes
    % reliées dont les dimensions sont adaptées au nombre et à la taille de
    % ces solutions.

    import com.comsol.model.*
    import com.comsol.model.util.*
    
    model = ModelUtil.create('Model');
    ModelUtil.showProgress(true);

    %% Création/ Mise à jour des variables et paramètres du modèle 
  
    % Paramètres géométriques du tube
    model.param.set('d12', '20e-3', 'distance inter-microphone');
    model.param.set('d2s', '80e-3', 'distance microphone 2 - solution');
    model.param.set('xl1', '0', 'ligne d''acotement à gauche de la solution courante');
    model.param.set('Td', '30e-3', 'profondeur du tube d''impédance');

    % Variables
    param = env.air.parameters;
    var = model.variable.create('var1');
    var.set('co', num2str(param.c0), 'Vitesse du son');
    var.set('cp', num2str(param.Cp), 'Capacite thermique a pression constante');
    var.set('kappa', num2str(param.kappa), 'Conductivite thermique');
    var.set('neta', num2str(param.eta), 'Viscosite dynamique');
    var.set('rho0', num2str(param.rho), 'Masse volumique de l''air');
    var.set('gamma', num2str(param.gamma), 'Masse volumique de l''air');

    %% Création des objets du modèle

    % On crée un composant et une géométrie
    model.component.create('component', true);
    model.component('component').geom.create('geometry', 3);

    % On crée un matériau "air_perso" qui sera appliqué automatiquement à
    % toutes les géométries implémentées
    model = perso_add_air_to_model(model);
    
    % On crée deux physiques et une frontière multiphysique
    ap = model.component('component').physics.create('phy_ap', 'PressureAcoustics', 'geometry');
    ap.selection.set([]);
    tv = model.component('component').physics.create('phy_tv', 'ThermoacousticsSinglePhysics', 'geometry');
    tv.selection.set([]);
    multiphy_bnd = model.component('component').multiphysics.create('multiphy_bnd', 'AcousticThermoacousticBoundary', 2);
    multiphy_bnd.selection.set([]);

    % On crée un maillage
    mesh = model.component('component').mesh.create('mesh');


    %% Géométrie

    % Mise en place des solutions

    for i = 1:length(list_of_solutions)
        model = list_of_solutions{i}.set_COMSOL_3D_Model(model, i, env);
    end

    % Création de la géométrie du tube
    blkt1 = model.component('component').geom('geometry').create('blkt1', 'Block');
    blkt1.set('pos', {'0' '-Td/2' 'd2s'});
    blkt1.set('size', {['xr' num2str(length(list_of_solutions))] 'Td' 'd12'});

    blkt2 = model.component('component').geom('geometry').create('blkt2', 'Block');
    blkt2.set('pos', {'0' '-Td/2' '0'});
    blkt2.set('size', {['xr' num2str(length(list_of_solutions))] 'Td' 'd2s'});

    model.component('component').geom('geometry').run('fin');

    %% Sélection des boites

    % % Pour l'intégralité des sélection
    % box_all = model.component('component').selection.create('all', 'Box');
    % box_all.set('entitydim', 2); % On sélectionne les domaines

    % Pour le tube d'impédance
    box_tube = model.component('component').selection.create('tube', 'Box');
    box_tube.set('entitydim', 3); % On sélectionne les domaines
    box_tube.set('zmax', 'd12+d2s+0.01[mm]');
    box_tube.set('zmin', '-0.01[mm]');
    box_tube.set('condition', 'inside');

    % Pour le plan de la source acoustique
    box_src = model.component('component').selection.create('src', 'Box');
    box_src.set('entitydim', 2); % On sélectionne les arêtes
    box_src.set('zmax', 'd12+d2s+0.01[mm]');
    box_src.set('zmin', 'd12+d2s-0.01[mm]');
    box_src.set('condition', 'inside');

    % Pour le 2nd microphone
    box_mic = model.component('component').selection.create('mic2', 'Box');
    box_mic.set('entitydim', 2); % On sélectionne les arêtes
    box_mic.set('zmax', 'd2s+0.01[mm]');
    box_mic.set('zmin', 'd2s-0.01[mm]');
    box_mic.set('condition', 'inside');

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
    box_all_bnds_cont_ap.set('entitydim', 2);
    box_all_bnds_cont_ap.set('input', all_bnds_ap_tv_selection);

    %% Physique

    % On ajoute le tube à la physique Acoustic Pressure
    model = perso_add_selection_to_physics(model, 'phy_ap', 'tube');

    % Création d'une fonctionnalité de pression dans la physique acoustique
    pr1 = ap.create('pr1', 'Pressure', 2); 
    pr1.selection.named('src');  % Sélection du plan de la source
    pr1.set('p0', 1);  % Définition de la pression initiale à 1 Pa

    % On ajoute les frontières visco-thermiques à la multiphysique
    model = perso_add_selection_to_multiphysics(model, 'multiphy_bnd', 'all_bnds_ap_tv');

    %% Maillage

    % Création d'un maillage triangulaire libre
    ftri_tube = mesh.create('ftri_tet', 'FreeTet');  
    % Sélection de la boîte pour le maillage triangulaire libre
    ftri_tube.selection.named('tube');  
    % Création d'une taille pour le maillage triangulaire
    ftri_tube.create('size1', 'Size');  

    mesh.run;
    

    %% Etude

    % Création d'une étude nommée 'std1'
    model.study.create('std1');  
    % Création d'un type d'étude de fréquence
    model.study('std1').create('freq', 'Frequency');  
    % Définition de la liste des fréquences à partir des valeurs de w
    model.study('std1').feature('freq').set('plist', num2str(env.w/2/pi));  
    
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
    model.sol('sol1').feature('v1').set('clist',  cellstr(join(string(env.w/2/pi)+"[Hz]")));  
    
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
    model.sol('sol1').feature('s1').feature('p1').set('plistarr', cellstr(num2str(env.w/2/pi)));  
    
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
    model.result.numerical.create('av1', 'AvSurface');  
    
    % Sélection du microphone 2
    model.result.numerical('av1').selection.named('mic2');  
    model.result.numerical('av1').set('probetag', 'mic2');  
    
    % création d'une table de résultats
    model.result.table.create('tbl1', 'Table');
    model.result.numerical('av1').set('table', 'tbl1');
    model.result.table('tbl1').comments('acoustic indicators');
    model.result.numerical('av1').label('acoustic indicators');
    
    model.result.numerical('av1').set('expr', ['1-abs((exp(-j*ta.omega/acpr.c*d12)-acpr.p_t)' ...
        '/(acpr.p_t-exp(j*ta.omega/acpr.c*d12))*exp(2*j*ta.omega/acpr.c*(d2s+d12)))^2']);
    model.result.numerical('av1').set('unit', {'1'});
    model.result.numerical('av1').set('descr', {'Sound absorption'});
    
    model.result.numerical('av1').setIndex('expr', ['real((exp(-j*ta.omega/acpr.c*d12)-acpr.p_t)' ...
        '/(acpr.p_t-exp(j*ta.omega/acpr.c*d12))*exp(2*j*ta.omega/acpr.c*(d2s+d12)))'], 1);
    model.result.numerical('av1').setIndex('descr', 'Re(R)', 1);
    model.result.numerical('av1').setIndex('unit', '1', 1);
    
    model.result.numerical('av1').setIndex('expr', ['imag((exp(-j*ta.omega/acpr.c*d12)-acpr.p_t)' ...
        '/(acpr.p_t-exp(j*ta.omega/acpr.c*d12))*exp(2*j*ta.omega/acpr.c*(d2s+d12)))'], 2);
    model.result.numerical('av1').setIndex('descr', 'Im(R)', 2);
    model.result.numerical('av1').setIndex('unit', '1', 2);
    
    model.result.numerical('av1').setIndex('expr', ['real((1+(exp(-j*ta.omega/acpr.c*d12)-acpr.p_t)' ...
        '/(acpr.p_t-exp(j*ta.omega/acpr.c*d12))*exp(2*j*ta.omega/acpr.c*(d2s+d12)))' ...
        '/(1-(exp(-j*ta.omega/acpr.c*d12)-acpr.p_t)/(acpr.p_t-exp(j*ta.omega/acpr.c*d12))' ...
        '*exp(2*j*ta.omega/acpr.c*(d2s+d12))))'], 3);
    model.result.numerical('av1').setIndex('descr', 'Re(Zns)', 3);
    
    model.result.numerical('av1').setIndex('expr', ['imag((1+(exp(-j*ta.omega/acpr.c*d12)-acpr.p_t)' ...
        '/(acpr.p_t-exp(j*ta.omega/acpr.c*d12))*exp(2*j*ta.omega/acpr.c*(d2s+d12)))' ...
        '/(1-(exp(-j*ta.omega/acpr.c*d12)-acpr.p_t)/(acpr.p_t-exp(j*ta.omega/acpr.c*d12))' ...
        '*exp(2*j*ta.omega/acpr.c*(d2s + d12))))'], 4);
    model.result.numerical('av1').setIndex('descr', 'Im(Zns)', 4);
    
    model.result.numerical('av1').setResult;

    % %% Groupes de graphiques
    % 
    % pg1 = model.result.create('pg1', 'PlotGroup');
    % model.result('pg1').create('surf1', 'Surface');
    % model.result('pg1').feature('surf1').set('selection', 
end