close all
clc

%  Reférences

% [1] Hybrid composite meta-porous structure for improving and broadening sound absorption
% N. Gao, J. Wu, K. Lu and H. Zhong
% DOI: 10.1016/J.YMSSP.2020.107504  

% Importation de tous les chemins d'accès
% addpath ('C:\Users\Utilisateur\OneDrive - ETS\CRIAQ-REAR\Maitrise LB\Functions') 
% add_all_paths('C:\Users\Utilisateur\OneDrive - ETS\CRIAQ-REAR\Maitrise LB');

% Création de l'environnement
env = create_environnement(23, 100800, 50, 1, 6000, 200);

%% Données de références ([1] p.2)

% Configuration initiale ([1] fig 2.a, courbe noire)
width = 30e-3; % W
plates_thickness = 1e-3; % l
added_length = 1e-3; % d
left_spacing = 4.9e-3; % m
right_spacing = 7.4e-3; % n 
first_left_plate_length = 8e-3; % a1
first_right_plate_length = 8e-3; % b1
nb_of_plates = 18;

total_thickness =  50e-3;
% total_thickness = 10 * left_spacing + plates_thickness * nb_of_plates / 2;

% % Configuration S1 ([1] fig 2.a, courbe rouge)
% width = 30e-3; % W
% plates_thickness = 1e-3; % l
% added_length = 1e-3; % d
% left_spacing = 5e-3; % m
% right_spacing = 7.5e-3; % n 
% first_left_plate_length = 8e-3; % a1
% first_right_plate_length = 8e-3; % b1
% nb_of_plates = 9;
% height = 10 * left_spacing + plates_thickness * nb_of_plates / 2;

% Paramètres JCA du matériau poreux ([1] p.3)
phi = 0.96; % porosité
tor = 1.07; % tortuosité
vl = 2.73e-4; % longueur caractéristique visqueuse
tl = 6.72e-4; % longueur caractéristique thermique
sig = 2843; % résistivité

% phi = 1; % porosité
% tor = 1; % tortuosité
% vl = 3e-2; % longueur caractéristique visqueuse
% tl = 3e-2; % longueur caractéristique thermique
% sig = 1; % résistivité

input_section = width^2; % Section d'entrée

% Fréquence 1/4 d'onde de référence
lambda_QWL = total_thickness * 4;
freq_QWL = env.air.parameters.c0 / lambda_QWL;

% Construction des objets de classe
configMTP = classMTP.create_config(width, plates_thickness, ...
    added_length, left_spacing, right_spacing, first_left_plate_length, ...
    first_right_plate_length, nb_of_plates, input_section);

Porous = classJCA_Rigid(classJCA_Rigid.create_config(phi, tor, sig, vl, tl, total_thickness, input_section));

configMTP = classMTP.define_porous_media(configMTP, phi, tor, sig, vl, tl, input_section);

MTP1 = classMTP1(configMTP);
% MTP2 = classMTP2(configMTP);
% MTP_Cav = classMTP1_with_slit_cavities(configMTP);
% MTP_SC = classMTP_with_section_changes(configMTP);
% MTP_Cav_SC = classMTP_with_cavities_and_section_changes(configMTP);

% On importe des données de réferences
black = csvread('MLP_métaporous_fig2a_black.txt');
[x_black, y_black] = interpole_et_lisse(black(:, 1), black(:, 2), 1000, 0.05);

blue = csvread('MLP_métaporous_fig2a_blue.txt');
[x_blue, y_blue] = interpole_et_lisse(blue(:, 1), blue(:, 2), 1000, 0.05);

green = csvread('MLP_métaporous_fig2a_green.txt');
[x_green, y_green] = interpole_et_lisse(green(:, 1), green(:, 2), 1000, 0.05);

red = csvread('MLP_métaporous_fig2a_red.txt');
[x_red, y_red] = interpole_et_lisse(red(:, 1), red(:, 2), 1000, 0.05);


%% Absorption

figure()

% On compare les matériaux poreux 
% subplot(2,2,1)
hold on
plot(x_blue, y_blue, 'LineStyle', '--', 'LineWidth', 0.3, 'Color', 'b')
plot(env.w / (2 * pi), Porous.alpha(env), 'Color', 'b')
legend('Données de référence', 'Poreux')
 
% plot(x_black, y_black, 'LineStyle', '--', 'Color', 'k')
% plot(x_red, y_red, 'LineStyle', '--', 'Color', 'r')
% plot(x_green, y_green, 'LineStyle', '--', 'Color', 'g')

plot(env.w / (2 * pi), MTP1.alpha(env), 'DisplayName', 'Compressibilité modifiée (volume)')
% plot(env.w / (2 * pi), MTP2.alpha(env), 'DisplayName', 'Compressibilité modifiée (longueur)')
% plot(env.w / (2 * pi), MTP_Cav.alpha(env), 'DisplayName', 'volume + cavités parallèles')
% plot(env.w / (2 * pi), MTP_SC.alpha(env), 'DisplayName', 'Changements de section')
% plot(env.w / (2 * pi), MTP_Cav_SC.alpha(env), 'DisplayName', 'Changements de section + cavités parallèles')
% xline(freq_QWL, 'Color', [0 0 0], 'Label', 'Fréquence 1/4 d''onde', 'LabelVerticalAlignment', 'bottom');

xlabel("frequence (Hz)")
ylabel("Coefficient d'absorption (ad)")

xlim([0 5000])
ylim([0, 1])

title("Modèles MTP")