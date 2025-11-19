function [freqTM, T11c, T12c, T21c, T22c, TMc] = compute_TM_from_txt(fileA, fileB)
% Fichier txt COMSOL format : freq, p1, p2, v1, v2
% Ignore les 4 premières lignes

    % --- Lecture robuste avec saut des 4 premières lignes ---
    A = readmatrix(fileA, 'NumHeaderLines', 5);
    B = readmatrix(fileB, 'NumHeaderLines', 5);

    % Suppression des lignes vides éventuelles
    A = A(all(~isnan(A),2), :);
    B = B(all(~isnan(B),2), :);

    % Vérification du nombre minimal de colonnes
    if size(A,2) < 5 || size(B,2) < 5
        error("Les fichiers doivent comporter au moins 5 colonnes : freq p1 p2 v1 v2");
    end

    % --- Extraction colonnes ---
    freqA = A(:,1);  p1A = A(:,2);  p2A = A(:,3);  v1A = A(:,4);  v2A = A(:,5);
    freqB = B(:,1);  p1B = B(:,2);  p2B = B(:,3);  v1B = B(:,4);  v2B = B(:,5);

    % --- Vérification des fréquences ---
    if ~isequal(freqA, freqB)
        warning("Fréquences différentes entre A et B -> intersection");
        [freqTM, idxA, idxB] = intersect(freqA, freqB);
        p1A = p1A(idxA);  p2A = p2A(idxA);  v1A = v1A(idxA);  v2A = v2A(idxA);
        p1B = p1B(idxB);  p2B = p2B(idxB);  v1B = v1B(idxB);  v2B = v2B(idxB);
    else
        freqTM = freqA;
    end

    % --- Déterminant ---
    Delta = p2A .* v2B - p2B .* v2A;

    % Correction Delta très faible
    Delta(abs(Delta) < 1e-20) = 1e-20;

    % --- Coefficients TM ---
    T11c = (p1A .* v2B - p1B .* v2A) ./ Delta;
    T12c = -(p1B .* p2A - p1A .* p2B) ./ Delta;
    T21c = -(v1A .* v2B - v1B .* v2A) ./ Delta;
    T22c = (v1B .* p2A - v1A .* p2B) ./ Delta;

    % --- Matrice complète 2x2xN ---
    N = numel(freqTM);
    TMc = zeros(2,2,N);
    TMc(1,1,:) = T11c; TMc(1,2,:) = T12c;
    TMc(2,1,:) = T21c; TMc(2,2,:) = T22c;
end