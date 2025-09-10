function absorptionCoefGraph(app,f1,f2,list_of_elements)
    air = app.Air;
    param = air.parameters;
    f = f1:f2;
    w = 2*pi*(f);
    phi_i = sum(app.ElementDatas.ListOfInputSurfaces)/app.EPCSurface;
    TM = element_assembly(list_of_elements).transferMatrix(air,w);
    Z0 = param.rho*param.c0;
    Zs = TM.T11./TM.T21./phi_i;
    alpha = 1-abs((Zs-Z0)./(Zs+Z0)).^2;

    figure
    plot(f,alpha)
    xlabel("Frequencies (Hz)"),ylabel("Sound absorption coefficient")
    ylim([0 1])
    pause(1)
end