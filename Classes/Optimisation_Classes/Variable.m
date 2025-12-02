classdef VariableType

    properties

        name % string
        lowerBound % double
        upperBound % double
        isInteger % bool
        isDiscrete % bool
        admittedValues % double
    end

    methods
        function obj = VariableType(name, lower_bound, upper_bound, is_integer, options)

            arguments
                name
                lower_bound
                upper_bound
                is_integer = false
                options.is_discrete = false
                options.admitted_values  = NaN;
            end

            obj.name = name;
            obj.lowerBound = lower_bound;
            obj.upperBound = upper_bound;
            obj.isInteger = is_integer;
            obj.isDiscrete = options.is_discrete;
            obj.admittedValues = options.admitted_values;
        end

        function val = setValues(number, method)

            val = method.setValues(obj, number);
        end
    end
end