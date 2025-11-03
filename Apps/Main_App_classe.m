classdef Main_App_classe < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                   matlab.ui.Figure
        FileMenu                   matlab.ui.container.Menu
        ClearMenu                  matlab.ui.container.Menu
        OpenMenu                   matlab.ui.container.Menu
        SaveMenu                   matlab.ui.container.Menu
        ModifyenvironnementparametersMenu  matlab.ui.container.Menu
        fonctiontemporaireinit_typesMenu  matlab.ui.container.Menu
        ConfigurationMenu          matlab.ui.container.Menu
        NewElementMenu             matlab.ui.container.Menu
        DeleteFirstElementMenu     matlab.ui.container.Menu
        ImportElementMenu          matlab.ui.container.Menu
        GridLayout                 matlab.ui.container.GridLayout
        ParametersPanel            matlab.ui.container.Panel
        ParametersGrid             matlab.ui.container.GridLayout
        Panel                      matlab.ui.container.Panel
        ButtonsPanel               matlab.ui.container.GridLayout
        ComputeButton              matlab.ui.control.Button
        ParametricStudyButton      matlab.ui.control.Button
        OptimiseButton             matlab.ui.control.Button
        ParametersViewPanel        matlab.ui.container.Panel
        TypeDropDown               matlab.ui.control.DropDown
        TypeDropDownLabel          matlab.ui.control.Label
        ParametersSubPanel         matlab.ui.container.Panel
        ViewGrid                   matlab.ui.container.GridLayout
        VariablesGrid              matlab.ui.container.GridLayout
        VariablesButtonsGrid       matlab.ui.container.GridLayout
        deletevariableButton       matlab.ui.control.Button
        addvariableButton          matlab.ui.control.Button
        VariablesTable       matlab.ui.control.Table
        GraphPanel                 matlab.ui.container.Panel
        GraphGrid                  matlab.ui.container.GridLayout
        GridView                   matlab.ui.container.GridLayout
        Navigator                  matlab.ui.control.UIAxes
        ElementsGraph              matlab.ui.control.UIAxes
        SubelementsGraph           matlab.ui.control.UIAxes
    end

    
    properties (Access = public)
        
        EnvApp
        ParametricStudyApp
        OptimisationApp
        Graph 
        ParametersView
        Elements 
        Types
        Variables
    end

    events
        ElementsUpdated
    end
    
    
    methods (Access = public)
    
        function init_types(app)
            perso_init_types(app);
        end
    
        function subelement_type_dropdown_value_changed(app, ~, ~)
            perso_subelement_type_dropdown_value_changed(app);
        end
    
        function import_element(app)
            perso_import_element_file(app);  % appelle la fonction externe
        end
    
        function alpha = compute_alpha(app, varargin)
            
            % Construit la liste des éléments de l'application
            list_of_elements = {};
            for i = 1:length(app.Elements.Content)
                list_of_elements{end+1} = app.Elements.Content{i}.app_to_class(app, app.Variables);
            end
        
            % Crée l'assemblage et affiche le résultat
            assembly = classelementassembly(classelementassembly.create_config(list_of_elements));
            alpha = assembly.alpha(app.EnvApp, varargin{:});  
        end
    end

    methods (Access = private)
        function display_handle_variables(app)
            perso_display_handle_variables(app); 
        end
    end

    methods (Access = private) % Callbacks 

        % Code that executes after component creation
        function startupFcn(app, env)
            
            % Affichage centré sur l'écran
            disp_centered_app(app);
            
            % On créer l'environnement
            app.EnvApp = env;

            % On initialise le graphe
            set(app.ElementsGraph, 'YDir', 'normal');
            set(app.SubelementsGraph, 'YDir', 'normal');
            set(app.Navigator, 'YDir', 'normal');
            app.Graph = AppComponentContainer(app.GraphPanel, 'GlobalGraph');
            app.Graph.add_component(AppAxes(app.ElementsGraph, 'ElementsGraph'));
            app.Graph.add_component(AppAxes(app.SubelementsGraph, 'SubelementsGraph'));
            app.Graph.add_component(AppAxes(app.Navigator, 'Navigator'));

            % On initialise le panneau des paramètres
            app.ParametersView = AppComponentContainer(app.ParametersPanel, 'ParametersView');
            app.ParametersView.add_component(AppComponentContainer(app.ParametersSubPanel, 'ParametersSubView'));

            % On initialise les types de sous-élements 
            app.init_types();

            % On initialise la table des variables muettes
            app.VariablesTable.Data = (table({}, {}, {}, 'VariableNames', {'Name', 'Value', 'Description'}));
            app.VariablesTable.ColumnName = {'Name', 'Value', 'Description'};

            app.Variables = struct();

            % On crée un objet de classe AppContainer représentant la
            % collection d'élements gérés par l'application. On le
            % connecte au graphe de classe AppComponent associé à la
            % représentation des élements.

            app.Elements = AppContainer();
            app.Elements.scatter_with_call(app, app.Graph.Components.ElementsGraph);
            drawnow;
            app.Graph.Components.ElementsGraph.adjust_pictogram_sizes();
        end

        % Button pushed function: addvariableButton
        function addvariableButtonPushed(app, ~)
            % Ajoute une ligne dans le tableau des variables muettes

            len_table = length(app.VariablesTable.Data{:, 1}); 
            app.VariablesTable.Data(len_table + 1, :) = {'' '' ''}; 
        end 

        % Button pushed function: deletevariableButton
        function deletevariableButtonPushed(app, ~)
            % Supprime la dernière ligne dans le tableau des variables
            % muettes

            len_table = length(app.VariablesTable.Data{:, 1}); 
            app.VariablesTable.Data(len_table, :) = []; 
        end

        % % Menu selected function : DeleteElementenu
        % function DeleteFirstElementMenuSelected(app, ~)
        %     % if length(app.Elements.Content) > 1
        %     %     app.Elements.Content = app.Elements.Content{2:end};
        %     % end
        % end

        % Menu selected function: ImportElementMenu
        function ImportElementMenuSelected(app, ~)
            import_element(app)
        end

        % Menu selected function: ClearMenu
        function ClearMenuSelected(app, ~)
            cla(app.Graph.Components.SubelementsGraph.UIObject);
            cla(app.Graph.Components.ElementsGraph.UIObject);
            cla(app.Graph.Components.Navigator.UIObject);

            % On supprime les variables muettes stockées
            app.Variables = struct();
            display_handle_variables(app);

            % On cache tous les panneaux de paramètres
            app.ParametersView.Components.ParametersSubView.hide_components();
            app.TypeDropDown.Value = 'None';

            % On met à jour app.Elements et on l'affiche
            app.Elements = AppContainer();
            app.Elements.scatter_with_call(app, app.Graph.Components.ElementsGraph);
            % perso_visualizeContentTree(app.Elements, app.Tree);
        end

        % Display data changed function: VariablesTable
        function VariablesTableCellEdited(app, event)
            % Cette méthode est appelée lorsqu'une cellule du tableau est modifiée
        
            % Récupération de l'indice de la cellule modifiée
            row = event.Indices(1);
            col = event.Indices(2);
        
            % On ne traite que la deuxième colonne (Valeurs numériques)
            if col ~= 2
                return;
            end
        
            % On récupère le nom de la variable sur la même ligne
            var_name = app.VariablesTable.Data{row, 1}{1};
        
            % Si la variable est vide ou non définie, on ne fait rien
            if isempty(var_name) || var_name == ""
                return;
            end
        
            % Donnée brute entrée par l'utilisateur
            raw_value = event.NewData;
        
            % 🧠 Étape 1 : conversion du texte brut -> valeur numérique
            if ischar(raw_value) || isstring(raw_value)
                numbers = str2num(char(raw_value));
                if isempty(numbers)
                    % Entrée non reconnue comme numérique
                    numeric_value = NaN;
                else
                    numeric_value = numbers(1);
                end

            elseif isnumeric(raw_value)
                % Si c'est déjà une valeur numérique
                numeric_value = raw_value;
            else
                % Tout autre format est indésirable
                numeric_value = NaN;
                uialert(app.UIFigure, sprintf(...
                    'Format incompatible à la ligne %d. Une valeur numérique est attendue.', row), ...
                    'Erreur');
            end
        
            % 🧠 Étape 2 : Mettre à jour le tableau pour afficher la valeur formatée
            app.VariablesTable.Data{row, col} = {num2str(numeric_value)};
        
            % 🧠 Étape 3 : Mettre à jour ta structure interne Variables
            app.Variables.(var_name).Value = numeric_value;
            app.Variables.(var_name).Description = app.VariablesTable.Data{row, 3}{1};
        end

        % Button pushed function: ComputeButton
        function ComputeButtonPushed(app, ~)

        % Cette méthode est appelée lorsque l'utilisateur.ice clique sur le
        % bouton Compute. Elle permet de reconstruire l'objet de classe à
        % partir des paramètres renseignés dans l'interface
        
        % % 1. On extrait les paramètres de l’app vers une structure
        % paramsStruct = app.exportConfiguration();
        % 
        % % 2. On évalue ces paramètres dans un objet de calcul (modèle)
        % model = app.ModelEvaluator.evaluateFromStruct(paramsStruct);
        % 
        % % 3. L’affichage est volontairement séparé
        % app.DisplayManager.displayResults(model, app.EnvApp);



        alpha = compute_alpha(app);

        % Pour l'instant on affiche le tracé dans une figure à part
        assembly.plot_alpha(app.EnvApp, 'assembly', 'iter');
        hold on
        end

        % Button pushed function: ParametricStudyButton
        function ParametricStudyButtonPushed(app, ~)
        % Cette méthode est appelée lorsque l'utilisateur.ice clique sur le 
        % bouton Parametric Study.

            if isempty(app.ParametricStudyApp) || ~isvalid(app.ParametricStudyApp)
                app.ParametricStudyApp = Parametric_Study_App(app);
            else
                app.ParametricStudyApp.UIFigure.Visible = 'on';
            end
        end

        % Menu selected function: SaveMenu
        function SaveMenuSelected(app, ~)
        % Cette méthode est appelée lorsque l'utilisateur.ice enregistre la
        % configuration de l'application

            % Ouvre une boîte de dialogue pour sauvegarder un fichier avec extension .config
            [file, path] = uiputfile('*.config');
            filename = fullfile(path, file); % Construit le chemin complet du fichier
            
    
            datas = {app.Env, app.Elements, app.Variables};


            % Sauvegarde les données dans un fichier .config
            save(filename, 'datas');
        end

        % Menu selected function: OpenMenu
        function OpenMenuSelected(app, ~)
            % Cette méthode est appelée lorsque l'utilisateur.ice enregistre la
            % configuration de l'application

                % Ouvre une boîte de dialogue pour sauvegarder un fichier avec extension .config
                defaultFolder = 'C:\Users\lucas.barbier\Documents\Maitrise ETS\Répertoire GitHub\Apps\Configurations';
                [file, ~] = uigetfile({'*.config'},'Sélectionne un fichier', defaultFolder);
                datas = importdata(file);

                % On redéfinit les variables d'application
                app.Env = datas{1};
                app.Elements = datas{2};
                app.Variables = datas{3};
                app.Elements.Content{1}.show(app);

                % On affiche la configuration d'interface importée
                display_handle_variables(app);
                % perso_visualizeContentTree(app.Elements, app.Tree);
        end

        function OptimiseButtonPushed(app, ~)
            if isempty(app.OptimisationApp) || ~isvalid(app.OptimisationApp)
               app.OptimisationApp = Optimisation_App(app);
            else
                app.OptimisationApp.update_optimised_variables_table();
                app.OptimisationApp.UIFigure.Visible = 'on';
            end
        end

        % Menu selected function: fonctiontemporaireinit_typesMenu
        function fonctiontemporaireinit_typesMenuSelected(app, ~)
            app.init_types()
        end

        function app = reinit_app_typesMenuSelected(app, ~)

            app.startupFcn(app.EnvApp)
        end

        % Menu selected function: ModifyenvironnementparametersMenu
        function ModifyenvironnementparametersMenuSelected(app, ~)
            app.EnvApp.UIFigure.Visible = "on";
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 890 575];
            app.UIFigure.Name = 'MATLAB App';

            % Create FileMenu
            app.FileMenu = uimenu(app.UIFigure);
            app.FileMenu.Text = 'File';

            % Create ClearMenu
            app.ClearMenu = uimenu(app.FileMenu);
            app.ClearMenu.MenuSelectedFcn = createCallbackFcn(app, @ClearMenuSelected, true);
            app.ClearMenu.Text = 'Clear';

            % Create OpenMenu
            app.OpenMenu = uimenu(app.FileMenu);
            app.OpenMenu.MenuSelectedFcn = createCallbackFcn(app, @OpenMenuSelected, true);
            app.OpenMenu.Text = 'Open';

            % Create SaveMenu
            app.SaveMenu = uimenu(app.FileMenu);
            app.SaveMenu.MenuSelectedFcn = createCallbackFcn(app, @SaveMenuSelected, true);
            app.SaveMenu.Text = 'Save';

            % Create ModifyenvironnementparametersMenu
            app.ModifyenvironnementparametersMenu = uimenu(app.FileMenu);
            app.ModifyenvironnementparametersMenu.MenuSelectedFcn = createCallbackFcn(app, @ModifyenvironnementparametersMenuSelected, true);
            app.ModifyenvironnementparametersMenu.Text = 'Modify environnement parameters';

            % Create fonctiontemporaireinit_typesMenu
            app.fonctiontemporaireinit_typesMenu = uimenu(app.FileMenu);
            app.fonctiontemporaireinit_typesMenu.MenuSelectedFcn = createCallbackFcn(app, @fonctiontemporaireinit_typesMenuSelected, true);
            app.fonctiontemporaireinit_typesMenu.Text = 'fonction temporaire : init_types';

            % Create reinit_app_typesMenu
            app.fonctiontemporaireinit_typesMenu = uimenu(app.FileMenu);
            app.fonctiontemporaireinit_typesMenu.MenuSelectedFcn = createCallbackFcn(app, @reinit_app_typesMenuSelected, true);
            app.fonctiontemporaireinit_typesMenu.Text = 'fonction temporaire : reinit_app';

            % Create ConfigurationMenu
            app.ConfigurationMenu = uimenu(app.UIFigure);
            app.ConfigurationMenu.Text = 'Configuration';

            % Create NewElementMenu
            app.NewElementMenu = uimenu(app.ConfigurationMenu);
            app.NewElementMenu.Text = 'New Element';

            % Create DeleteFirstElementMenu
            app.DeleteFirstElementMenu = uimenu(app.ConfigurationMenu);
            app.DeleteFirstElementMenu.MenuSelectedFcn = createCallbackFcn(app, @DeleteFirstElementMenuSelected, true);
            app.DeleteFirstElementMenu.Text = 'Delete First Element';

            % Create ImportElementMenu
            app.ImportElementMenu = uimenu(app.ConfigurationMenu);
            app.ImportElementMenu.MenuSelectedFcn = createCallbackFcn(app, @ImportElementMenuSelected, true);
            app.ImportElementMenu.Text = 'Import Element';

            % Create GridLayout
            app.GridLayout = uigridlayout(app.UIFigure);
            app.GridLayout.ColumnWidth = {'3x', '2x'};
            app.GridLayout.RowHeight = {'1x'};

            % Create ViewGrid
            app.ViewGrid = uigridlayout(app.GridLayout);
            app.ViewGrid.ColumnWidth = {'1x'};
            app.ViewGrid.RowHeight = {'3x', '5x'};
            app.ViewGrid.Layout.Row = 1;
            app.ViewGrid.Layout.Column = 1;

            % Create GraphPanel
            app.GraphPanel = uipanel(app.ViewGrid);
            app.GraphPanel.Title = 'Graph';
            app.GraphPanel.Layout.Row = 2;
            app.GraphPanel.Layout.Column = 1;

            % Create GraphGrid
            app.GraphGrid = uigridlayout(app.GraphPanel);
            app.GraphGrid.ColumnWidth = {'2x'};
            app.GraphGrid.RowHeight = {'1x'};
            app.GraphGrid.ColumnSpacing = 0;
            app.GraphGrid.RowSpacing = 0;

            % Create GridView
            app.GridView = uigridlayout(app.GraphGrid);
            app.GridView.ColumnWidth = {'1x'};
            app.GridView.RowHeight = {'1x', '2x', '2x'};
            app.GridView.ColumnSpacing = 0;
            app.GridView.RowSpacing = 0;
            app.GridView.Padding = [0 0 0 0];
            app.GridView.Layout.Row = 1;
            app.GridView.Layout.Column = 1;

            % Create SubelementsGraph
            app.SubelementsGraph = uiaxes(app.GridView);
            app.SubelementsGraph.XTick = [];
            app.SubelementsGraph.YTick = [];
            app.SubelementsGraph.Layout.Row = 3;
            app.SubelementsGraph.Layout.Column = 1;
            app.SubelementsGraph.Tag = 'SubelementsGraph';

            % Create ElementsGraph
            app.ElementsGraph = uiaxes(app.GridView);
            app.ElementsGraph.XTick = [];
            app.ElementsGraph.YTick = [];
            app.ElementsGraph.Layout.Row = 2;
            app.ElementsGraph.Layout.Column = 1;
            app.ElementsGraph.Tag = 'ElementsGraph';

            % Create Navigator
            app.Navigator = uiaxes(app.GridView);
            app.Navigator.XTick = [];
            app.Navigator.YTick = [];
            app.Navigator.Layout.Row = 1;
            app.Navigator.Layout.Column = 1;

            % Create VariablesGrid
            app.VariablesGrid = uigridlayout(app.ViewGrid);
            app.VariablesGrid.ColumnWidth = {'1x'};
            app.VariablesGrid.RowHeight = {'4x', '2x'};
            app.VariablesGrid.Layout.Row = 1;
            app.VariablesGrid.Layout.Column = 1;

            % Create VariablesTable
            app.VariablesTable = uitable(app.VariablesGrid);
            app.VariablesTable.ColumnName = '';
            app.VariablesTable.RowName = {};
            app.VariablesTable.SelectionType = 'row';
            app.VariablesTable.ColumnEditable = true;
            app.VariablesTable.CellEditCallback = createCallbackFcn(app, @VariablesTableCellEdited, true);
            app.VariablesTable.Layout.Row = 1;
            app.VariablesTable.Layout.Column = 1;

            % Create VariablesButtonsGrid
            app.VariablesButtonsGrid = uigridlayout(app.VariablesGrid);
            app.VariablesButtonsGrid.RowHeight = {'1x'};
            app.VariablesButtonsGrid.Layout.Row = 2;
            app.VariablesButtonsGrid.Layout.Column = 1;

            % Create addvariableButton
            app.addvariableButton = uibutton(app.VariablesButtonsGrid, 'push');
            app.addvariableButton.ButtonPushedFcn = createCallbackFcn(app, @addvariableButtonPushed, true);
            app.addvariableButton.Layout.Row = 1;
            app.addvariableButton.Layout.Column = 1;
            app.addvariableButton.Text = 'add variable';

            % Create deletevariableButton
            app.deletevariableButton = uibutton(app.VariablesButtonsGrid, 'push');
            app.deletevariableButton.ButtonPushedFcn = createCallbackFcn(app, @deletevariableButtonPushed, true);
            app.deletevariableButton.Layout.Row = 1;
            app.deletevariableButton.Layout.Column = 2;
            app.deletevariableButton.Text = 'delete variable';

            % Create ParametersPanel
            app.ParametersPanel = uipanel(app.GridLayout);
            app.ParametersPanel.BorderType = 'none';
            app.ParametersPanel.Layout.Row = 1;
            app.ParametersPanel.Layout.Column = 2;

            % Create ParametersGrid
            app.ParametersGrid = uigridlayout(app.ParametersPanel);
            app.ParametersGrid.ColumnWidth = {'1x'};
            app.ParametersGrid.RowHeight = {'8x', '1x'};

            % Create ParametersViewPanel
            app.ParametersViewPanel = uipanel(app.ParametersGrid);
            app.ParametersViewPanel.Title = 'Parameters View';
            app.ParametersViewPanel.Layout.Row = 1;
            app.ParametersViewPanel.Layout.Column = 1;

            % Create ParametersSubPanel
            app.ParametersSubPanel = uipanel(app.ParametersViewPanel);
            app.ParametersSubPanel.Position = [20 58 290 341];

            % Create TypeDropDownLabel
            app.TypeDropDownLabel = uilabel(app.ParametersViewPanel);
            app.TypeDropDownLabel.HorizontalAlignment = 'right';
            app.TypeDropDownLabel.Position = [20 413 31 22];
            app.TypeDropDownLabel.Text = 'Type';

            % Create TypeDropDown
            app.TypeDropDown = uidropdown(app.ParametersViewPanel);
            app.TypeDropDown.Items = {};
            app.TypeDropDown.Position = [66 413 244 22];
            app.TypeDropDown.Value = {};

            % Create Panel
            app.Panel = uipanel(app.ParametersGrid);
            app.Panel.BorderType = 'none';
            app.Panel.Layout.Row = 2;
            app.Panel.Layout.Column = 1;

            % Create ButtonsPanel
            app.ButtonsPanel = uigridlayout(app.Panel);
            app.ButtonsPanel.ColumnWidth = {'1x', '1x', '1x'};
            app.ButtonsPanel.RowHeight = {'1x'};

            % Create OptimiseButton
            app.OptimiseButton = uibutton(app.ButtonsPanel, 'push');
            app.OptimiseButton.ButtonPushedFcn = createCallbackFcn(app, @OptimiseButtonPushed, true);
            app.OptimiseButton.Layout.Row = 1;
            app.OptimiseButton.Layout.Column = 3;
            app.OptimiseButton.Text = 'Optimise';

            % Create ParametricStudyButton
            app.ParametricStudyButton = uibutton(app.ButtonsPanel, 'push');
            app.ParametricStudyButton.ButtonPushedFcn = createCallbackFcn(app, @ParametricStudyButtonPushed, true);
            app.ParametricStudyButton.WordWrap = 'on';
            app.ParametricStudyButton.Layout.Row = 1;
            app.ParametricStudyButton.Layout.Column = 2;
            app.ParametricStudyButton.Text = 'Parametric Study';

            % Create ComputeButton
            app.ComputeButton = uibutton(app.ButtonsPanel, 'push');
            app.ComputeButton.ButtonPushedFcn = createCallbackFcn(app, @ComputeButtonPushed, true);
            app.ComputeButton.Layout.Row = 1;
            app.ComputeButton.Layout.Column = 1;
            app.ComputeButton.Text = 'Compute';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        function app = Main_App_classe(varargin)

            % Toujours commencer par créer l’objet (appel obligatoire du parent)
            app = app@matlab.apps.AppBase;

            % Identifiant unique pour singleton
            appID = 'MainAppSingleton';

            % Tester si une instance existe déjà
            runningApp = getappdata(0, appID);

            if isempty(runningApp) || ~isvalid(runningApp)

                % Création complète de l'app
                createComponents(app);
                registerApp(app, app.UIFigure);

                % Enregistrement du singleton
                setappdata(0, appID, app);

                % Lancement de la startup function
                runStartupFcn(app, @(app)startupFcn(app, varargin{:}));

                % Définition de la fermeture propre
                app.UIFigure.CloseRequestFcn = @(src, event) closeSingletonApp(app, appID);

            else
                % Instance existante => focus et retour
                figure(runningApp.UIFigure);
                app = runningApp;
                return;  % pas besoin de recréer l'app
            end

            % Effacer la variable locale si pas capturée par l'appelant
            if nargout == 0
                clear app;
            end
        end

        function closeSingletonApp(app, appID)
            % Supprimer la référence globale
            rmappdata(0, appID);

            % Appeler delete pour cleanup UI
            delete(app);
        end

        function delete(app)
            delete(app.UIFigure);
        end
    end
end