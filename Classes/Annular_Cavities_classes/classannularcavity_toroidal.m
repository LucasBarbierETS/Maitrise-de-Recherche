classdef classannularcavity_toroidal < classsubelement

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

        function obj = classannularcavity_toroidal(config)

            obj@classsubelement(config);
        end
        
        function Zsde = surface_impedance(obj, env)

            % Référence : 
            % perso_ouvrir_lien_Zotero('zotero://open-pdf/library/items/233HZ8GN?page=6&annotation=LHXS9YMV');

            config = obj.Configuration;
            w = env.w;
            air = env.air;
            rho = air.parameters.rho;
            eta = air.parameters.eta;
            c0 = air.parameters.c0 * (1+0.05*1j); % perso_ouvrir_lien_Zotero('zotero://open-pdf/library/items/233HZ8GN?page=7&annotation=QLW3FP87')
         
            mpri = config.MainPoreRadiusIn;
            mpro = config.MainPoreRadiusOut;
            rde  = config.DeadEndRadius;
            hde = config.DeadEndThickness;
            Ca = config.CurtainArea;

            switch config.CavityModel 

                case 'Hankel'

                    % récupération des paramètres JCA de la cavité annulaire
                    JCA_Rigid_config = classJCA_Rigid.create_config(Ca, rde - rmp, 1, 1, 12 * eta / hde^2, hde, hde); % surface d'entrée arbitraire
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
                    
                    % Calcul du volume de la cavité : On soustrait le
                    % volume du cône central à celui du cylindre externe
                    Vcav = pi * hde * (rde^2 - (mpri^2 + mpri*mpro + mpro^2)/3);
                    
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

        function config = create_config(main_pore_radius_in, main_pore_radius_out, dead_end_radius, dead_end_thickness, cavity_model)

            config = struct();
            [config.MainPoreRadiusIn, ri] = deal(main_pore_radius_in);
            [config.MainPoreRadiusOut, ro] = deal(main_pore_radius_out);
            config.DeadEndRadius = dead_end_radius;
            [config.DeadEndThickness, t] = deal(dead_end_thickness);
            config.CavityModel = cavity_model;

            config.CurtainArea = pi*(ri+ro)*sqrt((ri-ro)^2 + t^2); 
            % Référence : perso_ouvrir_lien_Zotero('zotero://open-pdf/library/items/233HZ8GN?page=6&annotation=3WQSLIYT');
        end

    end
end



