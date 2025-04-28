function [T_CS]=quadripole_changement_section(Se,Ss)
% === Entr�es du programme
% Se: surface de la section en amont du changement de section
% Ss: surface de la section en aval du changement de section
% === Sorties du programme
% T_CS: matrice de transfert du changement de section

%==== quadrip�le 
T_CS=zeros(2,2); %cr�ation du tableau (2,2)
T_CS(1,1)=1;
T_CS(1,2)=0;
T_CS(2,1)=0;
T_CS(2,2)=Ss/Se;

end
