function [cineq,ceq] = multiHRConcolstructure(x, Surface_echantillon, rho, c,vis,seuil_alpha, fpicsvis, freq,eparoi)
% Entrées : x : les paramètres 
%   - 

% x = [liste_Rcol,liste_Lcol,liste_Rcav,liste_Lcav]
% alpha = multiHR(freq,x(1:end/4),x(2*(1:end/4)),x(3*(1:end/4)),x(4*(1:end/4)),Surface_echantillon,rho,c,vis);
alpha_pics = multiHRcolstructure(fpicsvis,x(1:end/4),x(2*(1:end/4)),x(3*(1:end/4)),x(4*(1:end/4)),Surface_echantillon,rho,c,vis,eparoi);
% [alpha_pics, fpics] = findpeaks(alpha,freq);

%===== contraintes 
ceq = [];%equality contraint

% inequality 
% seuil_alpha<=alpha_pics
if not(isempty(alpha_pics))  
    cineq = seuil_alpha-alpha_pics;
else 
    cineq = seuil_alpha;%return false
end

end
