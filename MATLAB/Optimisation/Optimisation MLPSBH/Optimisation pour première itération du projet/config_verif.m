% variables d'ajustement
tcav = 14.3e-3;
pt_corr = 0;

% Configuration expérimentale 1
N = 6;
cd = 28e-3;
cw = 28e-3;
hr = {1e-3 * [0.475 0.475 0.45 0.45 0.45 0.45]};
dw = {1e-3 * [1.372 1.424 1.377 1.35 1.35 1.35]};
pd = {[9 9 2 1 3 4]};
pw = {[6 9 8 10 9 8]};

MPPSBH = @(tcav, pt_corr) classMPPSBH_Rectangular( ...
    classMPPSBH_Rectangular.create_explicit_config(N, cd, cw, hr, dw, pd, pw, {1e-3 * ([1 2 2 2 2 2] + pt_corr)}, {tcav}));

MPPSBH_config = MPPSBH.Configuration;
MPPSBH.plot_alpha(env, 150, 400, 'Modèle analytique');
perso_create_absorption_app(env);

