function [x,objects,element_start_index] = optivector(EPC)
% EPC is an element_assembly object
x = [];
objects = [];
element_start_index = [];
for i = 1:length(EPC.ListOfElements)
    element_start_index = [element_start_index,length(x)+1]; % index of the first parameter of an element
    for j = 1:length(EPC.ListOfElements(i).ListOfSubelements) % add each var to x
        objects = [objects,EPC.ListOfElements(i).ListOfSubelements{j}]; % make a list of all the subelement (helps to know which var goes where)          
        switch class(EPC.ListOfElements(i).ListOfSubelements{j})
            case "classJCA"
                x = [x,EPC.ListOfElements(i).ListOfSubelements{j}.Thickness];
            case "classMPP"
                x = [x,EPC.ListOfElements(i).ListOfSubelements{j}.Thickness];
                x = [x,EPC.ListOfElements(i).ListOfSubelements{j}.Porosity];
                x = [x,EPC.ListOfElements(i).ListOfSubelements{j}.PoreDimension];
                if ~strcmp(EPC.ListOfElements(i).ListOfSubelements{j}.Shape,'circular')
                    x = [x,EPC.ListOfElements(i).ListOfSubelements{j}.Width];
                end
            case "classHR1"
                x = [x,EPC.ListOfElements(i).ListOfSubelements{j}.NeckSurface];
                x = [x,EPC.ListOfElements(i).ListOfSubelements{j}.NeckLength];
                x = [x,EPC.ListOfElements(i).ListOfSubelements{j}.CavityVolume];
            case "classHR2"
                x = [x,EPC.ListOfElements(i).ListOfSubelements{j}.NeckRadius];
                x = [x,EPC.ListOfElements(i).ListOfSubelements{j}.NeckLength];
                x = [x,EPC.ListOfElements(i).ListOfSubelements{j}.CavityRadius];
                x = [x,EPC.ListOfElements(i).ListOfSubelements{j}.CavityLength];
            case "classgrid"
                x = [x,EPC.ListOfElements(i).ListOfSubelements{j}.MeshLength];
                x = [x,EPC.ListOfElements(i).ListOfSubelements{j}.MeshWidth];
                x = [x,EPC.ListOfElements(i).ListOfSubelements{j}.Thickness];
                x = [x,EPC.ListOfElements(i).ListOfSubelements{j}.Porosity];
            case "classscreen"
                x = [x,EPC.ListOfElements(i).ListOfSubelements{j}.Thickness];
            case "classQWL"
                x = [x,EPC.ListOfElements(i).ListOfSubelements{j}.MainRadius];
                x = [x,EPC.ListOfElements(i).ListOfSubelements{j}.QWLRadius];
                x = [x,EPC.ListOfElements(i).ListOfSubelements{j}.Thickness];
            case "classcavity"
                x = [x,EPC.ListOfElements(i).ListOfSubelements{j}.Thickness];
            case "classsectionchange"
                x = [x,EPC.ListOfElements(i).ListOfSubelements{j}.InputSurface];
                x = [x,EPC.ListOfElements(i).ListOfSubelements{j}.OutputSurface];
        end
    end
end
end

