classdef classsectionchange < classsubelement

%%%%%%%%%%%%%%%%%%%%%%%%%%%% PROPERTIES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                
% InputSurface  (m2)  
% OutputSurface (m2) 
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% METHODS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% obj.transfer_matrix(Air,w) : compute a structure of arrays implemented :
%                                   obj.transfer_matrix(Air,w).Tij 
%                              where (i,j)∈{1,2}². The structures represents 
%                              the transfer matrix of the MPP : (T11  T12)
%                                                               (T21  T22)
% 
% obj.surfaceImpedance(Air,w):               Surface impedance of the MPP
    
    properties
        
        Type = 'SectionChange'

        % Configuration (Héritée)
        % 
        %              .InputSection
        %              .OutputSection
    end
    
    methods
        function obj = classsectionchange(config)
            
            obj@classsubelement(config);
        end
        
        function TM = transfer_matrix(obj, ~)

            TM.T11 = 1;
            TM.T12 = 0;
            TM.T21 = 0;
            TM.T22 = obj.Configuration.OutputSection/obj.Configuration.InputSection;
        end
    end

    methods (Static, Access = public)

        function config = create_config(input_section, output_section)

            config = struct();
            config.InputSection = input_section;
            config.OutputSection = output_section;
        end
    end
end

