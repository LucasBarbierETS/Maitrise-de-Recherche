function path = get_full_path(panel)
    path = panel.Title;
    parent = panel.Parent;
    while ~isa(parent, 'matlab.ui.Figure')
        path = [get(parent, 'Title'), ' > ', path]; %#ok<AGROW>
        parent = parent.Parent;
    end
end