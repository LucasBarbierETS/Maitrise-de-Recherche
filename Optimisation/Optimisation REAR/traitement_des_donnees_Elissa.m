p0 = 20e-6;

% Lis le fichier en ignorant les lignes qui commencent par '#'
M = readmatrix('C:\Users\lucas.barbier\Documents\Maitrise dossier secondaire\MATLAB\Optimisation\Optimisation REAR\stator_spectrum_data.txt', ...
               'CommentStyle', '#');

f1 = M(:,1); 
f2 = M(:,2);
fmean = M(:, 3);
mf2500 = fmean < 2500;
DSP_dB = M(:,5); % (dB re p0^2/Hz)

df = f2 - f1;

% Linéarisation de la densité spectrale de puissance (Pa^2/Hz)
DSP = (p0^2) * 10.^(DSP_dB/10);

% On retouve la pression RMS par bande (en Pa, Pas = 7.38 Hz)
p_RMS_band  = sqrt(DSP .* df); 

% Niveau RMS par bande
L_RMS_band = 20*log10(p_RMS_band / p0); % (dB re 2e-5 Pa)  

% Niveau RMS moyen par bande
L_RMS_band_mean = mean(L_RMS_band);

% DSP moyenne 
DSP_dB_mean = mean(DSP_dB);

% Niveau RMS du signal entier
OASPL5000 = 10*log10(sum(p_RMS_band.^2)/p0^2); % (dB re 2e-5 Pa)
% OASPL5000 = 10*log10(sum(DSP .* df)/p0^2); % (dB re 2e-5 Pa)
% OASPL5000 = 10*log10(sum(DSP)/p0^2); % (dB re 2e-5 Pa)
OASPL2500 = 10*log10(sum(p_RMS_band(mf2500).^2)/p0^2); % (dB re 2e-5 Pa)
% OASPL2500 = 10*log10(sum(DSP(mf2500) .* df(mf2500))/p0^2); % (dB re 2e-5 Pa)
% OASPL2500 = 10*log10(sum(DSP(mf2500))/p0^2); % (dB re 2e-5 Pa)

figure();
hold on
plot(fmean, DSP_dB, 'DisplayName', 'Densité spectrale de Puissance [dB re 4e-10 Pa^2/Hz]');
plot(fmean, L_RMS_band, 'DisplayName', 'Niveau de pression RMS par bande [dB re 2e-5 Pa], Pas = 7.38 Hz');
yline(OASPL5000, 'r--', 'DisplayName', 'Niveau RMS global 0-5000 Hz [dB re 2e-5 Pa]', ...
    'Label', ['OASPL5000 = ', num2str(round(OASPL5000, 2)), ' dB'], 'LabelHorizontalAlignment', 'left', 'LabelVerticalAlignment', 'top');
yline(OASPL2500, 'b--', 'DisplayName', 'Niveau RMS global 0-2500 Hz [dB re 2e-5 Pa]', ...
    'Label', ['OASPL2500 = ', num2str(round(OASPL2500, 2)), ' dB'], 'LabelHorizontalAlignment', 'right',  'LabelVerticalAlignment', 'bottom');
% yline(L_RMS_band_mean, 'k--', 'DisplayName', 'Niveau RMS moyen par bande [dB re 2e-5 Pa, Pas = 7.38 Hz]');
% yline(DSP_dB_mean, 'c--', 'DisplayName', 'DSP moyenne [dB re 4e-10 Pa^2/Hz]');
xlim([0 5000])
legend();