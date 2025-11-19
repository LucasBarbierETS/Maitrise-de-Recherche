%% --- Lecture du fichier principal de Manuel---
[file_main, path_main] = uigetfile('*.txt', 'Sélectionne le fichier principal');
raw_main = readmatrix(fullfile(path_main, file_main));
data_main = raw_main(61:end, :); % Suppression des 60 premières lignes
f_main = data_main(:,1)';
pt_rms_main = data_main(:,2)';

%% --- Création de l'environnement avec le fichier principal ---
env = create_environnement_2(t, sp, hum, f_main, 'Root', root);

%% --- Utilisation Niveau de pression elissa du modèle numérique---
file_path = fullfile([env.Root, '\Optimisation\Optimisation REAR\stator_spectrum_data.txt']);

% Appel simple (récupère les résultats sans tracer)
[fmean, L_RMS_band, OASPL2500, OASPL1000] = compute_LRMS_from_elissa(file_path, 'fmax', 5000);

%% --- Passage en Niveau de pression des données de Manuel REAR ---
PSD_main = 20*log10(abs(pt_rms_main)/env.p_ref);

%%--- Récupération matrice de transfert Comsol ---
[fileA, fileB] = deal('tableau_1_6D.txt', 'tableau_2_6D.txt');
[freqTM, T11c, T12c, T21c, T22c, TMc] = compute_TM_from_txt(fileA, fileB);

%% --- TM Poreux analytique ---

% --- Propriétés du matériau ---
porosity = 0.971; %Littérature marlene sciard
tortuosity = 1.02; %Littérature marlene sciard
air_flow_resistivity = 8644;     %8600; Littérature marlene sciard
viscous_caractersitic_length = 1.23e-4 ;    %1.23e-4;%Littérature marlene sciard
thermal_caracteristic_length = 1.86e-4  ;   %1.86e-4;%Littérature marlene sciard

% - Propriétés micros --
D = 6.35e-3; % diamètre du micro
surface = (pi/4)*D^2;
coeff = 6;
thickness = @(coeff) coeff * D;

% --- Création objet / config ---
config = @(coeff) classJCA_Rigid.create_config(surface, thickness(coeff), porosity, ...
    tortuosity, air_flow_resistivity, viscous_caractersitic_length, thermal_caracteristic_length);
obj = @(coeff) classJCA_Rigid(config(coeff));
elm = @(coeff) classelement(classelement.create_config({obj(coeff)}, 'closed', surface));

% --- debog TM et TM_inv --- 
[TM_inv, options] = obj(coeff).inverse_transfer_matrix(env); % bien changer la valeur du coeff en fonction de l'étude
TM = obj(coeff).transfer_matrix(env, options);
TM.T12 = TM.T12 * surface;
TM.T21 = TM.T21 / surface;

%% debog TM
T11i = interp1(freqTM, T11c, env.f, 'pchip', 'extrap');
T12i = interp1(freqTM, T12c, env.f, 'pchip', 'extrap');
T21i = interp1(freqTM, T21c, env.f, 'pchip', 'extrap');
T22i = interp1(freqTM, T22c, env.f, 'pchip', 'extrap');

% --- Structure pour la fonction de tracé ---
TM_struct.T11 = T11i;
TM_struct.T12 = T12i;
TM_struct.T21 = T21i;
TM_struct.T22 = T22i;

% --- Affichage ---
figure;
perso_plot_transfer_matrix(TM_struct, env, 'TM COMSOL', 2000);
perso_plot_transfer_matrix(TM, env, 'TM analytique', 2000);

%% --- Calcul de la PSD corrigée - analytique ---
% p_flush = pt_rms_main./TM_inv.T11; % rigid wall
p_flush_exp = TM.T11.*pt_rms_main; % rigid wall
PSD_corr_exp = 20*log10(abs(p_flush_exp)/env.p_ref);


%% --- Calcul de la PSD corrigée - Comsol ---
% p_flush = pt_rms_main./TM_inv.T11; % rigid wall
p_flush_c = T11i.*pt_rms_main; % rigid wall
PSD_corr_c = 20*log10(abs(p_flush_c)/env.p_ref);

%% -- OASPL CORRIGEE -- 
mf2500_c = f_main <2500;
mf1000_c = f_main <1000;
OASPL2500_corrigee = 10*log10(sum(abs(p_flush_exp(mf2500_c)).^2)/p0^2);
OASPL1000_corrigee = 10*log10(sum(abs(p_flush_exp(mf1000_c)).^2)/p0^2);

%% --- Figure PSD ---
figure('Name', sprintf('PSD - %s', file_main), 'NumberTitle','off');
hold on; grid on;
xlabel('Fréquence (Hz)'); ylabel('Niveau de pression (dB)');
xlim([0 2500]);
sgtitle(sprintf('Correction niveau de pression pariétale (6D) (%s)', file_main), 'Interpreter','none');

% Courbe mesurée
plot(f_main, PSD_main, 'k--', 'LineWidth',1.5, 'DisplayName',sprintf('Mesure Bell (%dD) - 3500RPM',coeff));

% Courbe corrigée / simulée - analytique
plot(env.f, PSD_corr_exp, 'c-', 'LineWidth',1.8, 'DisplayName', sprintf('Corrigée analytique (%dD) - 3500RPM',coeff));

% Courbe corrigée / simulée - comsol
plot(env.f, PSD_corr_c, 'r-', 'LineWidth',1.8, 'DisplayName', sprintf('Corrigée comsol (%dD) - 3500RPM',coeff));

% Courbe référence
plot(fmean, L_RMS_band, 'LineWidth',1.2, 'DisplayName','Numérique (Elissa)');
yline(OASPL2500, 'b--', 'DisplayName', 'Niveau RMS global 0-2500 Hz [dB re 2e-5 Pa]', ...
    'Label', ['OASPL2500_elissa = ', num2str(round(OASPL2500, 2)), ' dB'], 'LabelHorizontalAlignment', 'right',  'LabelVerticalAlignment', 'bottom', 'HandleVisibility', 'off');
yline(OASPL1000, 'r--', 'DisplayName', 'Niveau RMS global 0-1000 Hz [dB re 2e-5 Pa]', ...
    'Label', ['OASPL1000_elissa = ', num2str(round(OASPL1000, 2)), ' dB'], 'LabelHorizontalAlignment', 'left',  'LabelVerticalAlignment', 'bottom', 'HandleVisibility', 'off');
yline(OASPL2500_corrigee, 'k--', 'DisplayName', 'Niveau RMS global 0-2500 Hz [dB re 2e-5 Pa]', ...
    'Label', ['OASPL2500_corrigée = ', num2str(round(OASPL2500_corrigee, 2)), ' dB'], 'LabelHorizontalAlignment', 'right',  'LabelVerticalAlignment', 'bottom', 'HandleVisibility', 'off');
yline(OASPL1000_corrigee, 'g--', 'DisplayName', 'Niveau RMS global 0-1000 Hz [dB re 2e-5 Pa]', ...
    'Label', ['OASPL1000_corrigée = ', num2str(round(OASPL1000_corrigee, 2)), ' dB'], 'LabelHorizontalAlignment', 'left',  'LabelVerticalAlignment', 'bottom', 'HandleVisibility', 'off');
legend('show','Location','best');

% === BANDES DE FRÉQUENCE À METTRE EN ÉVIDENCE ===
bandes = [...
    220   240;   % Bande 1
    430 470;  % Bande 2
    640 700; % Bande 3
    870 950  % Bande 4
];

% Ajout des bandes
yl = ylim; % Récupère les limites verticales actuelles
colors = [0.9 0.9 0.9; 0.85 0.85 0.85];   % Alternance de gris clair

for i = 1:size(bandes,1)
    x_patch = [bandes(i,1), bandes(i,2), bandes(i,2), bandes(i,1)];
    y_patch = [yl(1), yl(1), yl(2), yl(2)];
    patch(x_patch, y_patch, colors(mod(i,2)+1,:), ...
        'FaceAlpha', 0.3, 'EdgeColor', 'none',...
        'HandleVisibility','off');
end