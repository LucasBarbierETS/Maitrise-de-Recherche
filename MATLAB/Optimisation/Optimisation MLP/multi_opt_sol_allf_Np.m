% Ce script itératif : 
% - Crée une population de points de départ pour l'algorithme génétique
% - Pour chaque point de départ, fait tourner l'algorythme génétique jusqu'à créer
%   une population qui converge en distance sur l'espace des paramètres
%   d'entrées ET sur les données de sorties (extremum local). L'algorythme
%   fournit alors un nouveau point de départ qui servira lors de la
%   prochain itération
% - calcule les distance obtenus entre les extremums locaux et croise entre
%   eux ceux qui sont le plus proche (mutation progressive)
