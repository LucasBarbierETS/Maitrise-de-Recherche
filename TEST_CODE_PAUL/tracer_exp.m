%% --- Sélection de tous les fichiers à traiter ---
[files, path] = uigetfile('*.txt', ...
    'Sélectionne tous les fichiers Mesure (multisélection)', 'MultiSelect', 'on');

if isequal(files,0)
    error('Aucun fichier sélectionné.');
end

if ischar(files)
    files = {files};
end

%% --- Lecture du premier fichier pour créer l'environnement ---
raw0 = readmatrix(fullfile(path, files{1}));
data0 = raw0(61:end, :);
f0 = data0(:,1)';                % fréquence
pt_rms0 = data0(:,2)';           % pression RMS

% Environnement basé sur le 1er fichier
env = create_environnement_2(t, sp, hum, f0, 'Root', root);

%% --- Récupération des données numériques Elissa ---
file_path = fullfile([env.Root, '\Optimisation\Optimisation REAR\stator_spectrum_data.txt']);
[fmean, L_RMS_band, OASPL2500, OASPL1000] = compute_LRMS_from_elissa(file_path, 'fmax', 5000);

%% --- FIGURE ---
figure; hold on; grid on;
xlabel('Fréquence [Hz]');
ylabel('Niveau de pression [dB re p_{ref}]');
title('Comparaison des niveaux de pression – Mesures vs Numérique');

%% --- Boucle sur tous les fichiers sélectionnés ---
for i = 1:length(files)

    raw = readmatrix(fullfile(path, files{i}));
    data = raw(61:end, :);

    f = data(:,1)';               % fréquence
    pt_rms = data(:,2)';          % pression RMS

    PSD = 20*log10(abs(pt_rms)/env.p_ref);

    plot(f, PSD, 'LineWidth', 1.2, 'DisplayName', files{i});
end

%% --- Courbe numérique Elissa ---
plot(fmean, L_RMS_band, 'k', 'LineWidth', 1.8, 'DisplayName','Numérique (Elissa)');

%% --- Lignes OASPL ---
yline(OASPL2500, 'b--', ...
    'DisplayName','Niveau RMS global 0-2500 Hz', ...
    'Label',['OASPL2500_{elissa} = ' num2str(round(OASPL2500,2)) ' dB'], ...
    'LabelHorizontalAlignment','right', ...
    'LabelVerticalAlignment','bottom', ...
    'HandleVisibility','off');

yline(OASPL1000, 'r--', ...
    'DisplayName','Niveau RMS global 0-1000 Hz', ...
    'Label',['OASPL1000_{elissa} = ' num2str(round(OASPL1000,2)) ' dB'], ...
    'LabelHorizontalAlignment','left', ...
    'LabelVerticalAlignment','bottom', ...
    'HandleVisibility','off');

%% --- Zoom horizontal ---
xlim([0 2500]);

%% --- Légende ---
legend('show', 'Location', 'best');