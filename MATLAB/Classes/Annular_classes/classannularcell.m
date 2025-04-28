classdef classannularcell < classelement

%% References: 

% [1] Dupont, Thomas, et al. "A Microstructure Material Design for
% Low Frequency Sound Absorption." Applied Acoustics, vol. 136,
% July 2018, pp. 86-93. 
% DOI: 10.1016/j.apacoust.2018.02.016.

%% Description

% Cette classe d'objet appartient au groupe des classes d'élements ouverts

% Un objet de type "classannularcell" représente une cavité fine dans laquelle la propagation serait partiellement ou totalement radiale
% (basée sur les fonctions de Hankel). Pour modéliser ce type de cellule on doit considérer la dimension longitudinale de la cellule
% (son épaisseur) qui induit un déphasage entre les surfaces d'entrée et de sortie et une dimension annulaire qui détermine son comportement acoustique
% Pour cela on ajoute en série trois bloc élementaire : 
% - une cavité à propagation longitudinale, de rayon égal à celui du port central, sans pertes pariétales,
%   associée à la première moitié de l'épaisseur réelle de la cavité
% - une cavité à propagation radiale sans épaisseur (avec pertes pariétales?) de rayon égal au rayon interne de la cavité annulaire
% - une seconde cavité annulaire identique à la première

% La construction de cette cellule s'apparente à celle présentée dans [1], fig.4

%% Properties

    properties

        Type = 'Annular Cell'
        
    end

%% Methods
    
    methods 

        function obj = classannularcell(annular_cell_configuration)

            % On appelle le constructeur de classe "classelement" à vide
            obj@classelement(classelement.create_config({}, "opened"));
            
            % On tranfert les attributs de la configuration d'appel vers la configuration de classe
            obj.Configuration = transferFields(annular_cell_configuration, obj.Configuration);

            rmpi = obj.Configuration.MainPoreRadiusIn;
            rmpo = obj.Configuration.MainPoreRadiusOut;
            rmp = (rmpi + rmpo)/2; 
            rde = obj.Configuration.DeadEndRadius;
            tde = obj.Configuration.DeadEndThickness;
            cm = obj.Configuration.CavitiesModel;
            
            % Demi-pore d'entrée  
            % obj.Configuration.ListOfSubelements{end+1} = classconicalcavity(classconicalcavity.create_config(tde/2, rmpi, rmp));
            % obj.Configuration.ListOfSubelements{end+1} = classcavity(classcavity.create_config(tde/2, rmpi, rmp));

            % Cavité annulaire
            annular_cavity = classannularcavity(classannularcavity.create_config(rmp, rde, tde, cm));
            obj.Configuration.ListOfSubelements{end+1} = classjunction_cylindrical(classjunction_cylindrical.create_config(annular_cavity, rmp, tde));

            % Demi-pore de sortie 
            % obj.Configuration.ListOfSubelements{end+1} = classconicalcavity(classconicalcavity.create_config(tde/2, rmp, rmpo));
            % obj.Configuration.ListOfSubelements{end+1} = classcavity(classcavity.create_config(tde/2, rmpi, rmp));
        end 
    end

    methods (Static, Access = public)

        function config = create_config(main_pore_radius_in, main_pore_radius_out, dead_end_radius, dead_end_thickness, cavities_model)
            
            config.MainPoreRadiusIn = main_pore_radius_in;
            config.MainPoreRadiusOut = main_pore_radius_out;
            config.DeadEndRadius = dead_end_radius;
            config.DeadEndThickness =  dead_end_thickness;
            config.CavitiesModel = cavities_model;
        end
    end
end

