load('C:\Users\lucas.barbier\Documents\Maitrise ETS\Répertoire GitHub\Optimisation\Optimisation MPPSBH non contrainte\résultat d''optimisation.mat');

NV = 4;  % nombre de variables
N = 6;  % plaques
NS = 4;  % prototypes
NP = 500;

X = reshape(xopti, NP, NV, N, NS);  % 500 × 4 × 6 × 4
r = X(:, 1, :, :);
r_mean = mean(r, [3, 4]);
X = permute(X, [1 3 4 2]);          % 500 × 4 × 6 × 4 → 500 × 4 × (NS×N)
X = reshape(X, NP * N * NS, NV);    % 500 × 24 × 4

figure(); histogram(X(:, 1));


figure(); 

for i = 1:5
    subplot(1, 5, i); scatter(scores(:, i), r_mean);
end

