function perso_assign_callbacks_to_childrens(parentComponent, callbackFcn)
% PERSO_ASSIGN_CALLBACKS_TO_CHILDRENS
% Associe un callback à tous les enfants d'un objet graphique qui acceptent 
% une propriété de type Callback (ValueChangedFcn, ButtonPushedFcn, etc.)
%
% USAGE :
%   perso_assign_callbacks_to_childrens(parentPanel, @(src, evt) myCallback(src, evt));
%
% INPUTS :
%   parentComponent : handle d'objet graphique (ex: Panel, UIFigure...)
%   callbackFcn     : fonction à assigner (ex: @(src,evt) disp(src.Value))

    % Recherche récursive de tous les sous-composants graphiques
    children = findall(parentComponent);

    % Parcourir tous les enfants
    for i = 1:length(children)
        cmp = children(i);
        props = properties(cmp);

        % Liste des callbacks intéressants (extensible selon tes besoins)
        potentialCallbacks = { ...
            'ValueChangedFcn', ...
            'ButtonPushedFcn', ...
            'ValueChangingFcn', ...
            'SelectionChangedFcn', ...
            'CheckedChangedFcn' ...
        };

        % Parcourir les callbacks possibles et assigner si la propriété existe
        for j = 1:length(potentialCallbacks)
            callbackProp = potentialCallbacks{j};

            if isprop(cmp, callbackProp)
                try
                    cmp.(callbackProp) = callbackFcn;
                catch
                    % Ignorer silencieusement les erreurs si l'objet n'accepte pas
                    % un certain format (ex: boutons sans event args)
                end
            end
        end
    end
end
