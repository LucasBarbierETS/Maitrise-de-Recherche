% Démarrez la connexion COMSOL depuis MATLAB
mphstart();

addpath 'E:\OneDrive - ETS\CRIAQ-REAR\Maitrise LB\MATLAB\MATLAB scripts';

% Lancer l'environnement
launch_environnement()

% Création d'une instance de classe classHelmholtz_Resonator
HR = classHelmholtz_Resonator(classHelmholtz_Resonator.create_config(1e-3, 8e-3, 30e-3, 30e-3, 100e-3, 30e-3^2));

% On crée une instance de classNiloofar
% solN = classNiloofar(classNiloofar.create_config(30e-3, 2e-3, 5e-4, 5e-3, 7.4e-3, 8e-3, 8e-3, 15, 30e-3^2));

% On lance les scripts d'optimisation
% optimisation_tonale_BF();
% optimisation_large_bande_BF_MF();

%% Mesures en incidence normale
% % On créer des tubes 2D avec chacunes des solutions
% Tube_2D = ImpedanceTube2D(ImpedanceTube2D.create_config({}));
% Tube_2D_N = ImpedanceTube2D(ImpedanceTube2D.create_config({solN}));
% Tube_2D_BF = ImpedanceTube2D(ImpedanceTube2D.create_config({sol_bf_lin}));
% Tube_2D_MF = ImpedanceTube2D(ImpedanceTube2D.create_config({sol_lb_mf}));
% Tube_2D_BF_MF = ImpedanceTubeGI2D(ImpedanceTubeGI2D.create_config({sol_bf_lin, sol_lb_mf}));

%% Mesures en incidence rasante
% % On créer des tubes 2D avec chacunes des solutions
% Tube_GI_2D = ImpedanceTubeGI2D(ImpedanceTubeGI2D.create_config({}));
Tube_GI_2D_HR = ImpedanceTubeGI2D(ImpedanceTubeGI2D.create_config({HR}));
% Tube_GI_2D_N = ImpedanceTubeGI2D(ImpedanceTubeGI2D.create_config({solN}));
% Tube_GI_2D_BF = ImpedanceTubeGI2D(ImpedanceTubeGI2D.create_config({sol_bf_lin}));
% Tube_GI_2D_MF = ImpedanceTubeGI2D(ImpedanceTubeGI2D.create_config({sol_lb_mf}));
% Tube_GI_2D_BF_MF = ImpedanceTubeGI2D(ImpedanceTubeGI2D.create_config({sol_bf_lin, sol_lb_mf}));
