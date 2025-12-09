classdef classair
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Reference :   Rasmussen, K (1997). "Calculation method for the physical 
%               properties of air used in the calibration of microphones".
%
%%%%%%%%%%%%%%%%%%%%%%%%% PUBLIC PROPERTIES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INPUT
% sp : static pressure (Pa)
% t : room temperature (°C)
% hum : relative humidity (%)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%% PUBLIC PROPERTIES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% OUTPUT
% obj.Parameters.rho     : density of air (kg/m^3)
% obj.Parameters.c0      : sound speed (m/s)
% obj.Parameters.eta     : dynamic viscosity
% obj.Parameters.gamma   : specific heat ratio
% obj.Parameters.Pr      : Prandtl number
% obj.Parameters.Z0      : characteristic impedance
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    properties
        Temperature          % (°C)
        StaticPressure       % (Pa)
        RelativeHumidity     % (%)
        parameters           % structure contenant tous les paramètres calculés
    end

    properties (Access = private, Constant)
        apsv = [1.237884e-5 -1.9121316e-2  33.93711047 -6.3431645e3];
        af   = [1.00062      3.14e-8       5.6e-7];
        aZ   = [1.58123e-6  -2.9331e-8     1.1043e-10   5.707e-6     -2.051e-8    1.9898e-4 -2.376e-6  1.83e-11 -0.765e-8];
        ac   = [331.5024     0.603055     -0.000528     51.471935     0.14955874 -0.000782  -1.82e-7   3.73e-8  -2.93e-10  -85.20931  -0.228525  5.91e-5  -2.835149 -2.15e-13  29.179762 0.000486];
        ak   = [1.400822    -1.75e-5      -1.73e-7     -0.0873629    -0.0001665  -3.26e-6    2.047e-8 -1.26e-10  5.939e-14 -0.1199717 -0.0008693 1.979e-6 -0.01104  -3.478e-16 0.050616  1.82e-6];
        aeta = [84.986       7.0           113.157     -1            -3.7501e-3  -100.015];
        aka  = [60.054       1.846         2.06e-6 40  -1.775e-4];
        acp  = [0.251625    -9.25525e-5    2.1334e-7   -1.0043e-10    0.12477    -2.283e-5   1.267e-7  0.001116  4.61e-6    1.74e-8];
        xc   = 0.0004 % Mole fraction of CO2 in air
    end
    
    methods
        function obj = classair(t, sp, hum)
            obj.Temperature      = t;
            obj.StaticPressure   = sp;
            obj.RelativeHumidity = hum;

            % Calcul unique des paramètres
            obj.parameters = obj.compute_parameters();
        end
    end

    methods (Access = private)
        function param = compute_parameters(obj)

            T = obj.Temperature;
            H = obj.RelativeHumidity;
            P = obj.StaticPressure;

            TK = T + 273.15;
            param.TK = TK;

            % Vapour saturation pressure
            psv = exp(obj.apsv(1)*TK^2 + obj.apsv(2)*TK + obj.apsv(3) + obj.apsv(4)/TK);

            % Enhancement factor
            f = obj.af(1) + obj.af(2)*psv + obj.af(3)*T^2;

            % Mole fraction water
            param.xw = H/100 * psv/P * f;
            xw = param.xw;

            % Compressibility factor
            Z = 1 - P/TK*(obj.aZ(1) + obj.aZ(2)*T + obj.aZ(3)*T^2 ...
                         + (obj.aZ(4)+obj.aZ(5)*T)*xw ...
                         + (obj.aZ(6)+obj.aZ(7)*T)*xw^2 ) ...
                + (P/TK)^2 * (obj.aZ(8) + obj.aZ(9)*xw^2);
            param.Z = Z;

            % Thermal conductivity
            kappa = (obj.aka(1) + obj.aka(2)*TK + obj.aka(3)*TK^2 ...
                    + (obj.aka(4)+obj.aka(5)*TK)*xw)*1e-8;
            param.kappa = kappa;

            % Specific heat
            Cp = obj.acp(1) + obj.acp(2)*TK + obj.acp(3)*TK^2 + obj.acp(4)*TK^3 ...
                + (obj.acp(5)+obj.acp(6)*TK+obj.acp(7)*TK^2)*xw ...
                + (obj.acp(8)+obj.acp(9)*TK+obj.acp(10)*TK^2)*xw^2;
            param.Cp = Cp;

            % Density
            rho = (3.48349 + 1.44*(obj.xc-0.0004))*1e-3 * P/Z/TK * (1 - 0.378*xw);
            param.rho = rho;

            % Speed of sound
            c0 = obj.ac(1) + obj.ac(2)*T + obj.ac(3)*T^2 ...
               + (obj.ac(4)+obj.ac(5)*T+obj.ac(6)*T^2)*xw ...
               + (obj.ac(7)+obj.ac(8)*T+obj.ac(9)*T^2)*P ...
               + (obj.ac(10)+obj.ac(11)*T+obj.ac(12)*T^2)*obj.xc ...
               + obj.ac(13)*xw^2 + obj.ac(14)*P^2 + obj.ac(15)*obj.xc^2 ...
               + obj.ac(16)*xw*P*obj.xc;
            param.c0 = c0;

            % Dynamic viscosity
            eta = (obj.aeta(1)+obj.aeta(2)*TK + (obj.aeta(3)+obj.aeta(4)*TK)*xw ...
                  + obj.aeta(5)*TK^2 + obj.aeta(6)*xw^2)*1e-8;
            param.eta = eta;

            % Specific heat ratio
            gamma = obj.ak(1) + obj.ak(2)*T + obj.ak(3)*T^2 ...
                + (obj.ak(4)+obj.ak(5)*T+obj.ak(6)*T^2)*xw ...
                + (obj.ak(7)+obj.ak(8)*T+obj.ak(9)*T^2)*P ...
                + (obj.ak(10)+obj.ak(11)*T+obj.ak(12)*T^2)*obj.xc ...
                + obj.ak(13)*xw^2 + obj.ak(14)*P^2 + obj.ak(15)*obj.xc^2 ...
                + obj.ak(16)*xw*P*obj.xc;
            param.gamma = gamma;

            % Prandtl number
            param.Pr = Cp * eta / kappa;

            % Characteristic impedance
            param.Z0 = rho * c0;
        end
    end
end
