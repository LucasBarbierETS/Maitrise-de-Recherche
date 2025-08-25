function perso_plot_surface_admittance(Ys, env, name)

    % Partie réelle
    subplot(2, 1, 1)
    hold on
    xlabel('Fréquence (Hz)')
    ylabel('Re(Ys*Z0)')
    % ylim([0 30])

    ReYs = real(Ys*env.air.parameters.Z0);
    ImYs = imag(Ys*env.air.parameters.Z0);

    mask = ImYs(1:end-1) .* ImYs(2:end) < 0;
    % f0 = f(mask);
    % ReZs0 = ReZs(mask);

    % for i = 1:length(f0)
    %     xline(f0(i), '--', 'Label', [num2str(f0(i)), ' Hz'], 'HandleVisibility', 'off')
    %     % yline(ReZs0(i), '--', 'HandleVisibility', 'off')
    % end

    plot(env.w/(2*pi), ReYs, 'DisplayName', name);
    yline(1, '--', 'HandleVisibility', 'off');
    legend('Location', 'best');

    % Partie imaginaire
    subplot(2, 1, 2)
    hold on
    xlabel('Fréquence (Hz)')
    ylabel('Im(Ys*Z0)')
    ylim([-10 10])
    
    % for i = 1:length(f0)
    %     xline(f0(i), '--', 'HandleVisibility', 'off')
    % end
    plot(env.w/(2*pi), ImYs, 'DisplayName', name);
    yline(0, '--', 'HandleVisibility', 'off');
    legend('Location', 'best');
end