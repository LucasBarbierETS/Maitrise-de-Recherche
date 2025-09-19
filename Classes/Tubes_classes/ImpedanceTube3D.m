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
            obj.Configuration.Data3D = mphtable(obj.Configuration.ComsolModel, 'tbl1').data;
        end

        function obj = launch_tube_measurement_ap(obj, env)
            obj.Configuration.ComsolModel = ImpedanceTube3DModel_ap(obj.Configuration.ListOfSolutions, env);
            obj.Configuration.Data3D = mphtable(obj.Configuration.ComsolModel, 'tbl1').data;
        end

        function obj = plot_alpha(obj, name)

            hold on

            try
                data = obj.Configuration.Data3D;
                plot(data(:, 1), data(:, 2), 'LineStyle', '--', 'DisplayName', name)
            catch
                return
            end

            perso_configure_alpha_figure(3000);
        end

        function obj = plot_surface_impedance(obj, name)

            hold on

            try
                data = obj.Configuration.Data3D;
                Zs_num = data(:, 5) + 1i*data(:, 6);
                perso_plot_surface_impedance(data(:, 1), Zs_num, name);
            catch 
                return
            end
        end     


    end

    methods (Static)
        function config = create_config(list_of_solutions)
            config = struct();
            config.ListOfSolutions = list_of_solutions;
        end
    

        function Tube3D = load_model(model)
            
            Tube3D = ImpedanceTube2D({});
            Tube3D.Configuration.ComsolModel = model;
            Tube3D.Configuration.Data2D = mphtable(Tube3D.Configuration.ComsolModel, 'tbl1').data;
        end
    end
end