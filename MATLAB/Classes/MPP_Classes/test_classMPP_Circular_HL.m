
Pref = 20e-6;
db2rms = @(dB) Pref * 10^(dB/20);
f = @(dB, phi) sqrt(1/4 + (2*sqrt(2)*db2rms(dB)) / (air.parameters.rho * air.parameters.c0^2) ...
                    * (1 - phi^2) / phi^2);