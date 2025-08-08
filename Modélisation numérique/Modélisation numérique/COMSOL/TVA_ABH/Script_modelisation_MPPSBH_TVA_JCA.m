PathName = 'C:\Users\AQ99270\Documents\COMSOL\Projet_bell\TVA_ABH';%for save the mph and the export files
FileName = 'test_ABH_MPP_JCA';
f = 1:20:4000;% frequency
% f =100;% frequency
N = 6;
list_hp = linspace(27,4.5,6)*1e-3; % perforation heights
list_wp = repelem(1,6)*1e-3; % perforation widths/thicknesses
list_wc  = repelem(9,6)*1e-3; % cavity widths/thicknesses
height_sample = 38.1e-3;
max_mesh_size = (8.3E-4)*2; % (m)
min_mesh_size = 1.66E-6; % (m)
% % Test: avec toutes les plaques de perforations identiques
phi = repelem(5.14/100,N).';
rp=repelem(.5e-3,N).';
sigma = 8*1.81e-5./phi./rp.^2;
tor = 1+(0.48*sqrt(pi*rp.^2).*(1-1.14*phi)./list_wp.');
matrix_MPP_properties = [phi sigma tor rp rp];


tic
model = Model_TVA_ABH_rectangulaire_MPP(2*pi*f,matrix_MPP_properties,list_hp,list_wp,list_wc,height_sample,PathName,FileName,[max_mesh_size,min_mesh_size]);
disp("temps calcul "+num2str(toc)+" s")

%% load indicators
M=load(['indicators_',FileName,'.txt']);
alpha = M(:,2);
R = M(:,3)+1j*M(:,4);
Zns = M(:,5)+1j*M(:,6);
alpha_verif1 = 1-abs(R).^2;
alpha_verif2 = 1-abs((Zns-1)./(Zns+1)).^2;

Zns_phi = Zns*(list_hp(1)/height_sample)^2;
TL = 20*log10(abs(1+1+1./Zns_phi*(list_hp(1)/height_sample)^2)/2);


%%

figure
hold on
plot(f,alpha,"displayname","ABH MPP TVA-JCA","LineWidth",2)
ylim([0 1])
legend("Location","best")
xlabel("frequency (Hz)")
ylabel("Sound absorption (-)")

% TL
% figure
% plot(f,TL,"displayname","alpha","LineWidth",2)
% xlabel("frequency (Hz)")
% ylabel("STL (dB)")

% % ZnS
% figure
% hold on
% subplot(2,1,1)
% plot(f,real(Zns),"displayname","","LineWidth",2)
% ylim([0 4])
% ylabel("Re(Zns) (-)")

% subplot(2,1,2)
% plot(f,imag(Zns),"displayname","","LineWidth",2)
% ylim([-10 10])
% xlabel("frequency (Hz)")
% ylabel("Im(Zns) (-)")

