function h = draw_classQWL_Slit(env, obj, ax)
    imgPath = fullfile([env.Root, '\Functions\App\Fonctions d''affichages des sous élements\Pictogrammes\QWL Slit.png']);
    h = draw_png_with_border(obj, ax, imgPath, 'picto_QWL_slit');
end