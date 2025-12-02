function nsga2_plot_rank_diversity(pop, f_pop, gen)
persistent hFig;

if isempty(hFig) || ~isvalid(hFig)
    hFig = figure('Name','NSGA-II Diversity');
end

figure(hFig); clf; hold on; grid on;

d = pdist(pop);
histogram(d, 30);

xlabel('distance entre solutions');
ylabel('count');
title(sprintf('Diversité population — Génération %d', gen));
drawnow;
end
