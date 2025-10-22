function perso_set_app_interactivity(app, state)

    comps = app.UIFigure.Children;
    for k = 1:numel(comps)
        if isprop(comps(k), 'Enable')
            if strcmp(state, 'on')
                comps(k).Enable = 'on';
            elseif strcmp(state,'off')
                comps(k).Enable = 'off';
            end
        end
    end
end