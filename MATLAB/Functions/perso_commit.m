function perso_commit(message)
% perso_commit(commit_message)
%   Commit tous les fichiers du dossier MATLAB avec un message donné
%   en excluant les fichiers avec l'extension .mph via .gitignore.

    % Définir le chemin du dépôt
    repo_path = 'C:\Users\lucas.barbier\Documents\Maitrise dossier secondaire';

    % Vérifier si le dossier existe
    if ~isfolder(repo_path)
        error('Le dossier MATLAB n''existe pas dans ce répertoire.');
    end

    % Accéder au répertoire du dépôt
    cd(repo_path);

    % Vérifier si le fichier .gitignore existe, sinon le créer
    if ~isfile('.gitignore')
        fid = fopen('.gitignore', 'w'); % Créer le fichier s'il n'existe pas
        fclose(fid);
    end

    % Ajouter .mph à .gitignore si ce n'est pas déjà fait
    fid = fopen('.gitignore', 'r');
    file_contents = fread(fid, '*char')';
    fclose(fid);
    if ~contains(file_contents, '*.mph')
        fid = fopen('.gitignore', 'a'); % Ouvrir en mode ajout
        fprintf(fid, '\n*.mph\n'); % Ajouter les fichiers .mph à ignorer
        fclose(fid);
    end

    % Ajouter tous les fichiers au dépôt, sauf ceux ignorés
    status = system('git add .');
    if status ~= 0
        error('Erreur lors de l''ajout des fichiers au dépôt.');
    end

    % Faire le commit avec le message fourni
    commit_command = sprintf('git commit -m "%s"', message);
    status = system(commit_command);
    if status == 0
        fprintf('✅ Commit réalisé avec succès.\n');
    else
        warning('⚠️ Le commit n''a pas réussi. Vérifiez l''état du dépôt.');
        return;
    end

    % Pousser les modifications vers le dépôt distant
    status = system('git push');
    if status == 0
        fprintf('✅ Push vers GitHub réussi.\n');
    else
        warning('⚠️ Le push vers GitHub a échoué. Vérifiez la connexion.');
    end
end
