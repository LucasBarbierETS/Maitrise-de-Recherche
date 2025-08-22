function perso_plot_surface_impedance(f, Zs, env)

    % Partie réelle
    subplot(2, 1, 1)
    hold on
    xlabel('Fréquence (Hz)')
    ylabel('Re(Zs/Z0)')
    % ylim([0 30])

    ReZs = real(Zs/env.air.parameters.Z0);
    ImZs = imag(Zs/env.air.parameters.Z0);

    mask = ImZs(1:end-1) .* ImZs(2:end) < 0;
    % f0 = f(mask);
    % ReZs0 = ReZs(mask);

    % for i = 1:length(f0)
    %     xline(f0(i), '--', 'Label', [num2str(f0(i)), ' Hz'], 'HandleVisibility', 'off')
    %     % yline(ReZs0(i), '--', 'HandleVisibility', 'off')
    % end

    plot(f, ReZs, 'DisplayName', 'Partie réelle');
    yline(1, '--', 'HandleVisibility', 'off');
    legend('Location', 'best');

    % Partie imaginaire
    subplot(2, 1, 2)
    hold on
    xlabel('Fréquence (Hz)')
    ylabel('Im(Zs/Z0)')
    ylim([-10 10])
    
    % for i = 1:length(f0)
    %     xline(f0(i), '--', 'HandleVisibility', 'off')
    % end
    plot(f, ImZs, 'DisplayName', 'Partie imaginaire');
    yline(0, '--', 'HandleVisibility', 'off');
    legend('Location', 'best');
end