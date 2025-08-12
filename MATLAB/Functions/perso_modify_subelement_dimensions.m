function subelement = perso_modify_subelement_dimensions(subelement, new_width, new_depth)

    config = subelement.Configuration;
    current_surface = config.Surface;
    current_section = config.Section;
    [subelement.Configuration.Width, w] = deal(new_width);
    [subelement.Configuration.Depth, d] = deal(new_depth);
    [subelement.Configuration.Surface, s] = deal(w * d);
    surface_ratio = s/current_surface;
    subelement.Configuration.Section = current_section * surface_ratio;
end
