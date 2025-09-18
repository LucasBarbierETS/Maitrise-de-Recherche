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
            
            obj@classsubelement(config);
        end
        
        function T = transfer_matrix(obj, env)
            
            S = obj.Configuration.Section;
            w = env.w;
            air = env.air;
            param = air.parameters;
            c0 = param.c0;
            % c0 = air.parameters.c0 * (1+0.05*1j); % perso_ouvrir_lien_Zotero('zotero://open-pdf/library/items/233HZ8GN?page=7&annotation=QLW3FP87')
            % c0 = air.parameters.c0 * (1+0.01*1j); % perso_ouvrir_lien_Zotero('zotero://open-pdf/library/items/233HZ8GN?page=7&annotation=QLW3FP87')
            k0 = w ./ c0;
            Z0 = c0 * param.rho;
            H = obj.Configuration.Thickness;

            T.T11 = cos(k0 * H);
            T.T12 = 1j * Z0 / S * sin(k0 * H);
            T.T21 = 1j * S / Z0 * sin(k0 * H);
            T.T22 = cos(k0 * H);
        end

        function Zs = surface_impedance(obj, env)

            S = obj.Configuration.Surface;
            T = obj.transfer_matrix(env);
            Zs = S * T.T11 ./ T.T21;
        end
    end

    methods (Static, Access = public)
    
        function config = create_config(surface, thickness)

            config = struct();
            [config.Section, config.Surface] = deal(surface);
            config.Thickness = thickness; 
        end
    end
end