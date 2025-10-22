% --- Script : plot_txt_files.m
% Permet de sélectionner plusieurs fichiers .txt et tracer colonne 1 / colonne 2
% en remplaçant les "_" par des espaces dans la légende

clear; clc; close all;

% --- Sélection des fichiers
[filenames, filepath] = uigetfile('*.txt', ...
    'Sélectionnez un ou plusieurs fichiers texte', ...
    'MultiSelect', 'on');

if isequal(filenames, 0)
    disp('Aucun fichier sélectionné.');
    return;
end

% S'assurer que filenames est une cellule
if ischar(filenames)
    filenames = {filenames};
end

figure; hold on; grid on;
xlabel('Colonne 1');
ylabel('Colonne 2');
title('Tracé des fichiers TXT');

% --- Lecture et tracé de chaque fichier
for i = 1:numel(filenames)
    file = fullfile(filepath, filenames{i});
    
    % Lecture du fichier
    data = readmatrix(file);

    if size(data, 2) < 2
        warning('Le fichier "%s" ne contient pas au moins deux colonnes.', filenames{i});
        continue;
    end
    
    % Nom de légende avec "_" remplacés par des espaces
    cleanName = strrep(filenames{i}, '_', ' ');
    cleanName = erase(cleanName, '.txt'); % retire l'extension .txt

    % Tracé
    plot(data(:,1), data(:,2), 'DisplayName', cleanName, 'LineWidth', 1.5);
end

legend('Location', 'best');
hold off;
