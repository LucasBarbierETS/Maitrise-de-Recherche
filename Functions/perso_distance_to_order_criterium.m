function dist = perso_distance_to_order_criterium(list_pw)
    
    % Cette fonction mesure la somme des distances entre la position des nombre
    % de perforations et leur position associée dans la configuration triée

    index = linspace(1, length(list_pw), length(list_pw))';
    index_reverse = linspace(length(list_pw), 1, length(list_pw))';
    d_max = sum((index_reverse - index).^2);
    [~, sorted_index] = sort(list_pw, 1, 'descend');
    d = sum((sorted_index - index).^2);
    dist = d / d_max;
end