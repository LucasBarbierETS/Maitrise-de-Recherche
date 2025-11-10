classdef classMultiAnnular < classelement

%% Réferences

% [1] A broadband and low-frequency sound absorber of sonic black holes with multi-layered micro-perforated panels
%     https://doi.org/10.1016/j.apacoust.2023.109817
% [2] Thin metamaterial using acoustic black hole profiles for broadband sound absorption
%     https://doi.org/10.1016/j.apacoust.2023.109744
% [3] Propagation of sound in porous media, Atalla, Allard
% [4] A microstructure material design for low frequency sound absorption
    
%% Methods

    methods (Access = public)

        function obj = classMultiAnnular(config)
        
            % Appel du constructeur de la classe parente
            obj@classelement(classelement.create_config({}, 'closed', []));
               
            if nargin > 0    
                % Tranfert des champs de la configuration d'appel vers la configuration de classe
                obj.Configuration = perso_transfer_fields(config, obj.Configuration);

                S = config.Surface;
                rmp = config.MainPoresRadius;
                hmp = config.MainPoresThickness;
                rde = config.DeadEndRadius;
                hde = config.DeadEndThickness;
                N = config.CellNumber;

                % Section du pore principal
                Smp = @(i) pi*rmp(i)^2;

                % Résistivité au passage de l'air du pore principal
                % sig_mp = @(env) 8*env.air.parameters.eta /(rmp^2); % [4] Table 2
                
                % Demi-pore principal 
                half_main_pore = @(i) classQWL_Circle(classQWL_Circle.create_config(hmp/2, rmp(i)));
                % half_main_pore = @(i) classJCA_Rigid(classJCA_Rigid.create_config(Smp(i), hmp/2, 1, 1, @(env) sig_mp(env, i), rmp(i), rmp(i)));
                
                % Cellule annulaire (common pore + annular cavity)
                annular_cell = @(i) classannularcell(classannularcell.create_config(rmp(i), rmp(i+1), rde, hde));

                % Rayonnement
                s = @(i) Smp(i)/S; % Porosité apparente
                % hend = @(i) 0;
                hend = @(i) 0.48*sqrt(pi)*rmp(i)*(1-1.14*sqrt(s(i)));
                end_effect = @(i) classQWL_Circle(classQWL_Circle.create_config(hend(i), rmp(i)));
                % end_effect = @(i) classJCA_Rigid(classJCA_Rigid.create_config(Smp(i), hend(i), 1, 1, sig_mp, rmp(i), rmp(i)));

                obj.Configuration.ListOfObjects{end+1} = end_effect(1);
                % obj.Configuration.ListOfObjects{end+1} = half_main_pore(1);

                % Boucle sur les cavités et plaques
                for i = 1:N - 1

                    obj.Configuration.ListOfObjects{end+1} = half_main_pore(i);
                    % obj.Configuration.ListOfObjects{end+1} = end_effect(i);
                    obj.Configuration.ListOfObjects{end+1} = annular_cell(i); 
                    obj.Configuration.ListOfObjects{end+1} = half_main_pore(i+1);
                end
                
                obj.Configuration.ListOfObjects{end+1} = half_main_pore(end);
                obj.Configuration.ListOfObjects{end+1} = annular_cell(end);
                obj.Configuration.ListOfObjects{end+1} = end_effect(end);
            end 
        end
    end

    methods (Static, Access = public)

        function config = create_config(radius, main_pore_radius, main_pore_thickness, dead_end_radius, dead_end_thickness, cell_number)
            
            config = {};
            config.Radius = radius;
            config.Surface = pi*radius^2;
            config.MainPoresRadius = main_pore_radius;
            config.MainPoresThickness = main_pore_thickness;
            config.DeadEndRadius = dead_end_radius;
            config.DeadEndThickness = dead_end_thickness;
            config.CellNumber = cell_number;
        end
    
        function validate(env)

            perso_figure('Validation classMultiAnnular')
          
            % subplot(2, 1, 1)
            title('Matériau multi-pancakes à profil constant')
            hold on

            % création de l'objet de classe
            N = 15;
            MultiAnnular_QWL = classMultiAnnular(classMultiAnnular.create_config(14.5e-3, repmat(2e-3, 1, N+1), 1e-3, 13e-3, 1e-3, N));

            % % Debog : Comparaison entre les admittances de surface des cavités annulaires avec Hankel et avec l'approximation volumique
            % perso_figure('Debog - classannularcavity_cylindrical dans classMultiAnnular/validation - Zs_Hankel / Zs_Volume');
            % annular_cavity = MultiAnnular.Configuration.ListOfObjects{3}.Configuration.ListOfObjects{2}.Configuration.JunctionElement;
            % perso_plot_surface_impedance(annular_cavity.surface_impedance(env), env, 'Hankel');
            % annular_cavity.Configuration.CavityModel = 'Volume';
            % perso_plot_surface_impedance(annular_cavity.surface_impedance(env), env, 'Volume');

            alpha_model = MultiAnnular_QWL.alpha(env);
            
            % importation des données de références
            data_mes = readmatrix('validation classMultiAnnular Dupont2018 fig5 black.txt');
            [x_data_mes, y_data_mes] = perso_interpole_et_lisse(data_mes(:, 1), data_mes(:, 2), 1000, 0.05);

            data_mod = readmatrix('validation classMultiAnnular Dupont2018 fig5 blue.txt');
            [x_data_mod, y_data_mod] = perso_interpole_et_lisse(data_mod(:, 1), data_mod(:, 2), 1000, 0.05); 

            plot(env.w/ (2*pi), alpha_model, 'Color', 'g', 'LineWidth', 1, 'DisplayName', 'Prédiction du code analytique');
            plot(x_data_mes, y_data_mes, 'Color', 'k','LineWidth', 1, 'LineStyle', '--', 'DisplayName', 'Résultat expérimental de référence');
            % plot(x_data_mod, y_data_mod, 'Color', 'b','LineWidth', 1, 'LineStyle', '--', 'DisplayName', 'Données de références - Modèle');
            
            perso_configure_alpha_figure(4000);

            %% Validation profil décroissant

            % subplot(2, 1, 2)
            title('Matériau multi-pancakes à profil décroissant')
            hold on   

            %% Données de référence : A microstructure material design for low frequency sound absorption, fig.3

            % création de l'objet de classe
            N = 15;
            MultiAnnular_QWL = classMultiAnnular_QWL(classMultiAnnular.create_config(22.2e-3, perso_interp_config({{4e-3, 0.5e-3, 15, 1}}, 15), 1e-3, 21e-3, 1e-3, N));
            alpha_model = MultiAnnular_QWL.alpha(env);

            % importation des données de références
            data_mes = readmatrix('validation classMultiAnnular Bezançon2024 fig5b black.txt');
            [x_data_mes, y_data_mes] = perso_interpole_et_lisse(data_mes(:, 1), data_mes(:, 2), 1000, 0.05);

            data_mod = readmatrix('validation classMultiAnnular Bezançon2024 fig5b blue.txt');
            [x_data_mod, y_data_mod] = perso_interpole_et_lisse(data_mod(:, 1), data_mod(:, 2), 1000, 0.05);

            plot(env.w/ (2*pi), alpha_model, 'Color', 'g', 'LineWidth', 1, 'DisplayName', 'Prédiction du code analytique');
            plot(x_data_mes, y_data_mes, 'Color', 'k','LineWidth', 1, 'LineStyle', '--', 'DisplayName', 'Résultat expérimental de référence');
            % plot(x_data_mod, y_data_mod, 'Color', 'b','LineWidth', 1, 'LineStyle', '--', 'DisplayName', 'Données de références - Modèle');

            perso_configure_alpha_figure(4000);
        end
    end

    methods (Static, Access = private)

        function d = radiusMLPSBH(black_hole_length, first_perforated_area_radius, last_perforated_area_radius, order)
            % RADIUSMLPSBH Retourne une fonction handle pour calculer le profil du rayon d'un trou noir acoustique.
            %
            % Syntaxe:
            %   d = RADIUSMLPSBH(black_hole_length, first_perforated_area_radius, last_perforated_area_radius, order)
            %
            % Description:
            %   RADIUSMLPSBH génère une fonction handle qui calcule le rayon d'un trou noir acoustique en fonction de la position 
            %   sur l'axe des abscisses. Cette fonction est utilisée pour modéliser la variation du rayon à l'intérieur du trou noir 
            %   en fonction de sa longueur et des rayons de la zone perforée.
            %
            % Paramètres d'entrée:
            %   black_hole_length - (double) Longueur totale du trou noir acoustique (L).
            %   first_perforated_area_radius - (double) Rayon de la première zone perforée (rin).
            %   last_perforated_area_radius - (double) Rayon de la dernière zone perforée (rend).
            %   order - (double) Ordre du polynôme utilisé pour modéliser la variation du rayon (n).
            %
            % Paramètres de sortie:
            %   d - (function handle) Fonction handle qui prend en entrée une position sur l'axe des abscisses (x_position) 
            %       et retourne le rayon correspondant du trou noir acoustique.
            %
            % Exemple:
            %   % Créer un handle de fonction pour un trou noir acoustique
            %   d = RADIUSMLPSBH(10, 2, 5, 2);
            %   % Calculer le rayon à la position x = 4
            %   radius_at_x4 = d(4);
            %
            % Voir aussi: create_config
            %
            % Auteur: Lucas Barbier
            % Date:  29 Août 2024
            
            L = black_hole_length;
            rin = first_perforated_area_radius;
            rend = last_perforated_area_radius;
            n = order;
            d = @(x_position) (rin - rend)/L^n * abs(x_position - L)^n + rend;
            
        end
    end
end
