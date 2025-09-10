classdef sol_bf < classelement
    
    methods

        function obj = sol_bf(config)

            % Appel du constructeur de la classe parente
            obj@classelement(classelement.create_config({}, 'closed'));
               
            if nargin > 0    
                % Transfert des champs de la configuration d'appel vers la configuration de classe
                obj.Configuration = perso_transfer_fields(config, obj.Configuration);
    
                cw = config.CavitiesWidth;
                cd = config.CavitiesDepth;
                sw = config.SlitsWidth;
                tpp = config.TopPlatePorosity;
                tphr = config.TopPlateHolesRadius;
                pt = config.PlatesThickness;
                ct = config.CavitiesThickness;

                hl = config.HighLevel;

                % (Par la suite on pourra ajouter un mesh grid par dessus la
                % solution)

                % On créer la première cellule contenant une plaque
                % perforée
                if length(sw) > 1
                    
                    obj.Configuration.ListOfSubelements{end+1} = CellMPP(CellMPP.create_config(tpp, tphr, pt(1), ...
                    ct(1), cd, cw, sw(1), sw(2), hl));
                    
                    % On ajoute péridiquement les cellules contenant des fentes
                    for i = 1:length(sw) - 1
                        obj.Configuration.ListOfSubelements{end+1} = CellSlit(CellSlit.create_config(pt(i), ct(i), cd, cw, sw(i), sw(i+1)));
                    end
                else
                    
                    obj.Configuration.ListOfSubelements{end+1} = CellMPP(CellMPP.create_config(tpp, tphr, pt(1), ...
                    ct(1), cd, cw, sw(1), sw(1), hl));
                end 
            end
        end
   
        function output_model = set_COMSOL_2D_Model(obj, input_model, index, env)
            output_model = ModelSol_BF(obj.Configuration, input_model, index, env);
        end

        
        function obj = launch_comsol_3D_model(obj)

            env = create_environnement(28, 108000, 50, 1, 5000, 200, 130);
            model = ModelSol_BF_3D(obj.Configuration, env);
            obj.Configuration.Comsol3DModel = model;
        end
    end

    methods (Static, Access = public)

        function config = create_config(input_section, number_of_plates, cavities_depth, ...
                 cavities_width, slits_width, top_plate_porosity, top_plate_holes_radius, ...
                 plates_thickness, cavities_thickness, cavities_model, ...
                 thickness_correction_method, common_pores_used, high_level)

            config = {};
            config.InputSection = input_section;
            config.EndStatus = 'closed';
            config.NumberOfPlates = number_of_plates;

            % Paramètres des méthodes
            config.ThicknessCorrectionMethod = thickness_correction_method;
            config.CavitiesModel = cavities_model;
            config.CommonPoresUsed = common_pores_used;
            config.HighLevel = high_level;

            % Paramètres globaux
            config.CavitiesDepth = cavities_depth;
            config.CavitiesWidth = cavities_width;
            config.TopPlateHolesRadius = top_plate_holes_radius;
            config.TopPlatePorosity = top_plate_porosity;

            % Paramètres variables en fonction des cellules
            
            config.PlatesThickness = perso_interp_config(plates_thickness, number_of_plates);
            config.CavitiesThickness = perso_interp_config(cavities_thickness, number_of_plates);
            config.SlitsWidth = perso_interp_config(slits_width, number_of_plates);
        end
    end
end

