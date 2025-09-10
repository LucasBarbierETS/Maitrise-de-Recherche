function handle_assembly = prepareElementAssembly(app, list_of_input_surfaces)
    
%% Description

    % La fonction prepareElementAssembly prépare l'assemblage des éléments en 
    % utilisant les surfaces définies par l'utilisateur et les sous-éléments 
    % positionnés dans l'interface utilisateur

    % Méthodologie :
    % 1. **Initialisation des Structures** : On commence par initialiser une liste 
    %    vide pour les éléments et les sous-éléments.
    % 2. **Parcours des Éléments** : On parcourt chaque élément en fonction des 
    %    coordonnées des axes définis dans l'interface utilisateur.
    % 3. **Collecte des Sous-éléments** : Pour chaque élément, on collecte les 
    %    sous-éléments correspondants en fonction de leur position définie.
    % 4. **Création des Objets élémentaires** : On crée des objets éléments 
    %    basés sur les sous-éléments collectés et les surfaces spécifiées.
    % 5. **Définition de l'Assemblage** : Enfin, on définit un handle pour 
    %    l'assemblage en utilisant les éléments créés.

    % Arguments :
    % - app : L'objet de l'application contenant les données et les paramètres.
    % - list_of_input_surfaces : Un tableau des surfaces d'entrée pour chaque élément.

    % Retour :
    % - handle_assembly : Un handle fonctionnel permettant de créer un objet de type classelementassembly

 %% Code
 
    % Initialisation du tableau des éléments
    cell_of_elements = {};

    % Parcours de chaque élément défini par l'utilisateur dans l'interface
    for ii = 1:length(app.MainApp.UIAxes.YTick)
        % Initialisation du tableau des sous-éléments pour cet élément
        cell_of_subelements = {};

        % Parcours de chaque sous-élément défini dans l'interface utilisateur
        for jj = 1:length(app.MainApp.UIAxes.XTick)
            % Pour chaque sous-élément, on vérifie sa position et on l'ajoute
            % à la liste des sous-éléments si sa position correspond.
            fnames = fieldnames(app.MainApp.SubelementDatas);
            for fi = 1:length(fnames)
                if ~ismember(getfield(app.MainApp.SubelementDatas, fnames{fi}, "Name"), ["None", "Undefined"])
                    Position = getfield(app.MainApp.SubelementDatas, fnames{fi}, "Position");
                    if Position(1) == app.MainApp.UIAxes.XTick(jj) + 1 && Position(2) == app.MainApp.UIAxes.YTick(ii) + 1
                        handle_object = getfield(app.MainApp.SubelementDatas, fnames{fi}, "Object");
                        cell_of_subelements{end + 1} = handle_object;
                    end
                end
            end
        end

        % Création d'un objet élément avec les sous-éléments collectés
        if ~isscalar(app.MainApp.UIAxes.XTick) && ~isempty(cell_of_subelements)
            if ii == 1
                % Cas particulier pour le premier élément
                new_element = @(params) Element(list_of_input_surfaces(ii) / app.MainApp.EPCSurface, ...
                    cellfun(@(x) cellfunction2list(x, params), cell_of_subelements, 'UniformOutput', false), 'opened');
            else
                % Cas général pour les autres éléments
                new_element = @(params) Element(list_of_input_surfaces(ii) / app.MainApp.EPCSurface, ...
                    cellfun(@(x) cellfunction2list(x, params), cell_of_subelements, 'UniformOutput', false), 'closed');
            end
            cell_of_elements{end + 1} = new_element;
        end
    end

    % Création du handle pour l'assemblage des éléments en utilisant la liste
    % des éléments préparés
    list_of_elements = @(params) cellfun(@(x) cellfunction2list(x, params), cell_of_elements);
    handle_assembly = @(params) classelementassembly(list_of_elements(params));
end


