function perso_save(folder_path, file_name, varargin)
    % Vérifier si le dossier existe, sinon le créer
    if ~exist(folder_path, 'dir')
        mkdir(folder_path);
    end
    
    % Créer le chemin complet du fichier
    fullfile_name = fullfile(folder_path, [file_name, '.mat']);
    
    % Si des variables supplémentaires sont passées, les enregistrer
    if nargin > 2
        % Enregistrer les variables spécifiques passées en arguments
        save(fullfile_name, varargin{:});
    else
        % Enregistrer toutes les variables de l'environnement de base
        vars = who;  % Liste de toutes les variables dans l'environnement de base
        save(fullfile_name, vars{:});  % Enregistrer toutes les variables dans le fichier
    end
end