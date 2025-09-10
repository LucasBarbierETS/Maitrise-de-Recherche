function outputStr = perso_camelcase(inputStr)
    % Remplace les underscores par des espaces pour séparer les mots
    words = strsplit(inputStr, '_');
    
    % Met chaque mot en capitalisant la première lettre
    words = cellfun(@(w) [upper(w(1)) lower(w(2:end))], words, 'UniformOutput', false);
    
    % Concatène les mots sans espace
    outputStr = strjoin(words, '');
end