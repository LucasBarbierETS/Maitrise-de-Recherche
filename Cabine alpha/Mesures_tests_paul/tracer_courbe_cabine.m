%% --- Sélection du fichier ---
[file, path] = uigetfile('*.txt', 'Sélectionne ton fichier TXT');
if isequal(file,0)
    error('Aucun fichier sélectionné.');
end

fullpath = fullfile(path, file);

%% --- Lecture brute du fichier (toutes les lignes, même texte) ---
fid = fopen(fullpath, 'r');
rawLines = textscan(fid, '%s', 'Delimiter', '\n', 'Whitespace', '');
fclose(fid);
rawLines = rawLines{1};   % cell array de toutes les lignes

%% --- Convertir lignes 32 à 61 en données numériques ---
data = [];
for k = 32:61
    nums = sscanf(rawLines{k}, '%f');   % lecture strictement numérique
    data = [data; nums'];               % chaque ligne devient un row vector
end

% %% --- Vérification minimale ---
% if size(data, 2) < 146
%     error('Les colonnes 127 ou 136 ne sont pas présentes dans ces lignes.');
% end

%% --- Extraction des colonnes ---
frequences = data(:, 1);
alpha1     = data(:, 127);
alpha2     = data(:, 136);

%% --- Tracé ---
figure;
plot(frequences, alpha1, 'LineWidth', 1.6); hold on;
plot(frequences, alpha2, 'LineWidth', 1.6);

grid on;
xlabel('Fréquence (Hz)');
ylabel('Absorption');
title('Absorption en fonction de la fréquence');
legend('Col.128','Col.137', 'Location','best');