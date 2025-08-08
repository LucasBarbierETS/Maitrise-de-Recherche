PathName = 'C:\Users\AQ99270\Desktop';%for save the mph and the export files
FileName = 'test_ABH_MLB';
f = 1:100:4000;% frequency
% f =100;% frequency
N = 6;
list_hp = linspace(27,4.5,6)*1e-3; % perforation heights
list_wp = repelem(1,6)*1e-3; % perforation widths/thicknesses
list_wc  = repelem(9,6)*1e-3; % cavity widths/thicknesses
height_sample = 38.1e-3;
max_mesh_size = (8.3E-4)*2; % (m)
min_mesh_size = 1.66E-6; % (m)


%fente: comme si sans MPP. Attenetion dans les paramètre JCA, la porosité
%esst ici de 100% pusique le changement de section est déjà pris en compte
%dans la géométrie de COMSOL. Aussi de façon similiare il n'y a pas de
%correction de longueur, puisque le rayonnement déjà modélisé par COMSOL. 
phi1 =repelem(1,N).';
lcv =list_hp.';
lct =list_hp.';
% sigma1 = 12*1.81e-5./(list_hp/height_sample).'./(lcv).^2;
sigma1 = 12*1.81e-5./phi1./(lcv).^2;
tor1 = ones(N,1);%1+(0.48*sqrt(pi*list_hp.^2).*(1-1.14*list_hp/height_sample)./list_wp).';
matrix_MPP_properties = [phi1 sigma1 tor1 lcv lct];

%% first JCA-TVA
tic
model = Model_TVA_ABH_rectangulaire_MPP(2*pi*f,matrix_MPP_properties,list_hp,list_wp,list_wc,height_sample,PathName,[FileName,'_JCATVA'],[max_mesh_size,min_mesh_size]);
disp("temps calcul "+num2str(toc)+" s")

M_JCA_TVA=load(['indicators_',FileName,'_JCATVA','.txt']);


%% 2nd full TVA

model = Model_TVA_ABH_rectangulaire(2*pi*f,list_hp,list_wp,list_wc,height_sample,PathName,[FileName,'_fullTVA'],[max_mesh_size,min_mesh_size]);
disp("temps calcul "+num2str(toc)+" s")

M_fullTVA=load(['indicators_',FileName,'_fullTVA','.txt']);

%% Comparaison Full TVA et TVA(cavités)-JCA(pore associéié à des fentes)


% TVA

figure(10)
hold on
plot(M_fullTVA(:,1),M_fullTVA(:,2),"displayname","TVA(matériau complet)","LineWidth",2)
ylim([0 1])
legend("Location","best")

figure(11)
subplot(2,1,1),hold on
plot(M_fullTVA(:,1),M_fullTVA(:,5),"displayname","TVA(matériau complet)","LineWidth",2)
ylim([0 4])
ylabel("Re(Zns) (-)")

subplot(2,1,2),hold on
plot(M_fullTVA(:,1),M_fullTVA(:,6),"displayname","TVA(matériau complet)","LineWidth",2)
ylim([-10 10])



% JCA
figure(10)
plot(M_JCA_TVA(:,1),M_JCA_TVA(:,2),"--","displayname","JCA(pore)-TVA(cavités)","LineWidth",2)
ylim([0 1])
legend("Location","best")
xlabel("frequency (Hz)")
ylabel("Sound absorption (-)")

figure(11)
subplot(2,1,1),hold on
plot(M_JCA_TVA(:,1),M_JCA_TVA(:,5),"--","displayname","JCA(pore)-TVA(cavités)","LineWidth",2)
ylim([0 4])
ylabel("Re(Zns) (-)")

subplot(2,1,2),hold on
plot(M_JCA_TVA(:,1),M_JCA_TVA(:,6),"--","displayname","JCA(pore)-TVA(cavités)","LineWidth",2)
ylim([-10 10])
legend("Location","best")


