folder_path = [env.Root, '\Mesures expérimentales\Echantillons Hutchinson 1ère itération\Incidence rasante'];
configurations = open([env.Root, '\Mesures expérimentales\Echantillons Hutchinson 1ère itération\configurations.mat']);

data_C1_RL_IR = perso_load_mecanum_files_IR([folder_path, '\Export_Data_rasant']);
f = data_C1_RL_IR.f;
TL = data_C1_RL_IR.STL.echantillon;

N = [3, 1, 2, 4];

for i = 1:4

    perso_figure('Validation expérimentale - C1 - TL - 100 dB'); subplot(2, 2, i); hold on
    title(['C1.', num2str(N(i))])
    
    plot(f, TL.(['Sample', num2str(i)]), 'DisplayName', 'mesure exp.');
    
    MPPSBH = classMPPSBH_Rectangular(configurations.(['config_1_', num2str(N(i))]));
    side_branch = classsidebranch(classsidebranch.create_config(MPPSBH, 30e-3, 38.1e-3^2));
    % MPPSBH.plot_alpha(env, 'alpha')
    plot(env.w/(2*pi), side_branch.transmission_loss(env), 'DisplayName', 'modèle RL IR')
    xlim([f(1) f(end)]);
end