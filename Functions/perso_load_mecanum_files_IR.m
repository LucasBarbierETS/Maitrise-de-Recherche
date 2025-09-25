function data = perso_load_mecanum_files_IR(folderPath)
% PERSO_LOAD_MECANUM_FILES
% Lecture de fichiers TUBIX exportés avec schéma :
%   <Projet>_<Intitulé mesure>_<Date>_<Heure>.txt
%
% Retour :
%   data.f
%   data.alpha.<Precision>.SampleN
%   data.Zs.<Precision>.SampleN
%   data.Zc.<Precision>.SampleN
%   data.R.<Precision>.SampleN
%   data.SPL.<Precision>.SampleN
%   data.STL.<Precision>.SampleN
%   data.k.<Precision>.SampleN
%   data.T11/T12/T21/T22.<Precision>.SampleN

    if nargin == 0
        folderPath = uigetdir();
    end

    files = dir(fullfile(folderPath, '*.txt'));
    data = struct();

    for iFile = 1:length(files)
        if files(iFile).isdir, continue; end
        fname = regexprep(files(iFile).name, '\.txt$', '');
        parts = split(fname, '_');

        % --- Extraire l’intitulé (après le projet, avant la date)
        if numel(parts) >= 3
            infoPart = strjoin(parts(2:end-2), ' ');
        else
            warning('Nom inattendu : %s', fname);
            continue;
        end
        infoPart = strtrim(infoPart);

        % --- Identifier grandeur et précision
        [grandName, precisionName, mode] = detectGrandeur(infoPart);

        if isempty(grandName)
            warning('Fichier non reconnu : %s', fname);
            continue;
        end

        % --- Lire fichier avec correction des décimales
        fileContent = fileread(fullfile(files(iFile).folder, files(iFile).name));
        fileContent = strrep(fileContent, ',', '.');
        tempFile = fullfile(folderPath, 'temp_file.txt');
        fid = fopen(tempFile, 'w'); fwrite(fid, fileContent); fclose(fid);

        opts = detectImportOptions(tempFile, ...
            'Delimiter', '\t', ...
            'DecimalSeparator', '.', ...
            'VariableNamingRule','preserve');
        opts.VariableNamesLine = 1;
        opts.DataLines = [2 Inf];
        T = readtable(tempFile, opts);
        delete(tempFile);

        nCols = width(T);
        if strcmp(grandName,'Zc') && nCols==2
            mode = 'real'; % Zc parfois réel
        end

        % --- Nombre de samples
        if strcmp(mode,'real')
            nSamples = nCols/2;
        else
            if mod(nCols,3)==0
                nSamples = nCols/3;
            else
                nSamples = nCols/4;
            end
        end

        % --- Extraire et stocker
        for s = 1:nSamples
            sampleName = sprintf('Sample%d', s);

            if strcmp(mode,'real')
                fcol = (s-1)*2 + 1;
                vcol = (s-1)*2 + 2;
                if ~isfield(data,'f')
                    data.f = T{:,fcol};
                end
                if isempty(precisionName)
                    data.(grandName).(sampleName) = T{:,vcol};
                else
                    data.(grandName).(precisionName).(sampleName) = T{:,vcol};
                end
            else
                if mod(nCols,3)==0
                    base=(s-1)*3;
                    f = T{:,base+1}; Re=T{:,base+2}; Im=T{:,base+3};
                else
                    base=(s-1)*4;
                    f = T{:,base+1}; Re=T{:,base+2}; Im=T{:,base+4};
                end
                if ~isfield(data,'f')
                    data.f = f;
                end
                if isempty(precisionName)
                    data.(grandName).(sampleName) = Re+1i*Im;
                else
                    data.(grandName).(precisionName).(sampleName) = Re+1i*Im;
                end
            end
        end
    end
end

% =============== Helper ===============
function [grandName, precisionName, mode] = detectGrandeur(infoPart)
    lowerStr = lower(infoPart);
    grandName = ''; precisionName=''; mode='real';

    if contains(lowerStr,'absorption')
        grandName='alpha'; mode='real';
        precisionName = regexprep(infoPart,'(?i)absorption coefficient','');

    elseif contains(lowerStr,'surface impedance') && ~contains(lowerStr,'characteristic')
        grandName='Zs'; mode='complex';
        precisionName = regexprep(infoPart,'(?i)normalized surface impedance','');

    elseif contains(lowerStr,'characteristic impedance')
        grandName='Zc'; mode='complex';
        precisionName = regexprep(infoPart,'(?i)normalized characteristic impedance','');

    elseif contains(lowerStr,'reflection') || contains(lowerStr,'reflexion')
        grandName='R'; mode='complex';
        precisionName = regexprep(infoPart,'(?i)reflection coefficient','');

    elseif contains(lowerStr,'sound pressure')
        grandName='SPL'; mode='real';
        precisionName = regexprep(infoPart,'(?i)sound pressure level','');

    elseif contains(lowerStr,'sound transmission loss')
        grandName='STL'; mode='real';
        precisionName = regexprep(infoPart,'(?i)normal sound transmission loss','');

    elseif contains(lowerStr,'wave number')
        grandName='k'; mode='real';
        precisionName = regexprep(infoPart,'(?i)characteristic wave number','');

    elseif contains(lowerStr,'transfer matrix')
        token = regexp(infoPart,'(T\d\d)','tokens','once');
        if ~isempty(token)
            grandName=upper(token{1}); mode='complex';
            precisionName = regexprep(infoPart,'(?i)transfer matrix coefficient','');
        end
    end

    % nettoyage précision
    precisionName = strtrim(precisionName);

    % supprimer unités entre crochets [dB], [m^-1], etc.
    precisionName = regexprep(precisionName, '\[.*?\]', '');

    % supprimer espaces
    precisionName = regexprep(precisionName,'\s+','');

    % rendre le nom valide pour struct
    precisionName = matlab.lang.makeValidName(precisionName);
end

