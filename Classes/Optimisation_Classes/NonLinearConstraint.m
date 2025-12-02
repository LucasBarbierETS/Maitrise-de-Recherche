classdef NonLinearConstraint

    properties
        
        handleFunction % handle 
        handleConfig % double (nb_var * nb_eval)
    end

    methods 
        function obj = NonLinearConstraint(handle_function, handle_config)

            obj.handleFunction = handle_function;
            obj.handleConfig = handle_config;
        end

        function c = getConstraints(obj, x) % double (1, nb_eval)
            
            % On évalue la contrainte pour chaque colonne des variables configurées
            config = obj.handleConfig(x);
            c = arrayfun(@(i) obj.handleFunction(config(:, i), 1:size(obj.handleConfig(2))));
        end
    end
end

