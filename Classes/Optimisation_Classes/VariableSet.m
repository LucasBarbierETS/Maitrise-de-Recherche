classdef VariableSet

    properties

        children % cell
    end

    methods
        function obj = VariableSet(children)

            obj.children = children;
        end

        function val = generateValues(obj, number, method)
            
            values_cell = cellfun(@(child) child.getValues(number, method), obj.children, ...
                'UniformOutput', false);
            val = horzcat(values_cell{:});
        end
    end
end

