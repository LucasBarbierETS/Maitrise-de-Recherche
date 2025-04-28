%% Programme principal pour optimisation
%-----------
% M. LOPEZ
%Dernière modification: session H2023
%-----------

clear all;
clc



%% ============================ Données Générales => matériaux et milieu d'entrée "in"

%===== Données air
rho=1.213; % masse volumique [kg.m-3]
c=342.2; % célérité du son dans l'air [m.s-1]
Z_0=rho*c; % impédance spécifique de l'air [Pa.s.m-1]

%===== vecteur fréquence
fc = c/(2*20e-2);

freq=1:1:fc;


%% ===================== Vecteur initial 
%

%===== Ce que j'ai ajouté pour le TP
vis = 1.81e-5;%viscosité dynamique de l'air (Pa.s)
eparoi = 5e-3;
% %Départ (indiqué par 0)
% %col
Rcol0 = [.5 .5]*1e-2;%Rayon col (m)
Lcol0 = [3 3]*1e-2;%Longueur col (m)
%cavité
Rcav0 = [4 4]*1e-2;%Rayon cav (m)
Lcav0 = [0.18 0.20];%Longueur cav (m)



%%
N = length(Rcol0);%nombre de résonateurs superposés

Surface_echantillon = (20e-2)^2;%Surface échantillon (m)

%% ===================== Definition des paramètres de l'optimisation 
%===== vecteur initial et les bornes
% frequences_vises = [120 180];
frequences_vises = [60 180];
% frequences_vises = [120 240];
% frequences_vises = 120;
seuil_alpha_accepetable = .8;
x0 = [Rcol0 Lcol0 Rcav0 Lcav0];
lb =[repelem(1e-3,N) repelem(10e-3,N) repelem(3e-3,N) repelem(1e-3,N)];%borne inf
ub =[repelem(5e-2,N) repelem(1e-1,N) repelem(1e-1,N) repelem(5e-1,N)];%borne sup

%===== contraintes
% Aineq x ≤ bineq
%  x(2)-x(1)<=0; %inequality
Aineq  = zeros(length(x0));
bineq = zeros(length(x0),1);
% % impose : Rcols <= Rcav <=> Rcols-Rcav <= 0
for i =1:N
    Aineq (i,i)=1;
    Aineq (i,2*i+1)=-1;

end


%===== Options
optionsmultistart = optimset('Algorithm','interior-point');

optionsgraph = optimset('Disp','iter','PlotFcns',{'optimplotfval','optimplotx'});%,'OutputFcn',@peaksPlotIterates);
nombre_points_depart = 2;
optionsmultistart= optimset(optionsmultistart,optionsgraph);

optionGsMS = [];%optionsgraph;

% optionsGa = optimoptions('ga','Disp','iter','PlotFcns','gaplotbestf');
optionsGa = optimoptions('ga','MaxGenerations',300,'MaxStallGenerations', 10);

%% ===================== Optimisation 

% fonction objectif
objectif = @(x)multiHRObjcolstructure(x, Surface_echantillon, rho, c,vis,seuil_alpha_accepetable, frequences_vises, freq,eparoi);
nlcontraintes = @(x)multiHRConcolstructure(x, Surface_echantillon, rho, c,vis,seuil_alpha_accepetable, frequences_vises, freq,eparoi);

% création du problème pour Global Search and Multi start
problem = createOptimProblem('fmincon','objective',objectif,'x0',x0,'Aineq',Aineq,'bineq',bineq,...
        'lb',lb,'ub',ub,'nonlcon',nlcontraintes,'options',optionGsMS);

%% =====================  Multi start
rng default % For reproducibility

% ms = MultiStart;

tic;
[xoptiMs, fvalMs,eflagMs,ouputMs,solutionsMs]=run(MultiStart,problem,nombre_points_depart);
% sum([solutionsMs.X(:4*(1:end/4)) solutionsMs.X(:,2*(1:end/4))])
% solutionsMs.X(:,1)
tempsMs = toc
% tableResults('MultiStart',:) = num2cell([xoptiMs,fvalMs,0,timeMs,0]);
 

%% genetic algorithm 

rng default % For reproducibility
% x = ga(fun,nvars,A,b,[],[],lb,ub,nonlcon,IntCon,options)

tic;
[xoptiGa,fvalGa,exitflagGa,outputGa,populationGa,scoresGa] = ga(objectif,...
    length(x0),Aineq,bineq,[],[],lb,ub,nlcontraintes,[],optionsGa);
timeGa = toc


%% =====================  => Résultats
%===== absorption

alpha0 = multiHRcolstructure(freq,x0(1:end/4),x0(2*(1:end/4)),x0(3*(1:end/4)),x0(4*(1:end/4)),Surface_echantillon,rho,c,vis,eparoi);
fval0 = objectif(x0);
alphaMs = multiHRcolstructure(freq,xoptiMs(1:end/4),xoptiMs(2*(1:end/4)),xoptiMs(3*(1:end/4)),xoptiMs(4*(1:end/4)),Surface_echantillon,rho,c,vis,eparoi);
alphaGa = multiHRcolstructure(freq,xoptiGa(1:end/4),xoptiGa(2*(1:end/4)),xoptiGa(3*(1:end/4)),xoptiGa(4*(1:end/4)),Surface_echantillon,rho,c,vis,eparoi);
[~, fpics0 ] = findpeaks(alpha0,freq);
[~, fpicsMs ] = findpeaks(alphaMs,freq);
[~, fpicsGa ] = findpeaks(alphaGa,freq);

if length(fpicsGa) < N
    fpicsGa(end+1) = NaN
    
end
%===== Table des resultats
% les lignes correspondent à chaque solution 
Rcols_mm = round([x0(1:end/4) ; xoptiMs(1:end/4) ; xoptiGa(1:end/4)]*1E3);
Lcols_mm = round([x0(2*(1:end/4)) ; xoptiMs(2*(1:end/4)) ; xoptiGa(2*(1:end/4))]*1E3);
Rcavs_mm = round([x0(3*(1:end/4)) ; xoptiMs(3*(1:end/4)) ; xoptiGa(3*(1:end/4))]*1E3);
Lcavs_mm = round([x0(4*(1:end/4)) ; xoptiMs(4*(1:end/4)) ; xoptiGa(4*(1:end/4))]*1E3);
Ltotale_mm = round([sum([x0(4*(1:end/4)) x0(2*(1:end/4))]); sum([xoptiMs(4*(1:end/4)) xoptiMs(2*(1:end/4))]); sum([xoptiGa(4*(1:end/4)) xoptiGa(2*(1:end/4))])]*1E3);
fonction_cout = [fval0 ;fvalMs; fvalGa];
frequences_pics = [ fpics0(1:N);fpicsMs(1:N);fpicsGa(1:N)];
temps = [ 0;tempsMs;timeGa];

tableResultats = table(Rcols_mm,Lcols_mm,Rcavs_mm,Lcavs_mm,Ltotale_mm,fonction_cout,frequences_pics,temps);
tableResultats.Properties.RowNames = ["init" "Ms" "GA"];
tableResultats

save("optiresults_"+replace(string(datetime ),':','_')+".mat", 'tableResultats');
%% =====================  => Affichage
figure;
hold on;
plot(freq,alpha0,"-",'linewidth',2,"displayname",num2str(2)+"xRH : vecteur initial");
plot(freq,alphaMs,"--",'linewidth',2,"displayname",num2str(2)+"xRH : opti Ms");
plot(freq,alphaGa,"--",'linewidth',2,"displayname",num2str(2)+"xRH : opti Ga");

% plot(fvis,ones(1,length(fvis)),'*',"displayname","Résonance")
grid on
% legend("location","northwest");
legend
xlabel('Fréquence [Hz]');ylabel("Coefficient d'absorption [1]");
grid on;
title("axe des X en linéaire")
xlim([0 fc]),ylim([0 1])
title("Absorption pour un résonateur d'Helmholtz")
xlim([0 1000])


