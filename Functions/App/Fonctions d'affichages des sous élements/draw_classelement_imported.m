function h = draw_classelement_imported(env, obj, ax, varargin)
    imgPath = fullfile([env.Root, '\Functions\App\Fonctions d''affichages des sous élements\Pictogrammes\Imported Element.png']);
    h = draw_png_with_border(env, obj, ax, imgPath, varargin{:});
end
