% Définir les valeurs initiales et les bornes
init_value = struct();
init_value.cavities_length = 0.1;
init_value.plates_porosity = 0.05;
init_value.plates_thickness = 0.001;
init_value.plates_perforations_dimensions = 0.001;

bound = struct();
bound.cavities_length = [0.01 0.5];
bound.plates_porosity = [0 1];
bound.plates_thickness = [0.0001 0.005];
bound.plates_perforations_dimensions = [0.0001 0.003];

% Définir la structure des variables muettes
variables = struct();

variables.l1 = [init_value.cavities_length, bound.cavities_length(1), bound.cavities_length(2)];
variables.l2 = [init_value.cavities_length, bound.cavities_length(1), bound.cavities_length(2)];
variables.l3 = [init_value.cavities_length, bound.cavities_length(1), bound.cavities_length(2)];
variables.l4 = [init_value.cavities_length, bound.cavities_length(1), bound.cavities_length(2)];

variables.p1 = [init_value.plates_porosity, bound.plates_porosity(1), bound.plates_porosity(2)];
variables.p2 = [init_value.plates_porosity, bound.plates_porosity(1), bound.plates_porosity(2)];
variables.p3 = [init_value.plates_porosity, bound.plates_porosity(1), bound.plates_porosity(2)];
variables.p4 = [init_value.plates_porosity, bound.plates_porosity(1), bound.plates_porosity(2)];

variables.t1 = [init_value.plates_thickness, bound.plates_thickness(1), bound.plates_thickness(2)];
variables.t2 = [init_value.plates_thickness, bound.plates_thickness(1), bound.plates_thickness(2)];
variables.t3 = [init_value.plates_thickness, bound.plates_thickness(1), bound.plates_thickness(2)];
variables.t4 = [init_value.plates_thickness, bound.plates_thickness(1), bound.plates_thickness(2)];

variables.r1 = [init_value.plates_perforations_dimensions, bound.plates_perforations_dimensions(1), bound.plates_perforations_dimensions(2)];
variables.r2 = [init_value.plates_perforations_dimensions, bound.plates_perforations_dimensions(1), bound.plates_perforations_dimensions(2)];
variables.r3 = [init_value.plates_perforations_dimensions, bound.plates_perforations_dimensions(1), bound.plates_perforations_dimensions(2)];
variables.r4 = [init_value.plates_perforations_dimensions, bound.plates_perforations_dimensions(1), bound.plates_perforations_dimensions(2)];

% Définir la structure de configuration
config = struct();
config.cavities_dimensions = [[0.05; 0.05], [0.05; 0.05], [0.05; 0.05], [0.05; 0.05]];
config.cavities_length = {'l1', 'l2', 'l3', 'l4'};
config.cavities_shape = {'rectangle', 'rectangle', 'rectangle', 'rectangle'};
config.plates_perforations_shape = {'circle','circle','circle','circle'};
config.plates_porosity = {'p1', 'p2', 'p3', 'p4'};
config.plates_thickness = {'t1', 't2', 't3', 't4'};
config.plates_correction_length = [0; 0]; 
config.plates_perforations_dimensions = {'r1', 'r2', 'r3', 'r4'};

% Appeler la fonction pour mettre à jour la configuration avec les valeurs réelles
config_updated = replace_fields(config, variables);

% Afficher la configuration mise à jour
disp(config_updated);
