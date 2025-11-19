function [fmean, L_RMS_band, OASPL2500, OASPL1000] = compute_LRMS_from_elissa(file_path, varargin)
% compute_LRMS_from_DSP - Charge un spectre DSP (dB re Pa²/Hz),
%                         calcule le niveau RMS par bande (dB re 2e-5 Pa),
%                         et renvoie les valeurs.
%
% USAGE :
%   [fmean, L_RMS_band] = compute_LRMS_from_DSP(file_path)
%   [fmean, L_RMS_band] = compute_LRMS_from_DSP(file_path, 'fmax', 5000)

    % Référence de pression acoustique
    p0 = 20e-6;

    % Options par défaut
    opts = struct('fmax', Inf); % si tu veux filtrer les fréquences en sortie
    for i = 1:2:length(varargin)
        opts.(varargin{i}) = varargin{i+1};
    end

    % Lecture du fichier (ignore les lignes qui commencent par '#')
    M = readmatrix(file_path, 'CommentStyle', '#');
    fmean = M(:,3);              % fréquence centrale par bande
    DSP_dB = M(:,5);             % DSP (dB re 4e-10 Pa²/Hz)
    df = M(:,2) - M(:,1);  
    mf2500 = fmean < 2500 ; % largeur de bande
    mf1000 = fmean < 1000 ;

    % Conversion DSP (dB -> Pa²/Hz)
    DSP = (p0^2) * 10.^(DSP_dB / 10);

    % Pression RMS par bande (Pa)
    p_RMS_band = sqrt(DSP .* df);

    % Niveau RMS en dB SPL (par bande)
    L_RMS_band = 20 * log10(p_RMS_band / p0);

    OASPL2500 = 10*log10(sum(p_RMS_band(mf2500).^2)/p0^2);
    OASPL1000 = 10*log10(sum(p_RMS_band(mf1000).^2)/p0^2);
    % Si une limite de fréquence max est donnée, on filtre :
    if isfinite(opts.fmax)
        keep = fmean <= opts.fmax;
        fmean = fmean(keep);
        L_RMS_band = L_RMS_band(keep);
    end
end