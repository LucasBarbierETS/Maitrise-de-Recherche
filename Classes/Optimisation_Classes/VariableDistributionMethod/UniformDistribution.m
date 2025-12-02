classdef UniformDistribution

    methods (Static)

        function val = setValues(variable, number)

            val = variable.lowerBound + rand(1, number) * (variable.upperBound - variable.lowerBound);
        end
    end
end