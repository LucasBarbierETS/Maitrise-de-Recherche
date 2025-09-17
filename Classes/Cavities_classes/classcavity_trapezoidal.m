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

        % function T = transfer_matrix(obj, env)
        % 
        %     % dérivé de [1] eq. 7
        % 
        %     air = env.air;
        %     w = env.w;
        %     param = air.parameters;
        % 
        %     % Modification des propriétés dissipatives de l'air (très peu d'effet)
        %     % c0 = air.parameters.c0;
        %     c0 = air.parameters.c0 * (1+0.05*1j); % perso_ouvrir_lien_Zotero('zotero://open-pdf/library/items/233HZ8GN?page=7&annotation=QLW3FP87')
        % 
        %     k0 = w ./ c0;
        %     Z0 = c0 * param.rho;
        % 
        %     % Paramètres géométriques
        %     config = obj.Configuration;
        %     d = config.Thickness;
        %     wi = config.Width;
        %     di = config.Depth;
        %     wo = config.WidthOut;
        %     do = config.DepthOut;
        % 
        %     Lz = d * wi / (wi - wo); % Distance orthogonale entre la surface et le sommet du cône de la cavité
        %     kd = k0 .* d;
        %     kl = k0 .* Lz;
        %     R = sqrt(wo*do / (wi*di)); % le ratio des rayons de sortie et d'entrée
        %     Si = wi*di; % la section d'entrée de la cavité
        % 
        %     T.T11 = R .* cos(kd) + 1 ./ (kl) .* sin(kd);
        %     T.T12 = 1j * Z0 * R .* sin(kd);
        %     T.T21 = 1j * Si / Z0 * ((R + 1 ./ (kl).^2) .* sin(kd) - d ./ (k0 * Lz^2) .* cos(kd));
        %     T.T22 = 1 / R * (cos(kd) - 1 ./ kl .* sin(kd));
        % end

        function T = transfer_matrix(obj, env)

            % Cavité centrale trapézoïdale (section rectangulaire variable) adaptée de (7)
            % Référence: MTMM conique (Eq. 7) -> remapping r := sqrt(S), S = w*d
            % Si = wi*di, So = wo*do, ri = sqrt(Si), ro = sqrt(So), lz = d*ri/(ri - ro)
            
            % --- Air (faible dissipation optionnelle comme dans l’article) ---
            param = env.air.parameters;
            c0 = param.c0;
            % c0    = param.c0 * (1+0.05*1j);      % même esprit que c = c0(1+j*eta)
            k0    = env.w ./ c0;
            Z0    = c0 * param.rho;
        
            % --- Géométrie trapézoïdale (rectangulaire) ---
            cfg = obj.Configuration;
            d   = cfg.Thickness;   % longueur axiale de la cavité
            wi  = cfg.Width;       % largeur en entrée
            di  = cfg.Depth;       % "hauteur" en entrée
            wo  = cfg.WidthOut;    % largeur en sortie
            do  = cfg.DepthOut;    % "hauteur" en sortie
        
            % Sections et "rayons d’aire" équivalents
            Si = wi * di;                  % aire d'entrée
            So = wo * do;                  % aire de sortie
            ri = sqrt(Si);
            ro = sqrt(So);
        
            % Cas limite (cylindre): éviter singularité quand ro ~ ri
            tol = 1e-12 * max(1, ri);
            kd  = k0 .* d;
        
            if abs(ro - ri) < tol
                % Tube à section constante: matrice uniforme classique (TMM)
                ckd = cos(kd); skd = sin(kd);
                T11 = ckd;
                T12 = 1j * Z0 / Si .* skd;   % ATTENTION: bien /Si
                T21 = 1j * Si / Z0 .* skd;
                T22 = ckd;
            else
                % "Conique par l’aire" (structure identique à Eq. 7)
                R   = ro / ri;                     % = sqrt(So/Si)
                Lz  = d * ri / (ri - ro);          % sommet équivalent
                klz = k0 .* Lz;
        
                ckd = cos(kd); skd = sin(kd);
        
                T11 = R .* ckd + (1 ./ klz) .* skd;
                % Correction clé: /Si ici (comme la forme rigoureuse de (7))
                T12 = 1j * Z0 * (R ./ Si) .* skd;
                T21 = 1j * Si / Z0 .* ( (R + 1./(klz.^2)) .* skd ...
                                      - (d ./ (k0 .* Lz.^2)) .* ckd );
                T22 = (1 ./ R) .* ( ckd - (1 ./ klz) .* skd );
            end
        
            T.T11 = T11;  T.T12 = T12;
            T.T21 = T21;  T.T22 = T22;
        end

        function Zs = surfaceimpedance(obj, Air, w)

            T = obj.transfer_matrix(Air, w);
            Zs = T.T11 ./ T.T21;
        end
    end

    methods (Static, Access = public)

        function config = create_config(cavity_thickness, width, depth, width_out, depth_out) 
            
            config.Thickness = cavity_thickness; 
            config.Width = width;
            config.Depth = depth;
            config.WidthOut = width_out; 
            config.DepthOut = depth_out;
            config.Section = (width+width_out)/2 * (depth+depth_out)/2;
        end
    end
end