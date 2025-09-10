function alpha_model = plot_figures_multi_QWL (multi_QWL_opti, gabarit, air, w)

    % Calcul de la matrice de transfert
    TM = multi_QWL_opti.transferMatrix(air, w);
    
    % Calcul de l'impédance caractéristique et du coefficient d'absorption
    param = air.parameters;
    Z0 = param.rho * param.c0;
    Zs = TM.T11./TM.T21;
    alpha_model = 1 - abs((Zs - Z0)./(Zs + Z0)).^2;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% figures %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Tracé des contributions de chaque résonateur
    figure;
    
    % Subplot 1: Contributions des résonateurs quart d'onde
    subplot(2, 2, 1);
    plot_contributions_multi_QWL(multi_QWL_opti,'circle', air, w)
    
    
    % Subplot 2: Modèle obtenu et gabarit
    subplot(2, 2, 2);
    plot(w/(2*pi), alpha_model, 'LineWidth', 1.5, 'DisplayName', 'Modèle Obtenu');
    hold on;
    plot(w/(2*pi), gabarit, 'LineWidth', 1, 'DisplayName', 'Gabarit', 'Color', [0.8, 0.2, 0.2], 'LineStyle', '--');
    title("Multi-résonateurs quart d'onde optimisé");
    xlabel('Fréquence (Hz)');
    ylabel('Coefficient d''absorption');
    legend('Location', 'Best');
    grid on;
    hold off;
    
    % Subplot 3: Schéma du multi résonateurs
    subplot(2, 2, 3);
    draw_multi_QWL(multi_QWL_opti);
    title("Schéma du multi-résonateurs");
    
    % Subplot 4: Config dérivées n-1 résonateurs et matrice de corrélation
    subplot(2, 2, 4);
    verif_config_multi_QWL(multi_QWL_opti, 'circle', air, w);
    title("Ecart à la configuration de référence");

end