classdef element_assembly
    % Reference : Verdière, Kévin, et al. « Transfer Matrix Method Applied 
    %             to the Parallel Assembly of Sound Absorbing Materials ». 
    %             The Journal of the Acoustical Society of America, vol. 
    %             134, no 6, décembre 2013, p. 4648‑58. DOI.org (Crossref), 
    %             https://doi.org/10.1121/1.4824839.

    
    properties
        ListOfElements
    end
    
    methods
        function obj = element_assembly(list_of_elements)
            %ASSEMBLAGE Construct an instance of this class
            obj.ListOfElements = list_of_elements;
        end
        
        function TM = transferMatrix(obj,Air,w)

            function Yi = admitance(transfer_matrix) % Admitance (cf. Reference)
                Yi.Y11 = 1./transfer_matrix.T12.*transfer_matrix.T22;
                Yi.Y12 = 1./transfer_matrix.T12.*(transfer_matrix.T21.*transfer_matrix.T12-transfer_matrix.T22.*transfer_matrix.T11);
                Yi.Y21 = 1./transfer_matrix.T12;
                Yi.Y22 = -1./transfer_matrix.T12.*(transfer_matrix.T11);
            end    
            
            opened_elements = [];
%             opened_elements = zeros(length(obj.ListOfElements));
            closed_elements = [];
%             closed_elements = zeros(length(obj.ListOfElements));
            ri = zeros([1,length(obj.ListOfElements)]);
            transfer_matrix = [];
            Yi = [];

            % Discriminates open from closed components + creates list of surface ratios and admitances (cf. Reference)
            % Several means of doing it : - list of open/closed elements

            %                             - list of open/closed elements
            %                             located a the same place that
            %                             they are in the undiscrimated
            %                             list of elements 

            %                             - list of open/closed elements
            %                             index in undiscriminated list of  <-- the method I chose
            %                             elements                          
            for i = 1:length(obj.ListOfElements)
                if strcmp(obj.ListOfElements(i).EndStatus,'open')
%                     opened_elements = [opened_elements,obj.ListOfElements(i)];
%                     opened_elements(i) = obj.ListOfElements(i);
                    opened_elements = [opened_elements,i]; % list of the indexes of open elements
                else
%                     closed_elements = [closed_elements,obj.ListOfElements(i)];
%                     closed_elements(i) = obj.ListOfElements(i);
                    closed_elements = [closed_elements,i]; % list of indexes of closed elements
                end
                ri(i) = obj.ListOfElements(i).SurfaceRatio;
                transfer_matrix = [transfer_matrix,obj.ListOfElements(i).transferMatrix(Air,w)];
                Yi = [Yi,admitance(transfer_matrix(i))];
            end

            % Calculate all the sums needed in the final matrix (because they are used several times) 
            % i all the elements
            % j open elements
            % k closed elements
            rjyj21 = 0;
            rjyj22 = 0;
            riyi11 = 0;
            bigsum = 0;
            rjyj12 = 0;
            for i = 1:length(obj.ListOfElements)
                riyi11 = riyi11 + ri(i)*Yi(i).Y11;
            end
            for j = 1:length(opened_elements)
                rjyj21 = rjyj21 + ri(opened_elements(j)).*Yi(opened_elements(j)).Y21;
                rjyj22 = rjyj22 + ri(opened_elements(j)).*Yi(opened_elements(j)).Y22;
                rjyj12 = rjyj12 + ri(opened_elements(j)).*Yi(opened_elements(j)).Y12;
            end
            for k = 1:length(closed_elements)
                bigsum = bigsum + ri(closed_elements(k)).*Yi(closed_elements(k)).Y12.*Yi(closed_elements(k)).Y21./Yi(closed_elements(k)).Y22;
            end

            %Final matrix
            TM.T11 = -1./rjyj21.*rjyj22;
            TM.T12 =  1./rjyj21;
            TM.T21 = -1./rjyj21.*(rjyj22.*(riyi11-bigsum)-rjyj12.*rjyj21);
            TM.T22 = -1./rjyj21.*(bigsum-riyi11);
        end
    end
end

