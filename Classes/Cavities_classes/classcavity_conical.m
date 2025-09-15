classdef classcavity_conical < classcavity

% Références
%
% [1]
% Titre : Modification of the transfer matrix method for the sonic black hole and broadening effective absorption band
% DOI : 10.1016/j.ymssp.2024.111660
% URL : https://linkinghub.elsevier.com/retrieve/pii/S0888327024005582
    
    methods 

        function obj = classcavity_conical(config) 
            
            obj@classcavity(config);
        end

        function T = transfer_matrix(obj, env)

            % [1] eq. 7, p. 3

            param = env.air.parameters;
            c0 = param.c0;
            % c0 = air.parameters.c0 * (1+0.05*1j); % perso_ouvrir_lien_Zotero('zotero://open-pdf/library/items/233HZ8GN?page=7&annotation=QLW3FP87')
            % c0 = air.parameters.c0 * (1+0.01*1j); % perso_ouvrir_lien_Zotero('zotero://open-pdf/library/items/233HZ8GN?page=7&annotation=QLW3FP87')
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