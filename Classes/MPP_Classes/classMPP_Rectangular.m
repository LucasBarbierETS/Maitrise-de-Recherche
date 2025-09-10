classdef classMPP_Rectangular < classJCA

%% References:

%            [1] Atalla, Noureddine, et Franck Sgard. « Modeling of Perforated 
%                Plates and Screens Using Rigid Frame Porous Models ». Journal 
%                of Sound and Vibration, vol. 303, no 1‑2, juin 2007, p. 195‑208.
%                DOI.org (Crossref), https://doi.org/10.1016/j.jsv.2007.01.012.
% 
%            [2] Ingard, Uno. « On the Theory and Design of Acoustic Resonators ». 
%                The Journal of the Acoustical Society of America, vol. 25, no 6, 
%                juin 2005, p. 1037. world, asa.scitation.org, 
%                https://doi.org/10.1121/1.1907235.
% 
%            [3] Okuzono, Takeshi, et al. "Note on Microperforated Panel Model Using
%                Equivalent-Fluid-Based Absorption Elements." Acoustical Science and 
%                Technology, vol. 40, no. 3, May 2019, pp. 221–24. DOI.org (Crossref), 
%                https://doi.org/10.1250/ast.40.221.)
%
%            [4] Stinson & Champoux, Propagation of sound and the assignment of 
%                shape factors in model porous materials having simple pore geometries
%                http://asa.scitation.org/doi/10.1121/1.402530

%% Description

% 'end_correction' take two values : 
%               - NaN : la correction de longueur est déterminée en interne
%               - scalar : la corection de longueur est donnée et utilisée telle quelle
                 
%% properties

    properties

        Configuration

        % contient : 
        % Shape              % Shape of the pore : 'circle', 'slit', 'rectangle'
        % PoreDimensions     % Depends on the value of 'shape' : 
                             % - if shape = 'circle'    : varargin{1} = radius
                             % - if shape = 'slit'      : varargin{1} = thickness, varargin{2} = width
                             % - if shape = 'rectangle' : varargin{1} = length, varargin{2} = width

        % Porosity
        % Thickness
        % Correction Length

           
      % propriétés héritées de classMPP

      % Porosity
      % AirflowResistivity
      % Tortuosity
      % ViscousCharacteristicLength
      % ThermalCharacteristicLength
      % Thickness
      % Frame = "rigid";
      % MaterialDensity % different from air density2

    end

    methods 

        function obj = classMPP_Rectangular(config)

            pp = config.PlatePorosity;
            pt = config.PlateThickness;
            ppl = config.PlatePerforationsLength;
            ppw = config.PlatePerforationsWidth;

            k0 = 1.78; % [4] p.8 (square pore)

            % Rayon hydraulique
            rh = 2 * ppl * ppw / (ppl + ppw); % [4] p.8

            if isnan(correction_length)
                correction_length = 2 * 0.48 * sqrt(ppl * ppw);  % [2] p.6 eq. 4       a revoir
            end 

            resistivity = @(eta) 4 * k0 * eta / pp / rh^2; % [1] p.5 eq. 11, 12
            obj@classJCA('rigid', pp, resistivity, 1, rh, rh, pt + correction_length); % correction dans la longueur

            % obj@classJCA("rigid", porosity, resistivity, 1 + correction_length / d, rh, rh, d); % correction dans la tortuosité

        end
            
        
        function ep = equivalent_parameters(obj, air, w) % on définie des paramètres de poreux équivalent
            
            obj.AirflowResistivity = obj.AirflowResistivity(air.parameters.eta); 
            ep = equivalent_parameters@classJCA(obj, air, w); 

        end
    end
end