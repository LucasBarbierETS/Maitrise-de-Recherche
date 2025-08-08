function [c, ceq] = perso_Hutchinson_nonlconf(x, top_plate, phi_max)

    c = top_plate(x).Configuration.Porosity - phi_max;
    ceq = [];
end