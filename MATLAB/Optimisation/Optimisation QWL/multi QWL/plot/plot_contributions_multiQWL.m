function plot_contributions_multi_QWL(multiQWL, shape, air, w)
    
    QWL = @classQWL;
    config = multiQWL.Configuration
    n = length(config)/3;
    R = config(1:n);
    r = config(n+1:2*n);
    L = config(2*n+1:end);
    main_radius = sqrt(sum(R.^2));

    param_air = air.parameters;
    Z0 = param_air.Z0;

    for i = 1:n
        qwl_i = QWL(main_radius, r(i), L(i), shape);
        TM_i = qwl_i.transferMatrix(air, w);
        phi_i = r(i)^2/main_radius^2;
        Zs_i = TM_i.T11./TM_i.T21;
        alpha_model_i = 1 - abs((Zs_i/phi_i - Z0)./(Zs_i/phi_i + Z0)).^2;
    
        plot(w/(2*pi), alpha_model_i, 'LineWidth', 1.5, 'DisplayName', ['Résonateur' num2str(i)]);
        hold on;
    end

    title("Contributions des résonateurs quart d'onde");
    xlabel('Fréquence (Hz)');
    ylabel('Coefficient d''absorption');
    legend('Location', 'Best');
    grid on;
    hold off;

end 