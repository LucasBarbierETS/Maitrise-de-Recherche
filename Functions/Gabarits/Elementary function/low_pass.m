function gabarit = low_pass(w, f, Q, alpha)

    gabarit = alpha*(1 - (1./(1+exp(-(w-f*2*pi)/Q^2))));

end


