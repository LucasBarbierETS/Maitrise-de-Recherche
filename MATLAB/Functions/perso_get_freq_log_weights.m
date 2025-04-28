function weights = perso_get_freq_log_weights(freqs)
    logf = log10(freqs);
    dlogf = diff(logf);
    dlogf(end+1) = dlogf(end);
    weights = transpose(dlogf(:));
end