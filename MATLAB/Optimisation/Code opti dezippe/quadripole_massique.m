function [T_m]=quadripole_massique(freq,rho,ep)
% ------------------------------------------------------------------------
% ENTRÉES:
%   freq: fréquence
%   rho: densité de la paroi massique [kg.m-3]
%   ep: épaisseur de la paroi massique [m]
% SORTIES:
%   T_m: matrice de transfert de la paroi massique

omega=2*pi*freq;

%===== données paroi massique
mass_surf=rho*ep;

%==== quadripôle 
T_m=zeros(2,2,length(freq)); %création du tableau (2,2,n_freq)
T_m(1,1,:)=1*ones(1,length(freq));
T_m(1,2,:)=1i*mass_surf*omega;
T_m(2,1,:)=zeros(1,length(freq));
T_m(2,2,:)=1*ones(1,length(freq));

end
