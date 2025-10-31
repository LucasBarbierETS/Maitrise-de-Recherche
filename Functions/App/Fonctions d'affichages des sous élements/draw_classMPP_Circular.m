function h = draw_classMPP_Circular(env, obj, ax, varargin)
    imgPath = fullfile([env.Root, '\Functions\App\Fonctions d''affichages des sous élements\Pictogrammes\MPP.png']);
    h = draw_png_with_border(obj, ax, imgPath, varargin{:});
end