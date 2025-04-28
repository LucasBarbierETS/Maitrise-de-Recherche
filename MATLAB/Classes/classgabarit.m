classdef classgabarit
    
    properties 
        Parametres_gabarits % cell array
    end
    
    methods

        % Constructeur de la classe
        function obj = classgabarit(parametres_gabarits)
            obj.Parametres_gabarits = parametres_gabarits;
        end

        function obj = add_gabarit(obj, parameters_newline)
            obj.Parametres_gabarits = [obj.Parametres_gabarits; parameters_newline];
        end

        function obj = delete_gabarit(obj, line_number)
            obj.Parametres_gabarits(line_number, :) = [];
        end
                
        % Méthode pour créer un vecteur gabarit à partir d'un vecteur support
        function gabarit = build_gabarit(obj, w)
            % Initialiser le vecteur gabarit
            gabarits = zeros(size(obj.Parametres_gabarits, 1), length(w));
            
            % Parcourir les lignes du tableau Parametres et appliquer les fonctions correspondantes
            for i = 1:size(obj.Parametres_gabarits, 1)
                fonctionName = obj.Parametres_gabarits{i, 1};
                frequencePic = str2double(obj.Parametres_gabarits{i, 2});
                bandeFrequence = str2double(obj.Parametres_gabarits{i, 3});
                Q = str2double(obj.Parametres_gabarits{i, 4});
                alphaMax = str2double(obj.Parametres_gabarits{i, 5});
        
                % Appliquer la fonction correspondante avec les paramètres donnés
                gabarits(i, :) = feval(['classgabarit.',fonctionName], w, frequencePic, bandeFrequence, Q, alphaMax);
            end
            
            % Combiner les gabarits individuels pour obtenir le gabarit final
            gabarit = min(gabarits, [], 1);
        end
    end

    methods (Static)
        % Fonction Notch
        function gabarit = notch(w, f, ~, Q, alpha)
            gabarit = 1 - 2 * alpha * (1 - (1 ./ (1 + exp(-((w - f * 2 * pi) / Q^2).^2))));
        end
        
        % Fonction Low Pass
        function gabarit = low_pass(w, f, ~, Q, alpha)
            gabarit = alpha * (1 - (1 ./ (1 + exp(-(w - f * 2 * pi) / Q^2))));
        end
        
        % Fonction High Pass
        function gabarit = high_pass(w, f, ~, Q, alpha)
            gabarit = alpha * (1 ./ (1 + exp(-(w - f * 2 * pi) / Q^2))); 
        end
        
        % Fonction Band Pass
        function gabarit = band_pass(w, f, ~, Q, alpha)
            
            gabarit = 2 * alpha * (1 - (1./(1 + exp(-((w - f * 2 * pi) / Q^2).^2))));
        end
    end
end
