 classdef classelementassembly < classelement

    % References :
    
    %         [1] Transfer Matrix Method Applied to the Parallel Assembly 
    %             of Sound Absorbing Materials
    %         [2] Comparison between parallel transfer matrix method and 
    %             admittance sum method

    % Par besoin de formulation d'une condition de fin, les éléments ouverts d'un objet de classe classelementassembly débouchent tous sur un même plan
    % dans la direction de propagation de l'onde
    
    methods % Constructeur
        function obj = classelementassembly(config)

            obj@classelement(config)
            obj.HandleAppBuilder = @(app, class_element_assembly) AppElementAssembly.class_to_app(app, class_element_assembly);
        end
    end

    methods % Matrices
        function [TM, options] = transfer_matrix(obj, env, options)

            opened_elements = obj.Configuration.OpenedElements;
            closed_elements = obj.Configuration.ClosedElements;

            % Somme des admittances

            Yu = zeros(1, length(env.w));

            if isempty(opened_elements)
                
                for k = 1:length(closed_elements)
                    
                    [TM, options] = closed_elements{k}.transfer_matrix(env, options);
                    Yu = Yu + TM.T21 ./ TM.T11;
                end
            
                TM = struct();
                TM.T11 = ones(1, length(env.w));
                TM.T21 = Yu;
                TM.T12 = zeros(1, length(env.w)); 
                TM.T22 = zeros(1, length(env.w));
                return
            end
        
            % P-TMM

            A = 0; B = 0; C = 0; D = 0;
       
            % Éléments ouverts
            for j = 1:length(opened_elements)
                
                YM = opened_elements{j}.admittance_matrix(env, options);
                A = A + YM.Y22;
                B = B + YM.Y21;
                C = C + YM.Y12;
                D = D + YM.Y11;
            end
        
            % Éléments fermés
            for k = 1:length(closed_elements)
                
                YM = closed_elements(k).admittance_matrix(env, options);
                D = D + YM.Y11 - YM.Y12 .* YM.Y21 ./ YM.Y22;
            end
        
            % Matrice finale (équation [2] eq. 3)
            TM = struct();
            TM.T11 = -A ./ B;
            TM.T12 =  1 ./ B;
            TM.T21 = C - A .* D ./ B;
            TM.T22 = D ./ B;
        end 
    end

    methods (Static, Access = public) % Configurations

        function config = create_config(list_of_elements)

            config = struct();
            config.ListOfElements = list_of_elements;
            config.EndStatus = 'closed';
            sum_surface = 0;

            for i = 1:length(config.ListOfElements)
                sum_surface = sum_surface + config.ListOfElements{i}.Configuration.Surface;
                if strcmp(config.ListOfElements{i}.Configuration, 'opened')
                    config.EndStatus = 'opened';
                end
            end

            config.OpenedElements = cell({});
            config.ClosedElements = cell({});

            for i = 1:length(config.ListOfElements)
        
                if strcmp(config.ListOfElements{i}.Configuration.EndStatus, 'opened')
                    config.OpenedElements{end+1} = config.ListOfElements{i};
                else
                    config.ClosedElements{end+1} = config.ListOfElements{i};
                end
            end
        
            config.Surface = sum_surface;
        end
    end
 end