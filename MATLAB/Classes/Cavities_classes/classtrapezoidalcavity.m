classdef classtrapezoidalcavity

%% Références

% [1]
% Titre : Modification of the transfer matrix method for the sonic black hole and broadening effective absorption band
% DOI : 10.1016/j.ymssp.2024.111660
% URL : https://linkinghub.elsevier.com/retrieve/pii/S0888327024005582

    properties

        Type = 'Trapezoidal Cavity'

        Thickness % (d) l'épaisseur (suivant z) de la cavité
        WidthIn % (wi) l'épaisseur (selon x) de la cavité à l'entrée
        WidthOut % (wo) l'épaisseur (selon x) de la cavité à la sortie
        Length % (l) l'épaisseur (selon x) de la cavité à l'entrée

    end
    
    methods 

        function obj = classtoroidalcavity(cavity_thickness, width_in, width_out, length) 
            
            obj.Thickness = cavity_thickness; 
            obj.WidthIn = width_in;
            obj.WidthOut = width_out; 
            obj.Length = length; 
        end

        function T = transfermatrix(obj, air, w)

            % dérivé de [1] eq. 7

            param = air.parameters;
            c0 = param.c0;
            k0 = w ./ c0;
            Z0 = c0 * param.rho;

            % Paramètres géométriques

            d = obj.Thickness;
            wi = obj.WidthIn;
            wo = obj.WidthOut;
            l = obj.Length;
            Lz = d * wi / (wi - wo); % Distance orthogonale entre la surface et le sommet du cône de la cavité
            kd = k0 .* d;
            kl = k0 .* Lz;
            R = wo / wi; % le ratio des rayons de sortie et d'entrée
            Si = wi * ;  % la section d'entrée de la cavité

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
end