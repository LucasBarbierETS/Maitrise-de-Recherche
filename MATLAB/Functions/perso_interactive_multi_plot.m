function perso_interactive_multi_plot(x, y, mean_bf, mean_lb_hf)
    % data : Cell array contenant les coordonnées de chaque tracé {x, y}
    
    % Paramètres initiaux
    currentIndex = 1;
    numPlots = size(y, 2);
    
    % Créer la figure
    fig = figure('Name', 'Multi-tracé interactif', ...
                 'NumberTitle', 'on', ...
                 'Position', [100, 100, 800, 600]);

    % Créer l'axe pour le tracé
    ax = axes('Parent', fig, 'Position', [0.1, 0.2, 0.8, 0.7]);
    hPlot = plot(ax, x, y{currentIndex}, 'LineWidth', 1);
    mean_bf_line = yline(ax, mean_bf{currentIndex}, '--b', sprintf('Moyenne 150-400 : %.2f', mean_bf{currentIndex}), 'LabelHorizontalAlignment', 'left', 'LabelVerticalAlignment', 'top');
    mean_lb_hf_line = yline(ax, mean_lb_hf{currentIndex}, '--r', sprintf('Moyenne 150-1500 : %.2f', mean_lb_hf{currentIndex}), 'LabelHorizontalAlignment', 'right', 'LabelVerticalAlignment', 'bottom');
    title(ax, sprintf('Tracé %d / %d', currentIndex, numPlots));
    perso_configure_alpha_figure(2000);
    grid on;
    legend("off");
    
    % Bouton Précédent
    btnPrev = uicontrol('Style', 'pushbutton', 'String', '<', ...
                        'Position', [50, 50, 50, 30], ...
                        'Callback', @(~,~) navigate(-1));
    
    % Bouton Suivant
    btnNext = uicontrol('Style', 'pushbutton', 'String', '>', ...
                        'Position', [700, 50, 50, 30], ...
                        'Callback', @(~,~) navigate(1));
                    
    % Fonction de navigation
    function navigate(direction)
        % Mettre à jour l'index en fonction de la direction (-1 ou 1)
        currentIndex = currentIndex + direction;
        % Boucle pour les extrémités
        if currentIndex < 1
            currentIndex = numPlots;
        elseif currentIndex > numPlots
            currentIndex = 1;
        end
        % Mettre à jour le tracé
        set(hPlot, 'XData', x, ...
                   'YData', y{currentIndex});
        set(mean_bf_line, 'Value', mean_bf{currentIndex}, ...
                          'Label', ['Moyenne 150-400 Hz: ', num2str(mean_bf{currentIndex}, 2)]);
        set(mean_lb_hf_line, 'Value', mean_lb_hf{currentIndex}, ...
                             'Label', ['Moyenne 150-1500 Hz: ', num2str(mean_lb_hf{currentIndex}, 2)]);
        title(ax, sprintf('Tracé %d / %d', currentIndex, numPlots));
    end
end
