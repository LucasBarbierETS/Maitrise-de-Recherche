function subelement = perso_modify_subelement_dimensions(subelement, new_width, new_depth)

    [subelement.Configuration.Width, w] = deal(new_width);
    [subelement.Configuration.Depth, d] = deal(new_depth);
    subelement.Configuration.Section = w * d;
end
