function h = draw_classQWL_Circle(env, obj, ax)
    imgPath = fullfile([env.Root, '\Functions\App\Fonctions d''affichages des sous élements\Pictogrammes\QWL Circle.png']);
    h = draw_png_with_border(obj, ax, imgPath, 'picto_QWL_Circle');
end