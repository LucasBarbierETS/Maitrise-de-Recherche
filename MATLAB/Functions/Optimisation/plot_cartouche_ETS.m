function plot_cartouche_ETS(x, Contributions, Cartouches, env)

    % Debog : Contributions des solutions à la cartouche ETS
    figure();
    Contributions.contribution_MPPSBH_element_i(x, 1).plot_alpha(env, 'contribution MPPSBH 1')
    Contributions.contribution_MPPSBH_element_i(x, 2).plot_alpha(env, 'contribution MPPSBH 2')
    Contributions.contribution_MPPSBH_element_i(x, 3).plot_alpha(env, 'contribution MPPSBH 3')
    Contributions.contribution_MPPSBH_element_i(x, 4).plot_alpha(env, 'contribution MPPSBH 4')
    Contributions.contribution_MPPSBH_element_i(x, 5).plot_alpha(env, 'contribution MPPSBH 5')
    Contributions.contribution_MPPSBH_element_i(x, 6).plot_alpha(env, 'contribution MPPSBH 6')
    Contributions.contribution_MPPSBH_element_i(x, 7).plot_alpha(env, 'contribution MPPSBH 7')
    Contributions.contribution_MPPSBH_element_i(x, 8).plot_alpha(env, 'contribution MPPSBH 8')
    Contributions.contribution_ETS_yellow_cavities(x).plot_alpha(env, 'contribution HR')
    Cartouches.cartouche_ETS(x).plot_alpha(env, 'Cartouche ETS');

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