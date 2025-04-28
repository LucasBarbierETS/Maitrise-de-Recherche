function [T_a]=quadripole_absorbant_partiel(freq,c,Z_0,L,Sc,Sp,sigma,modele)
% Entr�es du programme
% freq: fr�quence
% c: c�l�rit� du fluide saturant = Air
% Z_0: imp�dance du fluide saturant = Air
% L: longueur du conduit trait�
% Sc: Surface du conduit (sans mat�riau absorbant)
% Sp: Surface occup�e par le mat�riau absorbant
% sigma: r�sistivit� au passage � l'air du mat�riau absorbant
% modele: mod�le de l'absorbant: 1 pour Miki et 2 pour Qunli
%---------
% Dans ce programme on rentre directement les surfaces de la section du
% conduit sans mat�riau et de celle occup�e par le mat�riau


omega=2*pi*freq;

%===== Calcul des param�tres de l'absorbant
% %!!!! Choix du mod�le de mat�riau
%modele_p=1; %=>mat�riau Fibreux

if modele==1 %MATERIAU FIBREUX
    %======== MODELE DE MIKI
    alpha=1+0.1093*(freq/sigma).^-0.618;
    beta=-0.1597*(freq/sigma).^-0.618;
    R=1+0.0699*(freq/sigma).^-0.632;
    X=-0.107*(freq/sigma).^-0.632;
elseif modele==2 %MATERIAU MOUSSE
    %======== MODELE DE QUNLI
    alpha=1+0.188*(freq/sigma).^-0.554;
    beta=-0.163*(freq/sigma).^-0.592;
    R=1+0.209*(freq/sigma).^-0.548;
    X=-0.105*(freq/sigma).^-0.607;
end
%--
k_0=2*pi*freq/c; %nombre d'onde
kc=k_0.*(alpha+1i*beta);
Zc=Z_0*(R+1i*X);

%% Param�tre du conduit trait�

%Surface du conduit
%Sc=pi*(Dc/2)^2;
%Surface occup�e par le mat�riau absorbant
%Sp=Sc-pi*(Dc/2-hp)^2;


%=== Calcul des propri�t�s de la cavit� �quivalente: Loi de m�lange

% +++++++++++++ Mat�riau 0: air
%surface occup�e par l'air: 
S0=Sc-Sp;
% ratio par rapport � la surface totale
r0=S0/Sc;
%propri�t�s
rho0=Z_0.*k_0./omega;     %densit�
K0=Z_0.*omega./k_0;       %module d'incompressibilit�
    
% +++++++++++++ Mat�riau i: Absorbant
%surface occup�e par le mat�riau absorbant: 
Si=Sp;
% ratio par rapport � la surface totale
ri=Si/Sc;
%propri�t�s
ki=kc;                  %nombre d'onde
Zi=Zc;                  %imp�dance caract�ristique
rhoi=Zi.*ki./omega;     %densit�
Ki=Zi.*omega./ki;       %module d'incompressibilit�
    
% +++++++++++++ M�lange
rho_tild=(r0./rho0+ri./rhoi).^-1;
K_tild=(r0./K0+ri./Ki).^-1;
k_tild=omega.*sqrt(rho_tild./K_tild);
Z_tild=sqrt(rho_tild.*K_tild);


%%
%quadrip�le absorbant
T_a=zeros(2,2,length(freq)); %cr�ation du tableau (2,2,n_freq)
T_a(1,1,:)=cos(k_tild*L);
T_a(1,2,:)=1i*Z_tild.*sin(k_tild*L);
T_a(2,1,:)=1i.*sin(k_tild*L)./Z_tild;
T_a(2,2,:)=cos(k_tild*L);

end
