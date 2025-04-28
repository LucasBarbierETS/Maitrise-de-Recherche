function plot_handle = perso_plot_with_gradient(color1, color2, N)
    % Convertit les couleurs en format RGB si elles sont données en chaînes de caractères
    if ischar(color1)
        color1 = get_rgb(color1);
    end
    if ischar(color2)
        color2 = get_rgb(color2);
    end
    
    % Vérifie que les couleurs sont valides
    if ~isvector(color1) || length(color1) ~= 3 || ~isvector(color2) || length(color2) ~= 3
        error('Les couleurs doivent être des triplets RGB ou des chaînes de caractères valides.');
    end
    
    % Crée une fonction handle qui automatise le dégradé de couleur
    function h = custom_plot(idx, varargin)
        % Vérifie que l'index est valide
        if idx < 1 || idx > N
            error('L''index doit être compris entre 1 et %d.', N);
        end
        
        % Calcule la couleur intermédiaire
        t = (idx - 1) / (N - 1);  % Normalisation entre 0 et 1
        color = (1 - t) * color1 + t * color2;
        
        % Appelle la fonction plot native avec la couleur et les arguments supplémentaires
        h = plot(varargin{:}, 'Color', color);
    end

    % Retourne le handle de la fonction custom_plot
    plot_handle = @custom_plot;
end

% Fonction pour convertir une couleur en chaîne de caractères en RGB
function rgb = get_rgb(color_str)
    color_map = struct( ...
        'b', [0, 0, 1], ...  % Bleu
        'g', [0, 1, 0], ...  % Vert
        'r', [1, 0, 0], ...  % Rouge
        'c', [0, 1, 1], ...  % Cyan
        'm', [1, 0, 1], ...  % Magenta
        'y', [1, 1, 0], ...  % Jaune
        'k', [0, 0, 0], ...  % Noir
        'w', [1, 1, 1]);     % Blanc
    
    if isfield(color_map, color_str)
        rgb = color_map.(color_str);
    else
        error('Couleur non reconnue : %s', color_str);
    end
end