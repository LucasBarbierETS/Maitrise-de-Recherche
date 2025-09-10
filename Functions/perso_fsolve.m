function u = perso_fsolve(make_fun, w)
% perso_fsolve résout u(k) (complexe) séquentiellement sur k=1..N
% Usage minimal :
%   u = perso_seqsolve_complex(make_fun, w)
% où:
%   - make_fun : @(k,u) -> résidu complexe f_k(u) (scalaire complexe)
%   - w        : vecteur des fréquences (sert juste à définir N = numel(w))
%
% Dépendances : fsolve (Optimization Toolbox)

N = numel(w);
u = nan(N,1);

% Réglages internes (simples & raisonnables)
TolF        = 1e-10;   % accepte racine si |f| <= TolF
JumpTolRel  = 0.15;    % continuité: saut relatif autorisé
JumpTolAbs  = 1e-4;    % + filet absolu
Win         = 5;       % fenêtre pour la boîte de réensemencement
Expand      = 1.2;     % élargissement de la boîte
GridSide    = 5;       % grille de relance GridSide x GridSide
MaxRestarts = 2;       % relances max si discontinuité
x0          = 1 + 0i;  % point de départ pour k=1 (à adapter si besoin)

opts = optimoptions('fsolve','Display','off', ...
    'FunctionTolerance',1e-12,'StepTolerance',1e-12);

% k = 1
[u(1), ~] = solve_one(make_fun, 1, x0, opts, TolF);

% k = 2..N
for k = 2:N
    % tentative naturelle : départ à la racine précédente
    [uk, fk] = solve_one(make_fun, k, u(k-1), opts, TolF);

    % test de continuité
    jump_ok = abs(uk - u(k-1)) <= (JumpTolRel*max(abs(u(k-1)),1)) + JumpTolAbs;

    rcount = 0;
    while (~jump_ok) && (rcount < MaxRestarts)
        rcount = rcount + 1;

        % Boîte des W dernières racines (Re x Im), légèrement élargie
        i0  = max(1, k-Win); Uwin = u(i0:k-1); Uwin = Uwin(isfinite(Uwin));
        if isempty(Uwin), Uwin = u(1:k-1); Uwin = Uwin(isfinite(Uwin)); end
        if isempty(Uwin), Uwin = u(k-1) + (randn(10,1)+1i*randn(10,1))*1e-2; end
        rmin = min(real(Uwin)); rmax = max(real(Uwin));
        imin = min(imag(Uwin)); imax = max(imag(Uwin));
        cx  = 0.5*(rmin+rmax);  sx = max(0.5*(rmax-rmin), eps);
        cy  = 0.5*(imin+imax);  sy = max(0.5*(imax-imin), eps);
        rmin = cx - Expand*sx; rmax = cx + Expand*sx;
        imin = cy - Expand*sy; imax = cy + Expand*sy;

        % Grille de départs dans la boîte, ordonnée par proximité de u(k-1)
        rr = linspace(rmin, rmax, GridSide);
        ii = linspace(imin, imax, GridSide);
        [RR, II] = ndgrid(rr, ii);
        starts = RR(:) + 1i*II(:);
        [~,ord] = sort(abs(starts - u(k-1))); starts = starts(ord);

        % On essaie jusqu’à trouver une solution continue (ou la meilleure |f|)
        best_u = uk; best_f = fk;
        for t = 1:numel(starts)
            [ut, ft] = solve_one(make_fun, k, starts(t), opts, TolF);
            if abs(ut - u(k-1)) <= (JumpTolRel*max(abs(u(k-1)),1)) + JumpTolAbs
                uk = ut; fk = ft; break
            end
            if ft < best_f, best_f = ft; best_u = ut; end
            if t == numel(starts), uk = best_u; fk = best_f; end
        end

        jump_ok = abs(uk - u(k-1)) <= (JumpTolRel*max(abs(u(k-1)),1)) + JumpTolAbs;
    end

    u(k) = uk;
end

end % main

% ===== interne : une résolution complexe via fsolve (R2 -> R2)
function [uc, fval] = solve_one(make_fun, k, u0, opts, TolF)
fk  = @(u) make_fun(k, u); % résidu complexe
F2R = @(xy) [real(fk(xy(1)+1i*xy(2))); imag(fk(xy(1)+1i*xy(2)))];
x0r = [real(u0); imag(u0)];
try
    sol = fsolve(F2R, x0r, opts);
    uc  = sol(1) + 1i*sol(2);
    fval = abs(fk(uc));
    if ~(isfinite(fval) && fval <= TolF)
        % petite reprise locale si |f| trop grand
        sol  = fsolve(F2R, [sol(1); sol(2)], opts);
        uc   = sol(1) + 1i*sol(2);
        fval = abs(fk(uc));
    end
catch
    uc   = u0;
    fval = abs(fk(uc));
end
end
