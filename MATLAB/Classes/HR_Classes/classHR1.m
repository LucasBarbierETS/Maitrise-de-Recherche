classdef classHR1
% This class creates a Helmholtz resonnator using the mechanical
% analogy.
%
%                           _____________
%                          |             |
%                   _______|             |
%  NeckSurface|             CavityVolume |
%             |     _______              |
%                          |             |
%                          |_____________|
%                   _______
%                 NeckLength
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%% PROPRIETIES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% NeckSurface  : surface of the neck of the resonator  (m2)
% NeckLength   : length of the neck of thwe resonator  (m)
% CavityVolume : Volume of the cavity of the resonator (m3)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% METHODS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% obj.transfer_matrix(Air,w) : compute a structure of arrays implemented :
%                                   obj.transfer_matrix(Air,w).Tij 
%                              where (i,j)∈{1,2}². The structures represents 
%                              the transfer matrix of the MPP : (T11  T12)
%                                                               (T21  T22)
% 
% obj.surfaceImpedance(Air,w):               Surface impedance of the MPP

    properties
        NeckSurface
        NeckLength
        CavityVolume
    end
    methods
        function obj = classHR1(neck_surface,neck_length,cavity_volume)
            obj.NeckSurface = neck_surface;
            obj.NeckLength = neck_length;
            obj.CavityVolume = cavity_volume;
        end
        function Zs = surfaceImpedance(obj,Air,w)
            % air density in the neck taking the side effect into account
            param = Air.parameters;
            neck_radius = sqrt(obj.NeckSurface/pi);
            length_correction = 1.7*sqrt(obj.NeckSurface/pi);

            rhoeq = classJCA("rigid",100,8*param.eta/neck_radius^2,1,neck_radius,neck_radius,obj.NeckLength+length_correction).equivalent_parameters(Air,w).rhoeq; 
            
            % mechanical analogy
            m = rhoeq*(obj.NeckLength+length_correction)*obj.NeckSurface; % mass
            K0 = param.c0^2*param.rho;
            k = K0*obj.NeckSurface^2/obj.CavityVolume; % stiffness

            Zs = (-w.^2.*m+k)./1j./w./obj.NeckSurface;
        end
        function TM = transferMatrix(obj,Air,w)
            TM.T11 = 1;
            TM.T12 = 0;
            TM.T21 = -1./surfaceImpedance(obj,Air,w);
            TM.T22 = 1;
        end
    end
end 

