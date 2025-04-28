%% Création de l'environnement
addpath('E:\OneDrive - ETS\CRIAQ-REAR\Maitrise LB\MATLAB\MATLAB scripts');
launch_environnement

%% Lancement du script d'optimisation de la solution basse fréquence
% opt_sol_bf;

% %% Etude en fonction du rayon des perforations
% figure()
% title({'Etude paramétrique de la solution optimisée';'en fonction du rayon des perforations de la 1ère plaque'});
% hold on
% r = linspace(25e-5, 1e-3, 5);
% my_plot = perso_plot_with_gradient('r', 'b', length(r));
% for i = 1:length(r)
%     config = sol_bf_lin_config; % récupération de la configuration optimisée
%     config.TopPlateHolesRadius = r(i);
%     current_sol = sol_bf(config);
%     my_plot(i, env.w/(2*pi), current_sol.alpha(env), 'DisplayName', ['r = ', num2str(r(i))]);
% end
% legend();

% %% Etude en fonction du taux de porosité
% figure()
% title({'Etude paramétrique de la solution optimisée';'en fonction de la porosité de la première plaque'});
% hold on
% phi = logspace(-3, -1, 7);
% my_plot = perso_plot_with_gradient('b', 'g', length(phi));
% for i = 1:length(phi)
%     config = sol_bf_lin_config;
%     config.TopPlatePorosity = phi(i);
%     current_sol = sol_bf(config);
%     my_plot(i, env.w/(2*pi), current_sol.alpha(env), 'DisplayName', ['phi = ', num2str(phi(i))]);
% end
% legend();

% %% Etude en fonction de largeur de la fente
% figure()
% hold on
% 
% % Paramètres 1ère plaque
% r = 25e-5;
% pt = 2e-3;
% L = 56e-3/2;
% phi = 0.03;
% 
% % Paramètres de la fente
% sw = linspace(2e-3, 28e-3, 5);
% st = 2e-3;
% 
% my_plot = perso_plot_with_gradient('c', 'm', length(sw));
% 
% for i = 1:length(sw)
%     config = sol_bf.create_config(30e-3^2, 2, 30e-3, 30e-3, {[30e-3, sw(i)]}, phi, r, {pt}, {L}, 'Hankel', 'Bezançon', 'false', 'false');
%     current_sol = sol_bf(config);
%     my_plot(i, env.w/(2*pi), current_sol.alpha(env), 'DisplayName', ['sw = ', num2str(sw(i)*1000), 'mm']);
% end
% 
% title({'Etude paramétrique d''une solution SBF en fonction de la largeur de la fente';['r = ', num2str(r*1000), 'mm - pt = ', num2str(pt*1000), 'mm - L = ', num2str(L*1000), 'mm']});
% legend();

%% Etude en fonction de l'emplacement de la fente
figure()
hold on

% Paramètres 1ère plaque
r = 25e-5;
pt = 2e-3;
L = 56e-3;
phi = 0.03;

% Paramètres de la fente
bct = linspace(10e-3, 50e-3, 5); % épaisseur de la cavité arrière (après la fente)
st = 2e-3;
sw = 2e-3;

my_plot = perso_plot_with_gradient('c', 'm', length(bct));
alpha_num = zeros(5, length(env.w));

for i = 1:length(bct)
    config = sol_bf.create_config(30e-3^2, 2, 30e-3, 30e-3, {[30e-3, sw]}, phi, r, {pt}, {[L-bct(i), bct(i)]}, 'Hankel', 'Bezançon', 'false', 'false');
    current_sol = sol_bf(config);
    my_plot(i, env.w/(2*pi), current_sol.alpha(env), 'DisplayName', ['bct = ', num2str(bct(i)*1000), 'mm']);

    % Validation numérique
    % tube = ImpedanceTube2D(ImpedanceTube2D.create_config({current_sol}));
    % tube = tube.lauch_tube_measurement();
    % alpha_num(i, :) = tube.Configuration.Data2D(:, 2); 
    my_plot(i, tube.Configuration.Data2D(:, 1), tube.Configuration.Data2D(:, 2), '--', 'DisplayName', ['bct = ', num2str(bct(i)*1000), 'mm - FEM']);
end

title({'Etude paramétrique d''une solution SBF en fonction de l''emplacement de la fente'; ['r = ', num2str(r*1000), 'mm - pt = ', num2str(pt*1000), 'mm - L = ', num2str(L*1000), 'mm']});
legend();

%% Etude en fonction de la réparatition des surfaces

