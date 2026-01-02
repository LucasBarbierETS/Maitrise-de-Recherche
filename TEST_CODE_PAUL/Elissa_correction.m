
data = readmatrix([env.Root, '\TEST_CODE_PAUL\nearfield.txt']);
f = data(:, 1);
DSP_dB = data(:, 2);

%% --- Création de l'environnement avec le fichier principal ---
env = create_environnement_2(root, t, sp, hum, f);

%% --- Passage en Niveau de pression des données de Manuel REAR ---
DSP = env.p_ref^2 * 10.^(DSP_dB/10);

%% --- TM Poreux analytique ---

% --- Propriétés du matériau ---
porosity = 0.971; %Littérature marlene sciard
tortuosity = 1.02; %Littérature marlene sciard
air_flow_resistivity = 8644;     %8600; Littérature marlene sciard
viscous_caractersitic_length = 1.23e-4 ;    %1.23e-4;%Littérature marlene sciard
thermal_caracteristic_length = 1.86e-4  ;   %1.86e-4;%Littérature marlene sciard

% - Propriétés micros --
D = 6.35e-3; % diamètre du micro
surface = (pi/4)*D^2;
coeff = 6;
thickness = @(coeff) coeff * D;

% --- Création objet / config ---
config = @(coeff) classJCA_Rigid.create_config(surface, thickness(coeff), porosity, ...
    tortuosity, air_flow_resistivity, viscous_caractersitic_length, thermal_caracteristic_length);
obj = @(coeff) classJCA_Rigid(config(coeff));
elm = @(coeff) classelement(classelement.create_config({obj(coeff)}, 'closed', surface));

% --- debog TM et TM_inv --- 
[TM_inv, options] = obj(coeff).inverse_transfer_matrix(env); % bien changer la valeur du coeff en fonction de l'étude
TM = obj(coeff).transfer_matrix(env, options);
TM.T12 = TM.T12 * surface;
TM.T21 = TM.T21 / surface;

DSP_corr = TM.T11' .* DSP; % rigid wall
DSP_dB_corr = 10*log10(abs(DSP_corr)/env.p_ref^2);






