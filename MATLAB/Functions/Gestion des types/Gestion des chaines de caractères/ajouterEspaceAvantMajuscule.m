function output = ajouterEspaceAvantMajuscule(inputString)
    % Cette fonction ajoute un espace avant chaque lettre majuscule dans la chaîne de caractères donnée
    output = regexprep(inputString, '([A-Z])', ' $1');
    
    % Supprimer l'espace initial si la chaîne commence par une majuscule
    if startsWith(output, ' ')
        output = output(2:end);
    end
end
