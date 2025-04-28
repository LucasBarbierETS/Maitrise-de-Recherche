function perso_commit()
% perso_commit(commit_message)
%   Committe tous les fichiers du dossier MATLAB avec un message donné

    % Définir le chemin du dossier à ajouter
    repo_path = 'E:\Montréal 2023 - 2025\Maitrise LB\MATLAB';

    % Vérifier si le dossier existe
    if ~isfolder(repo_path)
        error('Le dossier MATLAB n''existe pas dans ce répertoire.');
    end

    % Ajouter tous les fichiers du dossier MATLAB
    system(sprintf('git add "%s"', repo_path));

    % Faire le commit
    commit_command = sprintf('git commit -m "%s"', datetime('now'));
    status = system(commit_command);

    if status == 0
        fprintf('✅ Commit réalisé avec succès.\n');
    else
        warning('⚠️ Le commit n''a pas réussi. Vérifiez l''état du dépôt.');
    end
    
    system('git push');
end