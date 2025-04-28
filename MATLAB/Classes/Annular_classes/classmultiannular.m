classdef classmultiannular

% References: 

%            [1] Dupont, Thomas, et al. "A Microstructure Material Design for
%            Low Frequency Sound Absorption." Applied Acoustics, vol. 136,
%            July 2018, pp. 86-93. 
%            DOI: 10.1016/j.apacoust.2018.02.016.

%            [2] Propagation of sound in porous media: modelling sound absorbing materials. 
%            Allard J.F., Atalla N. 
%            2nd ed. New York : John Wiley and Sons; 2009.

% Validation :

%            with figures of [1] 
%            with functions of Maël Lopez 

% Description

%            A 'classmultiannular' object is a metamaterial composed by a serie of main pores (losses) and parallel annular cavities (classannularcell)
%
%            In-section-change - - In-length-correction - - ( Main-pore - - Annular - - Main-pore - - Annular ... ) - - Main-pore - - Out-section-change
%
%            For more explanation see [1] fig. 2

    properties
        SampleRadius         % External radius of the sample (dsamp)
        MainPoreRadius        % Main pore radius (dmp)
        DeadEndRadius          % Dead-end radius (dde)
        DeadEndThickness         % Dead-end thickness (hde)
        MainPoreThickness         % Thickness of the main pore between two annular cavities (hmp)
        NumberOfCells              % Number of 'classannularcell' (N)

        HankelModel                  % 'True' if the model used for annular cavity comes from Hankels function 
                                     % 'False' if we only use the volume to modelise it
    end
    
    methods
        function obj = classmultiannular(sample_radius, main_pore_radius, dead_end_radius, dead_end_thickness, main_pore_thickness, number_of_cells, hankel_model)
            
            obj.SampleRadius = sample_radius;
            obj.MainPoreRadius = main_pore_radius;
            obj.DeadEndRadius = dead_end_radius;
            obj.DeadEndThickness = dead_end_thickness;
            obj.MainPoreThickness = main_pore_thickness;
            obj.NumberOfCells = number_of_cells;
            obj.HankelModel = hankel_model;
        end
        
        function TM = transfermatrix(obj, air, w)
           
            rmp = obj.MainPoreRadius; 
            rde = obj.DeadEndRadius;  
            tde = obj.DeadEndThickness;           
            tmp = obj.MainPoreThickness; 
            hm = obj.HankelModel;
            rsamp = obj.SampleRadius;

            % Annular cavity
            Ac_tm = classannularcell(rmp, rmp, rde, tde, hm).transfermatrix(air, w);

            % Main pore
            eta = air.parameters.eta;
            Mp_tm = classJCA('rigid', 1, 8 * eta / rmp^2, 1, rmp, rmp, tmp).transfermatrix(air, w);

            % Periodic serie of main pores and annular cavities
            TM = Mp_tm;

            for i = 1:obj.NumberOfCells % verif ici
                TM = matprod(TM, matprod(Ac_tm, Mp_tm));
            end

            % In-length-correction-cell (ilcc) at the entrance of the sample
            % [2] eq. (9.18) 
              
            hend = 0.48*sqrt(pi)*rmp*(1 - 1.14 * (rmp / rsamp));
            % [1] eq. (14)
            ilcc = classJCA('rigid', 1, 8 * eta / rmp^2, 1, rmp, rmp, hend);
            ilcc_tm = ilcc.transfermatrix(air, w);
            TM = matprod(ilcc_tm, TM);

            % In-section-change (isc) and out-section-change (osc)
            % [1] eq.(15)
            asample = pi*rsamp^2;           % Area of the sample
            amp = pi*rmp^2;                 % Area of the main-pore-cross-section

            isc = classsectionchange(asample, amp);
            isc_tm = isc.transfermatrix(air, w);
            osc = classsectionchange(amp,asample);
            osc_tm = osc.transfermatrix(air, w);
            TM = matprod(isc_tm, matprod(TM, osc_tm));

        end
        
        function Zs = surfaceimpedance(obj, air, w)
            
            TM = obj.transfermatrix(air, w);
            Zs = TM.T11 ./ TM.T21; % rigid backing

        end
    end
end
