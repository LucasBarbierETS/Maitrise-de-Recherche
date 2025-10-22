folder_path = [env.Root, '\Mesures expérimentales\Echantillons Hutchinson 1ère itération\Incidence normale'];
configurations = open([env.Root, '\Mesures expérimentales\Echantillons Hutchinson 1ère itération\configurations.mat']);

data_C1_Assembly_IN = perso_load_mecanum_files_IR([folder_path, '\Export_Data']);
f = data_C1_Assembly_IN.f;
alpha = data_C1_Assembly_IN.alpha.C1_4INonCavity.Sample1;

perso_figure('Validation expérimentale - C1 - Alpha assemblage - 100 dB'); hold on

plot(f, alpha, 'DisplayName', 'mesure exp.');

MPPSBH_1_1 = classMPPSBH_Rectangular(configurations.('config_1_1'));
MPPSBH_1_2 = classMPPSBH_Rectangular(configurations.('config_1_2'));
MPPSBH_1_3 = classMPPSBH_Rectangular(configurations.('config_1_3'));
MPPSBH_1_4 = classMPPSBH_Rectangular(configurations.('config_1_4'));
Assembly = classelement(classelement.create_config({...
classelementassembly(classelementassembly.create_config({MPPSBH_1_1, MPPSBH_1_2, MPPSBH_1_3, MPPSBH_1_4}))}, ...
'closed', pi*50e-3^2));
Assembly.plot_alpha(env, 'modèle analytique');
xlim([f(1) f(end)]);

perso_figure('Validation expérimentale - C1 - Impédance de surface - 100 dB'); hold on

Zs = data_C1_Assembly_IN.Zs.C1_4INonCavity.Sample1;
perso_plot_surface_impedance(f, Zs, env, 'mesure exp.');
Assembly.plot_surface_impedance(env, 'modèle analytique');
xlim([f(1) f(end)]);