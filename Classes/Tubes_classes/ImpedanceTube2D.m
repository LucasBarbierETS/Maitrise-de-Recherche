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

        function obj = plot_alpha(obj, env, name)

            hold on

            % % Résultats analytiques
            % assembly = classelementassembly(classelementassembly.create_config(obj.Configuration.ListOfSolutions)); 
            % try 
            %     alpha_model = assembly.alpha(env);
            %     f = env.w / (2 * pi);
            %     plot(f, alpha_model, 'color', 'b', 'DisplayName', 'Modèle analytique');
            % catch 
            % end
            
            % Résultats numériques
            if isfield(obj.Configuration, 'Data2D')
                data = obj.Configuration.Data2D;
                plot(data(:, 1), data(:, 2), '--r', 'DisplayName', 'Solution numérique');
            end
            
            % perso_configure_alpha_figure(2000);
            title(name);
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
    end
end