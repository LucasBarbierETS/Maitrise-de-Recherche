function plot_contributions(x, MPPSBH_element_i_contribution, ...
ETS_yellow_cavities_contribution, Poly_yellow_cavities_contribution, ...
Poly_elements_contribution, Module_ETS, Module_Poly, ...
Cartouche_ETS, Cartouche_Poly, Cartouche_globale, env, NS)

    figure();
    subplot(8, 2, 1);
    MPPSBH_element_i_contribution(x, 1).plot_alpha(env, 'Contribution MPPSBH 1');
    subplot(8, 2, 2);
    MPPSBH_element_i_contribution(x, 2).plot_alpha(env, 'Contribution MPPSBH 2');
    subplot(8, 2, 3);
    MPPSBH_element_i_contribution(x, 3).plot_alpha(env, 'Contribution MPPSBH 3');
    subplot(8, 2, 4);
    MPPSBH_element_i_contribution(x, 4).plot_alpha(env, 'Contribution MPPSBH 4');
    subplot(8, 2, 5);
    MPPSBH_element_i_contribution(x, 5).plot_alpha(env, 'Contribution MPPSBH 5');
    subplot(8, 2, 6);
    MPPSBH_element_i_contribution(x, 6).plot_alpha(env, 'Contribution MPPSBH 6');
    subplot(8, 2, 7);
    MPPSBH_element_i_contribution(x, 7).plot_alpha(env, 'Contribution MPPSBH 7');
    subplot(8, 2, 8);
    MPPSBH_element_i_contribution(x, 8).plot_alpha(env, 'Contribution MPPSBH 8');
    subplot(8, 2, 9);
    ETS_yellow_cavities_contribution(x).plot_alpha(env, 'Contribution cavité jaune module ETS');
    subplot(8, 2, 10);
    Poly_yellow_cavities_contribution(x).plot_alpha(env, 'Contribution cavité jaune module Poly');
    subplot(8, 2, 11);

    % % Debog : Tracé des impédances de surface des premières et deuxièmes plaques
    % figure(); 
    % perso_plot_surface_impedance(env.w/(2*pi), ETS_yellow_cavities_contribution(x).Configuration.ListOfObjects{1}.surface_impedance(env), env);
    % perso_plot_surface_impedance(env.w/(2*pi), Poly_yellow_cavities_contribution(x).Configuration.ListOfObjects{1}.surface_impedance(env), env);
    % sgtitle('Tracé des impédances de surface des première et deuxième plaques')

    % % Debog : Tracé des impédances de surface des contributions avec chacune des plaques
    % figure();
    % perso_plot_surface_impedance(env.w/(2*pi), ETS_yellow_cavities_contribution(x).surface_impedance(env), env);
    % perso_plot_surface_impedance(env.w/(2*pi), Poly_yellow_cavities_contribution(x).surface_impedance(env), env);
    % sgtitle('Tracé des impédances de surface des contributions avec chacune des plaques')

    Poly_elements_contribution(x).plot_alpha(env, 'Contribution élement Poly');
    subplot(8, 2, 12);
    Module_ETS(x).plot_alpha(env, 'Module ETS');
    subplot(8, 2, 13);
    Module_Poly(x).plot_alpha(env, 'Module Poly');
    subplot(8, 2, 14);
    Cartouche_ETS(x).plot_alpha(env, 'Cartouche ETS');
    subplot(8, 2, 15);
    Cartouche_Poly(x).plot_alpha(env, 'Cartouche Poly');
    subplot(8, 2, 16);
    Cartouche_globale(x).plot_alpha(env, 'Cartouche Globale');
end