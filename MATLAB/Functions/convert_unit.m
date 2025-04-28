function [convertedValue, unit] = convert_unit(value, fieldName)
    % Convertit la valeur en fonction du champ et définit l'unité appropriée
    % Utilisée dans : parse_structure()
    
    switch lower(fieldName)
        case 'porosity'
            convertedValue = value;
            unit = 'ad';
        case 'airflowresistivity'
            convertedValue = value * 1e-3; % Conversion en kNs/m^4
            unit = 'kNs/m^4';
        case 'tortuosity'
            convertedValue = value;
            unit = 'adimensional';
        case 'viscouscaracteristiclength'
            convertedValue = value * 1e6; % Conversion en micromètres (µm)
            unit = 'µm';
        case 'thermalcaracteristiclength'
            convertedValue = value * 1e6; % Conversion en micromètres (µm)
            unit = 'µm';
        case 'thickness'
            convertedValue = value * 1e3; % En millimètres (mm)
            unit = 'mm';
        case 'inputsection'
            convertedValue = value * 1e6; % En millimètres carré(mm^2)
            unit = 'mm^2';
        case 'outputsection'
            convertedValue = value * 1e6; % En millimètres carré(mm^2)
            unit = 'mm^2';
        otherwise
            convertedValue = value;
            unit = ''; % Unité vide si inconnue
    end
end