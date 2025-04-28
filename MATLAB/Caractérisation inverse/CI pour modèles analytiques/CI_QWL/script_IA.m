addpath 'C:\Users\Utilisateur\OneDrive - ETS\CRIAQ-REAR\Maitrise LB\Classes'
addpath 'C:\Users\Utilisateur\OneDrive - ETS\CRIAQ-REAR\Maitrise LB\Classes\QWL_classes'


% Propriétés de l'air

To = 23;
Po = 100800;
Hr = 50;
air = classair(To, Po, Hr);
param = air.parameters;

% Support fréquenciel

f = 1:3000;
w = 2 * pi * f; % Définir les plages de valeurs pour les paramètres d'entrée
lengths = linspace(0.5, 2, 50); % exemple de plage pour la longueur
radii = linspace(0.05, 0.2, 50); % exemple de plage pour les dimensions

%% création du dataset

% Initialiser les matrices pour stocker les données
num_samples = numel(lengths) * numel(radii);
inputs = zeros(num_samples, numel(w)); % matrice pour stocker les paramètres d'entrée
outputs = zeros(num_samples, 2); % matrice pour stocker les résultats du modèle

index = 1;
for i = 1:numel(lengths)
    for j = 1:numel(radii)
        % Définir les paramètres d'entrée
        length = lengths(i);
        dimension = radii(j);
        
        % Créer l'objet QWL et calculer le résultat
        qwl = classQWL(length, 'circle', dimension);
        result = qwl.alpha(air, w); % supposer que calculate() est la méthode de calcul du modèle
        
        % Stocker les paramètres d'entrée et le résultat
        inputs(index, :) = result;
        outputs(index, :) = [length, dimension];
        
        index = index + 1;
    end
end

%% création du problème d'IA

% Séparer les données en ensembles d'entraînement et de test
cv = cvpartition(size(inputs, 1), 'HoldOut', 0.2);
idx = cv.test;

% Normaliser les données
inputs = normalize(inputs, 'range');

X_train = inputs(~idx, :);
Y_train = outputs(~idx);
X_test = inputs(idx, :);
Y_test = outputs(idx);

layers = [
    featureInputLayer(numel(w), 'Normalization', 'none')
    fullyConnectedLayer(64)
    reluLayer
    fullyConnectedLayer(64)
    reluLayer
    fullyConnectedLayer(2)]; % Output two parameters: length and dimension

net = dlnetwork(layers);

function [gradients, loss] = modelGradients(dlX, dlYTrue, net, air, w)
    % Faire les prédictions avec le réseau de neurones
    dlYPred = forward(net, dlX);
    
    % Convertir les prédictions et les vraies valeurs en tableaux de données
    YPred = extractdata(dlYPred)';
    YTrue = extractdata(dlYTrue)';
    
    % Calculer la perte avec la fonction coût personnalisée
    loss = customLoss(YPred, YTrue, air, w);
    
    % Calculer les gradients des pertes par rapport aux paramètres du réseau
    gradients = dlgradient(loss, net.Learnables);
end

function loss = customLoss(YPred, YTrue, air, w)
    N = size(YPred, 1);
    errors = zeros(N, 1);
    
    for i = 1:N
        % Extraire les paramètres prévus
        length_pred = YPred(i, 1);
        dimension_pred = YPred(i, 2);
        
        % Extraire les paramètres réels
        length_true = YTrue(i, 1);
        dimension_true = YTrue(i, 2);
        
        % Calculer le résultat du modèle analytique pour les paramètres prévus et réels
        result_pred = classQWL(length_pred, 'circle', dimension_pred).alpha(air, w);
        result_true = classQWL(length_true, 'circle', dimension_true).alpha(air, w);
        
        % Calculer l'erreur entre les résultats du modèle analytique
        errors(i) = mean((result_pred - result_true).^2);
    end
    
    % Calculer la perte moyenne
    loss = mean(errors, 'all');
end

numEpochs = 100;
batchSize = 32;
numBatches = ceil(size(X_train, 1) / batchSize);
learningRate = 0.01;

for epoch = 1:numEpochs
    % Shuffle les données d'entraînement
    idx = randperm(size(X_train, 1));
    X_train = X_train(idx, :);
    Y_train = Y_train(idx, :);
    
    for batch = 1:numBatches
        % Sélectionner le batch
        startIdx = (batch - 1) * batchSize + 1;
        endIdx = min(batch * batchSize, size(X_train, 1));
        X_batch = X_train(startIdx:endIdx, :);
        Y_batch = Y_train(startIdx:endIdx, :);
        
        % Convertir les données en dlarray
        dlX = dlarray(X_batch', 'CB');
        dlYTrue = dlarray(Y_batch', 'CB');
        
        % Calculer les gradients et la perte en utilisant dlfeval
        [gradients, loss] = dlfeval(@modelGradients, dlX, dlYTrue, net, air, w);
        
        % Mettre à jour les poids du modèle en utilisant adamupdate
        [net.Learnables, velocity] = adamupdate(net.Learnables, gradients, [], [], epoch, learningRate);
    end
end

% Évaluer le modèle
YPred = predict(net, X_test');
YPred = YPred';
rmse_length = sqrt(mean((YPred(:, 1) - Y_test(:, 1)).^2));
rmse_dimension = sqrt(mean((YPred(:, 2) - Y_test(:, 2)).^2));

disp(['RMSE Length: ', num2str(rmse_length)]);
disp(['RMSE Dimension: ', num2str(rmse_dimension)]);