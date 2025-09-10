function output_model = perso_add_selection_to_physics(input_model, physics_name, selection_box_name)
    
    % On récupère les domaines déja associés à la physique
    model = input_model;
    current_selections = model.physics(physics_name).selection.entities;
    new_selections = model.selection(selection_box_name).entities;
    updated_selections = vertcat(current_selections, new_selections);
    model.physics(physics_name).selection.set(updated_selections);
    output_model = model;
end