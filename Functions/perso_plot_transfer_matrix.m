function perso_plot_transfer_matrix(TM, env, name, varargin)

    f = env.w / (2*pi);

    if nargin > 3
        x_max = varargin{1};
    else
        x_max = 2000;
    end

    % T11
    subplot(4, 2, 1)
    hold on
    plot(f, real(TM.T11), 'DisplayName', name);
    title('Re(T11)')
    xlim([0 x_max])

    subplot(4, 2, 2)
    hold on
    plot(f, imag(TM.T11), 'DisplayName', name);
    title('Im(T11)');
    xlim([0 x_max])

    % T12
    subplot(4, 2, 3)
    hold on
    plot(f, real(TM.T12), 'DisplayName', name);
    title('Re(T12)');
    xlim([0 x_max])

    subplot(4, 2, 4)
    hold on
    plot(f, imag(TM.T12), 'DisplayName', name);
    title('Im(T12)');
    xlim([0 x_max])
   
    % T21
    subplot(4, 2, 5)
    hold on
    plot(f, real(TM.T21), 'DisplayName', name);
    title('Re(T21)');
    xlim([0 x_max])

    subplot(4, 2, 6)
    hold on
    plot(f, imag(TM.T21), 'DisplayName', name);
    title('Im(T21)');
    xlim([0 x_max])

    % T22
    subplot(4, 2, 7)
    hold on
    plot(f, real(TM.T22), 'DisplayName', name);
    title('Re(T22)');
    xlim([0 x_max])

    subplot(4, 2, 8)
    hold on
    plot(f, imag(TM.T22), 'DisplayName', name);
    title('Im(T22)');
    xlim([0 x_max])
end