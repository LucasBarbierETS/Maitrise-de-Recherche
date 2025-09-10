function perso_plot_alpha(solution, env, varargin)
    
    plot(env.w/(2*pi), solution.alpha(env), 'DisplayName', 'Meilleure solution');
    
    if nargin > 2
        plot(env.w/(2*pi), varargin{1}(env), '--', 'DisplayName', 'Gabarit');
    end

    title('Visualisation de l''optimisation en cours');
    xlabel('Fréquence (Hz)');
    ylabel('Coefficient d''absorption');
    legend()
end