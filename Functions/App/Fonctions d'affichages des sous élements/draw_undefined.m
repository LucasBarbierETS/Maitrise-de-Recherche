function h = draw_undefined(ax, x, y)
    imgPath = fullfile('C:\Users\lucas.barbier\Documents\Maitrise ETS\Répertoire GitHub\Functions\App\Fonctions d''affichages des sous élements\Pictogrammes\Undefined.png');
    h = draw_png_with_border(ax, x, y, imgPath, 'picto_undefined');
end