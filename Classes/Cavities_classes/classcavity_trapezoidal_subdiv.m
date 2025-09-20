classdef classcavity_trapezoidal_subdiv < classelement

%% Références

% [1]
% Titre : Modification of the transfer matrix method for the sonic black hole and broadening effective absorption band
% DOI : 10.1016/j.ymssp.2024.111660
% URL : https://linkinghub.elsevier.com/retrieve/pii/S0888327024005582
    
    methods 

        function obj = classcavity_trapezoidal_subdiv(config) 
            
            % Appel du constructeur de la classe parente
            obj@classelement(classelement.create_config({}, 'closed', []));
               
            if nargin > 0  && ~isempty(config) && length(fields(config)) > 3
                % Transfert des champs de la configuration d'appel vers la configuration de classe
                obj.Configuration = perso_transfer_fields(config, obj.Configuration);

                ct = config.Thickness;
                wi = config.WidthIn;
                di = config.DepthIn;
                wo = config.WidthOut;
                do = config.DepthOut;
                N = config.SubdivNumber;
                w = linspace(wi, wo, N);
                d = linspace(di, do, N);

                for i = 1:N
                    obj.Configuration.ListOfSubelements{end+1} = classlossycavity(classcavity_rectangular.create_config(ct/N, w(i), d(i)));
                end
            end
        end
    end

    methods (Static, Access = public)

        function config = create_config(cavity_thickness, width_in, depth_in, width_out, depth_out, varargin) 
            
            config.Thickness = cavity_thickness; 
            config.WidthIn = width_in;
            config.DepthIn = depth_in;
            config.WidthOut = width_out; 
            config.DepthOut = depth_out;

            % Si le nombre de subdivisions est donné
            if nargin > 5
                config.SubdivNumber = varargin{1};
            else
                config.SubdivNumber = 5;
            end
        end
    end
end