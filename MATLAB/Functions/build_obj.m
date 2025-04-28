function output = build_obj(x,cost_function,w,myassembly,air,tableParameters)
% x: vector to optimize,
% cost_function whose the parameters are  is (w,param,myassembly,air)
% w: angular frequency
% myassembly: the object pof calsse Assmbly to optimize
% air: object of class Air
% tic
% for i=1:100000
for i=1:length(tableParameters{:,1})
    param.(tableParameters{i,1})=x(i);
end
% end
% toc
% tic
% for i=1:1000
output = cost_function(w,param,myassembly,air);
% end
% toc
% the construction is 32 less slower than the compte of the cost
% function
end