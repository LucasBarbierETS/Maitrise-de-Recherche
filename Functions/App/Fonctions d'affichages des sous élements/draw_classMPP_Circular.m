function h = draw_classMPP_Circular(obj, ax, varargin)
    imgPath = fullfile('C:\Users\lucas.barbier\Documents\Maitrise ETS\Répertoire GitHub\Functions\App\Fonctions d''affichages des sous élements\Pictogrammes\MPP.png');
    h = draw_png_with_border(obj, ax, imgPath, varargin{:});
end