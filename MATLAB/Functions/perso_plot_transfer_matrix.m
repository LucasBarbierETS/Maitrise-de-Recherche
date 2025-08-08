function perso_plot_transfer_matrix(TM, env)

    % figure('Name', name)
    f = env.w / (2*pi);

    % T11
    subplot(4, 2, 1)
    plot(f, real(TM.T11));
    title('Re(T11)')

    subplot(4, 2, 2)
    plot(f, imag(TM.T11));
    title('Im(T11)');

    % T12
    subplot(4, 2, 3)
    plot(f, real(TM.T12));
    title('Re(T12)');

    subplot(4, 2, 4)
    plot(f, imag(TM.T12));
    title('Im(T12)');
   
    % T21
    subplot(4, 2, 5)
    plot(f, real(TM.T21));
    title('Re(T21)');

    subplot(4, 2, 6)
    plot(f, imag(TM.T21));
    title('Im(T21)');

    % T22
    subplot(4, 2, 7)
    plot(f, real(TM.T22));
    title('Re(T22)');

    subplot(4, 2, 8)
    plot(f, imag(TM.T22));
    title('Im(T22)');
end