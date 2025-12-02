%% ==============================
%  MODULE VARIABLE DEFINITION
% ==============================

ProblemConfig = struct();

% ----- Dimensions générales -----
ProblemConfig.NS = 4;   % nombre de solutions / SDOF / plaques
ProblemConfig.N  = 4;   % nombre de plaques empilées (optionnel)
ProblemConfig.NV = 4;   % nombre de variables par SDOF/plate

% ----- Type de structure -----
%   "flat"   → vecteur [ NS × NV ]
%   "stack"  → plaques × solutions × variables  (ETS)
ProblemConfig.Structure = "flat";   % ou "stack"

% ----- Définition variable par variable -----
ProblemConfig.Variables = {
   struct("name","r", "lb", 0.1e-3, "ub", 0.3e-3, "type", "float")
   struct("name","dw", "lb", 3*0.1e-3, "ub",3*0.3e-3, "type", "float")
   struct("name","pw", "lb",1, "ub", 10, "type", "int")
   struct("name","theta", "lb",1, "ub", 5, "type", "float")
};

% ----- Population size -----
ProblemConfig.PopSize = 25;

% ----- Décodage (reshape) -----
ProblemConfig.decode = @(x) decode_variables(x, ProblemConfig);