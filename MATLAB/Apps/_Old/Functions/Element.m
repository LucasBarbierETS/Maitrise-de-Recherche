classdef Element
    %Subelements comes as cells
    %EndStatus = 'closed' or 'opened'(by default)
    
    properties
        SurfaceRatio
        ListOfSubelements
        ElementThickness
        EndStatus = 'opened' % 'opened'(default mode) or 'closed'
    end
    
    methods
        function obj = Element(surface_ratio,list_of_subelements,end_status)
            %SUBELEMENT Construct an instance of this class
            %   Detailed explanation goes here
            obj.ListOfSubelements = list_of_subelements;
            obj.EndStatus = end_status;
            obj.SurfaceRatio = surface_ratio;
            element_thickness = 0;
            for i = length(list_of_subelements)
                element_thickness = element_thickness + list_of_subelements{i}.Thickness;
            end
            obj.ElementThickness = element_thickness;
        end
        
        function TM = transferMatrix(obj,Air,w)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            tm = obj.ListOfSubelements{1}.transferMatrix(Air,w);
            if length(obj.ListOfSubelements)>1
                for i = 2:length(obj.ListOfSubelements)
                    tm = matrixProduct(tm,obj.ListOfSubelements{i}.transferMatrix(Air,w));
                end
            end
            TM = tm;
        end
    end
end



% classdef Element
%     %SUBELEMENT Summary of this class goes here
%     %   Detailed explanation goes here
%     
%     properties
%         SurfaceRatio
%         ListOfSubelements
%         EndStatus % 'opened' or 'closed'
%     end
%     
%     methods
%         function obj = Element(surface_ratio,list_of_subelements,end_status)
%             %SUBELEMENT Construct an instance of this class
%             %   Detailed explanation goes here
%             obj.ListOfSubelements = list_of_subelements;
%             obj.EndStatus = end_status;
%             obj.SurfaceRatio = surface_ratio;
%         end
%         
%         function TM = transferMatrix(obj,Air,w)
%             %METHOD1 Summary of this method goes here
%             %   Detailed explanation goes here
%             tm = obj.ListOfSubelements(1).transferMatrix(Air,w);
%             if length(obj.ListOfSubelements)>1
%                 for i = 2:length(obj.ListOfSubelements)
%                     tm = matrixProduct(tm,obj.ListOfSubelements(i).transferMatrix(Air,w));
%                 end
%             end
%             TM = tm;
%         end
%     end
% end
% 

