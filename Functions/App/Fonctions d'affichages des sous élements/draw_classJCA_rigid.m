function h = draw_classJCA_rigid(env, obj, ax, varargin)
    imgPath = fullfile([env.Root, '\Functions\App\Fonctions d''affichages des sous élements\Pictogrammes\Porous.png']);
    h = draw_png_with_border(obj, ax, imgPath, varargin{:});
end