classdef classsectionchange < classsubelement
    
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

