%% --- Lecture du fichier principal (mesuré et à corriger) ---
[file_main, path_main] = uigetfile('*.txt', 'Sélectionne le fichier principal');
data_main = readmatrix(fullfile(path_main, file_main));
f_main = data_main(:,1)';
PSD_main = data_main(:,2)';

%% --- Lecture du fichier de référence (optionnel) ---
[file_ref, path_ref] = uigetfile('*.txt', 'Sélectionne le fichier de référence (facultatif)');
if isequal(file_ref,0)
    f_ref = [];
    PSD_ref = [];
else
    data_ref = readmatrix(fullfile(path_ref, file_ref));
    f_ref = data_ref(:,1)';
    PSD_ref = data_ref(:,2)';
end

%% --- Création de l'environnement avec le fichier principal ---
env = create_environnement_2(t, sp, hum, f_main, 'Root', root, 'SPL', PSD_main);

%% --- Propriétés du matériau ---
porosity = 0.971; %Littérature marlene sciard
tortuosity = 1.02; %Littérature marlene sciard
air_flow_resistivity = 8600;     %8600; Littérature marlene sciard
viscous_caractersitic_length = 1.23e-4 ;    %1.23e-4;%Littérature marlene sciard
thermal_caracteristic_length = 1.86e-4  ;   %1.86e-4;%Littérature marlene sciard

%% - Propriétés micros --
D = 6.35e-3; % diamètre du micro
surface = (pi/4)*D^2;
thickness = @(coeff) coeff * D;

config = @(coeff) classJCA_Rigid.create_config(surface, thickness(coeff), porosity, ...
    tortuosity, air_flow_resistivity, viscous_caractersitic_length, thermal_caracteristic_length);
obj = @(coeff) classJCA_Rigid(config(coeff));
elem = @(coeff) classelement(classelement.create_config({obj(coeff)}, 'closed', surface));

%elem = classelement(classelement.create_config({obj}, 'closed', surface));

%% debog TM et TM_inv
[TM, TM_inv] = obj(3).inverse_transfer_matrix(env);
% perso_plot_transfer_matrix(TM, env, 'TM');
% perso_plot_transfer_matrix(TM_inv, env, 'TM inv');

%% --- Calcul de la PSD corrigée ---
P_flush = TM.T11 .* env.pt; % rigid wall
PSD_corr = 20*log10(abs(P_flush)/(sqrt(2)*env.p_ref));

% plot(f_main, real(P_flush))
% hold on
% plot(f_main, imag(P_flush))
% plot(f_main, abs(P_flush))

%% --- Figure PSD ---
figure('Name', sprintf('PSD - %s', file_main), 'NumberTitle','off');
hold on; grid on;
xlabel('Fréquence (Hz)'); ylabel('Niveau de pression (dB)');
sgtitle(sprintf('Comparaison PSD (%s)', file_main), 'Interpreter','none');

% Courbe mesurée
plot(f_main, PSD_main, 'k--', 'LineWidth',1.5, 'DisplayName','Mesurée');

% Courbe corrigée / simulée
plot(env.f, PSD_corr, 'r-', 'LineWidth',1.8, 'DisplayName','Corrigée');

% Courbe de référence (optionnelle)
if ~isempty(f_ref)
    plot(f_ref, PSD_ref, 'b-.', 'LineWidth',1.5, 'DisplayName','Référence');
end

legend('show','Location','best');

%% Figure TL

figure();
plot(env.w/(2*pi),elem(1).transmission_loss(env));
hold on
plot(env.w/(2*pi),elem(2).transmission_loss(env));
plot(env.w/(2*pi),elem(3).transmission_loss(env));
plot(env.w/(2*pi),elem(10).transmission_loss(env));