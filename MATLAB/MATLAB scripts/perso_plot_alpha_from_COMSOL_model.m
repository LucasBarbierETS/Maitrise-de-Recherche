function alpha_COMSOL = perso_plot_alpha_from_COMSOL_model(model, name, varargin)
    
    data = mphtable(model, 'tbl1').data;
    if nargin > 2
        color = varargin{1};
    else
        color = perso_random_color_rgb_triplet();
    end
    alpha_COMSOL = data(:, 2);
    plot(data(:, 1), alpha_COMSOL,'Color', color, 'DisplayName', name)
end