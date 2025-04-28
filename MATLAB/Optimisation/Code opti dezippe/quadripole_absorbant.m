function [T_a]=quadripole_absorbant(freq,c,Z_0,sigma,L,modele)
% ------------------------------------------------------------------------
% ENTR�ES:
%   freq: fr�quence
%   c: c�l�rit� du fluide saturant le squelette du mat�riau absorbant = Air
%   Z_0: imp�dance caract�ristique du fluide saturant le squelette du mat�riau absorbant = Air
%   sigma: r�sistivit� au passage � l'air du mat�riau absorbant
%   L: �paisseur de la couche du mat�riau absorbant
%   modele: mod�le empirique du mat�riau absorbant: 1 pour Miki (Fibreux)et 2 pour Qunli (Mousses)
% SORTIES:
%   T_a: matrice de transfert de la couche de mat�riau absorbant
%-----------
% O. Doutres
% Derni�re modification: session H2018
%-----------

%===== Calcul des param�tres de l'absorbant
% %!!!! Choix du mod�le de mat�riau
%modele=1; %=>mat�riau Fibreux


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

% % ======= Domaine de validit�
% E = freq/sigma;
% f_min = 0.01*sigma;
% f_max = 1.00*sigma;

%quadrip�le absorbant
T_a=zeros(2,2,length(freq)); %cr�ation du tableau (2,2,n_freq)
T_a(1,1,:)=cos(kc*L);
T_a(1,2,:)=1i*Zc.*sin(kc*L);
T_a(2,1,:)=1i.*sin(kc*L)./Zc;
T_a(2,2,:)=cos(kc*L);

end
