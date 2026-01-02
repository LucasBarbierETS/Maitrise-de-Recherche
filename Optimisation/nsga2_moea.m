function [pop, f_pop] = nsga2_moea(problem, opts)
% NSGA2_MOEA - Implémentation simple de NSGA-II pour problèmes multi-objectifs
%
% Entrées :
%   problem.objective : @(x) -> [f1 f2 ...]
%   problem.lb, ub    : bornes
%   problem.intcon    : indices des variables entières
%   problem.nonlcon   : @(x) -> [c, ceq] (peut être [])
%   opts.PopSize      : taille de population
%   opts.MaxGen       : nb de générations
%   opts.Pc           : proba crossover
%   opts.Pm           : proba mutation
%   opts.EtaC, EtaM   : paramètres SBX / mutation
%   opts.PlotFcn      : cell array de handles (@myplot1, @myplot2)
%
% Sorties :
%   pop   : population finale (N x D)
%   f_pop : valeurs des objectifs (N x M)

    %% Lire les bornes et options
    lb = problem.lb(:).';
    ub = problem.ub(:).';
    D  = numel(lb);
    N  = opts.PopSize;
    G  = opts.MaxGen;

    Pc = opts.Pc;
    Pm = opts.Pm;
    eta_c = opts.EtaC;
    eta_m = opts.EtaM;

    hasInt   = ~isempty(problem.intcon);
    intcon   = problem.intcon;
    hasNonl  = ~isempty(problem.nonlcon);

    %% Gestion PlotFcn
    if isfield(opts, "PlotFcn") && ~isempty(opts.PlotFcn)
        plotFcns = opts.PlotFcn;
    else
        plotFcns = {};
    end

    %% === Initialisation ===
    % pop = rand(N, D) .* (ub - lb) + lb;
    % pop = apply_integer_and_bounds(pop, lb, ub, hasInt, intcon);
    pop = opts.x0;

    [f_pop, cons_viol] = eval_population(problem, pop, hasNonl);

    %% === Boucle NSGA-II ===
    for g = 1:G

        % --- Ranking + crowding ---
        [fronts, rank] = fast_nondominated_sort(f_pop, cons_viol);
        crowd = crowding_distance(f_pop, fronts);

        % --- Sélection tournoi ---
        mating_pool_idx = tournament_selection(rank, crowd, N);
        parents = pop(mating_pool_idx, :);

        % --- Crossover ---
        offspring = zeros(size(parents));
        i = 1;
        while i <= N
            if rand < Pc && i < N
                p1 = parents(i, :);
                p2 = parents(i+1, :);
                [c1, c2] = sbx_crossover(p1, p2, lb, ub, eta_c);
                offspring(i,:)   = c1;
                offspring(i+1,:) = c2;
                i = i + 2;
            else
                offspring(i,:) = parents(i,:);
                i = i + 1;
            end
        end

        % --- Mutation ---
        for i = 1:N
            if rand < Pm
                offspring(i,:) = poly_mutation(offspring(i,:), lb, ub, eta_m);
            end
        end

        offspring = apply_integer_and_bounds(offspring, lb, ub, hasInt, intcon);

        % --- Évaluation progéniture ---
        [f_off, cons_off] = eval_population(problem, offspring, hasNonl);

        % --- Sélection environnementale ---
        pop_comb  = [pop; offspring];
        f_comb    = [f_pop; f_off];
        cons_comb = [cons_viol; cons_off];

        [fronts, rank] = fast_nondominated_sort(f_comb, cons_comb);
        crowd = crowding_distance(f_comb, fronts);

        new_pop = zeros(N, D);
        new_f   = zeros(N, size(f_pop,2));

        count = 0;
        for kf = 1:numel(fronts)
            Fk = fronts{kf};
            if count + numel(Fk) <= N
                new_pop(count+1:count+numel(Fk), :) = pop_comb(Fk,:);
                new_f(count+1:count+numel(Fk), :)   = f_comb(Fk,:);
                count = count + numel(Fk);
            else
                [~, idx_sort] = sort(crowd(Fk), 'descend');
                remain = N - count;
                sel = Fk(idx_sort(1:remain));
                new_pop(count+1:N,:) = pop_comb(sel,:);
                new_f(count+1:N,:)   = f_comb(sel,:);
                break;
            end
        end

        pop      = new_pop;
        f_pop    = new_f;
        [~, cons_viol] = eval_population(problem, pop, hasNonl);

        %% === DEBUG : Analyse interne NSGA-II ===

        if g == 1
            fprintf("\n=== DEBUG NSGA-II ===\n");
            fprintf("Génération | Front1 | Front2 | Front3 | Dominés | Mean crowd | Min crowd | Max crowd\n");
        end
        
        % Recalcule classement pour cette génération
        [fronts_dbg, rank_dbg] = fast_nondominated_sort(f_pop, cons_viol);
        crowd_dbg = crowding_distance(f_pop, fronts_dbg);
        
        % Taille des fronts (afficher 3 premiers max)
        nf1 = numel(fronts_dbg{1});
        nf2 = 0; if numel(fronts_dbg) >= 2, nf2 = numel(fronts_dbg{2}); end
        nf3 = 0; if numel(fronts_dbg) >= 3, nf3 = numel(fronts_dbg{3}); end
        
        dominated = sum(rank_dbg > 1);
        
        mc = mean(crowd_dbg(~isinf(crowd_dbg)));
        mic = min(crowd_dbg(~isinf(crowd_dbg)));
        mac = max(crowd_dbg(~isinf(crowd_dbg)));
        
        fprintf("%5d     | %6d | %6d | %6d | %7d | %10.4f | %10.4f | %10.4f\n", ...
                g, nf1, nf2, nf3, dominated, mc, mic, mac);
        
        %% OPTIONAL : Scatter plot (si f_pop a 2 objectifs)
        if size(f_pop,2) == 2
            figure(100); clf;
            scatter(f_pop(:,1), f_pop(:,2), 25, rank_dbg, 'filled');
            title(sprintf("Génération %d — Objectifs", g));
            xlabel("f_1"); ylabel("f_2");
            colorbar; drawnow;
        end

        %% --- PlotFcn : affichage en direct ---
        for pf = 1:numel(plotFcns)
            try
                feval(plotFcns{pf}, pop, f_pop, g);
            catch ME
                warning("PlotFcn error: %s", ME.message); %#ok<MEXCEP>
            end
        end

    end
end

%% ========================================================================
%                   FONCTIONS UTILITAIRES NSGA-II
% ========================================================================

function X = apply_integer_and_bounds(X, lb, ub, hasInt, intcon)
    X = max(X, lb);
    X = min(X, ub);
    if hasInt
        X(:, intcon) = round(X(:, intcon));
    end
end

function [F, cons_viol] = eval_population(problem, pop, hasNonl)
    N = size(pop,1);
    F = zeros(N, numel(problem.objective(pop(1,:))));
    cons_viol = zeros(N,1);

    for i = 1:N
        xi = pop(i,:);
        fi = problem.objective(xi);
        F(i,:) = fi(:).';

        if hasNonl
            [c, ceq] = problem.nonlcon(xi);
            c = c(:); ceq = ceq(:);
            cons_viol(i) = sum(max(c,0)) + sum(abs(ceq));
        else
            cons_viol(i) = 0;
        end
    end
end

function [fronts, rank] = fast_nondominated_sort(F, cons_viol)
    N = size(F,1);
    rank = zeros(N,1);
    fronts = {};
    S = cell(N,1);
    n = zeros(N,1);

    for p = 1:N
        S{p} = [];
        n(p) = 0;
        for q = 1:N
            if p == q, continue; end
            dom = dominates(F(p,:), cons_viol(p), F(q,:), cons_viol(q));
            dom_by = dominates(F(q,:), cons_viol(q), F(p,:), cons_viol(p));
            if dom
                S{p} = [S{p}, q];
            elseif dom_by
                n(p) = n(p) + 1;
            end
        end
        if n(p) == 0
            rank(p) = 1;
        end
    end

    front = find(rank == 1).';
    f_idx = 1;
    while ~isempty(front)
        fronts{f_idx} = front;
        Q = [];
        for p = front
            for q = S{p}
                n(q) = n(q) - 1;
                if n(q) == 0
                    rank(q) = f_idx + 1;
                    Q = [Q, q];
                end
            end
        end
        front = Q;
        f_idx = f_idx + 1;
    end
end

function d = crowding_distance(F, fronts)
    N = size(F,1);
    M = size(F,2);
    d = zeros(N,1);

    for k = 1:numel(fronts)
        idx = fronts{k};
        if numel(idx) <= 2
            d(idx) = Inf;
            continue;
        end

        Fk = F(idx,:);
        for m = 1:M
            [vals, order] = sort(Fk(:,m));
            d(idx(order(1)))   = Inf;
            d(idx(order(end))) = Inf;
            fmin = vals(1); 
            fmax = vals(end);
            if fmax == fmin, continue; end
            for j = 2:(numel(idx)-1)
                d(idx(order(j))) = d(idx(order(j))) + ...
                    (vals(j+1) - vals(j-1)) / (fmax - fmin);
            end
        end
    end
end

function sel = tournament_selection(rank, crowd, N)
    sel = zeros(N,1);
    for i = 1:N
        a = randi(N);
        b = randi(N);
        if better(a, b, rank, crowd)
            sel(i) = a;
        else
            sel(i) = b;
        end
    end
end

function flag = better(i, j, rank, crowd)
    if rank(i) < rank(j)
        flag = true;
    elseif rank(i) > rank(j)
        flag = false;
    else
        flag = crowd(i) > crowd(j);
    end
end

function b = dominates(f1, v1, f2, v2)
    if v1 == 0 && v2 > 0
        b = true;
    elseif v1 > 0 && v2 == 0
        b = false;
    elseif v1 > 0 && v2 > 0
        b = v1 < v2;
    else
        b = all(f1 <= f2) && any(f1 < f2);
    end
end

function [c1, c2] = sbx_crossover(p1, p2, lb, ub, eta)
    D = numel(p1);
    c1 = zeros(1,D); 
    c2 = zeros(1,D);
    for i = 1:D
        if rand <= 0.5
            if abs(p1(i) - p2(i)) > 1e-12
                x1 = min(p1(i), p2(i));
                x2 = max(p1(i), p2(i));
                L = lb(i); U = ub(i);
                beta = 1 + 2*(x1 - L)/(x2 - x1);
                alpha = 2 - beta^(-(eta+1));
                u = rand;
                if u <= 1/alpha
                    beta_q = (u*alpha)^(1/(eta+1));
                else
                    beta_q = (1/(2 - u*alpha))^(1/(eta+1));
                end
                c1(i) = 0.5*((x1+x2) - beta_q*(x2-x1));

                beta = 1 + 2*(U - x2)/(x2 - x1);
                alpha = 2 - beta^(-(eta+1));
                if u <= 1/alpha
                    beta_q = (u*alpha)^(1/(eta+1));
                else
                    beta_q = (1/(2 - u*alpha))^(1/(eta+1));
                end
                c2(i) = 0.5*((x1+x2) + beta_q*(x2-x1));

                c1(i) = min(max(c1(i), L), U);
                c2(i) = min(max(c2(i), L), U);
            else
                c1(i) = p1(i);
                c2(i) = p2(i);
            end
        else
            c1(i) = p1(i);
            c2(i) = p2(i);
        end
    end
end

function x = poly_mutation(x, lb, ub, eta)
    D = numel(x);
    for i = 1:D
        if rand < 1/D
            y  = x(i);
            yl = lb(i);
            yu = ub(i);
            if yl == yu, continue; end
            delta1 = (y - yl)/(yu - yl);
            delta2 = (yu - y)/(yu - yl);
            u = rand;
            mut_pow = 1/(eta+1);
            if u <= 0.5
                xy = 1 - delta1;
                val = 2*u + (1-2*u)*(xy^(eta+1));
                deltaq = val^mut_pow - 1;
            else
                xy = 1 - delta2;
                val = 2*(1-u) + 2*(u-0.5)*(xy^(eta+1));
                deltaq = 1 - val^mut_pow;
            end
            y = y + deltaq*(yu-yl);
            y = min(max(y,yl),yu);
            x(i) = y;
        end
    end
end
