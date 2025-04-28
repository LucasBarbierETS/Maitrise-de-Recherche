classdef classMLPSBH_Cylindrical < classelement

% References: 
%
% [1] A broadband and low-frequency sound absorber of sonic black holes with multi-layered micro-perforated panels
%     https://doi.org/10.1016/j.apacoust.2023.109817
% [2] Thin metamaterial using acoustic black hole profiles for broadband sound absorption
%     https://doi.org/10.1016/j.apacoust.2023.109744
% [3] Propagation of sound in porous media, Atalla, Allard
%
% Description
%
% Cette classe d'objet fait partie du groupe des classes d'élements fermés
%
% 'classMLPSBH' object is a sonic-black-hole (SBH) structure built 
% with multi-layered perforated plates and annular cavities (MLP)
% 'classMLPSBH' takes as input a structure (config) containing:
%       - config.CavitiesRadius : the radius of the annular cavities 
% 		- config.PlatesPerforatedAreaRadius : a vector containing the plate-perforated-area-radius of each plate
% 		- config.PlatesPorosity : a vector containing the porosity of the perforated part of each plate
% 		- config.PlatesHolesRadius : a vector containing the radius of holes of each plate
% 		- config.PlatesThickness : a vector containing the thickness of each plate	
% 		- config.HankelModelUsed : (boolean) 'true' for Hankel's model, 'false' for low frequency approximation (see classannularcavity)	
%       - config.CommonPoresUsed : (boolean) 'true' if common pores are used 'false' if not
%
% Chaque plaque est succédée par une cavité et la structure se termine par un fond rigide.
% La correction de longueur interne des MPP est désactivée, les termes correctifs sont ajoutés manuellement.
% Avec cette classe les corrections de longueur associées aux plaques remplace les common pores. Les cavités annulaires sont introduites directement 
% sans passer par 'classannularcell'. 

    properties

        Type = 'Cylindrical MLPSBH'

        % Configuration (Héritée)
        %
        % Attributs de la configuration de classe :
        %
        % - Configuration.ListOfSubelements
        % - Configuration.EndStatus
        % - Configuration.InputSection
        % - Configuration.OutputSection
        %
        % Attributs de la configuration d'appel :
        %
        % - Configuration.CavitiesRadius : (double) radius of the sample
        % - Configuration.PlatesPerforatedAreaRadius : (double) plate-perforated-area-radius of each plate
        % - Configuration.PlatesPorosity : (double) porosity of the perforated part of each plate
        % - Configuration.PlatesHolesRadius :  (double) radius of holes of each plate
        % - Configuration.PlatesThickness : (double) thickness of each plate	
        % - Configuration.CavitiesThickness : (double) thickness of each annular cavity
        % - Configuration.CavitiesModel : (boolean) 'true' for Hankel's model, 'false' for low frequency approximation (see classannularcavity)	
        % - Configuration.CommonPoresUsed : (boolean) 'true' if common pores are used 'false' if not

    end
    
%% Methods

    methods (Access = public)

        function obj = classMLPSBH_Cylindrical(config)
        
        % Appel du constructeur de la classe parente
        obj@classelement(classelement.create_config({}, 'closed'));
           
        if nargin > 0    
            % Tranfert des champs de la configuration d'appel vers la configuration de classe
            obj.Configuration = transferFields(config, obj.Configuration);

            % Paramètres géométriques et physiques
            SBHr = config.SBHRadius;
            cavr = config.CavitiesRadius;
            ppar = config.PlatesPerforatedAreaRadius;
            pp = config.PlatesPorosity;
            hr = config.PlatesHolesRadius;
            pt = config.PlatesThickness;
            ct = config.CavitiesThickness;
            ptc = config.PlatesThicknessCorrection;
            
            % Modèles et options
            cm = config.CavitiesModel;
            
            % Mise à jour de section d'entrée et de sortie
            obj.Configuration.InputSection = pi*SBHr^2;
            
            % Plaque perforée centrale (première MPP circulaire)
            obj.Configuration.ListOfSubelements{end+1} = classMPP_Circular(classMPP_Circular.create_config(pp(1), hr(1), pt(1), pi*ppar(1)^2, ptc(1)));
            % obj.Configuration.ListOfSubelements{end+1} = classMPP_Circular(classMPP_Circular.create_config(pp(1), hr(1), pt(1), pi*ppar(1)^2));
            
            % Boucle sur les cavités et plaques
            for i = 1:length(ct) - 1

                mpr = (ppar(i) + ppar(i+1)) / 2;

                 % Cavité annulaire
                annular_cavity = classannularcavity(classannularcavity.create_config(mpr, cavr, ct(i), cm));
                obj.Configuration.ListOfSubelements{end+1} = classjunction_cylindrical(classjunction_cylindrical.create_config(annular_cavity, mpr, ct(i)));
            
                % % Cavité annulaire ou jonction cylindrique
                % obj.Configuration.ListOfSubelements{end+1} = classannularcell(classannularcell.create_config(ppar(i), ppar(i+1), cavr, ct(i), cm));
            
                % MPP suivante
                obj.Configuration.ListOfSubelements{end+1} = classMPP_Circular(classMPP_Circular.create_config(pp(i+1), hr(i+1), pt(i+1), pi*ppar(i+1)^2, ptc(i+1)));
                % obj.Configuration.ListOfSubelements{end+1} = classMPP_Circular(classMPP_Circular.create_config(pp(i+1), hr(i+1), pt(i+1), pi*ppar(i+1)^2));
            end
            
            % Traitement de la dernière cavité
            obj.Configuration.ListOfSubelements{end+1} = classcavity(classcavity.create_config(ct(end), pi*cavr^2)); 
        end 
        end
    end

    methods (Static, Access = public)

        function validate()

            close all
            figure()
            title('Valiation Cylindrical MLPSBH')
            hold on   

            % création de l'environnement
            env = create_environnement(23, 100800, 22, 1, 6000, 1000);

            % %% Cavité cylindrique multi-annulaire avec profil décroissant
            % 
            % % Données de référence : Modification of the transfer matrix method for 
            % % the sonic black hole and broadening effective absorption band, fig. 7, p. 8
            % 
            % % data_path = ['C:\Users\Utilisateur\OneDrive - ETS\CRIAQ-REAR\Maitrise LB\' ...
            % %              'Classes\MPP_Classes\Validation\Laly2017\fig. 3.5\'];
            % 
            % subplot(1, 2, 1)
            % hold on
            % 
            % % Paramètres de la configuration (sect. 3.1, p. 7)
            % n = 1;
            % MLBr = 30e-3;
            % cavr = 30e-3;
            % L = 100e-3;
            % rend = 2e-3;
            % N = [10 20 30 40];
            % d = L ./ N;
            % 
            % % Prise en compte d'un facteur dissipatif dans l'air (sect. 3.1)
            % % env.air.parameters.c0 = env.air.parameters.c0 * (1 + 0.05* 1j);
            % 
            % for i = 1:length(N)
            % 
            %     MLBSBH = classMLBSBH_Cylindrical(classMLBSBH_Cylindrical.create_config(MLBr, cavr, {cavr, rend, n}, 1, 0, 0, d(i), 'Hankel', 'Bezançon', false, N(i)));
            %     plot(env.w / (2*pi), MLBSBH.alpha(env),'DisplayName', [num2str(N(i)), 'cavités']);
            %     % MLBSBH.disp_subelements_parameters_table(env)
            % end
            % 
            % xlabel("Fréquence (Hz)")
            % ylabel("Coefficient d'Absorption")
            % ylim([0 1])
            % xlim([0 3000])
            % legend()
            
            %% Données de référence : A microstructure material design for low frequency sound absorption, fig.3

            % création de l'objet de classe
            config = classMLPSBH_Cylindrical.create_config(14.5e-3, 13e-3, 2e-3, ...
            1, 2e-3, 1e-3, 1e-3, 'Hankel', 'Bezançon', false, 15);
            MLPSBH = classMLPSBH_Cylindrical(config);
            % MLPSBH.disp_subelements_parameters_table(env);
            alpha_model = MLPSBH.alpha(env);
            
            % importation des données de références
            data = csvread('Dupont2018.txt');
            [x_data, y_data] = interpole_et_lisse(data(:, 1), data(:, 2), 1000, 0.05);
            
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
        
        function config = create_config(SBH_radius, cavities_radius, plates_perforated_area_radius, plates_porosity, ...
        plates_holes_radius, plates_thickness, cavities_thickness, cavities_model, thickness_correction_method, common_pores_used, varargin)
            % CREATE_CONFIG Crée une configuration pour le constructeur de la classe classMLPSBH_Cylindrical.
            %
            % Syntaxe:
            %   config = create_config(CavitiesRadius, PlatesPerforatedAreaRadius, PlatesPorosity, plates_holes_radius, plates_thickness, cavities_thickness, cavities_model, CorrectionLengthMethod, common_pores_used, numCavities)
            %
            % Description:
            %   Cette méthode publique permet de créer une configuration d'appel pour le constructeur de la classe `classMLPSBH_Cylindrical`.
            %   Elle prend en compte plusieurs paramètres liés aux caractéristiques géométriques et physiques du trou noir acoustique
            %   et des cavités, en fonction desquels elle génère une configuration complète.
            %
            % Paramètres d'entrée:
            %   CavitiesRadius - (double) Rayon interne des cavitiés.
            %
            %   PlatesPerforatedAreaRadius - Peut prendre plusieurs formes :
            %       - (double) Rayon uniforme de toutes les plaques perforées.
            %       - (cell) {rin, rend, order} : Paramètres pour générer un profil de rayon des plaques (premier rayon, dernier rayon, ordre).
            %       - (double array) [r1, ..., rN] : Rayons spécifiques de chaque plaque.
            %
            %   PlatesPorosity - Peut prendre plusieurs formes :
            %       - (double) Porosité uniforme de toutes les plaques.
            %       - (double array) [phi1, ..., phiN] : Porosités spécifiques de chaque plaque.
            %
            %   plates_holes_radius - Peut prendre plusieurs formes :
            %       - (double) Rayon uniforme des trous pour toutes les plaques.
            %       - (double array) [hr1, ..., hrN] : Rayons spécifiques des trous pour chaque plaque.
            %
            %   plates_thickness - Peut prendre plusieurs formes :
            %       - (double) Épaisseur uniforme de toutes les plaques.
            %       - (double array) [pt1, ..., ptN] : Épaisseurs spécifiques de chaque plaque.
            %
            %   cavities_thickness - Peut prendre plusieurs formes :
            %       - (double) Épaisseur uniforme de toutes les cavités.
            %       - (double array) [ct1, ..., ctN] : Épaisseurs spécifiques de chaque cavité.
            %
            %   cavities_model - (string) Modèle utilisé pour les cavités :
            %       - 'hankel' : Modèle de Hankel.
            %       - 'volume' : Modèle d'admittance basé sur le volume.
            %
            %   CorrectionLengthMethod - (string) Méthode de correction de longueur :
            %       - 'none' : Aucune correction.
            %       - 'intern' : Utilisation de la méthode interne de `classMPP`.
            %       - 'bezancon' : Méthode de Bézançon.
            %       - 'chen' : Méthode de Chen.
            %
            %   common_pores_used - (boolean) Indique si des pores communs sont utilisés :
            %       - true : Pores communs utilisés.
            %       - false : Pores communs non utilisés.
            %
            %   numCavities (varargin) - (int) Nombre de cavités (paramètre supplémentaire).
            %
            % Paramètres de sortie:
            %   config - (struct) Structure contenant la configuration complète pour le constructeur de la classe `classMLPSBH_Cylindrical`.
            %
            % Exemple:
            %   % Créer une configuration avec un rayon de SBH de 10, un modèle de cavités 'hankel', et 5 cavités
            %   config = create_config(10, 5, [2, 3, 1], 0.2, 0.5, 1, 0.5, 'hankel', 'intern', true, 5);
            %
            % Voir aussi: classMLPSBH_Cylindrical, classMPP, classannularcavity
            
            % Code
            config = {};
            config.SBHRadius = SBH_radius;
            config.CavitiesRadius = cavities_radius;
            config.ThicknessCorrectionMethod = thickness_correction_method;
            config.CavitiesModel = cavities_model;
            config.CommonPoresUsed = common_pores_used;
            
            % Gestion des épaisseurs des plaques
            if isscalar(plates_thickness)
                config.PlatesThickness = repmat(plates_thickness, 1, varargin{1});
            else 
                config.PlatesThickness = plates_thickness;
            end
            
            % Gestion des épaisseurs des cavités
            if isscalar(cavities_thickness)
                config.CavitiesThickness = repmat(cavities_thickness, 1, varargin{1});
            else 
                config.CavitiesThickness = cavities_thickness;
            end
            
            % Rayon des plaques perforées
            L = sum(config.PlatesThickness) + sum(config.CavitiesThickness); % Longueur totale de SBH
            
            if iscell(plates_perforated_area_radius)  % Cas 2
                config.PlatesPerforatedAreaRadius = [plates_perforated_area_radius{1}]; % x_position = 0
                r = profilMLPSBH(L, plates_perforated_area_radius{1}, plates_perforated_area_radius{2}, plates_perforated_area_radius{3});
                for i = 1:varargin{1} - 1 
                    x_position = sum(config.PlatesThickness(1:i)) + sum(config.CavitiesThickness(1:i));
                    config.PlatesPerforatedAreaRadius =  [config.PlatesPerforatedAreaRadius r(x_position)];
                end 
            elseif isscalar(plates_perforated_area_radius) % Cas 1
                config.PlatesPerforatedAreaRadius = repmat(plates_perforated_area_radius, 1, varargin{1});    
            else % Cas 3
                config.PlatesPerforatedAreaRadius = plates_perforated_area_radius;
            end
            
            % Rayon des trous
            if isscalar(plates_holes_radius)
                config.PlatesHolesRadius = repmat(plates_holes_radius, 1, varargin{1});
            else 
                config.PlatesHolesRadius = plates_holes_radius;
            end
            
            % Porosité
            if isscalar(plates_porosity)
                config.PlatesPorosity = repmat(plates_porosity, 1, varargin{1});
            else
                config.PlatesPorosity = plates_porosity;
            end 

            % Longueur de correction

            config = add_thickness_correction(config);
        end
    
        function disp_config(config)

            % Afficher les attributs globaux
            global_fields = {'CavitiesRadius', 'CavitiesModel', 'ThicknessCorrectionMethod', 'CommonPoresUsed'};
            for i = 1:numel(global_fields)
                field = global_fields{i};
                value = config.(field);
        
                % Afficher la valeur en fonction de son type
                if isnumeric(value) || islogical(value)
                    if strcmp(field, 'CavitiesRadius')
                        value_str = sprintf('%.2f mm', value * 10^3);
                    else
                        value_str = mat2str(value);
                    end
                elseif ischar(value)
                    value_str = value;
                elseif iscell(value)
                    value_str = ['{' strjoin(cellfun(@mat2str, value, 'UniformOutput', false), ', ') '}'];
                else
                    value_str = 'Unsupported type';
                end
                fprintf('%s: %s\n', field, value_str);
            end
        
            % Afficher les attributs vectoriels en tableau
            vector_fields = {'PlatesThickness', 'CavitiesThickness', 'PlatesPerforatedAreaRadius', 'PlatesHolesRadius', 'PlatesPorosity', 'PlatesThicknessCorrection'};
        
            % Initialiser une table pour les attributs vectoriels
            vector_table = table();
        
            % Remplir la table avec les valeurs des attributs vectoriels
            for i = 1:numel(vector_fields)
                field = vector_fields{i};
                value = config.(field);
                if isvector(value)
                    vector_table.(field) = value(:); % Assurer que c'est une colonne
                else
                    vector_table.(field) = {'Unsupported type'};
                end
            end
        
            % Afficher la table
            disp(vector_table);
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
