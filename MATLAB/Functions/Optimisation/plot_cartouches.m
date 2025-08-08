function plot_cartouches(x, Cartouches, env)
    
    % Debog : Comparaison des cartouches ETS et Poly
    figure();
    
    % Cartouche ETS
    subplot(2, 1, 1)
    Cartouches.cartouche_ETS(x).plot_alpha(env, 'Cartouche ETS');
    Cartouches.cartouche_ETS_contributions(x).plot_alpha(env, 'Cartouche ETS contributions');
    Cartouches.cartouche_ETS_sans_HR(x).plot_alpha(env, 'Cartouche ETS sans HR');
    Cartouches.cartouche_ETS_sans_HR_contributions(x).plot_alpha(env, 'Cartouche ETS sans HR contributions');
   
    % Cartouche Poly
    subplot(2, 1, 2)
    Cartouches.cartouche_Poly(x).plot_alpha(env, 'Cartouche Poly');
    Cartouches.cartouche_Poly_contributions(x).plot_alpha(env, 'Cartouche Poly contributions');
    Cartouches.cartouche_Poly_sans_HR(x).plot_alpha(env, 'Cartouche Poly sans HR')
    Cartouches.cartouche_Poly_sans_HR_contributions(x).plot_alpha(env, 'Cartouche Poly sans HR contributions');
end