classdef classsidebranch < classelement
    
    methods 

        function obj = classsidebranch(config)

            % On appelle le constructeur de classe "classelement" à vide
            obj@classelement(classelement.create_config({}, "opened", []));
            
            % On tranfert les attributs de la configuration d'appel vers la configuration de classe
            obj.Configuration = perso_transfer_fields(config, obj.Configuration);

            J_elem = config.JunctionElement;
            s = config.Section;
            l = config.DuctLength;
            
            % Demi-tranche de conduite
            obj.Configuration.ListOfObjects{end+1} = classcavity(classcavity.create_config(s, l/2));

            % Jonction
            obj.Configuration.ListOfObjects{end+1} = classjunction(classjunction.create_config(J_elem, s));

            % Demi-tranche de conduite
            obj.Configuration.ListOfObjects{end+1} = classcavity(classcavity.create_config(s, l/2));
        end 
    end

    methods (Static, Access = public)

        function config = create_config(junction_element, duct_length, duct_section)
            
            config.JunctionElement = junction_element;
            config.DuctLength = duct_length;
            config.Section = duct_section;
            config.Surface = duct_section;
        end
    end
end

