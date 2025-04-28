function d = profilSBH (distance_between_perforated_areas, first_perforated_area_dimension, last_perforated_area_dimension, order)
    % Cette fonction retourne une handle function qui associe à une abscisse, la valeur du profil (largeur, longueur, rayon)
        
    L = distance_between_perforated_areas;
    din = first_perforated_area_dimension;
    dend = last_perforated_area_dimension;
    n = order;
    d = @(x_position) (din - dend)/L^n * (L - x_position).^n + dend;
end 

