function absorptionCoefGraph(app,w,myassembly)
    air = app.Air;
    Z0 = air.parameters.rho*air.parameters.c0;


    % Zs = myassembly.transfermatrix(air,w).T11./myassembly.transfermatrix(air,w).T21;
    Zns = myassembly.surfaceImpedance(air,w)/Z0;
    R = (Zns-1)./(Zns+1);

    alpha = 1-abs(R).^2;
    f=w/2/pi;
    subplot(1,2,1),hold on
    plot(f,alpha,"LineWidth",2)
    xlabel("Frequencies (Hz)"),ylabel("Sound absorption coefficient")
    ylim([0 1]),grid on
    pause(1)
    subplot(2,2,2),hold on
    plot(f,real(Zns),"LineWidth",2)
    xlabel("Frequencies (Hz)"),ylabel("Normalized resistance"),grid on
    subplot(2,2,4),hold on
    plot(f,imag(Zns),"LineWidth",2)
    xlabel("Frequencies (Hz)"),ylabel("Normalized adimtance"),grid on
    pause(1)
end