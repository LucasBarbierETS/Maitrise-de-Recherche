function surconfig = add_thickness_correction(config)

%% References

% [1] Modeling of perforated plates and screens using rigid frame porous models, Atalla, Allard
% [2] Thin metamaterial using acoustic black hole profiles for broadband sound absorption, Bezançon
% [3] A broadband and low-frequency sound absorber of sonic black holes with multi-layered micro-perforated panels

%% Description 

% Cette fonction permet de réécrire par dessus les configurations construites avec les méthodes 'buildMLPSBH_cylindrical'.
% Elle rajoute l'attribut 'PlatesCorrectionLength' à la configuration 'config' suivant différentes méthodes  :

% La variable 'method' admet plusieurs entrées :

%    - 'bezancon' : la méthode s'applique aux configurations dont les cavités sont fines et ou les corrections de longueurs de rayleigh 
%                   associées au rayonnement sont plus grandes que les cavités elles-mêmes. Dans cette méthode on ajoute une correction 
%                   de longueur égale à la moitié de l'épaisseur de la cavité adjacente pour chaque côté de la plaque.
%                   Une exception est faite pour la première cavité dont le côté libre est associé à la longueur de corection standard

% La suite pour plus tard....

%% Code

cavr = config.CavitiesRadius;
ppar = config.PlatesPerforatedAreaRadius;
pp = config.PlatesPorosity;
ct = config.CavitiesThickness;
hr = config.PlatesHolesRadius;

% Initialisation du vecteur des configurations
ptc = zeros(size(ppar));

    switch config.ThicknessCorrectionMethod

    case 'None' % aucune correction de longueur n'est considérée   ordre de grandeur 0

    case 'Bezançon' % used in [2]    ordre de grandeur : e-2
                    % compatible avec 'buildMLPSBH_bezançon'

        % Le rayonnement de la première plaque est associé à la porosité de la plaque et non à la porosité de la partie perforée seule.
        % On calcule la correction de longueur associée au rayonnement et on ajoute la moitié de l'épaisseur de la cavité suivante pour 
        % tenir compte du rayonnement en direction de la cavité

        s = pp(1) * ppar(1)^2 / cavr^2;                             % Porosité réelle de la plaque 
        S = pp(1) * pi * ppar(1)^2;                                 % Surface d'ouverture réelle de la plaque
        correction_length = 0.48 * sqrt(S) * (1 - 1.14 * sqrt(s));  % Longueur de correction de rayonnement. [1] eq. (9.18) p. 191
        ptc(1) = correction_length + (ct(1) / 2);                   % On ajoute la moitié de l'épaisseur de la cavité suivante 
        
        for i = 2:length(ptc)
            ptc(i) = (ct(i-1) + ct(i)) / 2; % Ajouter la moitié de l'épaisseur des cavités précédente et suivante
        end

    case 'Chen' % used in [3]    ordre de grandeur e-1
                % compatible avec 'buildMLPSBH'

        ptc = 2 * 0.85 * hr ./ pp.^2;
        
    case 'Beranek' % Beranek-Insgard % [1] eq.10 p.5

        
        for i = 1:length(ptc)
            porosity = pp(i) * ppar(i)^2 / cavr^2;
            ptc(i) = 0.48 * sqrt(pi * hr(i)^2) * (1 - 1.47 * sqrt(porosity) + 0.47 * sqrt(porosity));   
        end

    case 'Allard'  % Allard-Insgard ([1] après eq.9 p.4)
       
        for i = 1:length(ptc)
            porosity = pp(i) * ppar(i)^2 / cavr^2;
            ptc(i) = 2 * 0.48 * sqrt(pi * hr(i)^2) * (1 - 1.14 * sqrt(porosity));  
        end
    end 

    config.PlatesThicknessCorrection = ptc;
    surconfig = config;

end

