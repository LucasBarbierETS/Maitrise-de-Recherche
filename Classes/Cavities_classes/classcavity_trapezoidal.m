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

        function T = transfer_matrix(obj, env)

            % dérivé de [1] eq. 7

            air = env.air;
            w = env.w;
            param = air.parameters;

            % Modification des propriétés dissipatives de l'air (très peu d'effet)
            c0 = air.parameters.c0;
            % c0 = air.parameters.c0 * (1+0.05*1j); % perso_ouvrir_lien_Zotero('zotero://open-pdf/library/items/233HZ8GN?page=7&annotation=QLW3FP87')

            k0 = w ./ c0;
            Z0 = c0 * param.rho;

            % Paramètres géométriques
            config = obj.Configuration;
            d = config.Thickness;
            wi = config.Width;
            di = config.Depth;
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

        % function T = transfer_matrix(obj, env)
        %     % Cavité trapézoïdale (rectangle de taille variable) -> forme fermée type MTMM (Eq. 7)
        %     % Remapping conique par l’aire : r := sqrt(S), S = w*d
        %     % Cas limite ro ~ ri : tube à section constante (Si)
        % 
        %         % --- Fluide ---
        %         param = env.air.parameters;
        %         c0    = param.c0;               % comme ta version conique validée
        %         % c0  = param.c0 * (1+0.05*1j); % (optionnel) légère dissipation
        %         k0    = env.w ./ c0;
        %         Z0    = c0 * param.rho;
        % 
        %         % --- Géométrie trapézoïdale (rectangulaire) ---
        %         cfg = obj.Configuration;
        %         d   = cfg.Thickness;     % longueur axiale de la cavité
        %         wi  = cfg.Width;         % largeur entrée
        %         di  = cfg.Depth;         % hauteur/profondeur entrée
        %         wo  = cfg.WidthOut;      % largeur sortie
        %         do  = cfg.DepthOut;      % hauteur/profondeur sortie
        % 
        %         % Aires d'entrée/sortie et "rayons d’aire"
        %         Si = wi * di;            % section d'entrée
        %         So = wo * do;            % section de sortie
        %         ri = sqrt(Si);
        %         ro = sqrt(So);
        % 
        %         % Paramètres d'onde
        %         kd = k0 .* d;
        % 
        %         if abs(ro - ri) < 1e-3 * ri
        %             % ---- Cas limite : section constante = Si (cylindre) ----
        %             ckd = cos(kd);
        %             skd = sin(kd);
        % 
        %             T11 = ckd;
        %             T12 = 1j * Z0 / Si .* skd;   % ATTENTION: /Si
        %             T21 = 1j * Si / Z0 .* skd;
        %             T22 = ckd;
        % 
        %         else
        %             % ---- Forme fermée type conique via r = sqrt(S) ----
        %             R   = ro / ri;               % = sqrt(So/Si)
        %             Lz  = d * ri / (ri - ro);    % "sommet" équivalent par l’aire
        %             klz = k0 .* Lz;
        % 
        %             ckd = cos(kd);
        %             skd = sin(kd);
        % 
        %             T11 = R .* ckd + 1 ./ klz .* skd;
        %             T12 = 1j * Z0 * (R ./ Si) .* skd;                                  % (/Si corrigé)
        %             T21 = 1j * Si / Z0 .* ( (R + 1 ./ (klz.^2)) .* skd ...
        %                                   - (d ./ (k0 .* Lz.^2)) .* ckd );
        %             T22 = (1 ./ R) .* ( ckd - 1 ./ klz .* skd );
        %         end
        % 
        %         % Sortie au format struct
        %         T.T11 = T11;  T.T12 = T12;
        %         T.T21 = T21;  T.T22 = T22;
        %     end

        % function T = transfer_matrix(obj, env) % mieux mais still pas ouf
        % 
        %     % Cavité centrale trapézoïdale (section rectangulaire variable) adaptée de (7)
        %     % Référence: MTMM conique (Eq. 7) -> remapping r := sqrt(S), S = w*d
        %     % Si = wi*di, So = wo*do, ri = sqrt(Si), ro = sqrt(So), lz = d*ri/(ri - ro)
        % 
        %     % --- Air (faible dissipation optionnelle comme dans l’article) ---
        %     param = env.air.parameters;
        %     c0 = param.c0;
        %     % c0    = param.c0 * (1+0.05*1j);      % même esprit que c = c0(1+j*eta)
        %     k0    = env.w ./ c0;
        %     Z0    = c0 * param.rho;
        % 
        %     % --- Géométrie trapézoïdale (rectangulaire) ---
        %     cfg = obj.Configuration;
        %     d   = cfg.Thickness;   % longueur axiale de la cavité
        %     wi  = cfg.Width;       % largeur en entrée
        %     di  = cfg.Depth;       % "hauteur" en entrée
        %     wo  = cfg.WidthOut;    % largeur en sortie
        %     do  = cfg.DepthOut;    % "hauteur" en sortie
        % 
        %     % Sections et "rayons d’aire" équivalents
        %     Si = wi * di;                  % aire d'entrée
        %     So = wo * do;                  % aire de sortie
        %     ri = sqrt(Si);
        %     ro = sqrt(So);
        % 
        %     % Cas limite (cylindre): éviter singularité quand ro ~ ri
        %     tol = 1e-12 * max(1, ri);
        %     kd  = k0 .* d;
        % 
        %     if abs(ro - ri) < tol
        %         % Tube à section constante: matrice uniforme classique (TMM)
        %         ckd = cos(kd); skd = sin(kd);
        %         T11 = ckd;
        %         T12 = 1j * Z0 / Si .* skd;   % ATTENTION: bien /Si
        %         T21 = 1j * Si / Z0 .* skd;
        %         T22 = ckd;
        %     else
        %         % "Conique par l’aire" (structure identique à Eq. 7)
        %         R   = ro / ri;                     % = sqrt(So/Si)
        %         Lz  = d * ri / (ri - ro);          % sommet équivalent
        %         klz = k0 .* Lz;
        % 
        %         ckd = cos(kd); skd = sin(kd);
        % 
        %         T11 = R .* ckd + (1 ./ klz) .* skd;
        %         % Correction clé: /Si ici (comme la forme rigoureuse de (7))
        %         T12 = 1j * Z0 * (R ./ Si) .* skd;
        %         T21 = 1j * Si / Z0 .* ( (R + 1./(klz.^2)) .* skd ...
        %                               - (d ./ (k0 .* Lz.^2)) .* ckd );
        %         T22 = (1 ./ R) .* ( ckd - (1 ./ klz) .* skd );
        %     end
        % 
        %     T.T11 = T11;  T.T12 = T12;
        %     T.T21 = T21;  T.T22 = T22;
        % end

        % function T = transfer_matrix(obj, env)
        %     % TRANSFER_MATRIX
        %     % Matrice de transfert pour une cavité rectangulaire trapézoïdale
        %     % Section S(x) = S0 + a x intégrée via équation de Webster (système 1er ordre)
        % 
        %     % --- Paramètres fluide
        %     param = env.air.parameters;
        %     rho0  = param.rho;
        %     % c0    = param.c0;
        %     c0 = env.air.parameters.c0 * (1+0.05*1j); % perso_ouvrir_lien_Zotero('zotero://open-pdf/library/items/233HZ8GN?page=7&annotation=QLW3FP87')
        %     wvec  = env.w;                % peut être scalaire ou vecteur
        % 
        %     % --- Géométrie
        %     cfg = obj.Configuration;
        %     d   = cfg.Thickness;          
        %     Si  = cfg.Width  * cfg.Depth; 
        %     So  = cfg.WidthOut * cfg.DepthOut; 
        %     a   = (So - Si) / d;          
        % 
        %     % Cas limite (tube uniforme)
        %     Sbar = 0.5*(Si+So);
        % 
        %     % Préallocation
        %     nfreq = numel(wvec);
        %     T(nfreq) = struct('T11',[],'T12',[],'T21',[],'T22',[]);
        % 
        %     for iw = 1:nfreq
        %         w  = wvec(iw);
        %         k0 = w ./ c0;
        % 
        %         if abs(a)*d <= 1e-10*max(1,Sbar)
        %             % --- Tube uniforme
        %             kd  = k0 .* d;
        %             ckd = cos(kd); skd = sin(kd);
        %             Zc  = rho0*c0./Sbar;
        %             T(iw).T11 = ckd;
        %             T(iw).T12 = 1j*Zc.*skd;
        %             T(iw).T21 = 1j*(1./Zc).*skd;
        %             T(iw).T22 = ckd;
        %         else
        %             % --- Section variable : intégration
        %             S_of_x = @(x) Si + a*x;
        % 
        %             odefun = @(x,y) [ 0, -1i*w*rho0./S_of_x(x);
        %                               -1i*S_of_x(x)*k0.^2./(w*rho0), 0 ] * y;
        % 
        %             opts = odeset('RelTol',1e-8,'AbsTol',1e-10,'MaxStep',d/200);
        % 
        %             % Colonne 1
        %             [~,Y1] = ode45(odefun, [0 d], [1;0], opts);
        %             y1d = Y1(end,:).';
        % 
        %             % Colonne 2
        %             [~,Y2] = ode45(odefun, [0 d], [0;1], opts);
        %             y2d = Y2(end,:).';
        % 
        %             % TM
        %             T(iw).T11 = y1d(1); T(iw).T12 = y2d(1);
        %             T(iw).T21 = y1d(2); T(iw).T22 = y2d(2);
        %         end
        %     end
        % end

        % function T = transfer_matrix(obj, env) % idem qu'un autre pas ouf
        %     % TRANSFER_MATRIX — Cavité rectangulaire trapézoïdale (S(x)=Si+a x)
        %     % Formulation fermée (Bessel d’ordre 0, équation de Webster rectangulaire).
        %     % Convention d’état : y = [p ; U] avec U = débit volumique.
        %     %
        %     % Sortie : tableau struct T(1..Nf) avec champs T11,T12,T21,T22.
        % 
        %         % --- Fluide
        %         param = env.air.parameters;
        %         rho0  = param.rho;
        %         c0    = param.c0;        % éventuellement complexifié si pertes
        %         wvec  = env.w(:);        % scalaire ou vecteur
        %         kvec  = wvec ./ c0;
        % 
        %         % --- Géométrie
        %         cfg = obj.Configuration;
        %         d   = cfg.Thickness;
        %         Si  = cfg.Width  * cfg.Depth;       % section entrée
        %         So  = cfg.WidthOut * cfg.DepthOut;  % section sortie
        %         a   = (So - Si) / d;
        %         Sbar = 0.5*(Si+So);
        % 
        %         % --- Préallocation
        %         Nf = numel(wvec);
        %         T(Nf) = struct('T11',[],'T12',[],'T21',[],'T22',[]);
        % 
        %         % --- Seuils de robustesse
        %         tol_uniform = 1e-10 * max(1, Sbar);
        %         tol_det     = 1e-12;
        % 
        %         for i = 1:Nf
        %             w  = wvec(i);
        %             k0 = kvec(i);
        % 
        %             % Cas limite : tube uniforme
        %             if abs(So - Si) <= tol_uniform || abs(a) <= eps
        %                 kd  = k0 * d;
        %                 ckd = cos(kd); skd = sin(kd);
        %                 Zc  = rho0*c0 / Si;   % impédance carac. entrée (réf Si)
        %                 T(i).T11 = ckd;
        %                 T(i).T12 = 1j*Zc*skd;
        %                 T(i).T21 = 1j*(1/Zc)*skd;
        %                 T(i).T22 = ckd;
        %                 continue;
        %             end
        % 
        %             % --- Paramètres Bessel (formulation Webster rectangulaire)
        %             beta = k0 / a;           % = k0 / pente
        %             z1   = beta * Si;
        %             z2   = beta * So;
        % 
        %             % Fonctions de Bessel aux deux extrémités
        %             J0z1 = besselj(0, z1);  J1z1 = besselj(1, z1);
        %             Y0z1 = bessely(0, z1);  Y1z1 = bessely(1, z1);
        %             J0z2 = besselj(0, z2);  J1z2 = besselj(1, z2);
        %             Y0z2 = bessely(0, z2);  Y1z2 = bessely(1, z2);
        % 
        %             % Coefficient alpha (p–U convention)
        %             alpha = (a*beta) / (1j*w*rho0);   % ~ k0/(jωρ0)
        % 
        %             % Matrices fondamentales : dépendent de la section locale
        %             M1 = [ J0z1,           Y0z1;
        %                    alpha*Si*J1z1,  alpha*Si*Y1z1 ];
        %             M2 = [ J0z2,           Y0z2;
        %                    alpha*So*J1z2,  alpha*So*Y1z2 ];
        % 
        %             % Inversion 2x2
        %             detM1 = M1(1,1)*M1(2,2) - M1(1,2)*M1(2,1);
        % 
        %             if ~isfinite(detM1) || abs(detM1) < tol_det
        %                 % Fallback tube uniforme (référence Si)
        %                 kd  = k0 * d;
        %                 ckd = cos(kd); skd = sin(kd);
        %                 Zc  = rho0*c0 / Si;
        %                 T(i).T11 = ckd;
        %                 T(i).T12 = 1j*Zc*skd;
        %                 T(i).T21 = 1j*(1/Zc)*skd;
        %                 T(i).T22 = ckd;
        %             else
        %                 invM1 = [  M1(2,2), -M1(1,2);
        %                           -M1(2,1),  M1(1,1) ] / detM1;
        %                 M = M2 * invM1;
        %                 T(i).T11 = M(1,1);  T(i).T12 = M(1,2);
        %                 T(i).T21 = M(2,1);  T(i).T22 = M(2,2);
        %             end
        %         end
        %     end
                
        function Zs = surfaceimpedance(obj, env)

            T = obj.transfer_matrix(env);
            S = obj.Configuration.Surface;
            Zs = S * T.T11 ./ T.T21;
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