function nsga2_plot_pareto(pop, f_pop, gen)
persistent hFig;

if isempty(hFig) || ~isvalid(hFig)
    hFig = figure('Name','NSGA-II Pareto Front');
end

figure(hFig); clf; hold on; grid on;

if size(f_pop,2) == 2
    scatter(f_pop(:,1), f_pop(:,2), 40, 'filled');
    xlabel('f_1'); ylabel('f_2');
else
    scatter3(f_pop(:,1), f_pop(:,2), f_pop(:,3), 40, 'filled');
    xlabel('f_1'); ylabel('f_2'); zlabel('f_3');
end

title(sprintf('Pareto front — Génération %d', gen));
drawnow;
end
