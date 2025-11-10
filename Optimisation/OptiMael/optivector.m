function [x,objects,element_start_index] = optivector(EPC)
% EPC is an element_assembly object
x = [];
objects = [];
element_start_index = [];
for i = 1:length(EPC.ListOfElements)
    element_start_index = [element_start_index,length(x)+1]; % index of the first parameter of an element
    for j = 1:length(EPC.ListOfElements(i).ListOfObjects) % add each var to x
        objects = [objects,EPC.ListOfElements(i).ListOfObjects{j}]; % make a list of all the subelement (helps to know which var goes where)          
        switch class(EPC.ListOfElements(i).ListOfObjects{j})
            case "classJCA"
                x = [x,EPC.ListOfElements(i).ListOfObjects{j}.Thickness];
            case "classMPP"
                x = [x,EPC.ListOfElements(i).ListOfObjects{j}.Thickness];
                x = [x,EPC.ListOfElements(i).ListOfObjects{j}.Porosity];
                x = [x,EPC.ListOfElements(i).ListOfObjects{j}.PoreDimension];
                if ~strcmp(EPC.ListOfElements(i).ListOfObjects{j}.Shape,'circular')
                    x = [x,EPC.ListOfElements(i).ListOfObjects{j}.Width];
                end
            case "classHR1"
                x = [x,EPC.ListOfElements(i).ListOfObjects{j}.NeckSurface];
                x = [x,EPC.ListOfElements(i).ListOfObjects{j}.NeckLength];
                x = [x,EPC.ListOfElements(i).ListOfObjects{j}.CavityVolume];
            case "classHR2"
                x = [x,EPC.ListOfElements(i).ListOfObjects{j}.NeckRadius];
                x = [x,EPC.ListOfElements(i).ListOfObjects{j}.NeckLength];
                x = [x,EPC.ListOfElements(i).ListOfObjects{j}.CavityRadius];
                x = [x,EPC.ListOfElements(i).ListOfObjects{j}.CavityLength];
            case "classgrid"
                x = [x,EPC.ListOfElements(i).ListOfObjects{j}.MeshLength];
                x = [x,EPC.ListOfElements(i).ListOfObjects{j}.MeshWidth];
                x = [x,EPC.ListOfElements(i).ListOfObjects{j}.Thickness];
                x = [x,EPC.ListOfElements(i).ListOfObjects{j}.Porosity];
            case "classscreen"
                x = [x,EPC.ListOfElements(i).ListOfObjects{j}.Thickness];
            case "classQWL"
                x = [x,EPC.ListOfElements(i).ListOfObjects{j}.MainRadius];
                x = [x,EPC.ListOfElements(i).ListOfObjects{j}.QWLRadius];
                x = [x,EPC.ListOfElements(i).ListOfObjects{j}.Thickness];
            case "classcavity"
                x = [x,EPC.ListOfElements(i).ListOfObjects{j}.Thickness];
            case "classsectionchange"
                x = [x,EPC.ListOfElements(i).ListOfObjects{j}.InputSurface];
                x = [x,EPC.ListOfElements(i).ListOfObjects{j}.OutputSurface];
        end
    end
end
end

