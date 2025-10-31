function h = draw_classjunction(ax, x, y)
    imgPath = fullfile('C:\Users\lucas.barbier\Documents\Maitrise ETS\Répertoire GitHub\Functions\App\Fonctions d''affichages des sous élements\Pictogrammes\Junction.png');
    h = draw_png_with_border(ax, x, y, imgPath, 'picto_junction');
end