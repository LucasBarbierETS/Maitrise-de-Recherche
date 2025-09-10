function perso_plot_admittance_matrix(YM, env)

    % figure('Name', name)
    f = env.w / (2*pi);

    % Y11
    subplot(4, 2, 1)
    plot(f, real(YM.Y11));
    title('Re(Y11)')

    subplot(4, 2, 2)
    plot(f, imag(YM.Y11));
    title('Im(Y11)');

    % Y12
    subplot(4, 2, 3)
    plot(f, real(YM.Y12));
    title('Re(Y12)');

    subplot(4, 2, 4)
    plot(f, imag(YM.Y12));
    title('Im(Y12)');
   
    % Y21
    subplot(4, 2, 5)
    plot(f, real(YM.Y21));
    title('Re(Y21)');

    subplot(4, 2, 6)
    plot(f, imag(YM.Y21));
    title('Im(Y21)');

    % Y22
    subplot(4, 2, 7)
    plot(f, real(YM.Y22));
    title('Re(Y22)');

    subplot(4, 2, 8)
    plot(f, imag(YM.Y22));
    title('Im(Y22)');
end