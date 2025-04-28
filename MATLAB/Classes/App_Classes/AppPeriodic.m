classdef AppPeriodic < AppElement
% Cette classe permet de répéter périodiquement son contenu.
% Son contenu est un élement
   
    properties

        Content % Objet de classe AppContainer
        PeriodNumber 
    end

    methods
        function obj = AppPeriodic(varargin)

            % varargin = {content, period_number, ...
            
            obj@AppElement();

            % Si le contenu est donné
            if nargin > 0
                
                obj.Content = varargin{1};
                obj.Content.Container = obj;

                % Si le nombre de période est donné
                if nargin > 1
                    obj.PeriodNumber = varargin{2};
                end
            end    
           
        end

    end
end