function output_model = perso_add_selection_to_multiphysics(input_model, multiphysics_name, selection_box_name)
    
    % On récupère les domaines déja associés à la physique
    model = input_model;
    current_selections = model.multiphysics(multiphysics_name).selection.entities;
    new_selections = model.selection(selection_box_name).entities;
    updated_selections = vertcat(current_selections, new_selections);
    model.multiphysics(multiphysics_name).selection.set(updated_selections);
    output_model = model;
end