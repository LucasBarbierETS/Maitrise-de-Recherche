classdef Cell_MPPSBHr_HL < classelement
    
    % Cette classe constitue une cellule périodique comprenant : 
    %   - une plaque microperforée (classMPP_Circular)
    %   - une cellule comprenant le pore principale et une cavité bilatérale (CellBilateralCavity)
    
    methods
        function obj = Cell_MPPSBHr_HL(config)
            
            % Appel du constructeur de la classe parente
            obj@classelement(classelement.create_config({}, 'opened'));

            % On transfert les champs de la structure d'appel vers ceux de
            % a structure de classe
            obj.Configuration = perso_transfer_fields(config, obj.Configuration);

            % Paramètres de la plaque
            pp = config.Porosity;
            phr = config.PlateHolesRadius;
            pt = config.Thickness;
            
           % Paramètres de la cellule
            ct = config.CavityThickness;
            cd = config.CavityDepth;
            cw = config.CavityWidth;
            ciw = config.CellInnerWidth;
            cow = config.CellOuterWidth;
            cm = config.CavityMethod;
            pmw = (ciw + cow)/2; % pore mean width
            cid = config.CellInnerDepth;
            cod = config.CellOuterDepth;
            pmd = (cid + cod)/2; % pore mean depth

            % Plaque perforée (Modèle de Maa)
            obj.Configuration.ListOfSubelements{end+1} = classMPP_Circular_HL(classMPP_Circular.create_config(pp, phr, pt, ciw, cid));

            % Cavité cylindrique
            obj.Configuration.ListOfSubelements{end+1} = classcavity(classcavity.create_config(ct/2, ciw, cid));

            if strcmp(cm, 'volume')
                % Cavité cubique en parallèle
                cc = classcubicalcavity(classcubicalcavity.create_config(pmw, pmd, cw, cd, ct));
                obj.Configuration.ListOfSubelements{end+1} = classjunction(classjunction.create_config(cc, pmw, pmd));
            end

            % Cavité cylindrique
            obj.Configuration.ListOfSubelements{end+1} = classcavity(classcavity.create_config(ct/2, pmw, pmd));
        end
    end
end









