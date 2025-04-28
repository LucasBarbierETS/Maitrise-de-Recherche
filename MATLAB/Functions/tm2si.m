function Zs = tm2si(tm)
% Fonction qui permet de passer de la matrice de transfert (tm) d'un objet à sa surface d'impédance (si)
    Zs = tm.T11./tm.T21; % rigid wall
end

