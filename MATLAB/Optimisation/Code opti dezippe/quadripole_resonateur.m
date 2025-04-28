function [T_res]=quadripole_resonateur(freq,Zr)
% Entrées du programme
% freq: fréquence
% Zr: impédance acoustique à l'entrée du résonateur mis en parallèle.
% Zr peut être obtenu analytiquement (pour un résonateur quart d'onde
% simple) ou via un calcul TMM dans le cas d'un résonateur plus complexe.

%==== quadripôle 
T_res=zeros(2,2,length(freq)); %création du tableau (2,2,n_freq)
T_res(1,1,:)=1*ones(1,length(freq));
T_res(1,2,:)=zeros(1,length(freq));
T_res(2,1,:)=1./Zr;
T_res(2,2,:)=1*ones(1,length(freq));

end
