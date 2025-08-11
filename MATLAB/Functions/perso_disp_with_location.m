function perso_disp_with_location(msg)
    % Récupère le nom du fichier et le numéro de ligne actuels
    stack = dbstack;
    filename = stack(1).file;  % Nom du fichier
    line_number = stack(1).line;  % Numéro de ligne où la fonction a été appelée
    
    % Affiche le message avec l'endroit où il a été généré
    fprintf('%s (Ligne %d): %s\n', filename, line_number, msg);
    
    % Ajouter un point d'arrêt ici
    keyboard;  % Arrête l'exécution ici
end