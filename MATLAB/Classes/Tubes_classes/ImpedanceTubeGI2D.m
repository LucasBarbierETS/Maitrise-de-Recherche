classdef ImpedanceTubeGI2D

    properties
        Configuration
    end

    methods
        function obj = ImpedanceTubeGI2D(config)

            obj.Configuration = config;
        end

        function obj = lauch_tube_measurement(obj)
            env = create_environnement(28, 108000, 50, 1, 5000, 200, 130);
            [obj.Configuration.ComsolModel, obj.Configuration.Data2D] = ImpedanceTubeGI2DModel(obj.Configuration.ListOfSolutions, env);
        end

        function obj = plot_TL(obj, env, name)

            figure()
            hold on
            
            %% Résultats analytiques

            % On construit la matrice de transfert analytique de
            % l'échantillon suposé à réaction localisée, d'épaisseur nulle
            % au milieu de la zone ou se trouve l'échantillon réel. On
            % ajoute une matrice de transfert pour le tube en amont et en
            % aval de la jonction, d'une longueur du demi-échantillon de
            % chaque côté.

            sample_length = obj.Configuration.ComsolModel.param.evaluate(['xr' num2str(length(obj.Configuration.ListOfSolutions))]);
            tube_height = obj.Configuration.ComsolModel.param.evaluate('ht');
            tube_depth = 30e-3; % profondeur (arbitraire) du tube

            % Création du tronçon de tube le long duquel se trouve l'échantillon
            half_tube = classcavity(classcavity.create_config(sample_length/2, tube_height*tube_depth));
            assembly = classelementassembly(obj.Configuration.ListOfSolutions);
            junction = classjunction(classjunction.create_config(tube_height*tube_depth, assembly));
            junction.Configuration.CurtainArea = sample_length*tube_depth;
            element = classelement(classelement.create_config({half_tube, junction, half_tube}, 'opened', 30e-3^2));
            TL = element.transmission_loss(env);
            plot(env.w/(2*pi), TL, 'DisplayName', [name ' - Résultat Analytique']);


            %% Résultats numériques

            if isfield(obj.Configuration, 'Data2D')
                data = obj.Configuration.Data2D;
                plot(data.f, data.TLd, 'LineStyle', '--', 'DisplayName', [name ' - Résultat FEM Direct']);
                plot(data.f, data.TLi, 'LineStyle', '--', 'DisplayName', [name ' - Résultat FEM Indirect']);
            end

            xlabel("Fréquence (Hz)")
            ylabel("Transmission Loss (dB)")
            % xlim([0 2000])
            % ylim([0 1])
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