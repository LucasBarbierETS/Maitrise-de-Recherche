%% Etude en fontion du rayon des perforations
figure()

hold on
phi = 0.03;
pt = 2e-3;
L = 58e-3;
r = linspace(25e-5, 1e-3, 5);
my_plot = perso_plot_with_gradient('r', 'b', length(r));

for i = 1:length(r)
    config = classSDOF.create_config(phi, r(i), pt, L, 30e-3, 30e-3, 'false');
    current_sol = classSDOF(config);
    my_plot(i, env.w/(2*pi), current_sol.alpha(env), 'DisplayName', ['r = ', num2str(r(i)*1000), 'mm']);
end

title({'Etude paramétrique d''une solution SDOF';['phi = ', num2str(phi*100), '% - pt = ', num2str(pt*1000), 'mm - L = ', num2str(L*1000), 'mm']});
legend();

%% Etude en fonction de la porosité
figure()
hold on
r = 25e-5;
pt = 2e-3;
L = 58e-3;
phi = linspace(0.014, 0.053, 5);
my_plot = perso_plot_with_gradient('g', 'y', length(phi));

for i = 1:length(phi)
    config = classSDOF.create_config(phi(i), r, pt, L, 30e-3, 30e-3, 'false');
    current_sol = classSDOF(config);
    my_plot(i, env.w/(2*pi), current_sol.alpha(env), 'DisplayName', ['phi = ', num2str(phi(i)*100), '%']);
end

title({'Etude paramétrique d''une solution SDOF';['r = ', num2str(r*1000), 'mm - pt = ', num2str(pt*1000), 'mm - L = ', num2str(L*1000), 'mm']});
legend();

%% Etude en ajoutant un écran résistif