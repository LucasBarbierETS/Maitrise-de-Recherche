%% --- Création de l'environnement ---
PSD_micro = 100; % Niveau de pression détecté au micro (dB)/ à remplacer par la lecture d'un fichier txt
env = create_environnement(root, t, sp, hum, fmin, 20000, points,100); % création enviro dont w et calculer l'amplitude de pression
f = env.w/(2*pi);
%% --- Propriétés matériau ---
%https://www.researchgate.net/figure/The-five-JCA-parameters-of-melamine-foam_tbl1_366598650
porosity = 0.99642;
tortuosity = 1.0018;
air_flow_resistivity = 19338;
viscous_caractersitic_length = 6.9779e-4;
thermal_caracteristic_length = 6.9779e-4;

%% --- Propriétés du micro ---
D = 6.35e-3;                  % diamètre du micro [m]
surface = (pi/4) * D^2;       % surface du micro [m²]
coeff_list = [1, 2, 4, 6, 8]; % multiplicateurs d'épaisseur
colors = lines(numel(coeff_list));

%% ==================== FIGURE 1 : α et Zs ====================
fig1 = figure('Name', 'Absorption et Impédance', 'NumberTitle', 'off'); clf;
sgtitle('Coefficient d''absorption et impedance normalisee de la melamine');

subplot_titles = {'α', 'Re-impedance normalisee', 'Im-impedance normalisee'};
ylabels = {'Coefficient d''absorption', 'Partie réelle', 'Partie imaginaire'};

for i = 1:3
    subplot(3,1,i); hold on; grid on;
    xlabel('Fréquence (Hz)');
    ylabel(ylabels{i});
    title(subplot_titles{i});
end

%% --- Boucle principale ---
for i = 1:numel(coeff_list)
    coeff = coeff_list(i);
    thickness = coeff * D;

    % --- Création du matériau ---
    config = classJCA_Rigid.create_config(surface, thickness, porosity, ...
        tortuosity, air_flow_resistivity, ...
        viscous_caractersitic_length, thermal_caracteristic_length);
    obj = classJCA_Rigid(config);
 
    % --- Calculs physiques ---
    alpha = obj.absorption_coefficient(env);
    Zs = obj.surface_impedance(env);
    Zs_norm = Zs / env.air.parameters.Z0;

    % --- Tracés ---
    subplot(3,1,1);
    plot(f, alpha, 'Color', colors(i,:), 'LineWidth', 1.5, ...
        'DisplayName', sprintf('%.1f×D (%.2f mm)', coeff, thickness*1e3));

    subplot(3,1,2);
    plot(f, real(Zs_norm), 'Color', colors(i,:), 'LineWidth', 1.5);
    ylim ([-10 30])

    subplot(3,1,3);
    plot(f, imag(Zs_norm), 'Color', colors(i,:), 'LineWidth', 1.5);
     ylim ([-20 20])
end

for i = 1:3
    subplot(3,1,i);
    legend('show', 'Location', 'best');
end


%% ==================== FIGURE 2 : MATRICES DE TRANSFERT ====================
fig_TM = figure('Name', 'Matrices de transfert', 'NumberTitle', 'off'); clf;
sgtitle('Matrices de transfert pour différentes épaisseurs');

for i = 1:numel(coeff_list)
    coeff = coeff_list(i);
    thickness = coeff * D;

    % Création du matériau
    config = classJCA_Rigid.create_config(surface, thickness, porosity, ...
        tortuosity, air_flow_resistivity, ...
        viscous_caractersitic_length, thermal_caracteristic_length);
    obj = classJCA_Rigid(config);

    % Tracé
    perso_plot_transfer_matrix(obj.transfer_matrix(env), env, ...
        sprintf('Épaisseur = %.1f×D', coeff));
end

for ax = 1:8
    subplot(4,2,ax);
    legend('show', 'Location', 'best');
end

%% ==================== FIGURE 3 : PSD AU RASANT ====================
fig_PSD = figure('Name', 'PSD au rasant', 'NumberTitle', 'off'); clf;
hold on; grid on;
sgtitle('PSD au rasant pour différentes épaisseurs de melamine');
xlabel('Fréquence (Hz)');
ylabel('Niveau de pression (dB)');

%--- Courbe de référence au niveau du micro ---
plot([min(f) max(f)], [PSD_micro PSD_micro], 'k--', 'LineWidth', 1.5, ...
    'DisplayName', sprintf('Référence %d dB', PSD_micro));

for i = 1:numel(coeff_list)
    coeff = coeff_list(i);
    thickness = coeff * D;

    % --- Créer cavité rigide ---
    config = classJCA_Rigid.create_config(surface, thickness, porosity, ...
        tortuosity, air_flow_resistivity, ...
        viscous_caractersitic_length, thermal_caracteristic_length);
    obj = classJCA_Rigid(config);

    % --- Calcul de la PSD au rasant ---
    TM = obj.transfer_matrix(env);
    P_flush = TM.T11 .* env.pt_rms; % pression totale en sortie
    PSD_flush = 20 * log10(abs(P_flush) / (sqrt(2) * env.p_ref));

    % --- Tracé ---
    plot(f, PSD_flush, 'Color', colors(i,:), 'LineWidth', 1.5, ...
        'DisplayName', sprintf('%.1f×D (%.2f mm)', coeff, thickness*1e3));
end

legend('show', 'Location', 'best');