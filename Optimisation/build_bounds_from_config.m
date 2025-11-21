function [lb, ub, intcon] = build_bounds_from_config(Config)
    NS  = Config.NS;
    NV  = Config.NV;
    N   = Config.N;
    Vars = Config.Variables;

    % bornes d’UNE plaque, pour UNE solution
    lb_single = cellfun(@(v) v.lb, Vars);
    ub_single = cellfun(@(v) v.ub, Vars);

    switch Config.Structure
        case "flat"
            % NS solutions, NV vars chacune
            lb = repmat(lb_single, 1, NS);
            ub = repmat(ub_single, 1, NS);

        case "stack"
            % NS solutions, N plaques, NV vars/ plaque
            lb = repmat(lb_single, 1, NS * N);
            ub = repmat(ub_single, 1, NS * N);

        otherwise
            error("Structure inconnue : %s", Config.Structure);
    end

    % Variables entières (pw ici)
    D = numel(lb);
    isIntMask = false(1, D);

    for iv = 1:NV
        if isfield(Vars{iv}, 'isInt') && Vars{iv}.isInt
            isIntMask(iv:NV:D) = true;
        end
    end

    intcon = find(isIntMask);
end