%% 25.04.07 - Optimisation des paramètres pour Hutchinson

mphstart;
launch_environnement;

root = 'E:\OneDrive - ETS\CRIAQ-REAR\Maitrise LB\Présentations\Présentations Thomas\25.04.08 - résultats optimisation pour Hutchinson';

%% Script d'optimisation basse fréquence (1 solution)
% opt_sol_bf_10p;

% Sauvegarde
% save([root, '\optimisation finale basse fréquence 1 solutions.mat']);

load([root, '\optimisation finale basse fréquence 1 solution.mat'])

%% Exports 
MPPSBH_bf_1.export_plate_hole_coordinates([root, '\MPPSBH_bf_1'], '_bf_1');

MPPSBH_bf_1.export_report([root, '\MPPSBH_bf_1\Rapport de configuration.xlsx']);
% clear

%% Script d'optimisation moyenne fréquence (1 solution)
% opt_sol_mb_mf_10p;

% Sauvegarde
% save([root, '\optimisation finale moyenne fréquence 1 solutions.mat']);

load([root '\optimisation finale moyenne fréquence 1 solutions.mat']);

%% Export des coordonées des perforations
MPPSBH_mb_mf_1.export_plate_hole_coordinates([root, '\MPPSBH_mb_mf_1'], '_mb_mf_1');

MPPSBH_mb_mf_1.export_report([root, '\MPPSBH_mb_mf_1\Rapport de configuration.xlsx']);
% clear 

%% Script d'optimisation haute fréquence (1 solution)
% opt_sol_lb_hf_10p;

% Sauvegarde
% save([root, '\optimisation finale haute fréquence 2 solutions.mat']);

load([root, '\optimisation finale haute fréquence 2 solutions.mat'])

%% Export des coordonées des perforations
MPPSBH_lb_hf_1.export_plate_hole_coordinates([root, '\MPPSBH_lb_hf_1'], '_lb_hf_1');
MPPSBH_lb_hf_1.export_report([root, '\MPPSBH_lb_hf_1\Rapport de configuration.xlsx']);
MPPSBH_lb_hf_2.export_plate_hole_coordinates([root, '\MPPSBH_lb_hf_2'], '_lb_hf_2');
MPPSBH_lb_hf_2.export_report([root, '\MPPSBH_lb_hf_2\Rapport de configuration.xlsx']);
clear

%% Assemblage

% Validation numérique assemblage
Tube_assembly = ImpedanceTube2D(ImpedanceTube2D.create_config({MPPSBH_bf_1, MPPSBH_lb_hf_1, MPPSBH_mb_mf_1, MPPSBH_lb_hf_2}));
Tube_assembly = Tube_assembly.lauch_tube_measurement();
Tube_assembly.plot_alpha(env, 'assemblage');
mphsave(Tube_assembly.Configuration.ComsolModel, ['E:\OneDrive - ETS\CRIAQ-REAR\Maitrise LB\' ...
                                            'Présentations\Présentations Thomas\25.04.08 - résultats optimisation pour Hutchinson\' ...
                                            'validation numérique assemblage'])

% Critères d'évaluation
assembly = classelementassembly(classelementassembly.create_config({MPPSBH_bf_1, MPPSBH_lb_hf_1, MPPSBH_mb_mf_1, MPPSBH_lb_hf_2}));
alpha_mean_assembly_bf = assembly.alpha_mean(env, f_min_bf, f_max_bf);
alpha_mean_assembly_mb_mf = assembly.alpha_mean(env, f_min_mb_mf, f_max_lb_hf);
alpha_mean_assembly_lb_hf = assembly.alpha_mean(env, f_min_lb_hf, f_max_lb_hf);
[f_peak_assembly, alpha_peak_assembly] = assembly.alpha_peak(env, f_min_bf, f_max_lb_hf);




