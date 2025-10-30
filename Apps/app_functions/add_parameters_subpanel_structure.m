function ParametersPanelStruct = add_parameters_subpanel_structure(app, title, tags, units, varargin)
%ADD_PARAMETERS_SUBPANEL_STRUCTURE Crée une structure d'accès au panneau des paramètres.
%
%   Cette fonction permet de créer un panneau de paramètres dans
%   l'application App Designer et renvoie une structure contenant
%   les handles vers les composants créés (labels, champs, unités).
%
%   Utilisée dans : init_subelements_types, init_elements_types, etc.
%
%   Entrées :
%       app   - Objet de l'application
%       title - Titre du sous-panneau
%       tags  - Cell array de chaînes : noms des paramètres
%       units - Cell array de chaînes : unités ou type du champ ('m', 'word', 'dropdown', etc.)
%       varargin (optionnel) - Cell array des choix si certains champs sont des dropdowns
%
%   Sortie :
%       ParametersPanelStruct - Structure contenant tous les composants du panneau

    % Initialisation
    ParametersPanelStruct = struct();

    % Récupération du conteneur principal
    container = app.ParametersView.Components.ParametersSubView;
    panel = container.add_empty_panel(title);

    N = length(tags);
    Labels = cell(1, N);
    EditFields = cell(1, N);
    UnitsLbl = cell(1, N);

    % Si on a un cinquième argument, ce sont les listes d'options
    if nargin > 4 && ~isempty(varargin{1})
        dropdown_options = varargin{1};
    else
        dropdown_options = cell(1, N);
    end

    % Boucle de création
    for i = 1:N
        % Label du paramètre
        Labels{i} = uilabel(panel);
        Labels{i}.HorizontalAlignment = 'center';
        Labels{i}.Position = [10 200 - 28 * (i - 1) 126 32];
        Labels{i}.Text = tags{i};
        Labels{i}.WordWrap = 'on';
        Labels{i}.Tag = 'Parameter';

        % Type du champ
        field_type = units{i};

        % Création du champ selon le type
        switch lower(field_type)
            case {'m', 'word'}  % champ numérique ou texte
                EditFields{i} = uieditfield(panel);
                EditFields{i}.Position = [150 206 - 28 * (i - 1) 60 18];
                EditFields{i}.Tag = tags{i};

                % Label de l'unité
                UnitsLbl{i} = uilabel(panel);
                UnitsLbl{i}.Position = [215 200 - 28 * (i - 1) 50 32];
                UnitsLbl{i}.Text = field_type;
                UnitsLbl{i}.Tag = 'Unit';

            case 'dropdown'  % liste déroulante
                EditFields{i} = uidropdown(panel);
                EditFields{i}.Items = dropdown_options{i};
                EditFields{i}.Position = [150 206 - 28 * (i - 1) 120 22];
                EditFields{i}.Tag = tags{i};

                % Pas besoin d'unité ici
                UnitsLbl{i} = [];

            otherwise
                % Sécurité : fallback vers un champ texte standard
                EditFields{i} = uieditfield(panel);
                EditFields{i}.Position = [150 206 - 28 * (i - 1) 60 18];
                EditFields{i}.Tag = tags{i};

                UnitsLbl{i} = uilabel(panel);
                UnitsLbl{i}.Position = [215 200 - 28 * (i - 1) 50 32];
                UnitsLbl{i}.Text = field_type;
                UnitsLbl{i}.Tag = 'Unit';
        end
    end

    % Structure de sortie
    ParametersPanelStruct.Container = container;
    ParametersPanelStruct.Panel = panel;
    ParametersPanelStruct.ParametersLabels = Labels;
    ParametersPanelStruct.ParametersEditFields = EditFields;
    ParametersPanelStruct.ParametersUnits = UnitsLbl;
end