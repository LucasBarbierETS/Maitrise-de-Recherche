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
                rmp = config.MainPoreRadius;
                hmp = config.MainPoreThickness;
                rde = config.DeadEndRadius;
                hde = config.DeadEndThickness;
                N = config.CellNumber;

                % Section du pore principal
                Smp = pi*rmp^2;

                

                % Résistivité au passage de l'air du pore principal
                sig_mp = @(env) 8*env.air.parameters.eta /(hde^2); % [4] Table 2
                
                % Pore principal 
                main_pore = classJCA_Rigid(classJCA_Rigid.create_config(Smp, hmp, 1, 1, sig_mp, rmp, rmp));
                
                % Cellule annulaire (common pore + annular cavity)
                annular_cell = classannularcell(classannularcell.create_config(rmp, rmp, rde, hde));

                % Rayonnement
                s = Smp/S; % Porosité apparente
                hend = 0.48*sqrt(pi)*rmp*(1-1.14*sqrt(s));
                end_effect = classJCA_Rigid(classJCA_Rigid.create_config(Smp, hend, 1, 1, sig_mp, rmp, rmp));

                obj.Configuration.ListOfSubelements{end+1} = end_effect;

                % Boucle sur les cavités et plaques
                for i = 1:N - 1

                    obj.Configuration.ListOfSubelements{end+1} = main_pore;
                    obj.Configuration.ListOfSubelements{end+1} = annular_cell;
                end

                obj.Configuration.ListOfSubelements{end+1} = end_effect;

                % % Changement de section final
                obj.Configuration.ListOfSubelements{end+1} = classsectionchange(classsectionchange.create_config(Smp, S));
            end 
        end
    end

    methods (Static, Access = public)

        function config = create_config(surface, main_pore_radius, main_pore_thickness, dead_end_radius, dead_end_thickness, cell_number)

            
            config = {};
            config.Surface = surface;
            config.MainPoreRadius = main_pore_radius;
            config.MainPoreThickness = main_pore_thickness;
            config.DeadEndRadius = dead_end_radius;
            config.DeadEndThickness = dead_end_thickness;
            config.CellNumber = cell_number;
        end
    
    function validate()

            close all
            figure()
            title('Valiation Cylindrical MLPSBH')
            hold on   

            % création de l'environnement
            env = create_environnement(23, 100800, 22, 1, 6000, 1000);
           
            %% Données de référence : A microstructure material design for low frequency sound absorption, fig.3

            % création de l'objet de classe
            MultiAnnular = classMultiAnnular(classMultiAnnular.create_config(pi*14.5e-3^2, 2e-3, 1e-3, 13e-3, 1e-3, 15));
            alpha_model = MultiAnnular.alpha(env);
            
            % importation des données de références
            data = csvread('Dupont2018.txt');
            [x_data, y_data] = perso_interpole_et_lisse(data(:, 1), data(:, 2), 1000, 0.05);
            
            % affichage des résultats

            % configuration
            % classMLPSBH_Cylindrical.disp_config(config);

            % coefficient d'absorption
            subplot(1, 2, 2);
            hold on
            plot(env.w/ (2*pi), alpha_model, 'Color', 'b', 'LineWidth', 1);
            plot(x_data, y_data, 'Color', 'g','LineWidth', 1, 'LineStyle', '--');
            legend('Modèle', 'Données de références')
            xlabel("Fréquence (Hz)")
            ylabel("Coefficient d'Absorption")
            ylim([0 1])
            subtitle("configuration multi-annulaire -  Dupont2018")
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
