%% ETUDE PARAMETRIQUE MDOF

L = 60e-3; % Longueur totale
w = 30e-3; % Largeur des cavités
d = 30e-3; % Profondeur des cavités
S = w * d; % Section

%% Etude sur le nombre de plaque

pt = 1e-3; % Epaisseur des plaques
phi = 0.025; % Porosité des plaques
r = 0.5e-3; % Rayon des perforations

f1_1 = perso_figure('Etude paramétrique MMPP - Nombre de plaques - Coefficient d''absorption');
hold on
f1_2 = perso_figure('Etude paramétrique MMPP - Nombre de plaques - Surface d''impédance');
hold on

ct = @(N) L/N - pt; % Epaisseur (égale) des cavités
N = linspace(1, 6, 6);

for i = 1:length(N)
    MMPP = classMMPP(classMMPP.create_config(S, N(i), {r}, {phi}, {pt}, {ct(N(i))}));
    
    set(0, 'CurrentFigure', f1_1);
    plot(env.w/(2*pi), MMPP.alpha(env), 'DisplayName', [num2str(i), 'P'])
    set(0, 'CurrentFigure', f1_2);
    perso_plot_surface_impedance(env.w/(2*pi), MMPP.surface_impedance(env)/env.air.parameters.Z0, env, [num2str(i), 'P'], 20);
end

%% Etude sur l'épaisseur d'une plaque

N = 1;
ct = L/N - pt;
phi = 0.025; % Porosité des plaques
r = 0.5e-3; % Rayon des perforations

f2_1 = perso_figure('Etude paramétrique MMPP - Epaisseur de la première plaque - Coefficient d''absorption');
hold on
f2_2 = perso_figure('Etude paramétrique MMPP - Epaisseur de la première plaque - Surface d''impédance');
hold on

pt = linspace(1, 6, 6) * 1e-3; % Epaisseur des plaques

for i = 1:length(pt)
    MMPP = classMMPP(classMMPP.create_config(S, N, {r}, {phi}, {pt(i)}, {ct(N)}));
    
    set(0, 'CurrentFigure', f2_1);
    plot(env.w/(2*pi), MMPP.alpha(env), 'DisplayName', [num2str(i), 'P'])
    set(0, 'CurrentFigure', f2_2);
    perso_plot_surface_impedance(env.w/(2*pi), MMPP.surface_impedance(env)/env.air.parameters.Z0, env, [num2str(i), 'P'], 20);
end

%% Etude sur le rayon des perforations à 6 plaques équi-distantes

N = 6;
ct = L/N - pt;
phi = 0.025; % Porosité des plaques
pt = 1e-3; % Epaisseur des plaques

f3_1 = perso_figure('Etude paramétrique MMPP - Rayon des perforations pour 6 plaques équi-distantes, identiques - Coefficient d''absorption');
hold on
f3_2 = perso_figure('Etude paramétrique MMPP - Rayon des perforations pour 6 plaques équi-distantes, identiques - Surface d''impédance');
hold on

r = linspace(1e-4, 4e-4, 8); % Rayon des perforations

for i = 1:length(r)
    MMPP = classMMPP(classMMPP.create_config(S, N, {r(i)}, {phi}, {pt}, {ct}));
    
    set(0, 'CurrentFigure', f3_1);
    plot(env.w/(2*pi), MMPP.alpha(env), 'DisplayName', [num2str(i), 'P'])
    set(0, 'CurrentFigure', f3_2);
    perso_plot_surface_impedance(env.w/(2*pi), MMPP.surface_impedance(env)/env.air.parameters.Z0, env, [num2str(i), 'P'], 20);
end

%% Etude sur le rayon des perforations à 6 plaques équi-distantes - rayons inhomogènes

N = 6;
ct = L/N - pt;
phi = 0.025; % Porosité des plaques
pt = 1e-3; % Epaisseur des plaques

f4_1 = perso_figure('Etude paramétrique MMPP - Rayon des perforations pour 6 plaques équi-distantes, identiques - Coefficient d''absorption');
hold on
f4_2 = perso_figure('Etude paramétrique MMPP - Rayon des perforations pour 6 plaques équi-distantes, identiques - Surface d''impédance');
hold on

m = linspace(2e-4, 1e-3, 5);
e = 3e-3;
r = randn(N); 

for i = 1:length(m)
    r = m(i) + e * randn(N); % Rayon des perforations
    MMPP = classMMPP(classMMPP.create_config(S, N, {r}, {phi}, {pt}, {ct}));
    
    set(0, 'CurrentFigure', f4_1);
    plot(env.w/(2*pi), MMPP.alpha(env), 'DisplayName', [num2str(i), 'P'])
    set(0, 'CurrentFigure', f3_2);
    perso_plot_surface_impedance(env.w/(2*pi), MMPP.surface_impedance(env)/env.air.parameters.Z0, env, [num2str(i), 'P'], 20);
end
