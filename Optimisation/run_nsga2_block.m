function [xopti, fval, population, scores, eflag, timeNSGA2] = ...
    run_nsga2_block(objective, lb, ub, intcon, nonlcon, x0, NP, varargin)

% RUN_NSGA2_BLOCK
%  Wrapper générique autour de nsga2_moea, compatible avec ton pipeline GA.
%
% Entrées :
%  - objective : @(x) -> [f1 ... fM]
%  - lb, ub    : bornes (1×D ou D×1)
%  - intcon    : indices des variables entières ([] si aucune)
%  - nonlcon   : handle contraintes non-linéaires [] ou @(x)->[c,ceq]
%  - x0        : matrice NP×D de population initiale
%  - NP        : taille de population
%  - varargin  : Name-Value pour options NSGA2 (MaxGen, Pc, Pm, EtaC, EtaM, PlotFcn, etc.)
%
% Sorties :
%  - xopti     : solutions Pareto (N×D)
%  - fval      : objectifs (N×M)
%  - population, scores : alias pour compatibilité GA
%  - eflag     : 1 si OK
%  - timeNSGA2 : temps d'exécution

    % --- 1. Construction du "problem" générique ---
    problem            = struct();
    problem.objective  = objective;
    problem.lb         = lb(:).';      % row
    problem.ub         = ub(:).';
    problem.intcon     = intcon(:).';
    if isempty(nonlcon)
        problem.nonlcon = [];
    else
        problem.nonlcon = nonlcon;
    end

    % --- 2. Options par défaut ---
    opts = struct();
    opts.PopSize             = NP;
    opts.MaxGen              = 50;
    opts.Pc                  = 0.9;
    opts.Pm                  = 0.1;
    opts.EtaC                = 20;
    opts.EtaM                = 20;
    opts.Display             = "iter";
    opts.FunctionTolerance   = 1e-3;
    opts.ConstraintTolerance = 1e-6;
    opts.PlotFcn             = {};         % cellule de function handles
    opts.x0                  = x0;         % population initiale

    % --- 3. Override via Name-Value ---
    if mod(numel(varargin),2) ~= 0
        error('run_nsga2_block: varargin doit être des couples Name,Value');
    end

    for k = 1:2:numel(varargin)
        name  = varargin{k};
        value = varargin{k+1};
        if isfield(opts, name)
            opts.(name) = value;
        else
            warning('Option "%s" inconnue, ignorée.', name);
        end
    end

    % --- 4. Lancement NSGA-II ---
    rng;  % reproductibilité locale
    tic;
    [pop, f_pop] = nsga2_moea(problem, opts);
    timeNSGA2 = toc;

    % --- 5. Compatibilité "GA" ---
    xopti      = pop;
    fval       = f_pop;
    population = pop;
    scores     = f_pop;
    eflag      = 1;
end
