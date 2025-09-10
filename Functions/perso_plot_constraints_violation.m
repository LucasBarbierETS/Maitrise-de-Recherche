function state = perso_plot_constraints_violation(~, state, flag, NS, N)
    % Fonction pour afficher les violations des contraintes pendant l'optimisation

    % % Initialiser la variable stop
    % stop = false;
    % % nb_gp = size(optimValues.C, 2) / (NS*N);
    % 
    % % Variables persistantes pour garder la trace des violations et des itérations
    % persistent violation_count iteration_count violation_history
    % 
    % % Si la variable persistante n'est pas encore initialisée, initialisez-la
    % if isempty(violation_count)
    %     % Violation_count est un tableau pour compter les violations par groupe de contraintes
    %     violation_count = zeros(nb_gp, 1);  % 8 groupes de contraintes
    %     iteration_count = 0;  % Compteur du nombre d'itérations
    %     violation_history = [];  % Historique des violations
    % end
    % 
    % % Incrémenter le nombre d'itérations
    % iteration_count = iteration_count + 1;
    % 
    % % Récupérer les violations des contraintes dans optimValues
    % % Vous avez 160 contraintes non linéaires, organisées en 8 groupes avec 5 contraintes par groupe.
    % constraints = optimValues.C;  % Récupérer les contraintes non linéaires
    % 
    % % Diviser les contraintes en groupes (8 groupes avec 5 contraintes par groupe)
    % % Chaque groupe de contraintes contient 5 contraintes (par individu dans la population)
    % for groupIdx = 1:nb_gp
    %     % group_start_idx = (groupIdx - 1)*NS*N + 1;  % Premier index du groupe
    %     % group_end_idx = groupIdx*NS*N;  % Dernier index du groupe
    % 
    %     % Extraire les contraintes pour ce groupe
    %     group_constraints = constraints(:, group_start_idx:group_end_idx);
    % 
    %     % Compter les violations de contraintes dans ce groupe (c'est-à-dire, les valeurs > 0)
    %     violation_count(groupIdx) = violation_count(groupIdx) + sum(any(group_constraints > 0, 2));
    % end
    % 
    % % Calculer le nombre total de violations parmi toutes les configurations
    % total_violations = sum(violation_count);
    % 
    % % Enregistrer l'historique des violations à chaque itération
    % violation_history = [violation_history, total_violations];
    % 
    % % Afficher les violations périodiquement (par exemple toutes les 10 itérations)
    % if mod(iteration_count, 10) == 0
    %     % Affichage des violations par groupe
    %     disp('----------------------------------------------------');
    %     disp(['Itération ', num2str(iteration_count)]);
    %     disp(['Total de violations de contraintes : ', num2str(total_violations)]);
    %     for groupIdx = 1:8
    %         disp(['Groupe ', num2str(groupIdx), ' : ', num2str(violation_count(groupIdx))]);
    %     end
    %     disp('----------------------------------------------------');
    % 
    %     % Mise à jour du graphique des violations en temps réel
    %     figure(3);
    %     plot(1:iteration_count, violation_history, '-o');
    %     xlabel('Itérations');
    %     ylabel('Nombre total de violations');
    %     title('Évolution des violations des contraintes');
    %     drawnow;
    % end

    % Utiliser switch-case pour gérer les différents états
    switch flag
        case "init"
            % % Cette section est exécutée à l'initialisation de l'optimisation
            % % Initialisation des plots
            % figure;  % Crée une nouvelle figure
            % hold on; % Maintient l'affichage pour les prochaines itérations
            % title('Évolution des violations de contraintes');
            % xlabel('Itérations');
            % ylabel('Nombre total de violations');
            % grid on;
            % disp('Initialisation des graphiques...');
            
        case "iter"
            % Cette section est exécutée à chaque itération de l'optimisation
            % Affichage des violations de contraintes à chaque itération
            
            % % Ici, vous pouvez récupérer les violations de contraintes (par exemple)
            % % Récupérer les violations des contraintes dans optimValues
            % c2 = state.constrviolation(1);  % Violation de c2
            % c5 = state.constrviolation(2);  % Violation de c5
            % c6 = state.constrviolation(3);  % Violation de c6
            % c7 = state.constrviolation(4);  % Violation de c7
            % 
            % % Affichage des violations de contraintes dans la fenêtre de commande
            % disp(['Itération ', num2str(state.Generation)]);
            % disp(['C2 violations: ', num2str(c2)]);
            % disp(['C5 violations: ', num2str(c5)]);
            % disp(['C6 violations: ', num2str(c6)]);
            % disp(['C7 violations: ', num2str(c7)]);
            % 
            % % Exemple d'affichage dans un graphique
            % plot(state.Generation, c2, 'ro');  % Exemple de plot pour c2
            % plot(state.Generation, c5, 'bo');  % Exemple de plot pour c5
            % plot(state.Generation, c6, 'go');  % Exemple de plot pour c6
            % plot(state.Generation, c7, 'ko');  % Exemple de plot pour c7
            % 
            % % Mettre à jour l'affichage en temps réel
            % drawnow;

        case "done"
            % % Cette section est exécutée lorsque l'optimisation est terminée
            % % Finaliser le plot et nettoyer
            % disp('Optimisation terminée');
            % disp('Nettoyage des graphiques...');
            % hold off;  % Libérer le graphique
            % legend('C2 violations', 'C5 violations', 'C6 violations', 'C7 violations');
            
        % Vous pouvez ajouter un cas "interrupt" si nécessaire pour gérer des interruptions
        % case "interrupt"
        %    % Code pour gérer une interruption de l'optimisation si besoin
    end
end