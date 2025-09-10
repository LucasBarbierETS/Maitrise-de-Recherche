function [rows, cols, bestNum] = perso_distribute_holes(rectWidth, rectHeight, numHoles, searchRange)
    % Vérifie les entrées
    if numHoles <= 0 || floor(numHoles) ~= numHoles
        error('Le nombre de trous doit être un entier positif.');
    end
    if nargin < 4
        searchRange = 5; % Plage par défaut autour de numHoles
    end
    
    % Calcul du rapport d'aspect du rectangle
    rectAspectRatio = rectWidth / rectHeight;
    
    % Cherche le nombre avec le maximum de diviseurs autour de numHoles
    bestNum = numHoles;
    maxDivisors = 0;
    for n = numHoles - searchRange:numHoles + searchRange
        if n > 0
            numDivisors = length(findDivisors(n)); % Compte les diviseurs
            if numDivisors > maxDivisors
                maxDivisors = numDivisors;
                bestNum = n; % Met à jour le meilleur nombre
            end
        end
    end
    
    % Trouve tous les couples de diviseurs pour le meilleur nombre
    divisorPairs = findDivisorPairs(bestNum);
    
    % Initialisation pour trouver le couple optimal
    bestDiff = inf;
    bestPair = [1, bestNum]; % Par défaut
    
    % Parcourt les couples de diviseurs
    for i = 1:size(divisorPairs, 1)
        r = divisorPairs(i, 1); % Lignes
        c = divisorPairs(i, 2); % Colonnes
        
        % Calcul des deux rapports possibles
        aspectRatio1 = r / c; % Lignes/Colonnes
        aspectRatio2 = c / r; % Colonnes/Lignes
        
        % Calcul des différences entre les rapports
        diff1 = abs(log(aspectRatio1) - log(rectAspectRatio));
        diff2 = abs(log(aspectRatio2) - log(rectAspectRatio));
        
        % Sélectionne le meilleur couple
        if diff1 < bestDiff
            bestDiff = diff1;
            bestPair = [r, c];
        end
        if diff2 < bestDiff
            bestDiff = diff2;
            bestPair = [c, r];
        end
    end
    
    % Retourne les lignes (rows), colonnes (cols), et le meilleur nombre
    rows = bestPair(1);
    cols = bestPair(2);
end

function pairs = findDivisorPairs(N)
    % Trouve tous les couples de diviseurs d'un nombre
    pairs = [];
    for d = 1:floor(sqrt(N))
        if mod(N, d) == 0
            pairs = [pairs; d, N / d]; % Ajoute le couple (d, N/d)
        end
    end
end

function divisors = findDivisors(N)
    % Trouve tous les diviseurs d'un nombre
    divisors = [];
    for d = 1:N
        if mod(N, d) == 0
            divisors = [divisors, d];
        end
    end
end

