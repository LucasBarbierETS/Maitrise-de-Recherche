classdef AppGraphic < handle

    % Construit : AppComponent, AppComponentContainer
    
    properties
        Size
        Position
    end
    
    methods
        function obj = AppGraphic(size, position)
            obj.Size = size;
            obj.Position = position;
        end
    end
end

