function R = optitest(x,air,w,sample_area)
%OPTITEST Summary of this function goes here
%   Detailed explanation goes here

r_col1 = x(1);
l_col1 = x(2);
r_cav1 = x(3);
l_cav1 = x(4);
r_col2 = x(5);
l_col2 = x(6);
r_cav2 = x(7);
l_cav2 = x(8);
param = air.parameters;
phi1 = pi*r_col1^2/sample_area;
phi2 = pi*r_col2^2/sample_area;

HR1 = classHR2(r_col1,l_col1,r_cav1,l_cav1);
HR2 = classHR2(r_col2,l_col2,r_cav2,l_cav2);

elements = [Element(phi1,{HR1},'closed') Element(phi2,{HR2},'open')];
% elements = [Element(phi,{HR1},'open')];
matrice_tot = element_assembly(elements).transferMatrix(air,w);
Zs = matrice_tot.T11./matrice_tot.T21;

% Zs = (phi1./HR1.surfaceImpedance(air,w)+phi2./HR2.surfaceImpedance(air,w)).^(-1);
Z0 = param.rho*param.c0;
R = (Zs-Z0)./(Zs+Z0);
end

