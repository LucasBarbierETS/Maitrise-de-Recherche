function perso_create_absorption_app(env, f, alpha)
    % Initialisation des paramètres
    r_corr = 0;  % Valeur initiale de r_corr
    pt_corr = 0;  % Valeur initiale de pt_corr

    % Configuration expérimentale
    N = 4; 
    cd = 30e-3;
    cw = 30e-3;
    hr = @(r_corr) {1e-5 * ([45 45 45 45] + r_corr)};
    dw = {[0.0025 0.003 0.00325 0.0025]};
    pd = {[8 5 6 8]};
    pw = {[4 3 3 2]};
    pt = @(pt_corr) {1e-3 * ([2 2 2 2] + pt_corr)};
    ct = {0.013575};
    
    % Fonction MPPSBH pour créer la configuration
    MPPSBH = @(r_corr, pt_corr) classMPPSBH_Rectangular_HL( ...
        classMPPSBH_Rectangular_HL.create_explicit_config(N, cd, cw, hr(r_corr), dw, pd, pw, pt(pt_corr), ct));

    % Créer la figure de l'application
    fig = figure('Position', [100, 100, 800, 600], 'Name', 'Application d\''Absorption');
    
    % Ajouter un axe pour afficher le graphique
    ax = axes('Position', [0.2, 0.5, 0.75, 0.4]);

    % Créer le slider pour r_corr
    uicontrol('Style', 'text', 'String', 'r_corr (m)', 'Position', [20, 650, 100, 20]);
    r_corr_slider = uicontrol('Style', 'slider', 'Min', 0, 'Max', 20, 'Value', r_corr, ...
                            'Position', [120, 50, 120, 20]);
    r_corr_label = uicontrol('Style', 'text', 'String', ['r_corr: ', num2str(r_corr)], 'Position', [250, 50, 100, 20]);

    % Créer le slider pour pt_corr
    uicontrol('Style', 'text', 'String', 'pt_corr', 'Position', [20, 600, 100, 20]);
    pt_corr_slider = uicontrol('Style', 'slider', 'Min', 0, 'Max', 1, 'Value', pt_corr, ...
                               'Position', [120, 100, 120, 20]);
    pt_corr_label = uicontrol('Style', 'text', 'String', ['pt_corr: ', num2str(pt_corr)], 'Position', [250, 100, 100, 20]);

    % Fonction pour mettre à jour les valeurs et le graphique automatiquement
    function update_values(~, ~)
        % Récupérer les valeurs actuelles des sliders
        r_corr_value = r_corr_slider.Value;
        pt_corr_value = pt_corr_slider.Value;

        % Mettre à jour les labels avec les nouvelles valeurs
        r_corr_label.String = ['r_corr: ', num2str(r_corr_value)];
        pt_corr_label.String = ['pt_corr: ', num2str(pt_corr_value)];

        % Mettre à jour l'objet MPPSBH avec les nouvelles valeurs
        MPPSBH_instance = MPPSBH(r_corr_value, pt_corr_value);

        % Effacer l'ancien graphique
        cla(ax);

        plot(f, alpha, 'DisplayName', 'Mesure expérimentale')
        
        % Calculer l'absorption et tracer
        MPPSBH_instance.plot_alpha(env, 150, 400, 'Modèle analytique');
    end

    % Associer la fonction de mise à jour aux sliders
    r_corr_slider.Callback = @update_values;
    pt_corr_slider.Callback = @update_values;

    % Initialisation du graphique avec les valeurs par défaut
    update_values();
end
