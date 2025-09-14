%% Validation des configurations optimisées

load([root, '\Optimisation\Optimisation REAR\Optimisations finales\optimisation_ETS_Poly_H1-4_08_25_06_14\environnement matlab.mat']);

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

env = create_environnement(root, t, sp, hum, fmin, fmax, 100);

Objets.MPPSBH_i = @(x_ETS, x_radius, i) classMPPSBH_Rectangular(classMPPSBH_Rectangular.create_explicit_rectangular_pattern_config( ...
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
    classcavity(classcavity.create_config(ETS_cavities_thickness, ETS_cavities_width, ETS_cavities_depth)) ...
    Objets.MPPSBH_i(x_ETS(x), radius(x_radius(x)), i)}, 'closed', ETS_input_surface));

air_gap_ETS = classcavity(classcavity.create_config(air_gap_thickness, ETS_width, ETS_depth));

Contributions.contribution_MPPSBH_element_i = @(x, i) classelement(classelement.create_config( ...
    {top_plate_ETS(x_TP_ETS(x)), ...
     air_gap_ETS, ...
     classcavity(classcavity.create_config(ETS_cavities_thickness, ETS_cavities_width, ETS_cavities_depth)), ...
     Objets.MPPSBH_i(x_ETS(x), radius(x_radius(x)), i)}, 'closed', ETS_input_surface));

% Contributions des élements MPPSBHs
folder_full_name = [root, '\COMSOL\Optimisation\Optimisation REAR\Optimisations finales\optimisation_ETS_Poly_H1-4_08_25_06_14'];
mkdir([folder_full_name, '\Validation numérique\Validation 2D des contributions des élements MPPSBHs']);
mkdir([folder_full_name, '\Figures']);

%% Validation de la cavité jaune

perso_figure('Validation numérique 2D - contribution cavité jaune - module ETS')
Tube_ETS_yc_contrib = ImpedanceTube2D(ImpedanceTube2D.create_config({Contributions.contribution_ETS_yellow_cavity(x_opti)}));
Tube_ETS_yc_contrib = Tube_ETS_yc_contrib.launch_tube_measurement(env);
Tube_ETS_yc_contrib.plot_alpha(env, 'Contribution ETS cavité jaune');
comsol_model = Tube_ETS_yc_contrib.Configuration.ComsolModel;
Contributions.contribution_ETS_yellow_cavity(x_opti).plot_alpha(env, 'modèle linéaire');
saveas(gcf, [folder_full_name, '\Figures\Validation de la contribution de la cavité jaune de la cartouche ETS.fig']);
mphsave(comsol_model, [folder_full_name, '\Validation numérique\Validation de la contribution de la cavité jaune de la cartouche ETS.mph']);

for i = 1:NS

    % Vérification des MPPSBHs seuls
    perso_figure(['Validation numérique 2D - MPPSBH ', num2str(i)])
    Objets.MPPSBH_i(x_ETS(x_opti), radius(x_radius(x_opti)), i).plot_alpha(env, 'modèle linéaire');
    Tube_MPPSBH_element_contrib = ImpedanceTube2D(ImpedanceTube2D.create_config({classelement(classelement.create_config( ...
    {Objets.MPPSBH_i(x_ETS(x_opti), radius(x_radius(x_opti)), i)}, 'closed', ETS_input_surface))}));
    Tube_MPPSBH_element_contrib = Tube_MPPSBH_element_contrib.launch_tube_measurement(env);
    Tube_MPPSBH_element_contrib.plot_alpha(env, ['MPPSBH' num2str(i)]);

    perso_figure(['Validation numérique 2D - contribution MPPSBH ', num2str(i)])
    Contributions.contribution_MPPSBH_element_i(x_opti, i).plot_alpha(env, 'modèle linéaire');
    Tube_MPPSBH_element_contrib = ImpedanceTube2D(ImpedanceTube2D.create_config({Contributions.contribution_MPPSBH_element_i(x_opti, i)}));
    Tube_MPPSBH_element_contrib = Tube_MPPSBH_element_contrib.launch_tube_measurement(env);
    Tube_MPPSBH_element_contrib.plot_alpha(env, ['Contribution MPPSBH' num2str(i)]);
    comsol_model = Tube_MPPSBH_element_contrib.Configuration.ComsolModel;
    % perso_configure_alpha_figure(2000);
    try
        saveas(gcf, [folder_full_name, '\Figures\Validation de la contribution de MPPSBH', num2str(i) ,'.fig']);
    catch
        return 
    end

    perso_figure(['Géométrie 2D - MPPSBH ', num2str(i)])
    mphgeom(Tube_MPPSBH_element_contrib.Configuration.ComsolModel);
    saveas(gcf, [folder_full_name, '\Figures\Géométrie de l''élement MPPSBH', num2str(i), '.fig']);
    mphsave(comsol_model, [folder_full_name, '\Validation numérique\Validation 2D des contributions des élements MPPSBHs\validation_2D_MPPSBH_', num2str(i), '.mph']);
end


