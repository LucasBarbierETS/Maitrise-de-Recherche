function [T_res]=quadripole_resonateur(freq,Zr)
% Entr�es du programme
% freq: fr�quence
% Zr: imp�dance acoustique � l'entr�e du r�sonateur mis en parall�le.
% Zr peut �tre obtenu analytiquement (pour un r�sonateur quart d'onde
% simple) ou via un calcul TMM dans le cas d'un r�sonateur plus complexe.

%==== quadrip�le 
T_res=zeros(2,2,length(freq)); %cr�ation du tableau (2,2,n_freq)
T_res(1,1,:)=1*ones(1,length(freq));
T_res(1,2,:)=zeros(1,length(freq));
T_res(2,1,:)=1./Zr;
T_res(2,2,:)=1*ones(1,length(freq));

end
