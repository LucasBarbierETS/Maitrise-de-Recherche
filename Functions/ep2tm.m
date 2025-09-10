function TM = ep2tm(ep,d) % Fonction qui permet de passer des paramètres équivalents (ep) et de l'épaisseur (d) d'un poreux à sa matrice de transfert (TM)
    
    kd = ep.keq * d;
    TM.T11 = cos(kd);
    TM.T12 = 1j .* (ep.Zeq) .* sin(kd);
    TM.T21 = 1j ./ (ep.Zeq) .* sin(kd);
    TM.T22 = cos(kd);
end

            