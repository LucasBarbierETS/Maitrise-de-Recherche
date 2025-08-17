function plot_cartouche_ETS(x, Contributions, Cartouches, env)

    figure();
    subplot(1, 3, 1)
    Contributions.contribution_MPPSBH_element_i(x, 1).plot_alpha(env, 'contribution element MPPSBH 1 - modèle linéaire')
    Contributions.contribution_MPPSBH_element_HL_fp_i(x, 1).plot_alpha(env, 'contribution element MPPSBH 1 - modèle HL fp - dB rms')
    Contributions.contribution_MPPSBH_element_HL_i(x, 1).plot_alpha(env, 'contribution element MPPSBH 1 - modèle HL - dB rms')
    perso_configure_alpha_figure(2000);

    subplot(1, 3, 2)
    Contributions.contribution_ETS_yellow_cavity(x).plot_alpha(env, 'contribution HR - modèle linéaire')
    Contributions.contribution_ETS_HL_yellow_cavity(x).plot_alpha(env, 'contribution HR - modèle HL - dB rms')
    perso_configure_alpha_figure(2000);

    subplot(1, 3, 3)
    Cartouches.cartouche_ETS(x).plot_alpha(env, 'Cartouche ETS - modèle linéaire');
    Cartouches.cartouche_ETS_HL_fp(x).plot_alpha(env, 'Cartouche ETS - modèle HL  - dB rms');
    Cartouches.cartouche_ETS_HL(x).plot_alpha(env, 'Cartouche ETS - modèle HL - dB rms');
    perso_configure_alpha_figure(2000);

    sgt = sgtitle('Comparaison des solutions MPPSBH avec et sans cavité au dessus');
    sgt.FontSize = 10;
    
    % % Debog : Tracé de l'impédance de surface
    % figure(s)
    % hold on
    % perso_plot_surface_impedance(env.w/(2*pi), MPPSBH_i(x_ETS, 1).surface_impedance(env), env);
    % perso_plot_surface_impedance(env.w/(2*pi), MPPSBH_element_i(x_ETS, 1).surface_impedance(env), env);
    % sgt = sgtitle('Tracé de l''impédance de surface de l''élement MPPSBH 1');
    % sgt.FontSize = 10;
end