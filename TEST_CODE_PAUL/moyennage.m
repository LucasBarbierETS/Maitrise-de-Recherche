clc;
clear all;

% Sélection des fichiers .txt
[files, path] = uigetfile('*.txt', 'Sélectionnez les fichiers TXT', 'MultiSelect', 'on');

% Vérification de sélection
if isequal(files, 0)
    disp('Aucun fichier sélectionné.');
    return;
end

if ischar(files)
    files = {files};  % Un seul fichier sélectionné → cellule
end

% Initialisations
freq_all = [];
data_all = {};
couleurs = lines(length(files));  % Palette de couleurs pour tracé
figure; hold on; grid on;

% Lecture et tracé des courbes individuelles
for k = 1:length(files)
    data = load(fullfile(path, files{k}));
    
    freq = data(:,1);
    amp_db = data(:,2);
    
    % Nettoyage des doublons de fréquence (si présents)
    [freq_unique, ~, idx_grp] = unique(freq);
    amp_db_avg = accumarray(idx_grp, amp_db, [], @mean);
    
    % Stockage
    data_all{k}.freq = freq_unique;
    data_all{k}.amp_db = amp_db_avg;
    
    % Mise à jour des fréquences globales
    freq_all = [freq_all; freq_unique];
    
    % Tracé
    plot(freq_unique, amp_db_avg, 'Color', couleurs(k,:), 'DisplayName', files{k});
end

% Grille de fréquence commune (fusion de toutes)
freq_common = unique(freq_all);

% Interpolation et conversion dB → linéaire
amp_lin_matrix = NaN(length(freq_common), length(files));

for k = 1:length(files)
    amp_interp = interp1(data_all{k}.freq, data_all{k}.amp_db, freq_common, 'linear', NaN);
    amp_lin = 2e-5*10.^(amp_interp / 20);  % Conversion dB → linéaire
    amp_lin_matrix(:,k) = amp_lin;
end

% Moyenne linéaire (ignorant NaN), puis reconversion en dB
amp_lin_mean = mean(amp_lin_matrix, 2, 'omitnan');
amp_db_mean = 20 * log10(amp_lin_mean/2e-5);

% Tracé de la moyenne
plot(freq_common, amp_db_mean, 'k-', 'LineWidth', 2.5, 'DisplayName', 'Moyenne');

% Mise en forme
xlabel('Fréquence (Hz)');
ylabel('Amplitude (dB)');
title('Courbes + Moyenne');
legend show;

% Création du nom du fichier de sortie
[~, baseName, ~] = fileparts(files{1});  % Nom du 1er fichier sans extension
output_filename = fullfile(path, [baseName '_moyenne.txt']);

% Assemblage des données : fréquence + amplitude moyenne
result = [freq_common, amp_db_mean];

% Sauvegarde au format TXT (tabulations)
writematrix(result, output_filename, 'Delimiter', 'tab');

disp(['Fichier de moyenne sauvegardé sous : ' output_filename]);