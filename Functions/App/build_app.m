function build_app()
    projectRoot = 'C:\Users\lucas.barbier\Documents\Maitrise ETS\Répertoire GitHub';
    tempDir = fullfile(projectRoot, 'temp_build');

    % Nettoyage / création d’un dossier temporaire
    if isfolder(tempDir)
        rmdir(tempDir, 's');
    end
    mkdir(tempDir);

    % Copie du contenu sans les .mlx
    copyfile(fullfile(projectRoot, 'Apps'), fullfile(tempDir, 'Apps'));
    copyfile(fullfile(projectRoot, 'Classes'), fullfile(tempDir, 'Classes'));
    copyfile(fullfile(projectRoot, 'Functions'), fullfile(tempDir, 'Functions'));
    copyfile(fullfile(projectRoot, 'MATLAB scripts'), fullfile(tempDir, 'MATLAB scripts'));

    % Suppression des .mlx dans le dossier temporaire
    mlxFiles = dir(fullfile(tempDir, '**', '*.mlx'));
    for f = 1:numel(mlxFiles)
        delete(fullfile(mlxFiles(f).folder, mlxFiles(f).name));
    end

    % Utilisation du dossier temporaire pour la compilation
    appFile = fullfile(tempDir, 'Apps', 'Environnement_App.mlapp');
    outputDir = fullfile(tempDir, 'for_testing');

    cmd = sprintf('mcc -o EPCBellPresettingsApp -W ''WinMain:EPCBellPresettingsApp,version=1.0'' -T link:exe -d "%s" -v "%s" -a "%s" -a "%s" -a "%s" -a "%s"', ...
        outputDir, appFile, ...
        fullfile(tempDir, 'Apps'), ...
        fullfile(tempDir, 'Classes'), ...
        fullfile(tempDir, 'Functions'), ...
        fullfile(tempDir, 'MATLAB scripts'));

    fprintf('\n--- Compilation command ---\n%s\n', cmd);
    status = system(cmd);

    if status == 0
        disp('✅ Compilation terminée avec succès !');
    else
        error('❌ Échec de la compilation. Consulte la sortie ci-dessus.');
    end
end
