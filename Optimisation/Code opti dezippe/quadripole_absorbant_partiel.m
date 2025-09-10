function [T_a]=quadripole_absorbant_partiel(freq,c,Z_0,L,Sc,Sp,sigma,modele)
% Entrées du programme
% freq: fréquence
% c: célérité du fluide saturant = Air
% Z_0: impédance du fluide saturant = Air
% L: longueur du conduit traité
% Sc: Surface du conduit (sans matériau absorbant)
% Sp: Surface occupée par le matériau absorbant
% sigma: résistivité au passage à l'air du matériau absorbant
% modele: modèle de l'absorbant: 1 pour Miki et 2 pour Qunli
%---------
% Dans ce programme on rentre directement les surfaces de la section du
% conduit sans matériau et de celle occupée par le matériau


omega=2*pi*freq;

%===== Calcul des paramètres de l'absorbant
% %!!!! Choix du modèle de matériau
%modele_p=1; %=>matériau Fibreux

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

%% Paramètre du conduit traité

%Surface du conduit
%Sc=pi*(Dc/2)^2;
%Surface occupée par le matériau absorbant
%Sp=Sc-pi*(Dc/2-hp)^2;


%=== Calcul des propriétés de la cavité équivalente: Loi de mélange

% +++++++++++++ Matériau 0: air
%surface occupée par l'air: 
S0=Sc-Sp;
% ratio par rapport à la surface totale
r0=S0/Sc;
%propriétés
rho0=Z_0.*k_0./omega;     %densité
K0=Z_0.*omega./k_0;       %module d'incompressibilité
    
% +++++++++++++ Matériau i: Absorbant
%surface occupée par le matériau absorbant: 
Si=Sp;
% ratio par rapport à la surface totale
ri=Si/Sc;
%propriétés
ki=kc;                  %nombre d'onde
Zi=Zc;                  %impédance caractéristique
rhoi=Zi.*ki./omega;     %densité
Ki=Zi.*omega./ki;       %module d'incompressibilité
    
% +++++++++++++ Mélange
rho_tild=(r0./rho0+ri./rhoi).^-1;
K_tild=(r0./K0+ri./Ki).^-1;
k_tild=omega.*sqrt(rho_tild./K_tild);
Z_tild=sqrt(rho_tild.*K_tild);


%%
%quadripôle absorbant
T_a=zeros(2,2,length(freq)); %création du tableau (2,2,n_freq)
T_a(1,1,:)=cos(k_tild*L);
T_a(1,2,:)=1i*Z_tild.*sin(k_tild*L);
T_a(2,1,:)=1i.*sin(k_tild*L)./Z_tild;
T_a(2,2,:)=cos(k_tild*L);

end
