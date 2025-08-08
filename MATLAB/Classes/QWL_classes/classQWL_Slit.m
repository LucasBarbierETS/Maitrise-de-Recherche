classdef classQWL_Slit < classQWL

    % References:

    % [1] Stinson & Champoux, Propagation of sound and the assignment of
    %     shape factors in model porous materials having simple pore geometries
    %     http://asa.scitation.org/doi/10.1121/1.402530
    % [2] Modeling of perforated plates and screens using rigid frame porous models
    %     Noureddine Atallaa, Franck Sgard
    %     doi:10.1016/j.jsv.2007.01.012

    properties

    % Configuration
    
    end
   
    methods
        function obj = classQWL_Slit(config)

            obj@classQWL(config)

            % % Validation des arguments d'entrée
            % if nargin < 3
            %     error('Insufficient input arguments. Provide length, shape, and dimension.');
            % end
            % 
            % % Détermination des facteurs et corrections en fonction de la forme ([1] p.8)
            % if strcmp(shape, "circle")
            %     k0 = 2; 
            %     rh = dimensions; % dimensions = radius
            % 
            % elseif strcmp(shape, "square") 
            % 
            %     k0 = 1.78;
            %     rh = dimensions; % dimensions = side
            % 
            % elseif strcmp(shape, "rectangle")
            % 
            %     if numel(dimensions) ~= 2
            %         error('Dimension for rectangle must be a two-element vector [length, width].');
            %     end
            % 
            %     k0 = 1.78;
            %     rh = 2 * dimensions(1) * dimensions(2) / (dimensions(1) + dimensions(2))
            %
            % else
            %     error('Shape must be one of the following: "circle", "square", "rectangle", "slit".');
            % end
            % 
            % k0 = config.PermeabilityCoefficient;
            % rh = config.HydraulicRadius;
            % 
            % % Définir la résistivité
            % resistivity = @(eta) 4 * k0 * eta / rh^2;
            % 
            % % Appeler le constructeur de la classe parent
            % obj@classJCA_Rigid(classJCA_Rigid.create_config(1, 1, resistivity, rh, rh, length));
            % 
            % % Initialiser les propriétés
            % obj.Dimension = dimensions;
            % obj.Length = length;
            % obj.Shape = shape;
        end
    
        function s = input_section(obj)
            
            config = obj.Configuration;
            s = config.Width * config.Depth;
        end

        function output_model = set_COMSOL_2D_Model(obj, input_model, index, env, varargin)
            output_model = ModelQWL_Slit(obj.Configuration, input_model, index, env, varargin{:});
        end
    end
    
    methods (Static, Access = public)

        function config = create_config(length, width, depth)
        
            config = struct();
            config.Length = length;
            [config.Width, w] = deal(width);
            [config.Depth, d] = deal(depth);
            config.Section = w * d;
            config.PermeabilityCoefficient = 3; % [1] p. 8
            config.HydraulicRadius = width; % [1] p. 8
        end

        function sect = section(obj)

            if obj.Shape == "circle"
                sect = pi * obj.Dimension^2; % obj.Dimension =  radius

            elseif obj.Shape == "square"

                % fprintf('\nclass(obj) : %s\n', class(obj));
                % fprintf('\nclass(obj.Dimension) : %s\n', class(obj.Dimension));
                % fprintf('\nobj.Dimension : %s\n', obj.Dimension);
                
                sect = obj.Dimension.^2; % obj.Dimension = side

                fprintf('\nsect : %s\n', sect);
                
            elseif obj.Shape == "rectangle"

                sect = obj.Dimension(1) * obj.Dimension(2); % obj.Dimension = [length, width]
            end
        end
    end
end