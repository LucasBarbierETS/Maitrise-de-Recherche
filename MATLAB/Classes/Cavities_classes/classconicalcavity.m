classdef classconicalcavity < classsubelement

% Références
%
% [1]
% Titre : Modification of the transfer matrix method for the sonic black hole and broadening effective absorption band
% DOI : 10.1016/j.ymssp.2024.111660
% URL : https://linkinghub.elsevier.com/retrieve/pii/S0888327024005582

    properties

        Type = 'Conical Cavity'

        % Configuration (Héritée)
        %              .Thickness % l'épaisseur de la cavité
        %              .RadiusIn  % le rayon d'entrée de la cavité toroïdale
        %              .RadiusOut % le rayon de sortie de la cavité toroïdale
        %              .InputSection
        %              .OutputSection

    end
    
    methods 

        function obj = classconicalcavity(config) 
            
            obj@classsubelement(config);
        end

        function T = transfer_matrix(obj, env)

            % [1] eq. 7, p. 3

            param = env.air.parameters;
            c0 = param.c0;
            k0 = env.w ./ c0;
            Z0 = c0 * param.rho;

            % Paramètres géométriques (voir [1], fig. 4, p. 5)
            config = obj.Configuration;
            d = config.Thickness;
            ri = config.RadiusIn;
            ro = config.RadiusOut;
            Lz = d * ri / (ri - ro); % Distance orthogonale entre la surface et le sommet du cône de la cavité
            kd = k0 .* d;
            klz = k0 .* Lz;
            R = ro / ri; % le ratio des rayons de sortie et d'entrée
            Si = pi * ri^2;  % la section d'entrée de la cavité

            T.T11 = R .* cos(kd) + 1 ./ (klz) .* sin(kd);
            T.T12 = 1j * Z0 * R / Si .* sin(kd);
            T.T21 = 1j * Si / Z0 * ((R + 1 ./ (klz).^2) .* sin(kd) - d ./ (k0 * Lz^2) .* cos(kd));
            T.T22 = 1 / R * (cos(kd) - 1 ./ klz .* sin(kd));
        end

        function Zs = surface_impedance(obj, env)

            S = obj.Configuration.InputSection;
            T = obj.transfer_matrix(env);
            Zs = S * T.T11 ./ T.T21;
        end
    end

    methods (Static, Access = public)

        function config = create_config(cavity_thickness, radius_in, radius_out)

            config = struct();
            config.Thickness = cavity_thickness; 
            config.RadiusIn = radius_in;
            config.RadiusOut = radius_out;
            config.InputSection = pi*radius_in^2;
            config.OutputSection = pi*radius_out^2;
        end
    end

end