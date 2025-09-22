%% Validation des configurations optimisées

folder_path = [env.Root, '\Répertoire GitHub\Optimisation\Optimisation REAR\Optimisations finales\optimisation_ETS_Poly_H1-4_08_25_06_14'];
load([folder_path, '\environnement matlab.mat']);
launch_environnement;    

% Solution ETS
ETS_width = 30e-3;
ETS_depth = 28e-3;
ETS_cavities_width = 28e-3; 
ETS_cavities_depth = 28e-3; 
ETS_input_surface = ETS_width * ETS_depth;
plates_thickness = 2e-3;
rigid_backing_thickness = 1e-3;
depth_holes_number = 10;
depth_holes_distance = ETS_cavities_depth / (depth_holes_number + 1);
ETS_cavities_thickness = 17.17e-3;

env_FEM = handle_env_FEM(500);

Objets.MPPSBH_i = @(x_ETS, x_radius, i) classMPPSBH_Rectangular_iter2(classMPPSBH_Rectangular.create_explicit_slit_pattern_config( ...
        ETS_input_surface, N, ETS_cavities_depth, ETS_cavities_width, ...
        {x_radius}, ... {radius(x_ETS(i, :, 1))}, ... {eval_r(x0(:, 1, i))}, ... % rayon des perforations
        {x_ETS(i, :, 1)}, ... % distance entre perforations (width)
        {ETS_cavities_depth/depth_holes_number}, ... % distance entre perforations (depth)
        {depth_holes_number}, ... {transpose(x0(:, 3, i))}, ... % nombre de perforations en profondeur
        {x_ETS(i, :, 2)}, ... % nombre de perforations en largeur
        {plates_thickness}, ... % épaisseur des plaques (supérieure + internes)
        {ETS_cavities_thickness})); %;  % épaisseur de cavité

Objets.MPPSBH_element_i = @(x, i) classelement( ...
    classelement.create_config({ ...
    classcavity_rectangular(classcavity_rectangular.create_config(ETS_cavities_thickness, ETS_cavities_width, ETS_cavities_depth)) ...
    Objets.MPPSBH_i(x_ETS(x), radius(x_radius(x)), i)}, 'closed', ETS_input_surface));

air_gap_ETS = classcavity_rectangular(classcavity_rectangular.create_config(air_gap_thickness, ETS_width, ETS_depth));

Contributions.contribution_MPPSBH_element_i = @(x, i) classelement(classelement.create_config( ...
    {top_plate_ETS(x_TP_ETS(x)), ...
     air_gap_ETS, ...
     classcavity_rectangular(classcavity_rectangular.create_config(ETS_cavities_thickness, ETS_cavities_width, ETS_cavities_depth)), ...
     Objets.MPPSBH_i(x_ETS(x), radius(x_radius(x)), i)}, 'closed', ETS_input_surface));

%% Elements MPPSBHs

% mkdir([folder_path, '\Validations numériques\Validation 2D-TV des élements MPPSBHs']);
% mkdir([folder_path, '\Validations numériques\Validation 3D-AP des con élements MPPSBHs']);
% mkdir([folder_path, '\Figures']);


%% Contributions des élements MPPSBHs

% mkdir([folder_path, '\Validations numériques\Validation 2D-TV des contributions des élements MPPSBHs']);
% mkdir([folder_path, '\Validations numériques\Validation 3D-AP des contributions des élements MPPSBHs']);
% mkdir([folder_path, '\Figures']);

N = linspace(1, 8, 8);
% N = [1,8];

for i = 1:length(N)

    % % Calcul
    % Tube_MPPSBH_2D_tv = ImpedanceTube2D(ImpedanceTube2D.create_config({classelement(classelement.create_config( ...
    % {Objets.MPPSBH_i(x_ETS(x_opti), radius(x_radius(x_opti)), i)}, 'closed', ETS_input_surface))}));
    % Tube_MPPSBH_2D_tv = Tube_MPPSBH_2D_tv.launch_tube_measurement(env_FEM);
    % Tube_MPPSBH_2D_tv.plot_alpha(['MPPSBH' num2str(i), ' - 2D-TV']);
    % mphsave(Tube_MPPSBH_2D_tv.Configuration.ComsolModel, [folder_path, '\Validations numériques\Validation 2D-TV des contributions des élements MPPSBHs\validation_2D_TV_MPPSBH_', num2str(i), '.mph']);

    % Chargement
    Tube2D_tv = ImpedanceTube2D.load_model(mphload([folder_path, '\Validations numériques\Validation 2D-TV des contributions des élements MPPSBHs\validation_2D_TV_MPPSBH_', num2str(N(i)), '.mph']));
    perso_figure(['Validation numérique - MPPSBH ', num2str(N(i))]); hold on
    % perso_figure('Validation numérique - Série d''échantillons 2'); subplot(1, 2, i); title('Echantillon 2.', num2str(N(i))); hold on
    Objets.MPPSBH_i(x_ETS(x_opti), radius(x_radius(x_opti)), N(i)).plot_alpha(env, 'modèle linéaire');
    Tube2D_tv.plot_alpha('Modélisation numérique 2D - TV');

    perso_figure(['Impédance de surface - MPPSBH ', num2str(N(i))]); hold on
    Objets.MPPSBH_i(x_ETS(x_opti), radius(x_radius(x_opti)), N(i)).plot_surface_impedance(env, 'modèle linéaire');
    Tube2D_tv.plot_surface_impedance(env, 'Impédance de surface 2D - TV')
    
    % % Calcul
    % Tube_MPPSBH_3D_ap = ImpedanceTube3D(ImpedanceTube3D.create_config({Objets.MPPSBH_i(x_ETS(x_opti), radius(x_radius(x_opti)), N(i))}));
    % Tube_MPPSBH_3D_ap = Tube_MPPSBH_3D_ap.launch_tube_measurement_ap(env_FEM);
    % Tube_MPPSBH_3D_ap.plot_alpha(['MPPSBH' num2str(N(i)), ' - 3D-AP']);
    % mphsave(Tube_MPPSBH_3D_ap.Configuration.ComsolModel, [folder_path, '\Validations numériques\Validation 3D-AP des contributions des élements MPPSBHs\validation_3D_AP_MPPSBH_', num2str(N(i)), '.mph']);

    % Chargement
    Tube3D_ap = ImpedanceTube3D.load_model(mphload([folder_path, '\Validations numériques\Validation 3D-AP des contributions des élements MPPSBHs\validation_3D_AP_MPPSBH_', num2str(N(i)), '.mph']));
    perso_figure(['Validation numérique - MPPSBH ', num2str(N(i))]); hold on
    Tube3D_ap.plot_alpha('Modélisation numérique 3D - AP');

    perso_figure(['Impédance de surface - MPPSBH ', num2str(N(i))]); hold on
    Tube3D_ap.plot_surface_impedance(env, 'Impédance de surface 3D - AP');
    
    % perso_figure(['Validation numérique 2D - contribution MPPSBH ', num2str(N(i))])
    % Contributions.contribution_MPPSBH_element_i(x_opti, N(i)).plot_alpha(env, 'modèle linéaire');
    % Tube_MPPSBH_element_contrib = ImpedanceTube2D(ImpedanceTube2D.create_config({Contributions.contribution_MPPSBH_element_i(x_opti, N(i))}));
    % Tube_MPPSBH_element_contrib = Tube_MPPSBH_element_contrib.launch_tube_measurement(env);
    % Tube_MPPSBH_element_contrib.plot_alpha(env, ['Contribution MPPSBH' num2str(N(i))]);
    % comsol_model = Tube_MPPSBH_element_contrib.Configuration.ComsolModel;
    % % perso_configure_alpha_figure(2000);
    
    % try
    %     saveas(gcf, [folder_path, '\Figures\Validation numérique - MPPSBH', num2str(N(i)) ,'.fig']);
    % catch
    %     return 
    % end

    % perso_figure(['Géométrie 2D - MPPSBH ', num2str(N(i))]);
    % mphgeom(Tube_MPPSBH_3D_ap.Configuration.ComsolModel);
    % saveas(gcf, [folder_path, '\Figures\Géométrie de l''élement MPPSBH', num2str(N(i)), '.fig']);
    % mphsave(comsol_model, [folder_path, '\Validations numériques\Validation 2D des contributions des élements MPPSBHs\validation_2D_MPPSBH_', num2str(N(i)), '.mph']);
end


