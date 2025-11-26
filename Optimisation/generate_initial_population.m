function X0 = generate_initial_population(Config, NP, initType)
    if nargin < 3
        initType = "random";
    end

    NS = Config.NS;
    N  = Config.N;
    NV = Config.NV;

    switch Config.Structure
        case "flat"
            D = NS * NV;
        case "stack"
            D = NS * N * NV;
        otherwise
            error("Structure inconnue : %s", Config.Structure);
    end

    % matrice uniforme [0,1]
    switch lower(initType)
        case "random"
            U = rand(NP, D);

        case "latin"
            U = lhsdesign(NP, D, 'criterion','maximin','iterations',50);

        otherwise
            warning("Type d'initialisation inconnu (%s), random utilisé.", initType);
            U = rand(NP, D);
    end

    [lb, ub, ~] = build_bounds_from_config(Config);

    % assure lb,ub en row
    lb = lb(:).';
    ub = ub(:).';

    X0 = bsxfun(@plus, lb, bsxfun(@times, U, (ub - lb)));
end
