function [alpha,R,Zs_total] = multiHRcolstructure(freq,liste_Rcol,liste_Lcol,liste_Rcav,liste_Lcav,Surface_echantillon,rho,c,vis,eparoi)
%===== entrées :
%   - freq: fréquence (s-1) => à écrire en fonction de la fréquence
%   - liste_Rcol: Rayon col (m)
%   - liste_Lcol: Longueur col (m)
%   - liste_Rcav: Rayon cavité (m)
%   - liste_Lcav: Longueur cavité (m) 
%   - Surface échantillon (m)
%   - rho: masse volumique (kg.m-3)
%   - c: célérité du son dans l'air (m.s-1)
%   - vis: viscosité dynamique de l'air (Pa.s)

% correction de longueur seulement d'un côté
liste_Lcol_corr = liste_Lcol+0.82*liste_Rcol;

%surface des cols:
Scol = pi*liste_Rcol.^2;
Scav = pi*liste_Rcav.^2;
phi = 1;%porosité de surface (1)

%résistivité au passage de l'air
sigma_0_col = 8*vis./(phi*liste_Rcol.^2);
sigma_0_cav = 8*vis./(phi*liste_Rcav.^2);

Z_0=rho*c; % impédance spécifique de l'air [Pa.s.m-1]

modele = 2; 

%% *********************************************************************** Matrice de transfert totale du multicouche
%Creation d'une matrice identité 3D caron veut assembler plusieurs trucs à
%la suite
n=length(freq);
Ttotal=repmat(eye(2),[1 1 n]); % matrice 3D: taille 2x2 pour n fréquence

%échantillon vers col
for i = 1:length(liste_Lcol)
    [T_col]=quadripole_absorbant(freq,c,Z_0,sigma_0_col(i),liste_Lcol_corr(i),modele);
    %col structuré
    [T_qo]=quadripole_absorbant(freq,c,Z_0,0,liste_Lcol(i)-eparoi,1);
    Zr= squeeze(T_qo(1,1,:))./squeeze(T_qo(2,1,:));

    [T_res] = quadripole_resonateur(freq,Zr);
%     col vers cav1
    [T_CS2bis]=quadripole_changement_section(Scol(i),Scav(i)-Scol(i));
    %col vers cavité 2
    [T_CS2]=quadripole_changement_section(Scav(i)-Scol(i),Scav(i));
    [T_cav]=quadripole_absorbant(freq,c,Z_0,sigma_0_cav(i),liste_Lcav(i),modele);
    if i>1
        [T_CS3]=quadripole_changement_section(Scav(i-1),Scol(i));
    else
        T_CS3 =eye(2);
    end
    
    %Calcul du TMM total fréquence par fréquence
    %c'est ici qu'on mutliplie les différentes matrices de transfert des sous-éléments
%     for ff=1:n
%         Ttotal(:,:,ff)= Ttotal(:,:,ff)*T_CS3*T_col(:,:,ff)*T_CS2bis*T_res(:,:,ff)*T_CS2*T_cav(:,:,ff);
%     end

% plus rapide: divise le temps par 2 
    Ttotal = pagemtimes(Ttotal,pagemtimes(T_CS3,pagemtimes(T_col,pagemtimes(T_CS2bis,pagemtimes(T_res,pagemtimes(T_CS2,T_cav))))));
end
Zselem = squeeze(Ttotal(1,1,:)).'./squeeze(Ttotal(2,1,:)).';
Zs_total=assemblage_parallele([Zselem],[Scol(1)],Surface_echantillon);
%% == calcul des indicateurs avec les composantes de la matrice total
% calcul du coefficient de réflexion complexe R_comp et de l'absorption
%EQ diapositive 78
R = (Zs_total-Z_0)./(Zs_total+Z_0);
alpha=1-abs(R.^2);

end