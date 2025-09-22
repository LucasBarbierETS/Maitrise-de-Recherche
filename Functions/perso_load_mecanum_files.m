function data = perso_load_mecanum_files(folderPath)
% PERSO_LOAD_MECANUM_FILES
% Lecture de fichiers de mesures expérimentales (Absorption, Impédance, Réflexion, SPL)
% et structuration sous forme hiérarchique.
%
% Retour :
%   data.f
%   data.alpha.Sample1, Sample2, ...
%   data.Zs.SampleN (complexe)
%   data.R.SampleN (complexe)
%   data.SPL.SampleN

    if nargin == 0
        folderPath = uigetdir();
    end

    files = dir(fullfile(folderPath, '*.txt'));
    data = struct();

    for iFile = 1:length(files)
        if files(iFile).isdir, continue; end
        filePath = fullfile(files(iFile).folder, files(iFile).name);

        % --- Identifier la grandeur par le nom du fichier
        fname = lower(files(iFile).name);
        if contains(fname, 'absorption')
            grandName = 'alpha';
            mode = 'real';
        elseif contains(fname, 'impedance')
            grandName = 'Zs';
            mode = 'complex';
        elseif contains(fname, 'reflexion')
            grandName = 'R';
            mode = 'complex';
        elseif contains(fname, 'sound pressure')
            grandName = 'SPL';
            mode = 'real';
        else
            warning('Fichier non reconnu : %s', fname);
            continue;
        end

        % --- Corriger décimales
        fileContent = fileread(filePath);
        fileContent = strrep(fileContent, ',', '.');
        tempFile = fullfile(folderPath, 'temp_file.txt');
        fid = fopen(tempFile, 'w'); fwrite(fid, fileContent); fclose(fid);

        % --- Lire table
        opts = detectImportOptions(tempFile, ...
            'Delimiter', '\t', ...
            'DecimalSeparator', '.', ...
            'VariableNamingRule','preserve');
        opts.VariableNamesLine = 1;
        opts.DataLines = [2 Inf];
        T = readtable(tempFile, opts);
        delete(tempFile);

        % --- Gestion selon type
        nCols = width(T);
        if strcmp(mode, 'real')
            nSamples = nCols/2; % chaque sample = (freq, valeur)
        else
            nSamples = nCols/4; % chaque sample = (real_freq, real_val, imag_freq, imag_val)
        end

        for s = 1:nSamples
            sampleName = sprintf('Sample%d', s);

            if strcmp(mode, 'real')
                freqCol = (s-1)*2 + 1;
                valCol  = (s-1)*2 + 2;

                % sauver f si non déjà fait
                if ~isfield(data,'f')
                    data.f = T{:,freqCol};
                end

                data.(grandName).(sampleName) = T{:,valCol};

            else % complex
                realValCol = (s-1)*4 + 2;
                imagValCol = (s-1)*4 + 4;

                % sauver f si non déjà fait
                if ~isfield(data,'f')
                    data.f = T{:, (s-1)*4 + 1}; % Real_Frequency
                end

                Re = T{:,realValCol};
                Im = T{:,imagValCol};
                data.(grandName).(sampleName) = Re + 1i*Im;
            end
        end
    end
end
