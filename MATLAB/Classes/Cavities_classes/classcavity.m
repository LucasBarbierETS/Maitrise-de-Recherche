classdef classcavity < classsubelement

% REFERENCE : 

%%%%%%%%%%%%%%%%%%%%%%%%% PUBLIC PROPRIETIES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                          INPUT PARAMETERS
% - L : depth of the cavity (m)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%% PUBLIC METHODS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                          OUTPUT PARAMETERS
% - obj.transfer_matrix(w) : coefficients of the equivalent fluid's transfer matrix
%                                 obj.transfermatrix(Air, w).Tij (where (i, j)∈{1, 2}²)
% - obj.Zs(w)              : surface impedence of the equivalent fluid

    properties

        % Configuration (Héritée)
        %              .Thickness % (double) épaisseur de la cavité
        %              .InputSection

    end
    
    methods 

        function obj = classcavity(config) 
            
            if ~isfield(config, 'Section')
                h = msgbox('Le code est en pause dans classcavity : classcavity. OK pour continuer');
                uiwait(h);  % Attendre que l'utilisateur ferme la boîte de dialogue
            end
            
            obj@classsubelement(config);
        end

        function s = input_section(obj)

            config = obj.Configuration;
            if ~isfield(config, 'Width')
                h = msgbox('Le code est en pause dans classcavity : input_section. OK pour continuer');
                uiwait(h);  % Attendre que l'utilisateur ferme la boîte de dialogue
            end
            s = config.Width * config.Depth;
        end
        
        function T = transfer_matrix(obj, env)
            
            S = obj.Configuration.Section;
            w = env.w;
            air = env.air;
            param = air.parameters;
            c0 = param.c0;
            k0 = w ./ c0;
            Z0 = c0 * param.rho;
            L = obj.Configuration.Length;

            T.T11 = cos(k0 * L);
            T.T12 = 1j * Z0 / S * sin(k0 * L);
            T.T21 = 1j * S / Z0 * sin(k0 * L);
            T.T22 = cos(k0 * L);
        end

        function Zs = surface_impedance(obj, env)

            S = obj.Configuration.Surface;
            T = obj.transfer_matrix(env);
            Zs = S * T.T11 ./ T.T21;
        end
    
        function output_model = set_COMSOL_2D_Model(obj, input_model, index, xtlc, ytlc, env)
            output_model = ModelCavity(obj.Configuration, input_model, index, xtlc, ytlc, env);
        end
    end

    methods (Static, Access = public)
    
        function config = create_config(length, width, depth)

            config = struct();
            config.Length = length;
            [config.Width, w] = deal(width);
            [config.Depth, d] = deal(depth);
            config.Section = w * d;
            config.Surface = w * d;
        end

    end
end