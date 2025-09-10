classdef classMPP_Circular_HL_flow_iter < classMPP_Circular

% Description
% Ce constructeur de classe permet de créer une plaque microperforée à perforations circulaires
% Il se base sur le modèle de fluide équivalent (JCA) développé dans 'classJCA_Rigid'
% En plus de cela, on intègre la résistivité et la tortuosité modifiée développée par Laly dans [5]
% obtenue suivant une procédure itérative

% References
%            [1] Atalla, Noureddine, et Franck Sgard. « Modeling of Perforated 
%                Plates and Screens Using Rigid Frame Porous Models ». Journal 
%                of Sound and Vibration, vol. 303, no 1‑2, juin 2007, p. 195‑208.
%                DOI.org (Crossref), https://doi.org/10.1016/j.jsv.2007.01.012.
% 
%            [2] Ingard, Uno. « On the Theory and Design of Acoustic Resonators ». 
%                The Journal of the Acoustical Society of America, vol. 25, no 6, 
%                juin 2005, p. 1037. world, asa.scitation.org, 
%                https://doi.org/10.1121/1.1907235.
% 
%            [3] Okuzono, Takeshi, et al. "Note on Microperforated Panel Model Using
%                Equivalent-Fluid-Based Absorption Elements." Acoustical Science and 
%                Technology, vol. 40, no. 3, May 2019, pp. 221–24. DOI.org (Crossref), 
%                https://doi.org/10.1250/ast.40.221.)
%
%            [4] Stinson & Champoux, Propagation of sound and the assignment of 
%                shape factors in model porous materials having simple pore geometries
%                http://asa.scitation.org/doi/10.1121/1.402530
%
%            [5] Zacharie Laly, Acoustical modeling of micro-perforated panel at high 
%                sound pressure levels using equivalent fluid approach
%                https://linkinghub.elsevier.com/retrieve/pii/S0022460X17306740
%
%            [6] Zacharie Laly, Développement, validation expérimentale et optimisation 
%                des traitements acoustiques des nacelles de turboréacteurs sous hauts 
%                niveaux acoustiques
         
%% Constructeur de classe

    methods

        function obj = classMPP_Circular_HL_flow_iter(config, varargin)
            
            obj@classMPP_Circular(config)

            p = inputParser;
            addOptional(p, 'u_rms', 0, @isnumeric)
            parse(p, varargin{:});
            u_rms = p.Results.u_rms;
            
            phi = config.Porosity;
            pr = config.PerforationsRadius;
            t = config.Thickness;  
            S = obj.Configuration.Section;

            % On encapsule les méthodes non linéaires dans la définiton des paramètres JCA
            obj.Configuration.AirFlowResistivity = @(env) classMPP_Circular_HL_flow_iter.air_flow_resistivity(env, u_rms, phi, pr, t, S);
            obj.Configuration.Tortuosity = @(env) classMPP_Circular_HL_flow_iter.tortuosity(env, u_rms, phi, pr, t, S);
        end

        function surface_impedance(obj, env, varargin)

            p = inputParser;
            addRequired(p, 'env');
            addOptional(p, 'Va', 0, @isnumeric)
            parse(p, obj, varargin{:});
            Va = p.Results.Va;

            dB2RMS = @(dB) env.p_ref * 10^(dB/20);
            RMS2dB = @(p) 20 * log10(p/ env.p_ref);

            config = obj.Configuration;
            phi = config.PlatePorosity;
            pr = config.PerforationsRadius;
            t = config.PlateThickness;

            tol = 1e-6;  % Tolérance pour la convergence
            max_iter = 100;  % Nombre maximum d'itérations
            iter = 0;
            converged = false;
            
             while ~converged && iter < max_iter
                iter = iter + 1;

                % Calcul de l'impédance de surface avec la vitesse courante
                % en appelant la méthode définit dans la classe parente
                Z_s = abs(surface_impedance@classMPP_Circular(obj, env));
        
                % Mise à jour de la vitesse acoustique
                Va_new = env.p_ref * 10^(RMS2dB(env.p) / 20) ./ (env.air.parameters.Z0 * Z_s);
        
                % Vérification du critère de convergence
                error_rel = abs(Va_new - Va) / abs(Va);
                if error_rel < tol
                    converged = true;
                else
                    obj = classMPP_Circular_HL_flow_iter(obj.Configuration, Va_new);
                    Va = Va_new;
                end
            end
        end
    end

    methods (Static, Access = public)

        function sig = air_flow_resistivity(env, u_rms, phi, pr, t, S)

            beta = 1.6; % [5] p.8
            Cd = 0.76; % [5] p.8
            q = 0.3; % voir modèle Laly écoulement

            % Résistivité au passage de l'air ([5], p. 7, eq. 20)
            sig = 8 * env.air.parameters.eta / (phi * pr^2) ... résistivité linéaire
            + beta * env.air.parameters.rho * (1 - phi^2) / (pi * t * phi * Cd^2) * u_rms/S ... % fort niveau en fonction du débit RMS
            + env.air.parameters.rho * env.air.parameters.c0 * (1 - phi^2) / (phi * t) * q * env.M; % écoulement en fonction du nombre de Mach moyen

            % % debog : Tracé de la résistivité au passage de l'air en fonction de la fréquence
            % figure('Résistivité au passage de l''air dans classMPP_Circular_HL_flow_iter')
            % plot(abs(sig))
            % close();
        end

        function tor = tortuosity(env, u_rms, phi, pr, t, S)
             
            psi = 4/3; 
            a = [1.0 -1.4092 0.0 0.33818 0.0 0.06793 -0.02287 0.003015 -0.01614];
            sum_a = dot(a, sqrt(phi).^(0:length(a)-1));

            % Tortuosité non linéaire ([5], p. 7, eq. 22, 23)
            tor = 1 + 2 * psi / (1 + 305 * env.M^3) ./ (t * (1 + u_rms/S / (phi * env.air.parameters.c0))) ...
            * 0.48 * sqrt(pi * pr^2) * sum_a;

            % % debog : Tracé de la tortuosité en fonction de la fréquence
            % perso_figure('tor')
            % plot(tor);
            % % % close();
        end

        function validate()

        % launch_environnement();
        % 
        % % Courbe de référence
        % % perso_ouvrir_lien_Zotero('zotero://open-pdf/library/items/C3F2ZIGB?page=145&annotation=I8FZCE7A');
        % 
        % s = 1; % section arbitraire
        % t = 0.86e-3;
        % d = 1.517e-3;
        % phi = 0.0523;
        % cd = 25e-3;
        % dB1 = 125;
        % dB2 = 150;
        % 
        % perso_figure('Validation avec écoulement (Thèse Laly)');
        % 
        % subplot(2, 2, 1)
        % title('Fig 5.1, M = 0.1')
        % hold on 
        % 
        % data5_1 = load('C:\Users\lucas.barbier\Documents\Maitrise dossier secondaire\MATLAB\Classes\MPP_Classes\Validation\Thèse_Laly_fig5.1_black.txt');
        % 
        % SPL = 110; % Pression incidente
        % M = 0.1;
        % env = handle_env(SPL, M);
        % env0 = handle_env(SPL, 0);
        % 
        % t = 1e-3;
        % r = 0.3e-3;
        % phi = 0.038;
        % D = 20e-3;
        % s = 1; % Surface arbitraire
        % 
        % plate = classMPP_Circular_HL(classMPP_Circular.create_config(s, t, r, phi));
        % cavity = classcavity(classcavity.create_config(D, sqrt(s), sqrt(s)));
        % E = classelement(classelement.create_config({plate, cavity}, 'closed', s));
        % 
        % % Modèle non linéaire itératif
        % plot(env.w/(2*pi), E.alpha(env), 'DisplayName', 'Modèle non - linéaire itératif avec écoulement');
        % plot(env.w/(2*pi), E.alpha(env0), 'DisplayName', 'Modèle non - linéaire itératif sans écoulement');
        % perso_configure_alpha_figure(5000);
        % 
        % % Données de références
        % hold on
        % plot(data5_1(:, 1), data5_1(:, 2), 'DisplayName', 'Données de référence');
        % legend('Location', 'best');

        end
    end
end