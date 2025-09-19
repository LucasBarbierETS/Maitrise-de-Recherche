classdef ImpedanceTube2D

    properties
        Configuration
    end

    methods
        function obj = ImpedanceTube2D(config)

            obj.Configuration = config;
        end

        function obj = launch_tube_measurement(obj, env)
            obj.Configuration.ComsolModel = ImpedanceTube2DModel(obj.Configuration.ListOfSolutions, env);
            obj.Configuration.Data2D = mphtable(obj.Configuration.ComsolModel, 'tbl1').data;
        end

        function obj = plot_alpha(obj, name)

            hold on
            
            try 
                data = obj.Configuration.Data2D;
                plot(data(:, 1), data(:, 2), '--r', 'DisplayName', name);
            catch
                return
            end
            
            perso_configure_alpha_figure(3000);
        end
    
        function obj = plot_surface_impedance(obj, env, name)

            hold on

            try
                data = obj.Configuration.Data2D;
                Zs_num = data(:, 5) + 1i*data(:, 6);
                perso_plot_surface_impedance(data(:, 1), Zs_num, env, name);
            catch 
                return
            end
        end        
        
        function plot_alpha_mean_line(obj, f_min, f_max)

            hold on

            % Résultats analytiques
            assembly = classelementassembly(classelementassembly.create_config(obj.Configuration.ListOfSolutions));
            yline(assembly.alpha_mean(env, f_min, f_max), '--b', ...
            sprintf('Moyenne %s - %s : %.2f', f_min, f_max, assembly.alpha_mean(env, f_min, f_max)), 'LabelHorizontalAlignment', 'right', 'LabelVerticalAlignment', 'top');
        end
    end

    methods (Static)
        function config = create_config(list_of_solutions)
            config = struct();
            config.ListOfSolutions = list_of_solutions;
        end
    

        function Tube2D = load_model(model)
            
            Tube2D = ImpedanceTube2D({});
            Tube2D.Configuration.ComsolModel = model;
            Tube2D.Configuration.Data2D = mphtable(Tube2D.Configuration.ComsolModel, 'tbl1').data;
        end
    end
end