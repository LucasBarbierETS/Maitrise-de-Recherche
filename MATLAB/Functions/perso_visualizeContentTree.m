function perso_visualizeContentTree(object, tree)
    
    % Si un arbre existe déjà, supprimez tous les nœuds enfants
    if ~isempty(tree)
        delete(tree.Children);
    end
    
    % Crée ou réutilise le nœud racine
    rootNode = uitreenode(tree, 'Text', 'Root AppContainer');
    
    % Ajoute les nœuds enfants récursivement
    addContentNodes(rootNode, object);
    
    % Développe tous les nœuds
    expand(tree);
    
    % Ajoute un listener pour mettre à jour l'arbre lorsque le contenu change
    addlistener(object, 'ContentChanged', @(src, event) updateTree(tree, object));
end

function addContentNodes(parent_node, obj)
    % Vérifie si Content est un objet ou une cellule
    if iscell(obj.Content)
        contents = obj.Content;
    else
        contents = {obj.Content};
    end
    
    % Parcourt chaque élément dans Content
    for i = 1:numel(contents)
        child = contents{i};
        
        if isa(child, 'AppContainer')
            % Ajoute un nœud pour le AppContainer enfant
            childNode = uitreenode(parent_node, 'Text', ['AppContainer: ', class(child)]);
            addContentNodes(childNode, child);
        else
            % Ajoute un nœud pour les autres objets
            uitreenode(parent_node, 'Text', ['Content: ', class(child)]);
            
            % Si l'objet a un attribut Content, ajoutez-le récursivement
            if isprop(child, 'Content')
                % Vérifie si Content n'est pas vide
                contentProp = child.Content;
                if ~isempty(contentProp)
                    addContentNodes(parent_node, child);
                end
            end
        end
    end
end

function updateTree(tree, rootObject)
    
    % Supprime tous les nœuds existants
    delete(tree.Children);
    
    % Crée le nœud racine
    rootNode = uitreenode(tree, 'Text', 'Root AppContainer');
    
    % Ajoute les nœuds enfants récursivement
    addContentNodes(rootNode, rootObject);
    
    % Développe tous les nœuds
    expand(tree);
end
