classdef classcavity_trapezoidal< classcavity

%% Références

% [1]
% Titre : Modification of the transfer matrix method for the sonic black hole and broadening effective absorption band
% DOI : 10.1016/j.ymssp.2024.111660
% URL : https://linkinghub.elsevier.com/retrieve/pii/S0888327024005582
    
    methods 

        function obj = classcavity_trapezoidal(config) 
            
            obj@classcavity(config);
        end

        function T = transfermatrix(obj, air, w)

            % dérivé de [1] eq. 7

            param = air.parameters;
            c0 = param.c0;
            k0 = w ./ c0;
            Z0 = c0 * param.rho;

            % Paramètres géométriques
            config = obj.Configuration;
            d = config.Thickness;
            wi = config.WidthIn;
            di = config.DepthIn;
            wo = config.WidthOut;
            do = config.DepthOut;
            
            Lz = d * wi / (wi - wo); % Distance orthogonale entre la surface et le sommet du cône de la cavité
            kd = k0 .* d;
            kl = k0 .* Lz;
            R = sqrt(wo*do / (wi*di)); % le ratio des rayons de sortie et d'entrée
            Si = wi*di; % la section d'entrée de la cavité

            T.T11 = R .* cos(kd) + 1 ./ (kl) .* sin(kd);
            T.T12 = 1j * Z0 * R .* sin(kd);
            T.T21 = 1j * Si / Z0 * ((R + 1 ./ (kl).^2) .* sin(kd) - d ./ (k0 * Lz^2) .* cos(kd));
            T.T22 = 1 / R * (cos(kd) - 1 ./ kl .* sin(kd));
        end

        function Zs = surfaceimpedance(obj, Air, w)

            T = obj.transfermatrix(Air, w);
            Zs = T.T11 ./ T.T21;
        end
    end

    methods (Static, Access = public)

        function config = create_config(cavity_thickness, width_in, depth_in, width_out, depth_out) 
            
            config.Thickness = cavity_thickness; 
            config.WidthIn = width_in;
            config.DepthIn = depth_in;
            config.WidthOut = width_out; 
            config.DepthOut = depth_out;
            config.Section = (width_in+width_out)/2 * (depth_in+depth_out)/2;
        end
    end
end