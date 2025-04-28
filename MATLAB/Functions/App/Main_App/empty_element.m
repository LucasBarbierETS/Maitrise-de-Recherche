function element = empty_element()

    element = struct('ClassElementHandleObject', @(list_of_subelements) classelement(list_of_subelements, "closed")); 
    element.ListOfSubelements =  {};
    element.InputSurface = 0;

end

