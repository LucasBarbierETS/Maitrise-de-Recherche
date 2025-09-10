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
    blkt1.set('size', {['sol' num2str(length(list_of_solutions)) '_xr'] 'Td' 'd12'});

    blkt2 = model.component('component').geom('geometry').create('blkt2', 'Block');
    blkt2.set('pos', {'0' '-Td/2' '0'});
    blkt2.set('size', {['sol' num2str(length(list_of_solutions)) '_xr'] 'Td' 'd2s'});

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


    %% Sauvergarde

    % if nargin > 2
    %     mphsave(model, [varargin{1}, '\', varargin{2}, '\' varargin{2} '_modèle_numérique_2D.mph']);
    mphsave(model, 'C:\Users\lucas.barbier\Documents\Maitrise dossier secondaire\Mesures expérimentales\Echantillons Hutchinson 1ère itération\Echantillon 2 Hutchinson\validation_3D.mph');
    % model = perso_create_results_table(model);
    % end

    %% Calcul de la solution
    sol1.runAll;   

    %% Importation du modèle résolu (si besoin)
    % model = mphload([varargin{1}, '\', varargin{2}, '.mph']);
    % model = mphload('C:\Users\lucas.barbier\Documents\Maitrise dossier secondaire\MATLAB\Optimisation\Optimisation REAR\validation_MPPSBH_element_1.mph');
    model = perso_create_results_table(model);
    % mphsave(model, 'C:\Users\lucas.barbier\Documents\Maitrise dossier secondaire\MATLAB\Optimisation\Optimisation REAR\validation_MPPSBH_element_1.mph');
    %% Résultats et affichage
    
    % perso_plot_alpha_from_COMSOL_model(model, 'MPPSBH_element_1');
    
    %% Résultat
    
    
end