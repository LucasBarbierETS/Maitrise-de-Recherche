classdef classcavity_conical_subdiv < classelement

% Références
%
% [1]
% Titre : Modification of the transfer matrix method for the sonic black hole and broadening effective absorption band
% DOI : 10.1016/j.ymssp.2024.111660
% URL : https://linkinghub.elsevier.com/retrieve/pii/S0888327024005582
    
    methods 

        function obj = classcavity_conical_subdiv(config) 
            
            % Appel du constructeur de la classe parente
            obj@classelement(classelement.create_config({}, 'closed', []));
               
            if nargin > 0  && ~isempty(config) && length(fields(config)) > 3
                % Transfert des champs de la configuration d'appel vers la configuration de classe
                obj.Configuration = perso_transfer_fields(config, obj.Configuration);
            
                ct = config.Thickness;
                ri = config.RadiusIn;
                ro = config.RadiusOut;
                N = config.SubdivNumber;
                r = linspace(ri, ro, N);

                for i = 1:N
                    obj.Configuration.ListOfObjects{end+1} = classcavity_cylindrical(classcavity_cylindrical.create_config(ct/N, r(i)));
                end
            end
        end
    end

    methods (Static, Access = public)

        function config = create_config(thickness, radius_in, radius_out, varargin)

            config = struct();
            config.Thickness = thickness; 
            config.RadiusIn = radius_in;
            config.RadiusOut = radius_out;

            % Si le nombre de subdivisions est donné
            if nargin > 5
                config.SubdivNumber = varargin{1};
            else
                config.SubdivNumber = 5;
            end
        end
    end

end