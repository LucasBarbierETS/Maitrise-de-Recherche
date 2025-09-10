function TM = perso_empty_TM(w)
    TM = struct();
    TM.T11 = ones(1, length(w));
    TM.T12 = zeros(1, length(w));
    TM.T21 = zeros(1, length(w));
    TM.T22 = ones(1, length(w));
end