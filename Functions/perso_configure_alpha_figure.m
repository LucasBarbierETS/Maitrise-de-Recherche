function perso_configure_alpha_figure(f_max)
    xlabel("Fréquence (Hz)")
    ylabel("Coefficient d'Absorption")
    xlim([0 f_max])
    ylim([0 1])
    legend('Location','best')
end

