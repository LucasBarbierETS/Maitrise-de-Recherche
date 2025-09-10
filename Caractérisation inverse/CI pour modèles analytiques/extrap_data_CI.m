function data = extrap_data_CI(filename, f)

    addpath 'C:\Users\Utilisateur\OneDrive - ETS\CRIAQ-REAR\Maitrise LB\Caractérisation inverse\Données\données brutes CSV\CSV_MLPSBH'
    
    data = load(filename);
    x = data(:,1);
    y = data(:,2); 
    data = interp1(x, y, f, 'linear', 'extrap');   

end
