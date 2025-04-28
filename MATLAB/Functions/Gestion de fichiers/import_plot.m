function data = import_plot(filename)
% Cette fonction permet d'importer les données des tracés de référence obtenu avec WebPlotDigitalizer

    data = readmatrix(filename, 'Delimiter',';','DecimalSeparator',',');
end

