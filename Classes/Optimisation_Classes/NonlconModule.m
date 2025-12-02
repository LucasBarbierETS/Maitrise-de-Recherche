classdef NonlconModule

    properties

        inequalityConstraints % cell
        equalityConstraints % cell
    end

    methods
        function obj = NonlconModule(inequality_constraints, equality_constraints)
 
            obj.inequalityConstraints = inequality_constraints;
            obj.equalityConstraints = equality_constraints;
        end

        function [c, ceq] = getConstraints(obj, x)

            c = []; ceq = [];
            for i = 1:length(obj.inequalityConstraints)
                c = horzcat(c, obj.inequalityConstraints{i}.getConstraints(x));
            end

            for j = 1:length(obj.equalityConstraints)
                ceq = horzcat(ceq, obj.equalityConstraints{i}.getConstraints(x));
            end   
        end
    end
end