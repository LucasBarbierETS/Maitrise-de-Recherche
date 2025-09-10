classdef AppPanel < AppComponent

    methods
        function obj = AppPanel(ui_object, name)
            obj@AppComponent(ui_object, name)
        end

        function clean(obj)
            editfields = findall(obj.UIObject.Children, 'type', 'uieditfield');
            for i = 1:length(editfields)
                editfields(i).Value = '';
            end
        end
    end
end