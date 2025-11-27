function perso_interactive_multi_plot(x, alpha, Zs, f_max, Frequences)
% perso_interactive_multi_plot
% - x           : vecteur des fréquences (mêmes longueurs que les Y)
% - alpha       : cell(1,N), chaque cell -> [2 x numel(x)] (ligne1: globale, ligne2: HL fp)
% - Zs          : cell(1,N), chaque cell -> [2 x numel(x)] (complexe autorisé)
% - f_max       : max pour config de l’axe X
% - Frequences  : struct avec f_min_* et f_max_* (lb, h1..h4)
%
% Deux fenêtres :
%   figAlpha : α (une axe unique)
%   figZs    : Re(Zs) et Im(Zs) (deux subplots)
%
% Navigation : boutons <, > et clavier (←/→)

    % --- État ---
    currentIndex = 1;
    numPlots     = size(alpha, 2);

    % --- Fenêtre 1 : α ---
    figAlpha = figure('Name','Multi-tracé interactif (α)', ...
        'NumberTitle','on','Position',[100 100 900 600], ...
        'KeyPressFcn',@onKey); % clavier global

    s_alpha = subplot(1,1,1,'Parent',figAlpha);
    hold(s_alpha,'on'); box(s_alpha,'on');

    yA = alpha{currentIndex}; % [2 x numel(x)]
    hAlpha = plot(s_alpha, x, yA, 'DisplayName', 'Modèle');
    
    addBands(s_alpha, Frequences);
    title(s_alpha, sprintf('α — Tracé %d / %d', currentIndex, numPlots));
    perso_configure_alpha_figure(f_max);
    legend(s_alpha,'Location','best');

    % Boutons
    uicontrol(figAlpha,'Style','pushbutton','String','<', ...
        'Position',[40 20 40 28],'Callback',@(~,~)navigate(-1));
    uicontrol(figAlpha,'Style','pushbutton','String','>', ...
        'Position',[820 20 40 28],'Callback',@(~,~)navigate(1));

    % --- Fenêtre 2 : Zs ---
    figZs = figure('Name','Multi-tracé interactif (Z_s)', ...
        'NumberTitle','on','Position',[1050 120 900 600], ...
        'KeyPressFcn',@onKey); % même navigation clavier

    s_zs_real = subplot(2,1,1,'Parent',figZs, 'ylim', [0 30]);
    hold(s_zs_real,'on'); box(s_zs_real,'on');
    s_zs_imag = subplot(2,1,2,'Parent',figZs, 'ylim', [-10 10]);
    hold(s_zs_imag,'on'); box(s_zs_imag,'on');

    yZ = Zs{currentIndex}; % [2 x numel(x)] (complexe)
    % Réel
    hZR = plot(s_zs_real, x, real(yZ), 'DisplayName','Modèle');

    addBands(s_zs_real, Frequences);
    ylabel(s_zs_real,'Re(Z_s/Z_0)');
    title(s_zs_real, 'Partie réelle');

    % Imaginaire
    hZI = plot(s_zs_imag, x, imag(yZ), 'DisplayName','Modèle');
    
    addBands(s_zs_imag, Frequences);
    xlabel(s_zs_imag,'f (Hz)'); ylabel(s_zs_imag,'Im(Z_s/Z_0)');
    title(s_zs_imag, sprintf('Z_s/Z_0 — Tracé %d / %d', currentIndex, numPlots));

    legend(s_zs_real,'Location','best');
    legend(s_zs_imag,'Location','best');

    % Lier les axes X de toutes les figures
    linkaxes([s_alpha, s_zs_real, s_zs_imag],'x');

    % --- Navigation au clavier ---
    function onKey(~,evt)
        switch evt.Key
            case {'rightarrow','numpad6'}
                navigate(1);
            case {'leftarrow','numpad4'}
                navigate(-1);
        end
    end

    % --- Navigation principale ---
    function navigate(direction)
        currentIndex = currentIndex + direction;
        if currentIndex < 1
            currentIndex = numPlots;
        elseif currentIndex > numPlots
            currentIndex = 1;
        end

        % α
        yA = alpha{currentIndex};
        set(hAlpha,'XData',x,'YData',yA);
        title(s_alpha, sprintf('α — Tracé %d / %d', currentIndex, numPlots));

        % Z_s
        yZ = Zs{currentIndex};
        set(hZR,'XData',x,'YData',real(yZ));
        set(hZI,'XData',x,'YData',imag(yZ));
        title(s_zs_imag, sprintf('Z_s — Tracé %d / %d', currentIndex, numPlots));
        % (titres des axes conservés)
        drawnow;
    end
end

% --- Utilitaire : bandes colorées sur un axes donné ---
function addBands(ax, F)

    % Bande large (lb)
    % patch('Parent',ax, ...
    %       'XData',[F.f_min_lb F.f_min_lb F.f_max_lb F.f_max_lb], ...
    %       'YData',[ax.YLim(1) ax.YLim(2) ax.YLim(2) ax.YLim(1)], ...
    %       'FaceColor',[0 1 0],'FaceAlpha',0.12,'EdgeColor','none', ...
    %       'DisplayName','Bande optimisation (élargie)', ...
    %       'HandleVisibility','off');

    % H1..H4 en rouge
    drawBand(ax, F.f_min_h1, F.f_max_h1, 'bande 1 (BPF)');
    drawBand(ax, F.f_min_h2, F.f_max_h2, 'bande 2 (H1)');
    drawBand(ax, F.f_min_h3, F.f_max_h3, 'bande 3 (H2)');
    drawBand(ax, F.f_min_h4, F.f_max_h4, 'bande 4 (H3)');

    % Ajuster pour que les patchs couvrent bien l’axe
    uistack(findobj(ax,'Type','patch'),'bottom');
end

function drawBand(ax, fmin, fmax, name)
    yl = ax.YLim;
    patch('Parent',ax, ...
          'XData',[fmin fmin fmax fmax], ...
          'YData',[yl(1) yl(2) yl(2) yl(1)], ...
          'FaceColor',[1 0 0],'FaceAlpha',0.12,'EdgeColor','none', ...
          'DisplayName',name,'HandleVisibility','off');
end