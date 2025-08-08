function x = perso_simplex_map(theta, C)
% SIMPLEX_MAP : envoie theta ∈ R^n dans le simplexe de dimension n
% via une généralisation du stick-breaking sur n variables.
% C est la somme totale désirée (par défaut C = 1)
% theta : [1 x n]
% x     : [1 x n] avec x_i > 0 et sum(x) = C
    
    % Transformation : softmax
    exp_theta = exp(theta);  % stabilité numérique
    x = C * exp_theta / sum(exp_theta);
end
