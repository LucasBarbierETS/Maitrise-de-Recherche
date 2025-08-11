classdef ImpedanceTube2D

    properties
        Configuration
    end

    methods
        function obj = ImpedanceTube2D(config)

            obj.Configuration = config;
        end

        function obj = lauch_tube_measurement(obj, env)
            obj.Configuration.ComsolModel = ImpedanceTube2DModel(obj.Configuration.ListOfSolutions, env);
            obj.Configuration.Data2D = mphtable(obj.Configuration.ComsolModel, 'tbl1').data;
        end

        function obj = plot_alpha(obj, env, name) % f_min, f_max,

            figure()
            hold on

            % Limites fréquentielles
            % xline(f_min, '--k');
            % xline(f_max, '--k');

            % Résultats analytiques
            assembly = classelementassembly(classelementassembly.create_config(obj.Configuration.ListOfSolutions)); 
            alpha_model = assembly.alpha(env);
            f = env.w / (2 * pi);
            p1 = plot(f, alpha_model, 'color', 'b', 'DisplayName', name);
            % yline(assembly.alpha_mean(env, f_min, f_max), '--b', ...
            %       sprintf('%.2f', assembly.alpha_mean(env, f_min, f_max)), 'LabelHorizontalAlignment', 'right', 'LabelVerticalAlignment', 'top');
           
            % Résultats numériques
            if isfield(obj.Configuration, 'Data2D')
                data = obj.Configuration.Data2D;
                p2 = plot(data(:, 1), data(:, 2), '--r', 'DisplayName', name);
                % m = (data(:, 1) > f_min & data(:, 1) < f_max);
                % yline(mean(data(m, 2)), '--r', ...
                %       sprintf('%.2f', mean(data(m, 2))), 'LabelHorizontalAlignment', 'right', 'LabelVerticalAlignment', 'bottom');
            end

            perso_configure_alpha_figure(3000);
            legend([p1, p2], 'Location', 'best');
        end
    end

    methods (Static)
        function config = create_config(list_of_solutions)
            config = struct();
            config.ListOfSolutions = list_of_solutions;
        end
    end
end