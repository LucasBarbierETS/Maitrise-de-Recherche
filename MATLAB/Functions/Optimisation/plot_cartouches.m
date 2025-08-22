function plot_cartouches(x, Cartouches, env)
    
    % Première harmonique (Fondamentale) : 233 Hz
    f_min_h1 = 200;
    f_max_h1 = 250;
    
    % Deuxième harmonique : 467 Hz
    f_min_h2 = 380;
    f_max_h2 = 480;
    
    % Troisième harmonique : 700 Hz
    f_min_h3 = 550;
    f_max_h3 = 700;
    
    % Quatrième harmonique : 933 Hz
    f_min_h4 = 750;
    f_max_h4 = 950;

    f_min_lb = 200;
    f_max_lb = 1500;
   
    % % Cartouche ETS
    figure();
    % subplot(1, 2, 1)
    hold on 
    Cartouches.cartouche_ETS(x).plot_alpha(env, 'Cartouche ETS - modèle linéaire');
    Cartouches.cartouche_ETS_HL(x).plot_alpha(env, 'Cartouche ETS - modèle HL');
    Cartouches.cartouche_ETS_HL_fp(x).plot_alpha(env, 'Cartouche ETS - modèle HL fp');
    % Cartouches.cartouche_ETS_contributions(x).plot_alpha(env, 'Cartouche ETS - réaction localisée - modèle linéaire');
    % Cartouches.cartouche_ETS_HL_contributions(x).plot_alpha(env, 'Cartouche ETS - réaction localisée - modèle HL');
    % Cartouches.cartouche_ETS_HL_fp_contributions(x).plot_alpha(env, 'Cartouche ETS - réaction localisée - modèle HL fp');
    % Cartouches.cartouche_ETS_sans_HR(x).plot_alpha(env, 'Cartouche ETS sans HR');
    % Cartouches.cartouche_ETS_sans_HR_contributions(x).plot_alpha(env, 'Cartouche ETS sans HR contributions');
    patch([f_min_lb, f_min_lb, f_max_lb, f_max_lb], [0, 140, 140, 0], 'green', ...
          'FaceAlpha', 0.2, 'EdgeColor','none', 'DisplayName', 'Bande d''optimisation élargie');
    patch([f_min_h1, f_min_h1, f_max_h1, f_max_h1], [0, 140, 140, 0], 'red', ...
          'FaceAlpha', 0.2, 'EdgeColor','none', 'DisplayName', 'Bande d''optimisation 1', 'HandleVisibility', "off");
    patch([f_min_h2, f_min_h2, f_max_h2, f_max_h2], [0, 140, 140, 0], 'red', ...
          'FaceAlpha', 0.2, 'EdgeColor','none', 'DisplayName', 'Bande d''optimisation 2', 'HandleVisibility', "off");
    patch([f_min_h3, f_min_h3, f_max_h3, f_max_h3], [0, 140, 140, 0], 'red', ...
          'FaceAlpha', 0.2, 'EdgeColor','none', 'DisplayName', 'Bande d''optimisation 3', 'HandleVisibility', "off");
    patch([f_min_h4, f_min_h4, f_max_h4, f_max_h4], [0, 140, 140, 0], 'red', ...
          'FaceAlpha', 0.2, 'EdgeColor','none', 'DisplayName', 'Bande d''optimisation 4', 'HandleVisibility', "off");
    perso_configure_alpha_figure(2000);
   
    % % Cartouche Poly
    figure();
    % subplot(1, 2, 2)
    hold on
    Cartouches.cartouche_Poly(x).plot_alpha(env, 'Cartouche Poly');
    Cartouches.cartouche_Poly_HL(x).plot_alpha(env, 'Cartouche Poly - modèle HL');
    % Cartouches.cartouche_Poly_contributions(x).plot_alpha(env, 'Cartouche Poly - réaction localisée');
    % Cartouches.cartouche_Poly_HL_contributions(x).plot_alpha(env, 'Cartouche Poly - réaction localisée - modèle HL');
    % Cartouches.cartouche_Poly_sans_HR(x).plot_alpha(env, 'Cartouche Poly sans HR')
    % Cartouches.cartouche_Poly_sans_HR_contributions(x).plot_alpha(env, 'Cartouche Poly sans HR contributions');
    patch([f_min_lb, f_min_lb, f_max_lb, f_max_lb], [0, 140, 140, 0], 'green', ...
          'FaceAlpha', 0.2, 'EdgeColor','none', 'DisplayName', 'Bande d''optimisation élargie');
    patch([f_min_h1, f_min_h1, f_max_h1, f_max_h1], [0, 140, 140, 0], 'red', ...
          'FaceAlpha', 0.2, 'EdgeColor','none', 'DisplayName', 'Bande d''optimisation 1', 'HandleVisibility', "off");
    patch([f_min_h2, f_min_h2, f_max_h2, f_max_h2], [0, 140, 140, 0], 'red', ...
          'FaceAlpha', 0.2, 'EdgeColor','none', 'DisplayName', 'Bande d''optimisation 2', 'HandleVisibility', "off");
    patch([f_min_h3, f_min_h3, f_max_h3, f_max_h3], [0, 140, 140, 0], 'red', ...
          'FaceAlpha', 0.2, 'EdgeColor','none', 'DisplayName', 'Bande d''optimisation 3', 'HandleVisibility', "off");
    patch([f_min_h4, f_min_h4, f_max_h4, f_max_h4], [0, 140, 140, 0], 'red', ...
          'FaceAlpha', 0.2, 'EdgeColor','none', 'DisplayName', 'Bande d''optimisation 4', 'HandleVisibility', "off");
    perso_configure_alpha_figure(2000);

    % Cartouche Globale
    figure()
    hold on
    Cartouches.cartouche_globale(x).plot_alpha(env, 'Cartouche Globale - modèle linéaire');
    Cartouches.cartouche_globale_HL(x).plot_alpha(env, 'Cartouche Globale - modèle HL');
    Cartouches.cartouche_globale_HL_fp(x).plot_alpha(env, 'Cartouche Globale - modèle HL fp');

    patch([f_min_lb, f_min_lb, f_max_lb, f_max_lb], [0, 140, 140, 0], 'green', ...
          'FaceAlpha', 0.2, 'EdgeColor','none', 'DisplayName', 'Bande d''optimisation élargie', 'HandleVisibility', "off");
    patch([f_min_h1, f_min_h1, f_max_h1, f_max_h1], [0, 140, 140, 0], 'red', ...
          'FaceAlpha', 0.2, 'EdgeColor','none', 'DisplayName', 'Bande d''optimisation 1', 'HandleVisibility', "off");
    patch([f_min_h2, f_min_h2, f_max_h2, f_max_h2], [0, 140, 140, 0], 'red', ...
          'FaceAlpha', 0.2, 'EdgeColor','none', 'DisplayName', 'Bande d''optimisation 2', 'HandleVisibility', "off");
    patch([f_min_h3, f_min_h3, f_max_h3, f_max_h3], [0, 140, 140, 0], 'red', ...
          'FaceAlpha', 0.2, 'EdgeColor','none', 'DisplayName', 'Bande d''optimisation 3', 'HandleVisibility', "off");
    patch([f_min_h4, f_min_h4, f_max_h4, f_max_h4], [0, 140, 140, 0], 'red', ...
          'FaceAlpha', 0.2, 'EdgeColor','none', 'DisplayName', 'Bande d''optimisation 4', 'HandleVisibility', "off");
    perso_configure_alpha_figure(2000);
end