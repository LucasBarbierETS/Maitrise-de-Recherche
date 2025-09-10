classdef classrectangularcavity

%% References: 

%            [1] Dupont, Thomas, et al. "A Microstructure Material Design for
%            Low Frequency Sound Absorption." Applied Acoustics, vol. 136,
%            July 2018, pp. 86-93. 
%            DOI: 10.1016/j.apacoust.2018.02.016.

%            [2] Chen, A broadband and low-frequency sound absorber of sonic black 
%            holes with multi-layered micro-perforated panels

%% Description

%            "classrectangularcavity" est une classe objet qui modélise une cavité rectangulaire dans laquelle débouche un pore central
%            
   
%% Properties

    properties

        MainPoreLength    % Longueur du pore central (horizontale)
        MainPoreWidth     % Largeur du pore central (verticale)
        CavityLength      % Longueur de la cavité (horizontale)
        CavityWidth       % Longueure de la cavité (verticale)
        CavityThickness   % Epaisseur de la cavité
        CavityModel       % Modèle utilisé pour calculer l'admittance de la cavité
                          % - "volume" pour un modèle basé sur le volume

    end
    
%% Methods

    methods

        function obj = classrectangularcavity(main_pore_length, main_pore_width, cavity_length, cavity_width, cavity_thickness, cavity_model)

            obj.MainPoreLength = main_pore_length;
            obj.MainPoreWidth = main_pore_width;
            obj.CavityLength = cavity_length;
            obj.CavityWidth = cavity_width;
            obj.CavityThickness = cavity_thickness;
            obj.CavityModel = cavity_model;

        end

        function V = volume(obj)

            mpl = obj.MainPoreLength;
            mpw = obj.MainPoreWidth;
            cl = obj.CavityLength;
            cw = obj.CavityWidth;
            ct = obj.CavityThickness;

            % Volume d'un prisme à base rectangulaire recoupé d'un un pore central de même géométrie
            V = (cl * cw - mpl * mpw) * ct;

        end

        
        function Z = surfaceimpedance(obj, air, w)

            rho = air.parameters.rho;
            c0 = air.parameters.c0;         

            switch obj.CavityModel 

                case "Volume"

                    % L'admittance est donnée en fonction du volume de la cavité dans [2] eq.4

                    % Y = j * k / Z0 * V (k le nombre d'onde, Z0 l'impédance caractéristique de l'air, 
                    % V le volume de la cavité sans tenir compte du pore principal

                    % Comme k / Z0 = w / (rho * c0^2) 
                    % et que Z = 1 / Y

                    % on obtient la formule pour l'impédance :

                    Z = -1j * rho * c0^2 ./ (w * obj.volume());

            end
        end
    end
end

