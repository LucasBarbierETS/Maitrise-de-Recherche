classdef classDoublePorousSlits < classelement

    methods
        function obj = classDoublePorousSlits(config)

            % Paramètres globaux
            input_section = config.InputSection;
            solution_depth = config.CellDepth; % profondeur (solution projetée en 2D)          
            
            % Paramètres de la couche poreuse
            layer_width = config.LayerWidth;
            layer_thickness = config.LayerThickness;
            layer_porosity = config.LayerPorosity;
            layer_tortuosity = config.LayerTortuosity;
            layer_resistivity = config.LayerResistivity;
            viscous_length = config.CaracteristicViscousLength;
            thermal_length = config.CaracteristicThermalLength;
            
            % Paramètres des cavités 
            cavities_thickness = config.CavityThickness;
            cavities_width = config.CavityWidth;
            
            % Paramètres des fentes
            slits_number = config.SlitsNumber;
            slits_thickness = config.SlitsThickness;
            first_slit_width = config.FirstSlitWidth;
            last_slit_width = config.LastSlitWidth;
            
            cell_thickness = cavities_thickness + slits_thickness;

            L = (slits_number - 1) * cell_thickness;
            profil = @(i) feval(profilSBH(L, first_slit_width, last_slit_width, 1), ((i-1) * cell_thickness));
            
            list_of_subelements = {};

            for i = 1:slits_number
                list_of_subelements{end+1} = CellDoubleSlitswPorousLayer( ...
                CellDoubleSlitswPorousLayer.create_config(solution_depth, slits_thickness, ...
                profil(i), profil(i+1), layer_width, layer_porosity, layer_tortuosity, layer_resistivity, ...
                viscous_length, thermal_length, layer_thickness, cavities_thickness, cavities_width));
            end
            
            % Appel du constructeur de la classe parente
            obj@classelement(classelement.create_config(list_of_subelements, 'opened', input_section));

            % On transfert les champs de la structure d'appel vers ceux de
            % a structure de classe
            perso_transfer_fields(config, obj.Configuration); 
        end
    end

    methods (Static)
        function config = create_config(input_section, cell_depth, slits_thickness, slit_number, ...
                first_slit_width, last_slit_width, layer_width, layer_porosity, layer_tortuosity, layer_resistivity, ...
                caracteristic_viscous_length, caracteristic_thermal_length, ...
                layer_thickness, cavity_thickness, cavity_width)

            config = struct();

            % Paramètres globaux
            config.InputSection = input_section;
            config.CellDepth = cell_depth;

            % Paramètres de la couche poreuse
            config.LayerWidth = layer_width;
            config.LayerThickness = layer_thickness;
            config.LayerPorosity = layer_porosity;
            config.LayerTortuosity = layer_tortuosity;
            config.LayerResistivity = layer_resistivity;
            config.CaracteristicViscousLength = caracteristic_viscous_length;
            config.CaracteristicThermalLength = caracteristic_thermal_length; 

            % Paramètres des cavités
            config.CavityThickness = cavity_thickness;
            config.CavityWidth = cavity_width;

            % Paramètres des fentes
            config.SlitsNumber = slit_number;
            config.SlitsThickness = slits_thickness;
            config.FirstSlitWidth = first_slit_width;
            config.LastSlitWidth = last_slit_width;      
        end
    end
end