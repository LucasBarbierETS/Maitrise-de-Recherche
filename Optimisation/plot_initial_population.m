function plot_initial_population(X0, Config)
    NS   = Config.NS;
    NV   = Config.NV;
    Vars = Config.Variables;

    % --- Boxplots par variable ---
    figure;
    tiledlayout(NV,1,"TileSpacing","compact");

    for iv = 1:NV
        name = Vars{iv}.name;
        % pour structure stack : les colonnes iv, iv+NV, iv+2NV, ...
        idx  = iv:NV:(size(X0,2));

        nexttile;
        hold on; grid on;
        boxchart(X0(:, idx));
        title("Distribution variable : " + name);
        xlabel("Index (plaque×solution)");
        ylabel(name);
    end

    % --- Scatter global ---
    figure; hold on; grid on;
    colors = lines(NV);
    for iv = 1:NV
        name = Vars{iv}.name;
        idx  = iv:NV:(size(X0,2));
        x_idx = repelem(1:numel(idx), size(X0,1));
        y_val = X0(:, idx);
        scatter(x_idx, y_val(:), 10, 'filled', 'MarkerFaceColor', colors(iv,:));
    end
    title("Scatter toutes variables vs index");
    xlabel("Index variable (plaque×solution)");
    ylabel("Valeur");
end