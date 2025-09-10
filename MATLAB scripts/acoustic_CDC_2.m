%% Paramètres
p_ref = 20e-6;
fs    = 40960;

%% === 1) Charger le temporel et PSD (Welch) ===
data_t = load('C:\Users\lucas.barbier\Documents\Maitrise dossier secondaire\Mesures expérimentales\Mesures Manuel\Exp_Mic4_2024_3500_Time.txt');   % [t, p(t)]
t  = data_t(:,1);  x = data_t(:,2);                    % Pa
nfft = 4096; win = hann(nfft,"periodic"); ovl = round(0.5*numel(win));
[Spp_time, f] = pwelch(x, win, ovl, nfft, fs, "onesided");    % Pa^2/Hz

OASPL_time = 20*log10(rms(x)/p_ref);
OASPL_psd_time = 10*log10(trapz(f,Spp_time)/p_ref^2);

%% === 2) Charger le spectre narrowband (Pa RMS par raie) et convertir en PSD ===
data_nb = load('C:\Users\lucas.barbier\Documents\Maitrise dossier secondaire\Mesures expérimentales\Mesures Manuel\Spectrum_3500_Mic4_Hz.txt');    % [f, prms, (im=0)]
f_nb  = data_nb(:,1);
prms  = data_nb(:,2);                                  % Pa (RMS/raie)

% Pas fréquentiel local (sécurisé si légèrement irrégulier)
df_nb = zeros(size(f_nb));
df_nb(2:end-1) = 0.5*(f_nb(3:end)-f_nb(1:end-2));
df_nb(1)       = f_nb(2)-f_nb(1);
df_nb(end)     = f_nb(end)-f_nb(end-1);

Spp_nb = (prms.^2) ./ df_nb;                           % Pa^2/Hz
OASPL_nb = 10*log10(trapz(f_nb,Spp_nb)/p_ref^2);

%% --- Pondération C : temps + fréquence (robuste) ---
Cw = weightingFilter('C-weighting', fs);

% (A) Méthode temps: filtrer x, puis PSD
xC = Cw(x);
nfft = 4096; win = hann(nfft,'periodic'); ovl = round(0.5*numel(win));
[Spp_time,   f]  = pwelch(x,  win, ovl, nfft, fs, 'onesided');      % Pa^2/Hz
[Spp_time_C, fC] = pwelch(xC, win, ovl, nfft, fs, 'onesided');      % Pa^2/Hz

% (B) Méthode fréquence: |Hc(f)|^2 appliqué à la PSD
% Réponse du filtre C sur une grille en Hz
[Hc_fine, Ffine] = freqz(Cw, nfft, fs);      % Hc_fine : complexe, Ffine : Hz
Gc_fine = abs(Hc_fine).^2;                    % module^2 >= 0

% Recalage de |Hc|^2 sur tes axes
Gc_on_f   = interp1(Ffine, Gc_fine, f,   'pchip', 'extrap');  % pour Spp_time
Gc_on_fnb = interp1(Ffine, Gc_fine, f_nb,'pchip', 'extrap');  % pour Spp_nb

% PSD fichier (Pa RMS/raie -> Pa^2/Hz) déjà calculée avant:
% Spp_nb = (prms.^2) ./ df_nb;

Spp_time_C_freq = Gc_on_f   .* Spp_time;      % Pa^2/Hz
Spp_nb_C_freq   = Gc_on_fnb .* Spp_nb;        % Pa^2/Hz

% OASPL (contrôle)
p_ref = 20e-6;
OASPL_time_C      = 20*log10(rms(xC)/p_ref);
OASPL_psd_time_C  = 10*log10(trapz(fC,  Spp_time_C)/p_ref^2);
OASPL_nb_C_freq   = 10*log10(trapz(f_nb,Spp_nb_C_freq)/p_ref^2);

%% === Tracés: PSD en dB re Pa^2/Hz ===
figure; hold on; box on;
semilogx(f,    10*log10(Spp_time/p_ref^2), 'LineWidth', 0.5, 'DisplayName','PSD à partir du signal temporel');
semilogx(f_nb, 10*log10(Spp_nb/p_ref^2), 'LineWidth', 0.5, 'DisplayName','PSD à partir de la mesure en Pa/raie');
semilogx(f,    10*log10(Spp_time_C/p_ref^2), 'LineWidth',1, 'DisplayName','PSD temporel après pondération dB-C');
% semilogx(f_nb, 10*log10(Spp_nb_C_freq/p_ref^2), 'LineWidth',1.1, 'DisplayName','PSD fichier pondéré C (freq)');
xlabel('f [Hz]'); ylabel('PSD [dB re Pa^2/Hz]'); title('Densité Spectrale de Puissance'); legend('Location','best');
yline(OASPL_time, '--', 'DisplayName', 'Niveau de pression OASPL');
xlim([0 2000]);
ylim([45 100]);

%% === Récap OASPL ===
fprintf('\n=== RÉCAP OASPL ===\n');
fprintf('Temporel (rms)            : %6.2f dB\n', OASPL_time);
fprintf('PSD depuis temporel       : %6.2f dB\n', OASPL_psd_time);
fprintf('PSD depuis fichier (lin.) : %6.2f dB\n', OASPL_nb);
fprintf('Temporel pondéré C        : %6.2f dB\n', OASPL_time_C);
fprintf('PSD temp. pondéré C       : %6.2f dB\n', OASPL_psd_time_C);
fprintf('PSD fich. pondéré C (frq) : %6.2f dB\n', OASPL_nb_C_freq);