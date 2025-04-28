classdef classannularcavity < classsubelement

% References 
%
%            [1] Dupont, Thomas, et al. "A Microstructure Material Design for
%            Low Frequency Sound Absorption." Applied Acoustics, vol. 136,
%            July 2018, pp. 86-93. 
%            DOI: 10.1016/j.apacoust.2018.02.016.
%            URL : https://linkinghub.elsevier.com/retrieve/pii/S0003682X1730991X
%
%            [2]Yunwei Chen, A broadband and low-frequency sound absorber of sonic
%            black holes with multi-layered micro-perforated panels
%            DOI: 10.1016/j.apacoust.2023.109817
%            URL : https://linkinghub.elsevier.com/retrieve/pii/S0003682X23006151

% Description
%
%            'classannularcavity' is a class object thats gives the surface impedance of a parallel
%            annular straight cavity based on radial propagation of sound. There are two models to describe its surface impedance : 
%            The first on is based on Hankel's function and the second one consider the admittance as a function of the cavity volume.
   

    properties

        % Configuration (Héritée)
        %
        %              .MainPoreRadius      % Radius of the main port at the point where the annular cavity is linked (rmp)
        %              .DeadEndRadius       % Radius of the annular cavity (rde)
        %              .DeadEndThickness    % Thickness of the annular cavity (hde)
        %
        %              .CavityModel         % 'Hankel' if the model used for annular cavity is based on Hankel's functions
        %                                   % 'Volume' if we only use the volume to modelise it

    end


    methods

        function obj = classannularcavity(config)

            obj@classsubelement(config);
        end
        
        function Zsde = surface_impedance(obj, env)

            config = obj.Configuration;
            w = env.w;
            air = env.air;
            rho = air.parameters.rho;
            eta = air.parameters.eta;
            c0 = air.parameters.c0;
         
            rmp = config.MainPoreRadius;
            rde  = config.DeadEndRadius;
            hde = config.DeadEndThickness;
            Ca = config.CurtainArea;

            switch obj.Configuration.CavityModel 

                case 'Hankel'

                    % récupération des paramètres JCA de la cavité annulaire
                    JCA_Rigid_config = classJCA_Rigid.create_config(1, 1, 12 * eta / hde^2, hde, hde, rde, 1); % surface d'entrée arbitraire
                    slitJCA = classJCA_Rigid(JCA_Rigid_config);
                    kde = slitJCA.equivalent_parameters(env).keq;
                    Zde = slitJCA.equivalent_parameters(env).Zeq; 

                    % Les paramètres équivalent ne tiennent pas compte de
                    % la section donc on est encore en pression - vitesse à
                    % ce moment
    
                    % Calcul des fonction de Hankel
                    % [1] eq.10
                    num = besselh(0, 1, kde *  rmp) - (besselh(1, 1, kde *  rde) ./ besselh(1, 2, kde *  rde)) .*  besselh(0, 2, kde * rmp);
                    den = besselh(1, 1, kde *  rmp) - (besselh(1, 1, kde *  rde) ./ besselh(1, 2, kde *  rde)) .*  besselh(1, 2, kde * rmp);
                    
                    % Si on est en pression-vitesse et qu'on divise ici par
                    % la surface de jonction, on fait ici le travaille de
                    % la jonction

                    % Référence : perso_ouvrir_lien_Zotero('zotero://open-pdf/library/items/EI6UVSF8?page=89&annotation=CFRH8HVT')

                    % Si Zsde est formulé selon la convention Pression - Vitesse
                    Zsde = 1j .* Zde .* (num ./ den);

                    % % Si Zsde est formulé selon la convention Pression - Débit
                    % Zsde = 1j .* Zde ./ Ca .* (num ./ den); 

                case 'Volume'
                    
                    % Calcul du volume de la cavité
                    Vcav = pi * hde * (rde^2 - rmp^2); % Différence des volumes de deux cylindres 
                    
                    k = w/c0;
                    Z0 = rho * c0; 

                    % Référence : perso_ouvrir_lien_Zotero('zotero://open-pdf/library/items/AH7QFLYS?page=4&annotation=34H3J6W6')
                    
                    % Si l'admittance est formulée selon la convention Pression - Vitesse
                    Ycav = 1j * k/Z0 / Ca * Vcav;

                    % % Si l'admittance est formulée selon la convention Pression - Débit
                    % Ycav = 1j * k/Z0 * Vcav;   
                
                    Zsde = 1 ./ Ycav;
            end
        end
    end

    methods (Static, Access = public)

        function config = create_config(main_pore_radius, dead_end_radius, dead_end_thickness, cavity_model)

            config = struct();
            config.MainPoreRadius = main_pore_radius;
            config.DeadEndRadius = dead_end_radius;
            config.DeadEndThickness = dead_end_thickness;
            config.CavityModel = cavity_model;
            config.CurtainArea = pi*main_pore_radius^2*dead_end_thickness;
        end

    end
end



