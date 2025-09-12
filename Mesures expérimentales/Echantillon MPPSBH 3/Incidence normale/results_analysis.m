filename = '\Mesures expérimentales\Echantillon MPPSBH 3\Incidence normale\Export_Data';
exp_data = perso_load_mecanum_files([root_B  , filename]);

% Tracé des résultats expérimentaux
f = exp_data.Export.Sample1_Frequency_Hz_;
alpha100 = exp_data.Export.AbsorptionCoefficientOnCavity;
alpha130 = exp_data.Export.AbsorptionCoefficientOnCavity_1;
alpha139 = exp_data.Export.AbsorptionCoefficientOnCavity_2;
alpha145 = exp_data.Export.AbsorptionCoefficientOnCavity_3;
alpha149 = exp_data.Export.AbsorptionCoefficientOnCavity_4;

figure()
hold on
plot(f, alpha100, 'DisplayName', '100 dB');
plot(f, alpha130, 'DisplayName', '130 dB');
plot(f, alpha139, 'DisplayName', '139 dB');
plot(f, alpha145, 'DisplayName', '145 dB');
plot(f, alpha149, 'DisplayName', '149 dB');
perso_configure_alpha_figure(3000);

% Modèle analytique associé
N = 4; 
cd = 30e-3;
cw = 30e-3;
hr = {1e-5 * [45 45 45 45]};
wd = {[0.0025 0.003 0.00325 0.0025]};
pd = {[8 5 6 8]};
pw = {[4 3 3 2]};
pt = {1e-3 * [2 2 2 2]};
ct = {[0.013575 0.013575 0.013575 0.013575]};
MPPSBH = classMPPSBH_Rectangular_HL(classMPPSBH_Rectangular_HL.create_explicit_config(N, cd, cw, hr, wd, pd, pw, pt, ct));
MPPSBH.plot_alpha(env(100), 150, 400, '100 dB');
MPPSBH.plot_alpha(env(110), 150, 400, '110 dB');
MPPSBH.plot_alpha(env(120), 150, 400, '120 dB');
MPPSBH.plot_alpha(env(130), 150, 400, '130 dB');
MPPSBH.plot_alpha(env(140), 150, 400, '140 dB');

% Recherche des paramètres ajustés du modèle
perso_create_absorption_app(env(100), f, alpha100);

