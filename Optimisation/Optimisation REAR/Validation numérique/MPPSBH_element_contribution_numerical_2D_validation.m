function model = MPPSBH_element_contribution_numerical_2D_validation(MPPSBH_element, env, varargin)

% Ce script/ fonction sert de validation pour le processus d'optimisation global de
% la cartouche acoustique finale.
% L'objet construit en 2D est constitué d'une plaque couvrante, d'une
% couche d'air et d'une solution acoustique optimisée individuelle
    
    %% Création du modèle

    import com.comsol.model.*
    import com.comsol.model.util.*
    model = ModelUtil.create('Model');
    ModelUtil.showProgress(true);
    
    %% Création/ Mise à jour des variables et paramètres du modèle 
    
    % Paramètres géométriques du tube
    model.param.set('d12', '20e-3', 'distance inter-microphone');
    model.param.set('d2s', '80e-3', 'distance microphone 2 - solution');
    
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
    model.component('component').geom.create('geometry', 2);

    % On crée un matériau "air_perso" qui sera appliqué automatiquement à
    % toutes les géométries implémentées
    model = perso_add_air_to_model(model);
    
    % On crée deux physiques, une sous-physique et une frontière multiphysique
    ap = model.component('component').physics.create('phy_ap', 'PressureAcoustics', 'geometry');
    ap.selection.set([]);
    
    % Poroacoustic
    pom = ap.create('phy_poro', 'PoroacousticsModel', 2);
    pom.set('FluidModel', 'JohnsonChampouxAllard');
    pom.selection.named([]);

    tv = model.component('component').physics.create('phy_tv', 'ThermoacousticsSinglePhysics', 'geometry');
    tv.selection.set([]);
    multiphy_bnd = model.component('component').multiphysics.create('multiphy_bnd', 'AcousticThermoacousticBoundary', 1);
    multiphy_bnd.selection.set([]);

    % On crée un maillage
    mesh = model.component('component').mesh.create('mesh');

    %% Géométrie

    tp_config = MPPSBH_element.Configuration.ListOfSubelements{1}.Configuration;
    model.param.set('tpw', num2str(tp_config.Width), 'Largeur de la plaque couvrante');
    model.param.set('tpt', num2str(tp_config.Thickness), 'Epaisseur de la plaque couvrante');

    % Création de la géométrie du tube
    rt1 = model.component('component').geom('geometry').create('rt1', 'Rectangle');
    rt1.set('pos', {'0' 'd2s'});
    rt1.set('size', {'tpw', 'd12'});

    rt2 = model.component('component').geom('geometry').create('rt2', 'Rectangle');
    rt2.set('pos', {'0' '0'});
    rt2.set('size', {'tpw', 'd2s'});

    % Géométrie de l'élement acoustique
        
    % Plaque couvrante
    tp = model.component('component').geom('geometry').create('tp', 'Rectangle');
    tp.set('pos', {'0' '-tpt'});
    tp.set('size', {'tpw', 'tpt'});

    % Air gap
    ag_config = MPPSBH_element.Configuration.ListOfSubelements{2}.Configuration;
    model.param.set('agt', num2str(ag_config.Length), 'Epaisseur de la plaque couvrante');
    ag = model.component('component').geom('geometry').create('ag', 'Rectangle');
    ag.set('pos', {'0' '-tpt -agt'});
    ag.set('size', {'tpw', 'tpt'});

    % Cavité
    cavity_config = MPPSBH_element.Configuration.ListOfSubelements{3}.Configuration.ListOfSubelements{1}.Configuration;
    model.param.set('cavt', num2str(cavity_config.Length), 'Epaisseur de la première cavité');
    cav = model.component('component').geom('geometry').create('cavity', 'Rectangle');
    cav.set('pos', {'0' '-tpt -agt -cavt'});
    cav.set('size', {'tpw', 'cavt'});

    % MPPSBH
    model.param.set('sol1_ytlc', '-tpt-agt-cavt', 'Ligne d''accotement vertical de l''élement testé');
    MPPSBH = MPPSBH_element.Configuration.ListOfSubelements{3}.Configuration.ListOfSubelements{2};
    MPPSBH.set_COMSOL_2D_Model(model, 1, env, '0', 'sol1_ytlc');

    model.component('component').geom('geometry').run('fin');

    %% Sélection des boites

    % % Pour l'intégralité des sélection
    % box_all = model.component('component').selection.create('all', 'Box');
    % box_all.set('entitydim', 2); % On sélectionne les domaines

    % Pour le tube d'impédance
    box_tube = model.component('component').selection.create('tube', 'Box');
    box_tube.set('entitydim', 2); % On sélectionne les domaines
    box_tube.set('ymax', 'd12+d2s+0.01[mm]');
    box_tube.set('ymin', '-0.01[mm]');
    box_tube.set('condition', 'inside');

    % Pour le plan de la source acoustique
    box_src = model.component('component').selection.create('source', 'Box');
    box_src.set('entitydim', 1); % On sélectionne les arêtes
    box_src.set('ymax', 'd12+d2s+0.01[mm]');
    box_src.set('ymin', 'd12+d2s-0.01[mm]');
    box_src.set('condition', 'inside');

    % Pour le 2nd microphone
    box_mic = model.component('component').selection.create('microphone2', 'Box');
    box_mic.set('entitydim', 1); % On sélectionne les arêtes
    box_mic.set('ymax', 'd2s+0.01[mm]');
    box_mic.set('ymin', 'd2s-0.01[mm]');
    box_mic.set('condition', 'inside');

    % % Pour toutes les arrêtes de la solution
    box_bnds = model.component('component').selection.create('boundaries', 'Box');
    box_bnds.set('entitydim', 1);
    box_bnds.set('ymax', '0.01[mm]');
    box_bnds.set('condition', 'inside');

    % Pour l'arête supérieure de la plaque couvrante
    box_tp_bnd = model.component('component').selection.create('top_plate_boundary', 'Box');
    box_tp_bnd.set('entitydim', 1);
    box_tp_bnd.set('ymax', '0.01[mm]');
    box_tp_bnd.set('ymin', '-0.01[mm]');
    box_tp_bnd.set('condition', 'inside');

    % % Pour la plaque couvrante 
    box_top_plate = model.component('component').selection.create('top_plate', 'Box');
    box_top_plate.set('entitydim', 2); % On sélectionne les domaines
    box_top_plate.set('ymax', '0.01[mm]');
    box_top_plate.set('ymin', '-tpt-0.01[mm]');
    box_top_plate.set('condition', 'inside');

    % % Pour les bordures de la plaque couvrante 
    box_top_plate = model.component('component').selection.create('top_plate_bnds', 'Box');
    box_top_plate.set('entitydim', 1); % On sélectionne les domaines
    box_top_plate.set('ymax', '0.01[mm]');
    box_top_plate.set('ymin', '-tpt-0.01[mm]');
    box_top_plate.set('condition', 'inside');

    % Pour la lame d'air
    box_air_gap = model.component('component').selection.create('air_gap', 'Box');
    box_air_gap.set('entitydim', 2); % On sélectionne les domaines
    box_air_gap.set('ymax', '-tpt+0.01[mm]');
    box_air_gap.set('ymin', '-tpt-agt-0.01[mm]');
    box_air_gap.set('condition', 'inside');

    % Pour la cavité
    box_air_gap = model.component('component').selection.create('cavity', 'Box');
    box_air_gap.set('entitydim', 2); % On sélectionne les domaines
    box_air_gap.set('ymax', '-tpt-agt+0.01[mm]');
    box_air_gap.set('ymin', '-tpt-agt-cavt-0.01[mm]');
    box_air_gap.set('condition', 'inside');

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

    %% Matériaux

    % Création et application du matériau associé à la plaque couvrante
    JCAmat = perso_create_JCA_material(model, 'tp_mat', tp_config, env);
    JCAmat.selection.named('top_plate');

    %% Physique

    % On ajoute le tube, à la physique Acoustic Pressure
    model = perso_add_selection_to_physics(model, 'phy_ap', 'tube');
    model = perso_add_selection_to_physics(model, 'phy_ap', 'top_plate');
    pom.selection.named('top_plate');

    % On ajoute le reste de la solution à la Physique Thermo-Viscous Acoustic
    model = perso_add_selection_to_physics(model, 'phy_tv', 'air_gap');
    model = perso_add_selection_to_physics(model, 'phy_tv', 'cavity');


    % Création d'une fonctionnalité de pression dans la physique acoustique
    pr1 = ap.create('pr1', 'Pressure', 1); 
    pr1.selection.named('source');  % Sélection du plan de la source
    pr1.set('p0', 1);  % Définition de la pression initiale à 1 Pa

    % On ajoute les frontières visco-thermiques à la multiphysique
    % model = perso_add_selection_to_multiphysics(model, 'multiphy_bnd', 'all_bnds_ap_tv');
    model = perso_add_selection_to_multiphysics(model, 'multiphy_bnd', 'boundaries');

    %% Maillage

    % Création d'un maillage triangulaire libre pour le tube
    ftri_tube = mesh.create('ftri_tube', 'FreeTri');  
    ftri_tube.selection.named('tube');  
    ftri_tube.create('size1', 'Size');  
    dis1 = ftri_tube.create('dis1', 'Distribution');
    dis1.selection.named('top_plate_boundary');
    dis1.set('elemcount', floor(tp_config.Width*500)); % un noeud tous les 2mm

    % Création d'un maillage triangulaire libre pour la plaque couvrante
    ftri_tp = mesh.create('ftri_tp', 'FreeTri');
    ftri_tp.selection.named('top_plate');
    ftri_size = ftri_tp.create('size1', 'Size');
    ftri_size.set('hauto', 2); % Maillage très fin;
    
    % Création d'une couche de bord dans le maillage
    bl_tp = mesh.create('bl_tp', 'BndLayer'); 
    bl_tp.selection.named('top_plate');
    bl_tp.set('splitdivangle', 25);
    bl_tp.set('smoothtransition', false);
    blp_tp = bl_tp.create('blp', 'BndLayerProp');  
    blp_tp.selection.named('top_plate_bnds'); 
    blp_tp.set('blnlayers', 2);
    blp_tp.set('blstretch', 1.1);
    blp_tp.set('inittype', 'blhtot');
    blp_tp.set('blhmin', 'd_visc');

    % Création d'un maillage triangulaire libre pour la lame d'air
    ftri_ag = mesh.create('ftri_ag', 'FreeTri');
    ftri_ag.selection.named('air_gap');
    ftri_size = ftri_ag.create('size1', 'Size');
    ftri_size.set('hauto', 2); % Maillage très fin;

    % Création d'un maillage triangulaire libre pour la cavité
    ftri_cav = mesh.create('ftri_cav', 'FreeTri');
    ftri_cav.selection.named('cavity');
    ftri_size = ftri_cav.create('size1', 'Size');
    ftri_size.set('hauto', 2); % Maillage très fin;

    mesh.run;
    

    %% Etude

    std1 = model.study.create('std1');  
    std1.create('freq', 'Frequency');  
    std1.feature('freq').set('plist', num2str(env.w/(2*pi)));  
    
    sol1 = model.sol.create('sol1');  
    sol1.study('std1');  
    sol1.attach('std1');  
    sts1 = sol1.create('st1', 'StudyStep');
    sts1.label('Compile Equations: Frequency Domain');  

    v1 = sol1.create('v1', 'Variables');  
    v1.label('Dependent Variables 1.1');  
    v1.set('clistctrl', {'p1'});  
    v1.set('cname', {'freq'});   
    v1.set('clist',  cellstr(join(string(env.w/(2*pi))+"[Hz]")));  
    
    s1 = sol1.create('s1', 'Stationary');  
    s1.label('Stationary Solver 1.1'); 
    s1.feature('dDef').label('Direct 2');  
    s1.feature('aDef').label('Advanced 1');  
    s1.feature('aDef').set('complexfun', true);  

    s1.create('p1', 'Parametric');  
    s1.feature('p1').label('Parametric 1.1');  
    s1.feature('p1').set('pname', {'freq'});  
    s1.feature('p1').set('plistarr', cellstr(num2str(env.w/(2*pi))));  
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

end