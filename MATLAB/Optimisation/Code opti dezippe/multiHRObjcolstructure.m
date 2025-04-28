function objectif = multiHRObjcolstructure(x, Surface_echantillon, rho, c,vis,seuil_alpha, fpicsvis, freq,eparoi)
% Entrées : x : les paramètres 
%   - 

% x = [liste_Rcol,liste_Lcol,liste_Rcav,liste_Lcav]
alpha = multiHRcolstructure(freq,x(1:end/4),x(2*(1:end/4)),x(3*(1:end/4)),x(4*(1:end/4)),Surface_echantillon,rho,c,vis,eparoi);
[~, fpics] = findpeaks(alpha,freq);

% [~,~,Zs] = multiHR(freq,x(1:end/4),x(2*(1:end/4)),x(3*(1:end/4)),x(4*(1:end/4)),Surface_echantillon,rho,c,vis);
% fpics=discretefzeros(freq,imag(Zs));


if length(fpics) >= length(fpicsvis) %&& all(alpha_pics>seuil_alpha)
    objectif = sum(abs(fpics(1:length(fpicsvis))-fpicsvis));
else
    objectif = round(rand(1),2)*10E4;%pour éviter qu'il converge
end

end
