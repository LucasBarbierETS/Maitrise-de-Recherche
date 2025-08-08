%% Description

% On optimise les paramètres d'une plaque couvrante.
% Au cours de l'optimisation on définit les paramètres JCA perçus par les
% solutions individuelles en supposant que l'agancement des perforations
% est optimal, c.a.d que chaque solution voit un nombre maximal de perforations
% selon ses dimensions propres

%% Sélection du dossier de destination des élements sauvegardés
% folderName = uigetdir();

%% Paramètres et conditions de l'optimisation

NP = 100; % Nombre de points de départ

% Limites des bandes de fréquences 
f_min_bf = 150;
f_max_bf = 400;
f_min_mf = 400;
f_max_mf = 600;
f_min_hf = 600;
f_max_hf = 1500;

% Niveau sonore
dB = 135;

%% Paramètres géométriques invariants

total_thickness = 120e-3;
total_depth = 72e-3; 
total_width = 120e-3;

% Plaque couvrante
top_plate_thickness = 1e-3;

% Solution ETS
ETS_cavities_width = 28e-3; % bords externes : 30 mm
ETS_cavities_depth = 28e-3; % bords externes : 30 mm
ETS_input_section = ETS_cavities_depth * ETS_cavities_width;
plates_thickness = 2e-3;
plates_holes_radius = 4.5e-4;
rigid_backing_thickness = 2e-3;

% Solutions Poly
Poly_cavities_width = 28e-3; % bords externes : 30 mm
Poly_cavities_depth = 28e-3; % bords externes : 30 mm
Poly_input_section = Poly_cavities_width * Poly_cavities_depth; 

% Solutions HR
SDOF_cavities_thickness = total_thickness - top_plate_thickness;
SDOF_cavities_width = 28e-3; % bords externes : 30 mm
SDOF_cavities_depth = 10e-3; % bords externes : 12 mm
SDOF_input_section = SDOF_cavities_width * SDOF_cavities_depth;

%% Variables optimisées

% Structure des variables
NTP = 3; % (rayon, nombre de perf par ligne (width), nombre de perfs par colonne (depth))
NS = 4; % Nombre de MPPSBH optimisés
NV = 2; % Nombre de variables pour chaque solution (nombre de perfs en largeur, espacement des perfs en largeur)
N = 5; % Nombre de plaques optimisées indépendantes pour chaque solution

cavities_total_thickness = total_thickness - top_plate_thickness - N * plates_thickness; 

% Récupération des parties du vecteur d'optimisation
x_TP = @(x) x(1 : NTP);
x_ETS = @(x) reshape(x(NTP+1 : NTP + N*NV*NS), NS, N, NV);
x_SPLX = @(x) x(NTP + N*NV*NS + 1 : end);

% Récupération des paramètres de la plaque supérieur
tp_width_holes_distance = @(x_TP) total_width / x_TP(2);
tp_depth_holes_distance = @(x_TP) total_depth / x_TP(3);

% Définition des nombres de perforation maximisés en fonction de la surface d'entrée de la plaque

% Explication
% On calcule le nombre maximal de perforations qu'on peut faire tenir dans
% les dimensions de la surface d'entrée en évitant des perforations
% partiellement obstruées.
% On renvoie le nombre de perforation (entier) maximal tel que les bords
% extremes sont éloignés de moins que la dimension considérée

plate_width_holes_number = @(x_TP, input_width) floor((input_width - 2*x_TP(1))/tp_width_holes_distance(x_TP) + 1);
plate_depth_holes_number = @(x_TP, input_depth) floor((input_depth - 2*x_TP(1))/tp_depth_holes_distance(x_TP) + 1);

%% Valeurs minimales en fonction du type de variable

% Plaque couvrante
tp_phi_min = 0.05;
tp_r_min = 5e-4;
tp_whn_min = 15;
tp_dhn_min = 15;

% Solution ETS
dw_min = 4 * plates_holes_radius;
pw_min = 1;

theta_min = 0;

lb = horzcat([tp_r_min, tp_whn_min, tp_dhn_min, repmat(dw_min, 1, N * NS), ones(1, N * NS), zeros(1, N)]);

%% Valeurs maximales en fonction du type de variable

% Plaque couvrante
tp_phi_max = 0.4;
tp_r_max = 3e-3;
tp_whn_max = 100;
tp_dhn_max = 100;

% Solution ETS
dw_max = 8 * plates_holes_radius;
pw_max = 12;

theta_max = 5;

ub = horzcat([tp_r_max, tp_whn_max, tp_dhn_max, repmat(dw_max, 1, N * NS), repmat(pw_max, 1, N * NS), repmat(theta_max, 1, N)]);

%% Valeurs initiales en fonction du types de variable

% Plaque supérieure 
tp_r_init = tp_r_min + (tp_r_max - tp_r_min) * rand(NP, 1);
tp_phi_init = tp_phi_min + (tp_phi_max - tp_phi_min) * rand(NP, 1);
tp_hole_number_init = @(phi, r) round(total_width * total_depth * phi / (pi*r^2));
[tp_width_holes_number_init, tp_depth_holes_number_init] = arrayfun(@(i) perso_distribute_holes(total_width, total_depth, tp_hole_number_init(tp_phi_init(i), tp_r_init(i))), 1:NP ,'UniformOutput', false);

% Distance inter-perforation en largeur
dw_init = dw_min + (dw_max - dw_min) * rand(NP, N * NS);

% Nombre de perforation en largeur
pw_init = randi([pw_min, pw_max], NP, N * NS);
pw_init_sorted = sort(pw_init, 2, "descend");

% Paramètres de répartition de l'épaisseur
theta_init = theta_min + (theta_max - theta_min) * rand(NP, N);

x0 = horzcat([tp_r_init, cell2mat(tp_width_holes_number_init)', cell2mat(tp_depth_holes_number_init)', dw_init, pw_init_sorted, theta_init]);

%% Contrainte sur les variables entières

intcon = find(horzcat([[0, 1, 1], zeros(1, N*NS), ones(1, N*NS), zeros(1, N)]));

%% Fonction de définitions de la matrice de contraintes non linéaires  

% Définition du handle avec paramètres capturés
handle_perso_nonlcon = @(x) perso_MPPSBHr_nonlconf(x_ETS(x), NV, NS, N, ETS_cavities_width, ETS_cavities_depth);

%% Gabarits

% Définition des plages fréquentielles d'interet pour la fonction cout
g_bf = @(env) (env.w / (2*pi) > f_min_bf & env.w / (2*pi) < f_max_bf);
g_mf = @(env) (env.w / (2*pi) > f_min_mf & env.w / (2*pi) < f_max_mf);
g_hf = @(env) (env.w / (2*pi) > f_min_bf & env.w / (2*pi) < f_max_hf);
g_bf_mf = @(env) (env.w / (2*pi) > f_min_bf & env.w / (2*pi) < f_max_mf);
g_mf_hf = @(env) (env.w / (2*pi) > f_min_mf & env.w / (2*pi) < f_max_hf);
g_bf_hf = @(env) (env.w / (2*pi) > f_min_bf & env.w / (2*pi) < f_max_hf);

%% Importation de l'élement expérimental

% % Importation de l'impédance de surface de l'élement expérimental en parallèle
% data = perso_load_mecanum_files(['C:\Users\lucas.barbier\Documents\Maitrise dossier secondaire\' ...
%     'Mesures expérimentales\Echantillons Hutchinson 1ère itération\Echantillon Poly Hutchinson\Export_Data']);
% Zsn = data.NormalizedSurfaceImpedanceOnCavity;
% alpha = data.AbsorptionCoefficientOnCavity;
% frequency_support = Zsn.Sample1_Imag_Frequency_Hz_;
% surface_impedance = Zsn.NormalizedSurfaceImpedanceOnCavity + 1i * Zsn.NormalizedSurfaceImpedanceOnCavity_1;
% alpha100 = alpha.AbsorptionCoefficientOnCavity;

data = load(['C:\Users\lucas.barbier\Documents\Maitrise dossier secondaire\Mesures expérimentales\' ...
    'Echantillons Hutchinson 1ère itération\Echantillon Poly Hutchinson\25.05.27- Niloofar solution - numercial evaluation - Surface impedance.txt']);
frequency_support = data(:, 1);
surface_impedance = data(:, 2) + 1i * data(:, 3);

[Zs, imported_Poly_subelement] = classsubelement_imported(classsubelement_imported.create_config( ...
        frequency_support, surface_impedance, Poly_input_section)).surface_impedance(env(dB));

% Debog
% Tracé de l'impédance de surface
figure()
subplot(2, 1, 1)
plot(frequency_support, real(surface_impedance));
subplot(2, 1, 2)
plot(frequency_support, imag(surface_impedance));

% Tracé de l'absorption 
figure()
% plot(frequency_support, alpha100);
imported_Poly_subelement.plot_alpha(env(100), 'poly');

%% Fonction coût - Création d'un assemblage acoustique multicouche dynamique

% --- Solutions ETS

% Construction du ième MPPSBH à partir d'une découpe du vecteur d'optimisation
MPPSBH_HL_i = @(x_TP, x_ETS, x_SPLX, i) classMPPSBH_Rectangular_HL( ...
    classMPPSBH_Rectangular.create_explicit_slit_pattern_config( ...
        N+1, ETS_cavities_depth, ETS_cavities_width, ...
        {x_TP(1), 4.5e-4}, ... {eval_r(x0(:, 1, i))}, ... % rayon des perforations
        {tp_width_holes_distance(x_TP), x_ETS(i, :, 1)}, ... % distance entre perforations (width)
        {tp_depth_holes_distance(x_TP), ETS_cavities_depth/8}, ... % distance entre perforations (depth)
        {plate_depth_holes_number(x_TP, ETS_cavities_depth), 8}, ... {transpose(x0(:, 3, i))}, ... % nombre de perforations en profondeur
        {plate_width_holes_number(x_TP, ETS_cavities_width), x_ETS(i, :, 2)}, ... % nombre de perforations en largeur
        {top_plate_thickness, plates_thickness}, ... % épaisseur des plaques (supérieure + internes)
        {perso_simplex_map(x_SPLX, cavities_total_thickness)}, 'volume'));  % épaisseur de cavité

% Construction d'un cell array contenant les objets de classe MPPSBH
cell_of_MPPSBH = @(x, NS) arrayfun(@(i) ...
    MPPSBH_HL_i(x_TP(x), x_ETS(x), x_SPLX(x), i), 1:NS ,'UniformOutput', false);

% --- Solutions Poly

% Fonction d'appel flottante pour les plaques couvrant les élements importés
top_plate = @(x_TP, input_width, input_depth) classMPP_Circular_HL( ...
    classMPP_Circular.create_explicit_rectangular_plate_config(top_plate_thickness, x_TP(1), ...
    input_width, input_depth, ...
    plate_width_holes_number(x_TP, input_width), plate_depth_holes_number(x_TP, input_depth)));

% Création d’un élément combiné : plaque MPPSBH + sous-élément importé
combined_Poly_element = @(x_TP) classelement(classelement.create_config( ...
        {top_plate(x_TP, Poly_cavities_width, Poly_cavities_depth), imported_Poly_subelement}, 'closed', Poly_input_section));

SDOF = @(x_TP) classelement(classelement.create_config( ...
        {top_plate(x_TP, SDOF_cavities_width, SDOF_cavities_depth), classcavity(classcavity.create_config(SDOF_cavities_thickness, SDOF_input_section))}, 'closed', SDOF_input_section));

% Assemblage global : objets MPPSBH + élements combinés
x_to_global_assembly = @(x) ...
    classelementassembly(classelementassembly.create_config( ...
        [cell_of_MPPSBH(x, NS),... % Solutions ETS
            repmat({SDOF(x_TP(x))}, 1, 4), ...  % Solutions HR
                repmat({combined_Poly_element(x_TP(x))}, 1, 4)])); % Solutions Poly

% Evaluation du coût de la configuration 
cost_function_bf = @(x, env) sum(((x_to_global_assembly(x).alpha(env) - g_bf(env)) .* (g_bf(env) > 0.1)).^2, 'omitnan');
cost_function_mf = @(x, env) sum(((x_to_global_assembly(x).alpha(env) - g_mf(env)) .* (g_mf(env) > 0.1)).^2, 'omitnan');
cost_function_hf = @(x, env) sum(((x_to_global_assembly(x).alpha(env) - g_hf(env)) .* (g_hf(env) > 0.1)).^2, 'omitnan');
cost_function_bf_mf = @(x, env) sum(((x_to_global_assembly(x).alpha(env) - g_bf_mf(env)) .* (g_bf_mf(env) > 0.1)).^2, 'omitnan');
cost_function_mf_hf = @(x, env) sum(((x_to_global_assembly(x).alpha(env) - g_bf_mf(env)) .* (g_bf_hf(env) > 0.1)).^2, 'omitnan');
cost_function_bf_hf = @(x, env) sum(((x_to_global_assembly(x).alpha(env) - g_bf_hf(env)) .* (g_bf_hf(env) > 0.1)).^2, 'omitnan');

objective = @(x) [cost_function_bf(x, env(dB)), cost_function_mf(x, env(dB)), cost_function_hf(x, env(dB))];

%% Genetic Algorithm

% gaplotfeasibility = @(options, state, flag) perso_gaplotfeasibility(handle_perso_nonlcon, options, state, flag);

options = optimoptions('ga', ...
                       'Display', 'iter', ...
                       'PlotFcn',  {@gaplotpareto, @gaplotscorediversity},... {@gaplotbestf, @gaplotmaxconstr, @gaplotbestindiv}, ... {@gaplotfeasibility}, ... % {@perso_plotMaxDistancePlotFcn}
                       'PopulationSize', NP, ... % nombre de points dans la population initiale
                       'FunctionTolerance', 1e-2, ...
                       'ConstraintTolerance', 1, ...
                       'MaxStallGenerations', 10, ...
                       'MaxGenerations', 100, ...
                       'MutationFcn',  'mutationadaptfeasible',... {@mutationgaussian, 2, 0.5}, ... %'mutationuniform', ... 
                       'CrossoverFraction', 0.5, ...
                       'MigrationInterval', 10, ...
                       'MigrationFraction', 0.3, ...
                       'InitialPopulationMatrix', x0); 

rng; % For reproducibility"
tic;
[xopti_lb_hf, fval, eflag, output, population, scores] = gamultiobj(objective, numel(x0(1, :)), [], [], [], [], lb, ub, handle_perso_nonlcon, intcon, options);
timeGa = toc;

% Affichage 
figure()
hold on
% On trie les meileurs scores obtenus
[filtered_scores, filtered_index] = perso_convex_pareto_filter(scores);
scatter(filtered_scores(:, 1), filtered_scores(:, 2), 'r');

xopti_to_cell_array_of_global_assembly_alpha = @(x, env) arrayfun(@(i) x_to_global_assembly(x(i, :)).alpha(env), 1:size(x, 1), 'UniformOutput', false);
cell_of_MPPSBH_assembly_alpha_to_mean_alpha = @(alpha_cell_array, gabarit) arrayfun(@(i) mean(alpha_cell_array{i}(gabarit)), 1:size(alpha_cell_array, 2), 'UniformOutput', false);

% On récupère les vecteurs d'absorption des meilleures configurations
[sorted_scores_opti, sorted_index_opti] = sort(fval);
sorted_xopti = xopti_lb_hf(sorted_index_opti(:, 1), :);
filtered_alpha = xopti_to_cell_array_of_global_assembly_alpha(sorted_xopti, env(dB));

% On récupère, pour ces vecteurs, les alphas moyens sur différentes bandes fréquentielles d'intérêt
mean_alpha_bf = cell_of_MPPSBH_assembly_alpha_to_mean_alpha(filtered_alpha, g_bf(env(dB)));
mean_alpha_lb_hf = cell_of_MPPSBH_assembly_alpha_to_mean_alpha(filtered_alpha, g_hf(env(dB)));

% Tracé interractif des meilleurs résultats de l'optimisation multi objectif
perso_interactive_multi_plot(env(dB).w /(2*pi), filtered_alpha, mean_alpha_bf, mean_alpha_lb_hf, 2000);

%% Résultats

chosed_index = input('Veuillez entrer le numéro de la configuration choisie : ');

% Solutions et configurations optimisée
x_opti = sorted_xopti(chosed_index, :);
rtp_opti = x_opti(1);
nbw_opti = x_opti(2);
nbd_opti = x_opti(3);
assembly_lb_hf_opti = x_to_global_assembly(sorted_xopti(chosed_index, :));
MPPSBH_lb_hf_1 = assembly_lb_hf_opti.Configuration.ListOfElements{1};
MPPSBH_lb_hf_2 = assembly_lb_hf_opti.Configuration.ListOfElements{2};
MPPSBH_lb_hf_3 = assembly_lb_hf_opti.Configuration.ListOfElements{3};
MPPSBH_lb_hf_4 = assembly_lb_hf_opti.Configuration.ListOfElements{4};
Solution_SDOF = assembly_lb_hf_opti.Configuration.ListOfElements{5};
Solution_Poly = assembly_lb_hf_opti.Configuration.ListOfElements{9};
MPPSBH_lb_hf_1_config = MPPSBH_lb_hf_1.Configuration;
MPPSBH_lb_hf_2_config = MPPSBH_lb_hf_2.Configuration;
MPPSBH_lb_hf_3_config = MPPSBH_lb_hf_3.Configuration;
MPPSBH_lb_hf_4_config = MPPSBH_lb_hf_4.Configuration;
Solution_SDOF_config = Solution_SDOF.Configuration;
Solution_Poly_config = Solution_Poly.Configuration;

%% Affichage graphique

% Solutions ETS
figure()
hold on
plot(env(dB).w/(2*pi), g_hf(env(dB)) , "--", 'DisplayName', 'Gabarit');
plot(env(dB).w/ (2*pi), assembly_lb_hf_opti.alpha(env(dB)), 'DisplayName', 'Assemblage');
plot(env(dB).w/ (2*pi), MPPSBH_lb_hf_1.alpha(env(dB)), 'DisplayName', 'MPPSBH 1');
plot(env(dB).w/ (2*pi), MPPSBH_lb_hf_2.alpha(env(dB)), 'DisplayName', 'MPPSBH 2');
plot(env(dB).w/ (2*pi), MPPSBH_lb_hf_3.alpha(env(dB)), 'DisplayName', 'MPPSBH 3');
plot(env(dB).w/ (2*pi), MPPSBH_lb_hf_4.alpha(env(dB)), 'DisplayName', 'MPPSBH 4');
perso_configure_alpha_figure(2000);

% Autres Solutions
figure()
hold on
plot(env(dB).w/(2*pi), g_hf(env(dB)) , "--", 'DisplayName', 'Gabarit');
plot(env(dB).w/ (2*pi), assembly_lb_hf_opti.alpha(env(dB)), 'DisplayName', 'Assemblage');
plot(env(dB).w/ (2*pi), Solution_SDOF.alpha(env(dB)), 'DisplayName', 'SDOF');
plot(env(dB).w/ (2*pi), Solution_Poly.alpha(env(dB)), 'DisplayName', 'Solution Poly');
plot(env(dB).w/ (2*pi), imported_Poly_subelement.alpha(env(dB)), 'DisplayName', 'Solution Poly sans plaque');
perso_configure_alpha_figure(2000);

%% Indicateurs

alpha_mean_lb_hf_in_band = assembly_lb_hf_opti.alpha_mean(env(dB), f_min_bf, f_max_bf);
alpha_mean_lb_hf_out_band = assembly_lb_hf_opti.alpha_mean(env(dB), f_min_mf, f_max_hf);
alpha_mean = assembly_lb_hf_opti.alpha_mean(env(dB), f_min_bf, f_max_hf);

%% Validation numérique
%
% Tube_lb_hf = ImpedanceTube2D(ImpedanceTube2D.create_config(assembly_lb_hf_opti.Configuration.ListOfElements));
% Tube_lb_hf = Tube_lb_hf.lauch_tube_measurement();
% Tube_lb_hf.plot_alpha(env(dB), f_min_bf, f_max_lb_hf, 'solution large bande');
% mphsave(Tube_lb_hf.Configuration.ComsolModel, ['E:\Montréal 2023 - 2025\Maitrise LB\Présentations\Présentation groupe REAR\25.05.08 - configurations finales pour 1ère itération\' ...
%                                                'validation numérique de la solution fournie par ETS'])

% Sauvegarde des rapports de configuration





% report_root = 'E:\Montréal 2023 - 2025\Maitrise LB\Présentations\Présentation groupe REAR\25.05.08 - configurations finales pour 1ère itération\';
% MPPSBH_lb_hf_1.export_report([report_root, 'rapport de configuration - solution 1.xlsx'])
% MPPSBH_lb_hf_2.export_report([report_root, 'rapport de configuration - solution 2.xlsx'])
% MPPSBH_lb_hf_3.export_report([report_root, 'rapport de configuration - solution 3.xlsx'])
% MPPSBH_lb_hf_4.export_report([report_root, 'rapport de configuration - solution 4.xlsx'])

% MPPSBH_lb_hf_1.export_DXF();

%% Enregistrement de l'environnement
% save([folderName, '\environnement matlab.mat']);