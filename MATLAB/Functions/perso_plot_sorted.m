function perso_plot_sorted(x, y, varargin)
% perso_plot_sorted(x, y, ...)
% Trace y en fonction de x après tri croissant de x
%
% Arguments :
% - x : vecteur des abscisses
% - y : vecteur ou matrice des ordonnées
% - varargin : options de tracé ('LineWidth', 'Color', etc.)

    % Tri des données
    [x_sorted, idx] = sort(x);
    y_sorted = y(idx);

    % Tracé
    plot(x_sorted, y_sorted, varargin{:});
    grid on;
end