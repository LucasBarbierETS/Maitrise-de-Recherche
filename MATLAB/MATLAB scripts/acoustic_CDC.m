% Définition d'un cahier des charges acoustiques 
% A partir des mesures acoustiques de Manuel

pref = 20e-6;
fs = 40960; % Hz
Ts = 1/fs;

%% Données  (domaine temporel)

data_p_t = load('C:\Users\lucas.barbier\Documents\Maitrise dossier secondaire\Mesures expérimentales\Mesures Manuel\Exp_Mic4_2024_3500_Time.txt');
t = data_p_t(:, 1);
p_t = data_p_t(:, 2);

figure()
hold on 
plot(t, p_t, 'DisplayName', 'Signal temporel');
xlabel('Temps (s)')
ylabel('Pression acoustique (Pa)')
xlim([0 30])
legend();

SPL_rms = 20*log10(abs(p_t_rms)/20e-6);

%% Données mesurées (domaine fréquentiel)

data_p_Hz = load('C:\Users\lucas.barbier\Documents\Maitrise dossier secondaire\Mesures expérimentales\Mesures Manuel\Spectrum_3500_Mic4_Hz.txt');
f = data_p_Hz(:, 1);
p_Hz = data_p_Hz(:, 2);

figure()
hold on
plot(f, p_Hz, 'DisplayName', 'Pression RMS par bande (Pa/Hz)');
xlim([0 2000]);
legend();

p_Hz_dB = 20*log10(p_Hz/p_ref);
p_Hz_rms = sqrt(sum(p_Hz.^2, 'omitmissing'));
p_Hz_rms_dB = 20*log10(p_Hz_rms/p_ref);

figure()
hold on
plot(f, p_Hz_dB, 'DisplayName', 'Niveau de pression RMS par bande (dB/Hz)');
yline(p_Hz_rms_dB, '--', 'DisplayName', 'Niveau de pression OASPL')
xlabel('Fréquence (Hz)')
ylabel('Niveau de pression (dB)')
xlim([0 2000]);
legend()

%% Filtrage

% Créer le filtre de pondération C avec la fréquence d'échantillonnage fs
C_weighting = weightingFilter('C-weighting', fs);

% Appliquer le filtre dBC sur le signal temporel (avec le filtre de pondération A)
p_t_C = C_weighting(p_t);  % Filtrage du signal
p_t_C_rms = sqrt(mean(p_t_C.^2));

% Appliquer la FFT sur le signal temporel pour obtenir le spectre fréquentiel
N = length(p_t);  % Taille du signal
f_axis = (0:N-1)*(fs/N);  % Axe des fréquences

% Effectuer la FFT du signal de pression
% window = hanning(N);
% p_t_windowed = p_t .* window';
P_f_norm = fft(p_t)/N;
Spp = 2/(fs*N)*abs(P_f_norm);
figure()
plot(f_axis, abs(P_f_norm));
plot(f_axis, Spp);
xlim([0 2000]);

P_rms_f = sqrt(mean(abs(P_f).^2));
L_rms = 20*log10(P_rms_f/pref);
P_f_dB = 20*log10(abs(P_f)/20e-6);
% plot(f_axis, P_f_dB);

P_f_A = fft(p_t_A);
P_rms_f_A = sqrt(1/N*sum(abs(P_f_A).^2));
L_rms_A = 20*log10(P_rms_f_A/pref);
P_f_dB_A = 20*log10(abs(P_f_A)/20e-6);
% plot(f_axis, P_f_dB_A);

% Visualisation du spectre
figure();
hold on
plot(f_axis, abs(SPL), 'DisplayName', 'Spectre non pondéré');
yline(SPL_rms)
plot(f_axis, abs(SPL_dBA), 'DisplayName', 'Spectre pondéré dBA');

legend()
xlabel('Fréquence (Hz)');
ylabel('Niveau sonore (dB)');
xlim([0 1500]);
 
% f = data_fft(:, 1);
% 
% % Pression complexe en pascal
% p_f = data_fft(:, 2);
% SPL = 20*log10(p_f/20e-6);
% 
% plot(f, SPL);
% xlim([0 3e3]);

%% Niveau sonore au niveau du carénage (Données d'article)

dB_data = load('C:\Users\lucas.barbier\Documents\Maitrise dossier secondaire\MATLAB\Optimisation\Optimisation REAR\niveau sonore.txt');
f = dB_data(:, 1);
dB = dB_data(:, 2);
mask =  f <= env(dB).w(end)/(2*pi);
[f_interp, dB_interp] = perso_interpole_et_lisse(f(mask), dB(mask), length(env(dB).w), 10);


P_rms_f = sqrt(mean(abs(P_f).^2));
L_rms = 20*log10(P_rms_f/pref);

figure();
hold on
plot(log10(f_interp), dB_interp);
