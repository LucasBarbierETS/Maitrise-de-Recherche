function Zs_total=assemblage_parallele(ZSelements,Selements,St)
% Cette fonction assemble différents éléments pour une surface.
% Entrées du programme:
%   -Zs_elements: MATRICE contenant les impédances du sufrace de chaque 
% élément. Une ligne par élément.
%   -Selements: LISTE contenant les surfaces de chaque élement. L'ordre 
% des élément doit être le même que celui de Zs_elements
%   - St: surface totale de l'échantillon.

%==== surface impédance de l'ensemble 
len_w = size(ZSelements,2);
Zs_total = NaN(1,len_w);
Selements = reshape(Selements,[length(Selements) 1]); %on est certain que Selements est en colonne
for i = 1:len_w%pour chaque fréquence
    Zs_total(i) = sum(1./(St./Selements.*ZSelements(:,i))).^(-1);
end

end