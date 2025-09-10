classdef classHelmholtz_Resonator < classelement

%% Références

% [1] K. Mahesh, R.S. Mini, Investigation on the Acoustic Performance of Multiple Helmholtz Resonator Configurations
% Lien Zotero : perso_ouvrir_lien_Zotero('zotero://open-pdf/library/items/UF5M6PI2')

    properties (Access = public)
        NeckRadius
        NeckLength
        CavityRadius
        CavityLength
        Thickness
    end
    properties (Access = private)
        Neck
        SectionChange
        Cavity
    end
    
    methods
        function obj = classHelmholtz_Resonator(config)

            nr = config.NeckRadius;
            nl = config.NeckLength;
            ns = pi*nr^2; % Neck Section
            cw = config.CavityWidth;
            cd = config.CavityDepth;
            cl = config.CavityLength;
            cs = cd*cw; % Cavity Section
            obj@classelement(config)

            % On ajoute le col du résonateur
            phi = ns/cs;
            tc = 0.48 * sqrt(ns) * (1 - 1.14 * sqrt(phi)); % perso_ouvrir_lien_Zotero('zotero://open-pdf/library/items/UF5M6PI2?page=357&annotation=69ALD78C')
            sig = @(env) 8 * env.air.parameters.eta / (phi * nr^2); % perso_ouvrir_lien_Zotero('zotero://open-pdf/library/items/UF5M6PI2?page=357&annotation=6CBI54J6')
            tor = 1 + (2*tc/nl); % perso_ouvrir_lien_Zotero('zotero://open-pdf/library/items/UF5M6PI2?page=357&annotation=4QIE2UDU')
            obj.ListOfSubelements{end} = classJCA_Rigid(classJCA_Rigid.create_config(phi, tor, sig, nr, nr, nl, ns));

            % On ajoute la cavité
            obj.ListOfSubelements{end} = classcavity(classcavity.create_config(cl, cs));
        end
        
    end

    methods (Static, Access = public)

        function config = create_config(neck_radius, neck_length, cavity_width, cavity_depth, cavity_length)

            config.NeckRadius = neck_radius;
            config.NeckLength = neck_length;
            config.CavityWidth = cavity_width;
            config.CavityDepth = cavity_depth;
            config.CavityLength = cavity_length;
        end
    end
end

