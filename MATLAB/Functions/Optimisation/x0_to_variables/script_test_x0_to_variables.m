addpath 'C:\Users\Utilisateur\OneDrive - ETS\CRIAQ-REAR\Maitrise LB\Functions\Optimisation\variables_to_x0_lb_ub'

%% valeurs initiales en fonction du types de variable

init_value = struct();
init_value.cavities_length = 0.1;
init_value.plates_porosity = 0.05;
init_value.plates_thickness = 0.001;
init_value.plates_perforations_dimensions = 0.001;

%% bornes inf et sup en fonction des types de variable

bound = struct();
bound.cavities_length = [0.01 0.5];
bound.plates_porosity = [0 1];
bound.plates_thickness = [0.0001 0.005];
bound.plates_perforations_dimensions = [0.0001 0.003];

%% repertoire des "variables muettes

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

%% données du problèmes

[x0, lb, ub] = variables_to_x0_lb_ub(variables);

x0 = 2*x0;

updated_variables = x0_to_variables(x0, variables);

disp(updated_variables);

