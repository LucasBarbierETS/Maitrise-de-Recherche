function h = draw_none(env, obj, ax, varargin)
    imgPath = fullfile([env.Root, '\Functions\App\Fonctions d''affichages des sous élements\Pictogrammes\None.png']);
    h = draw_png_with_border(obj, ax, imgPath, varargin{:});
end
