PathName = 'C:\Users\AQ99270\Documents\COMSOL\Projet_bell\TVA_ABH';%for save the mph and the export files
FileName = 'test_lucas2';
f = 1:100:4000;% frequency
list_hp = linspace(27,4.5,6)*1e-3;% perforation heights
list_wp = repelem(1,6)*1e-3;%perforation widths/thicknesses
list_wc  = repelem(9,6)*1e-3;% cavity widths/thicknesses
height_sample = 38.1e-3;
max_mesh_size = (8.3E-4)*2;%(m)
min_mesh_size = 1.66E-6;%(m)

tic
model = Model_TVA_ABH_rectangulaire(2*pi*f,list_hp,list_wp,list_wc,height_sample,PathName,FileName,[max_mesh_size,min_mesh_size]);
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


figure
plot(f,TL,"displayname","alpha")

%%

figure
hold on
plot(f,alpha,"displayname","alpha")
plot(f,alpha_verif1,"--","displayname","alpha from R export")
plot(f,alpha_verif2,"*","displayname","alpha from Zns export","markersize",6)
ylim([0 1])
legend("Location","best")
xlabel("frequency (Hz)")
ylabel("Sound absorption (-)")


figure
hold on
subplot(2,1,1)
plot(f,real(Zns),"displayname","")
ylim([0 4])
subplot(2,1,2)
plot(f,imag(Zns),"displayname","")
ylim([-10 10])

