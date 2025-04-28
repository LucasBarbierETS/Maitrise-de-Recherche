load('data.mat')

x = data.X(1, :); % l'absorption
y = data.Y(1, :); % les paramètres

loss = multiQWL_cost_function(x, y, air, w);