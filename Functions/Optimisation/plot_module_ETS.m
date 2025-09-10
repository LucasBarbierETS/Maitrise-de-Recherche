function plot_module_ETS(x, x_ETS, Objets, Modules, env)

    % Debog : Comparaison du module ETS avec ses élements constitutifs
    figure();
    hold on
    Objets.MPPSBH_element_i(x_ETS(x), 1).plot_alpha(env, 'élement MPPSBH 1');
    Objets.MPPSBH_element_i(x_ETS(x), 2).plot_alpha(env, 'élement MPPSBH 2');
    Objets.MPPSBH_element_i(x_ETS(x), 3).plot_alpha(env, 'élement MPPSBH 3');
    Objets.MPPSBH_element_i(x_ETS(x), 4).plot_alpha(env, 'élement MPPSBH 4');
    Objets.MPPSBH_element_i(x_ETS(x), 5).plot_alpha(env, 'élement MPPSBH 5');
    Objets.MPPSBH_element_i(x_ETS(x), 6).plot_alpha(env, 'élement MPPSBH 6');
    Objets.MPPSBH_element_i(x_ETS(x), 7).plot_alpha(env, 'élement MPPSBH 7');
    Objets.MPPSBH_element_i(x_ETS(x), 8).plot_alpha(env, 'élement MPPSBH 8');
    Modules.module_ETS_sans_HR(x).plot_alpha(env, 'Module ETS sans HR');  
    Modules.module_ETS(x).plot_alpha(env, 'Module ETS');
    sgt = sgtitle('Comparaison du module ETS avec ses élements constitutifs');
    sgt.FontSize = 10;
end