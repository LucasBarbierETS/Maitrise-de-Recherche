classdef classMultiAnnular_QWL < classelement

%% Réferences

% [1] A broadband and low-frequency sound absorber of sonic black holes with multi-layered micro-perforated panels
%     https://doi.org/10.1016/j.apacoust.2023.109817
% [2] Thin metamaterial using acoustic black hole profiles for broadband sound absorption
%     https://doi.org/10.1016/j.apacoust.2023.109744
% [3] Propagation of sound in porous media, Atalla, Allard
% [4] A microstructure material design for low frequency sound absorption
    
%% Methods

    methods (Access = public)

        function obj = classMultiAnnular_QWL(config)
        
            % Appel du constructeur de la classe parente
            obj@classelement(classelement.create_config({}, 'closed', []));
               
            if nargin > 0    
                % Tranfert des champs de la configuration d'appel vers la configuration de classe
                obj.Configuration = perso_transfer_fields(config, obj.Configuration);

                S = config.Surface;
                rmp = config.MainPoresRadius;
                hmp = config.MainPoresThickness;
                rde = config.DeadEndRadius;
                hde = config.DeadEndThickness;
                N = config.CellNumber;

                % Section du pore principal
                Smp = @(i) pi*rmp(i)^2;

                % Résistivité au passage de l'air du pore principal
                % sig_mp = @(env) 8*env.air.parameters.eta /(hde^2); % [4] Table 2
                
                % Demi-pore principal 
                half_main_pore = @(i) classQWL_Circle(classQWL_Circle.create_config(hmp/2, rmp(i)));
                % half_main_pore = @(i) classJCA_Rigid(classJCA_Rigid.create_config(Smp(i), hmp/2, 1, 1, sig_mp, rmp(i), rmp(i)));
                
                % Cellule annulaire (common pore + annular cavity)
                annular_cell = @(i) classannularcell_QWL(classannularcell.create_config(rmp(i), rmp(i+1), rde, hde));

                % Rayonnement
                s = @(i) Smp(i)/S; % Porosité apparente
                % hend = @(i) 0;
                hend = @(i) 0.48*sqrt(pi)*rmp(i)*(1-1.14*sqrt(s(i)));
                end_effect = @(i) classQWL_Circle(classQWL_Circle.create_config(hend(i), rmp(i)));
                % end_effect = @(i) classJCA_Rigid(classJCA_Rigid.create_config(Smp(i), hend(i), 1, 1, sig_mp, rmp(i), rmp(i)));

                obj.Configuration.ListOfObjects{end+1} = end_effect(1);
                % obj.Configuration.ListOfObjects{end+1} = half_main_pore(1);

                % Boucle sur les cavités et plaques
                for i = 1:N - 1

                    obj.Configuration.ListOfObjects{end+1} = half_main_pore(i);
                    % obj.Configuration.ListOfObjects{end+1} = end_effect(i);
                    obj.Configuration.ListOfObjects{end+1} = annular_cell(i); 
                    obj.Configuration.ListOfObjects{end+1} = half_main_pore(i+1);
                end
                
                obj.Configuration.ListOfObjects{end+1} = half_main_pore(end);
                obj.Configuration.ListOfObjects{end+1} = annular_cell(end);
                obj.Configuration.ListOfObjects{end+1} = end_effect(end);
            end 
        end
    end
end
