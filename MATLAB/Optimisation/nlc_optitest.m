function [cineq,ceq]  = nlc_optitest(x,max_thickness)
%OBJ_OPTITEST Summary of this function goes here
%   Detailed explanation goes here


l_col1 = x(2);
l_cav1 = x(4);
l_col2 = x(6);
l_cav2 = x(8);

sample_thickness = max(l_col1+l_cav1,l_col2+l_cav2);
%===== contraintes 
ceq = [];%equality contraint

% inequality 
% sample_thickness<=max_thickness
cineq = sample_thickness-max_thickness;

end
