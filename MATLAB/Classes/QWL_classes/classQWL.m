classdef classQWL < classJCA_Rigid

    % References:

    % [1] Stinson & Champoux, Propagation of sound and the assignment of
    %     shape factors in model porous materials having simple pore geometries
    %     http://asa.scitation.org/doi/10.1121/1.402530
    % [2] Modeling of perforated plates and screens using rigid frame porous models
    %     Noureddine Atallaa, Franck Sgard
    %     doi:10.1016/j.jsv.2007.01.012

    properties

    % Configuration

    end
   
    methods
        function obj = classQWL(config)
            
            k0 = config.PermeabilityCoefficient;
            rh = config.HydraulicRadius;
            length = config.Length;
            
            % Si la cavité a été appelé dans le pore principal
            if isfield(config, 'InputSection')
                section = config.InputSection;
            % Sinon, elle est appelée dans une jonction
            else
                section = config.CurtainArea;
            end
            
            % Définir la résistivité
            resistivity = @(env) 4 * k0 * env.air.parameters.eta / rh^2;

            % Appeler le constructeur de la classe parent
            obj@classJCA_Rigid(classJCA_Rigid.create_config(1, 1, resistivity, rh, rh, length, section));
    
            % On tranfert les paramètres de la configuration d'appel vers
            % la configuration de classe
            obj.Configuration = perso_transfer_fields(config, obj.Configuration);
        end
    end
end
