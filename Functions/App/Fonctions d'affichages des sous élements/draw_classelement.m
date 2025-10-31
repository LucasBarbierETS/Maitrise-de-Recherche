function h = draw_classelement(env, obj, ax, varargin)
    imgPath = fullfile([env,Root, '\Fonctions d''affichages des sous élements\Pictogrammes\Element.png']);
    h = draw_png_with_border(env, obj, ax, imgPath, varargin{:});
end