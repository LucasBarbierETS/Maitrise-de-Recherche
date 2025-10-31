function h = draw_classQWL_Circle(ax, x, y)
    imgPath = fullfile('C:\Users\lucas.barbier\Documents\Maitrise ETS\Répertoire GitHub\Functions\App\Fonctions d''affichages des sous élements\Pictogrammes\QWL Circle.png');
    h = draw_png_with_border(ax, x, y, imgPath, 'picto_QWL_Circle');
end