function gabarit = notch(w, f, Q, alpha)

     gabarit = 1 - 2*alpha*(1 - (1./(1 + exp(-((w - f*2*pi)/Q^2).^2))));

end

