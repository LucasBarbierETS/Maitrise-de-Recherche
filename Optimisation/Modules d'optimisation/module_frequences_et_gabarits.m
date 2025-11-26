%% ========================================================================
%  MODULE D'OPTIMISATION: FREQUENCES CIBLES ET GABARITS
% =========================================================================

% % Objectif larges bande

Frequences.f_min_lb = 200;
Frequences.f_max_lb = 1500;
g_obj_lb = @(env) (env.w / (2*pi) > Frequences.f_min_lb & env.w / (2*pi) < Frequences.f_max_lb);

% Objectifs tonaux
% On définit une largeur de bande associée à la variation du régime moteur de 3000 à 3500 RPM
% On définit les bandes de variations des harmoniques tant que celles-ci ne se recoupent pas

% Première harmonique (Fondamentale) : 233 Hz (20 Hz)
Frequences.f_min_h1 = 220;
Frequences.f_max_h1 = 240;
g_obj_h1 = @(env) (env.w / (2*pi) > Frequences.f_min_h1 & env.w / (2*pi) < Frequences.f_max_h1);

% Deuxième harmonique : 467 Hz (40 Hz)
Frequences.f_min_h2 = 430;
Frequences.f_max_h2 = 470;
g_obj_h2 = @(env) (env.w / (2*pi) > Frequences.f_min_h2 & env.w / (2*pi) < Frequences.f_max_h2);

% Troisième harmonique : 700 Hz (60 Hz)
Frequences.f_min_h3 = 640;
Frequences.f_max_h3 = 700;
g_obj_h3 = @(env) (env.w / (2*pi) > Frequences.f_min_h3 & env.w / (2*pi) < Frequences.f_max_h3);

% Quatrième harmonique : 933 Hz (80 Hz)
Frequences.f_min_h4 = 870;
Frequences.f_max_h4 = 950;
g_obj_h4 = @(env) (env.w / (2*pi) > Frequences.f_min_h4 & env.w / (2*pi) < Frequences.f_max_h4);

g_obj_harm =  @(env) g_obj_h1(env) + g_obj_h2(env) + g_obj_h3(env) + g_obj_h4(env) > 0;