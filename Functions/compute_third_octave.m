function L_out = compute_third_octave(f_in, PSD_in, f_out)

    p0 = 20e-6;

    % === Bandes ISO ===
    f_iso = [12.5 16 20 25 31.5 40 50 63 80 100 125 160 200 250 315 ...
             400 500 630 800 1000 1250 1600 2000 2500 3150 4000 5000];

    factor = 2^(1/6);
    f_low  = f_iso / factor;
    f_high = f_iso * factor;

    % pas frequency local
    df = [diff(f_in); diff(f_in(end-1:end))];

    % ============================
    % 1) CALCUL DES BANDES ISO
    % ============================
    L_band = zeros(size(f_iso));

    for i = 1:length(f_iso)
        mask = (f_in >= f_low(i)) & (f_in < f_high(i));

        if ~any(mask)
            % ====== FIX : bande vide → remplir avec bande voisine ======
            if i == 1
                L_band(i) = L_band(i+1);   % copie de la bande suivante
            else
                L_band(i) = L_band(i-1);   % copie de la bande précédente
            end
            continue
        end

        p_rms2 = sum(PSD_in(mask) .* df(mask));
        L_band(i) = 10*log10(p_rms2 / p0^2);
    end

    % ============================
    % 2) MAPPING SUR f_out
    % ============================
    L_out = zeros(size(f_out));

    for k = 1:length(f_out)
        f = f_out(k);
        idx = find(f >= f_low & f < [f_low(2:end) inf], 1);

        if isempty(idx)
            % choix de la bande ISO la plus proche
            [~, idx] = min(abs(f - f_iso));
        end

        L_out(k) = L_band(idx);
    end

end
