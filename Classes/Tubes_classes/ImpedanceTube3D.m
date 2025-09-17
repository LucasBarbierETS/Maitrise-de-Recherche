classdef ImpedanceTube3D

    properties
        Configuration
    end

    methods
        function obj = ImpedanceTube3D(config)

            obj.Configuration = config;
        end

        function obj = launch_tube_measurement(obj, env)
            obj.Configuration.ComsolModel = ImpedanceTube3DModel(obj.Configuration.ListOfSolutions, env);
        end

        function obj = launch_tube_measurement_ap(obj, env)
            obj.Configuration.ComsolModel = ImpedanceTube3DModel_ap(obj.Configuration.ListOfSolutions, env);
        end

        function obj = plot_alpha(obj, name)

            hold on
            % Résultats numériques
            if isfield(obj.Configuration, 'ComsolModel')
                data = mphtable(obj.Configuration.ComsolModel, 'tbl1').data;
                obj.Configuration.Alpha3D = data;
                plot(data(:, 1), data(:, 2), 'LineStyle', '--', 'DisplayName', name)
            end

            xlabel("Fréquence (Hz)")
            ylabel("Coefficient d'Absorption")
            % xlim([0 2000])
            ylim([0 1])
            legend()
        end
    end

    methods (Static)
        function config = create_config(list_of_solutions)
            config = struct();
            config.ListOfSolutions = list_of_solutions;
        end
    end
end