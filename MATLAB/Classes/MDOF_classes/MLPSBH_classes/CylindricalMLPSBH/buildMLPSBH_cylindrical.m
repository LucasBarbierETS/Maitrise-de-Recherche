function MLPSBH = buildMLPSBH_cylindrical(SBHRadius, CavitiesRadius, PlatesPerforatedAreaRadius, PlatesPorosity, PlatesHolesRadius, PlatesThickness, CavitiesThickness, CavitiesModel, CorrectionLengthMethod, CommonPoresUsed, varargin)

%% Description

%   'build_classMLPSBH' is a function that use hyperparameters to create the input-structure 'config' of a 'classMLPSBH' object
% 	to diminish its number of degrees of freedom. 

%% Input parameters

%    Each input parameter can take several forms : 
%
%   - SBHRadius : R (double) : radius of the sample
%
%   - CavitiesRadius : cr (double) : radius of the cavities
% 
% 	- PlatesPerforatedAreaRadius :  - r (double) : radius of all plates
% 	   			                    - {rin, rend, order} (cell) : radius of the first plate's perforated area, residual radius, radius function order
% 	           			            - [r1 ... rN] (double) : radius of each plate
% 
% 	- PlatesPorosity : - phi (double) ; porosity of all plates
% 	                   - [phi1 ... phiN] (double) : porosity of each plate
% 
% 	- PlatesHolesRadius : - hr (double) : holes radius of all plates
% 	     	              - [hr1 ... hrN] (double) : holes radius of each platePoreDimens
% 
% 	- PlatesThickness : - pt (double) : thickness of all plates
% 	     	            - [pt1 ... ptN] (double) : holes radius of each plate
% 
%   - PlatesCorrectionLength : - pcl (double) : correction of all plates
%                              - [pcl1 ... pclN] (double) : correction of each plates
%
% 	- CavitiesThickness :  - ct (double) : thickness of all plates
% 	     	               - [ct1 ... ctN] (double) : holes radius of each plate
% 
% 	- CavitiesModel : (string) - 'hankel' for Hankel's model, 'false' for low frequency approximation (see classannularcavity)	
%                              - 'volume' pour le modèle d'admittance basé sur le volume 
%
%   - CorrectionLengthMethod : (string)   - 'none' : no length corrections are considered
%                                         - 'intern' : to use the 'classMPP's intern method
%                                         - 'bezancon' 
%                                         - 'chen'
%
%   - CommonPoresUsed : (boolean) 'true' if common pores are used 'false' if not
%
%   - varargin : (cell) number of cavities


%% Code 

config = {};
config.SBHRadius = SBHRadius;
config.CavitiesRadius = CavitiesRadius; % Pour l'instant toutes les cavités ont le même rayon 
config.CorrectionLengthMethod = CorrectionLengthMethod;
config.CavitiesModel = CavitiesModel;
config.CommonPoresUsed = CommonPoresUsed;

% Thickness

if isscalar(PlatesThickness)
    config.PlatesThickness = repmat(PlatesThickness, 1, varargin{1});
else 
    config.PlatesThickness = PlatesThickness;
end

if isscalar(CavitiesThickness)
    config.CavitiesThickness = repmat(CavitiesThickness, 1, varargin{1});
else 
    config.CavitiesThickness = CavitiesThickness;
end


% Radius

L = sum(config.PlatesThickness) + sum(config.CavitiesThickness); % SBH total length

if iscell(PlatesPerforatedAreaRadius)  % 2nd case
    config.PlatesPerforatedAreaRadius = [PlatesPerforatedAreaRadius{1}]; % x_position = 0
    r = profilMLPSBH(L, PlatesPerforatedAreaRadius{1}, PlatesPerforatedAreaRadius{2}, PlatesPerforatedAreaRadius{3});
    for i = 1:varargin{1} - 1 
        x_position = sum(config.PlatesThickness(1:i)) + sum(config.CavitiesThickness(1:i));
        config.PlatesPerforatedAreaRadius =  [config.PlatesPerforatedAreaRadius r(x_position)];
    end 
elseif isscalar(PlatesPerforatedAreaRadius) % 1st case
    config.PlatesPerforatedAreaRadius = repmat(PlatesPerforatedAreaRadius, 1, varargin{1});    
else % 3rd case
    config.PlatesPerforatedAreaRadius = PlatesPerforatedAreaRadius;
end


if isscalar(PlatesHolesRadius)
    config.PlatesHolesRadius = repmat(PlatesHolesRadius, 1, varargin{1});
else 
    config.PlatesHolesRadius = PlatesHolesRadius;
end

% Porosity

if isscalar(PlatesPorosity)
    config.PlatesPorosity = repmat(PlatesPorosity, 1, varargin{1});
else
    config.PlatesPorosity = PlatesPorosity;
end

% Correction Length

config.PlatesCorrectionLength = zeros(size(config.PlatesThickness));

config = add_thicknness_correction(config, CorrectionLengthMethod);

% On construit l'objet

MLPSBH = classMLPSBH_Cylindrical(config); 

end