function objectif = obj_optitest(x,air,w,sample_area)
%OBJ_OPTITEST Summary of this function goes here
%   Detailed explanation goes here
R = optitest(x,air,w,sample_area);

objectif = sum(abs(R).^2);
end

