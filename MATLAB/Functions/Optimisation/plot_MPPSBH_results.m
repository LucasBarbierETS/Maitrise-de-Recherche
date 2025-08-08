function plot_MPPSBH_results(x, i, x_ETS, Objets, Contributions, env)

    % Debog : Comparaison du module ETS avec ses élements constitutifs
    figure();
    Objets.MPPSBH_i(x_ETS(x), i).plot_alpha(env, ['MPPSBH ', num2str(i), ]);
    Objets.MPPSBH_element_i(x_ETS(x), 1).plot_alpha(env, ['MPPSBH element ', num2str(i)]);
    Contributions.contribution_MPPSBH_element_i(x, i).plot_alpha(env, ['MPPSBH element ', num2str(i), ' contribution']);
    % sgt = sgtitle('Comparaison du module ETS avec ses élements constitutifs');
    % sgt.FontSize = 10;
end