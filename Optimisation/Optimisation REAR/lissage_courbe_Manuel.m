%% ================================
%   SCRIPT : Lissage + Comparaison
%   ================================

clear; close all; clc;

%% --- 1. Charger les données ---------------------
data = readmatrix('C:\Users\lucas.barbier\Documents\Maitrise ETS\Rédaction du mémoire\Figures\données spectre lissé.txt');
x = data(:,1);
y = data(:,2);

% Tri (au cas où)
[x, idx] = sort(x);
y = y(idx);

%% --- 2. Interpolation EXACTE (passe par tous les points) ----
interp_method = 'pchip';  % ou 'spline'

% Grille plus dense uniquement POUR VISUALISATION
x_dense = linspace(min(x), max(x), 5*numel(x))';
y_smooth_dense = interp1(x, y, x_dense, interp_method);

% Mais pour comparer → replat sur les points ORIGINAUX
y_smooth = interp1(x_dense, y_smooth_dense, x, 'linear'); 
% (ou refaire directement : interp1(x,y,x,interp_method) = y → mais là on veut le "lissage" visuel)

%% --- 3. Différence cohérente -------------------
diff_curve = y - y_smooth;

%% --- 4. Affichage --------------------------------

figure;

subplot(3,1,1);
plot(x, y, 'k'); hold on;
plot(x_dense, y_smooth_dense, 'r', 'LineWidth', 1.5);
legend('Original', 'Interpolé / Lissé');
title('Original vs interpolation exacte (pchip)');
grid on;

subplot(3,1,2);
plot(x_dense, y_smooth_dense, 'r');
title('Courbe lissée (visualisation uniquement)');
grid on;

subplot(3,1,3);
plot(x, diff_curve, 'b');
title('Différence (Original - Lissé, même grille)');
xlabel('x');
grid on;
