%% Introduction

% Pour réaliser la caractérisation inverse d'un multi-résonateur (4) quart-d'onde il faut : 
% - un modèle validé pour calculer le coefficient d'absorption d'une configuration donnée
% - un range pour le dataset d'entrainement
% - un data set d'entrainement composé de valeurs aléatoires comprises dans le range défini précedemment 
%   et de la réponse associée fournie par le modèle
% - une structure pour le réseau d'apprentissage (la même que dans l'article)

clc
close all

addpath 'C:\Users\Utilisateur\OneDrive - ETS\CRIAQ-REAR\Maitrise LB\Functions';
add_all_paths('C:\Users\Utilisateur\OneDrive - ETS\CRIAQ-REAR\Maitrise LB');

% Création de l'environnement

fmin = 1;
fmax = 3000;
points = 7;
[air, w] = create_environnement(23, 100800, 50, fmin, fmax, points);


%% Training Set

sz = 1000; % Training Set Size

cnb = 4; % Cavities number

% Parameters ranges

llb = 1e-1; % length lower bound
lub = 1; % length upper bound
slb = 1e-3; % side lower bound
sub = 1e-2; % side upper bound

configurations_set = zeros(sz, cnb*2);
responses_set = zeros(sz, points);

for i = 1:sz

    % On génère une configuration aléatoire en fonction des seuils définis
    
    sides = slb + (sub - slb) * rand(1, 4);
    lengths = llb + (lub - llb) * rand(1, 4);
   

    configurations_set(i,:) = [sides, lengths];

    responses_set(i,:) = classmultiQWL(classmultiQWL.read_free_square_config(configurations_set(i,:))) ...
                    .alpha(air, w);
end

data = horzcat(responses_set, configurations_set);
save('data.mat','data');