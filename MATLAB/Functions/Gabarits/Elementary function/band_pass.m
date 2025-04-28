function gabarit = band_pass(w, f, Q, alpha)

     gabarit = 2*alpha*(1 - (1./(1 + exp(-((w - f*2*pi)/Q^2).^2))));


end


