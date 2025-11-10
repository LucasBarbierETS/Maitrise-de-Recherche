classdef classMultiAnnular_Chen_MTMM_subdiv < classMultiAnnular_Chen_MTMM

    %% Références : 

    % [1] A broadband and low-frequency sound absorber of sonic black holes with multi-layered micro-perforated panels

    methods
        function obj = classMultiAnnular_Chen_MTMM_subdiv(config)
        
            % Appel du constructeur de la classe parente
            obj@classMultiAnnular_Chen_MTMM({});
               
            if nargin > 0 && ~isempty(config)     
                % Transfert des champs de la configuration d'appel vers la configuration de classe
                obj.Configuration = perso_transfer_fields(config, obj.Configuration);
    
                rmp = config.MainPoresRadius;
                tmp = config.MainPoresThickness;
                rde = config.DeadEndRadius;
                hde = config.DeadEndThickness;

                for i = 1:config.CellNumber

                    % Cavité cylindrique avec pertes
                    obj.Configuration.ListOfObjects{end+1} = classcavity_cylindrical(classcavity_cylindrical.create_config(tmp, rmp(i)));
        
                    % Cavité conique
                    hc = (rmp(i) + rmp(i+1))/2;
                    obj.Configuration.ListOfObjects{end+1} = classcavity_conical_subdiv(classcavity_conical_subdiv.create_config(hde/2, rmp(i), hc, 10));
        
                    % Cavité annnulaire toroidale
                    annular_cavity = classannularcavity_toroidal(classannularcavity_toroidal.create_config(rmp(i), rmp(i+1), rde, hde, 'Hankel_Chen'));
                    obj.Configuration.ListOfObjects{end+1} = classjunction_cylindrical(classjunction_cylindrical.create_config(annular_cavity, hc, hde));

                    % Cavité conique
                    obj.Configuration.ListOfObjects{end+1} = classcavity_conical_subdiv(classcavity_conical_subdiv.create_config(hde/2, hc, rmp(i+1), 10));
                end
            end
        end
    end
end
