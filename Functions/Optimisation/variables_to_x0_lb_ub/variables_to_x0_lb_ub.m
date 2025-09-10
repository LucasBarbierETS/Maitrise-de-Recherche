function [x0, lb, ub] = variables_to_x0_lb_ub(variables_struct)

fdn = fieldnames(variables_struct);
n = size(variables_struct.(fdn{1}), 1);
m = length(fieldnames(variables_struct));
x0 = zeros(n, m);
lb = zeros(n, m);
ub = zeros(n, m);

for i = 1:numel(fdn)
        currentfield = fdn{i};
    x0(:, i) = variables_struct.(currentfield)(:, 1);
    lb(:, i) = variables_struct.(currentfield)(:, 2);
    ub(:, i) = variables_struct.(currentfield)(:, 3); 
end

end
