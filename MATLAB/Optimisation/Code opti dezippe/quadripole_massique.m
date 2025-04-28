function [T_m]=quadripole_massique(freq,rho,ep)
% ------------------------------------------------------------------------
% ENTR�ES:
%   freq: fr�quence
%   rho: densit� de la paroi massique [kg.m-3]
%   ep: �paisseur de la paroi massique [m]
% SORTIES:
%   T_m: matrice de transfert de la paroi massique

omega=2*pi*freq;

%===== donn�es paroi massique
mass_surf=rho*ep;

%==== quadrip�le 
T_m=zeros(2,2,length(freq)); %cr�ation du tableau (2,2,n_freq)
T_m(1,1,:)=1*ones(1,length(freq));
T_m(1,2,:)=1i*mass_surf*omega;
T_m(2,1,:)=zeros(1,length(freq));
T_m(2,2,:)=1*ones(1,length(freq));

end
