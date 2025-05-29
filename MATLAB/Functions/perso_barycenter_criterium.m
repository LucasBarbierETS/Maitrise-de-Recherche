function b = perso_barycenter_criterium(list_pw, pw_min, pw_max)
    
    % Cette fonction regarde si les fentes les plus larges sont plutôt
    % placées en haut ou en bas de la configuration. Pour cela on pondère
    % le nombre de perforation par la distance au milieu, positivement ou
    % négativement selon l'indice de la plaque.
    % La configuration de barycentre la plus exterme correspond à une
    % configuration avec la moitié des plaques à la valeur max et
    % l'autre moitié à la valeur min

    list_max =  horzcat(repmat(pw_max, 1, length(list_pw)/2), repmat(pw_min, 1, length(list_pw)/2));

    b = 0;
    b_max = 0;
    for i = 1:length(list_pw)
        % On pondère positivement les plaques du haut et négativement les plaques du bas
        b = b + list_pw(i) * -(i - (length(list_pw) + 1)/2);
        b_max = b_max + list_max(i) * -(i - (length(list_max) + 1)/2);
    end

    % On normalise par la valeur la plus extreme pour ramener le critère
    % entre -1 et 1.
    b = b/b_max;
end