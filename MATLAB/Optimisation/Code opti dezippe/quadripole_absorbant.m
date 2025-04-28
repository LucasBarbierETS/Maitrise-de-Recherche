function [T_a]=quadripole_absorbant(freq,c,Z_0,sigma,L,modele)
% ------------------------------------------------------------------------
% ENTRÉES:
%   freq: fréquence
%   c: célérité du fluide saturant le squelette du matériau absorbant = Air
%   Z_0: impédance caractéristique du fluide saturant le squelette du matériau absorbant = Air
%   sigma: résistivité au passage à l'air du matériau absorbant
%   L: épaisseur de la couche du matériau absorbant
%   modele: modèle empirique du matériau absorbant: 1 pour Miki (Fibreux)et 2 pour Qunli (Mousses)
% SORTIES:
%   T_a: matrice de transfert de la couche de matériau absorbant
%-----------
% O. Doutres
% Dernière modification: session H2018
%-----------

%===== Calcul des paramètres de l'absorbant
% %!!!! Choix du modèle de matériau
%modele=1; %=>matériau Fibreux


if modele==1 %MATERIAUX FIBREUX
    %======== MODELE DE MIKI
    alpha=1+0.1093*(freq/sigma).^-0.618;
    beta=-0.1597*(freq/sigma).^-0.618;
    R=1+0.0699*(freq/sigma).^-0.632;
    X=-0.107*(freq/sigma).^-0.632;
elseif modele==2 %MATERIAUX MOUSSES
    %======== MODELE DE QUNLI
    alpha=1+0.188*(freq/sigma).^-0.554;
    beta=-0.163*(freq/sigma).^-0.592;
    R=1+0.209*(freq/sigma).^-0.548;
    X=-0.105*(freq/sigma).^-0.607;
end
%--
kc=(2*pi*freq/c).*(alpha+1i*beta);
Zc=Z_0*(R+1i*X);

% % ======= Domaine de validité
% E = freq/sigma;
% f_min = 0.01*sigma;
% f_max = 1.00*sigma;

%quadripôle absorbant
T_a=zeros(2,2,length(freq)); %création du tableau (2,2,n_freq)
T_a(1,1,:)=cos(kc*L);
T_a(1,2,:)=1i*Zc.*sin(kc*L);
T_a(2,1,:)=1i.*sin(kc*L)./Zc;
T_a(2,2,:)=cos(kc*L);

end
