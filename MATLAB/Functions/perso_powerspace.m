function y = perso_powerspace(a, b, n, p)
    % Génère un vecteur de n points entre a et b en utilisant un espacement défini par la puissance p
    %
    % a  : début de l'intervalle
    % b  : fin de l'intervalle
    % n  : nombre de points
    % p  : puissance de l'espacement (ex: p = 2 pour quadratique, p = 0.5 pour racine carrée)

    % Crée un linspace normalisé entre 0 et 1
    x = linspace(0, 1, n);

    % Applique la transformation en puissance p
    x_transformed = x.^p;

    % Met à l'échelle pour obtenir l'intervalle [a, b]
    y = a + (b - a) * x_transformed;
end