function plot_impedance_roots_complex(Zx, omega, rho0, b)
    % Fonction pour calculer et afficher les racines complexes kx et kz dans un graphe complexe

    % Zx : Impédance de surface donnée (valeur scalaire ou vecteur)
    % omega : Fréquence angulaire (en rad/s)
    % rho0 : Densité de l'air (en kg/m^3)
    % b : Dimension géométrique caractéristique de la conduite (en mètres)

    % Initialisation de la fonction à résoudre
    func = @(k) -1i * omega * rho0 ./ k .* tan(k * b) - Zx;

    % Plage de recherche initiale pour les racines complexes (valeurs de kx)
    k_guess = linspace(0.1, 20, 100); % Plage des guesses pour kx (en rad/m)

    % Résolution des racines avec fsolve (méthode de résolution numérique)
    options = optimset('Display','off');  % Suppression des messages de fsolve
    roots_kx = NaN(size(k_guess));       % Initialiser un tableau pour les racines
    roots_kz = NaN(size(k_guess));       % Initialiser un tableau pour les racines kz

    % Calcul des racines complexes
    for i = 1:length(k_guess)
        k_solution = fsolve(func, k_guess(i), options);  % Trouver la racine complexe pour kx
        if ~isnan(k_solution)
            % Calcul de kz à partir de kx, en utilisant la relation de dispersion complexe
            kz_solution = sqrt(omega^2 / rho0^2 - k_solution.^2);  % k_z complexe

            % Sauvegarde des valeurs
            roots_kx(i) = k_solution;
            roots_kz(i) = kz_solution;
        end
    end
    
    % Tracer les racines dans le plan complexe
    figure;
    plot(real(roots_kx), imag(roots_kx), 'bo'); % kx (réel) vs kx (imaginaire)
    hold on;
    plot(real(roots_kz), imag(roots_kz), 'r*'); % kz (réel) vs kz (imaginaire)
    title('Racines complexes de k_x et k_z');
    xlabel('Partie réelle');
    ylabel('Partie imaginaire');
    legend('k_x (réel vs imaginaire)', 'k_z (réel vs imaginaire)');
    grid on;
    hold off;
end
