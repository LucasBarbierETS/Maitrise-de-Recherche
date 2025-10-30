classdef Environnement_App_classe < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                      matlab.ui.Figure
        pointsEditField               matlab.ui.control.NumericEditField
        pointsEditFieldLabel          matlab.ui.control.Label
        fmaxEditField                 matlab.ui.control.NumericEditField
        fmaxEditFieldLabel            matlab.ui.control.Label
        fminEditField                 matlab.ui.control.NumericEditField
        fminEditFieldLabel            matlab.ui.control.Label
        MEditField                    matlab.ui.control.NumericEditField
        MEditFieldLabel               matlab.ui.control.Label
        MLabel                        matlab.ui.control.Label
        RelativeHumidityEditField     matlab.ui.control.NumericEditField
        RelativeHumidityEditField_2Label  matlab.ui.control.Label
        RelativeHumidityLabel         matlab.ui.control.Label
        EnvironnementparametersLabel  matlab.ui.control.Label
        SPLEditField                  matlab.ui.control.NumericEditField
        SPLEditFieldLabel             matlab.ui.control.Label
        SPLLabel                      matlab.ui.control.Label
        StaticPressureEditField       matlab.ui.control.NumericEditField
        StaticPressureEditFieldLabel  matlab.ui.control.Label
        PaLabel                       matlab.ui.control.Label
        TemperatureEditField          matlab.ui.control.NumericEditField
        TemperatureEditFieldLabel     matlab.ui.control.Label
        CLabel                        matlab.ui.control.Label
        ContinueButton                matlab.ui.control.Button
    end

    
    properties (Access = public)

        MainApp
        Env
        Root
        w
        air
        SPL
        M
        pt
        pt_rms
    end
    
    methods (Access = private)
        
        function app = update_environnement_parameters(app, env)

            app.Env = env;
            app.Root = env.Root;
            app.w = env.w;
            app.air = env.air;
            app.SPL = env.SPL;
            app.M = env.M;
            app.pt = env.pt;
            app.pt_rms = env.pt_rms;   
        end
    end

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app, varargin)
            
            % Récupère la taille de l'écran
            screenSize = get(0, 'ScreenSize');  % [x y width height]
            
            % Taille de la fenêtre de l'app
            appWidth = app.UIFigure.Position(3);
            appHeight = app.UIFigure.Position(4);
            
            % Calcul des coordonnées centrées
            app.UIFigure.Position(1) = (screenSize(3) - appWidth) / 2;
            app.UIFigure.Position(2) = (screenSize(4) - appHeight) / 2;

            % varargin = {main_app, ...}

            if nargin > 1
   
                env = varargin{1};

                app = update_environnement_parameters(app, env);

                app.fminEditField.Value = env.fmin;
                app.fmaxEditField.Value = env.fmax;
                app.pointsEditField.Value = env.points;
                app.TemperatureEditField.Value = env.air.Temperature;
                app.StaticPressureEditField.Value = env.air.StaticPressure;
                app.RelativeHumidityEditField.Value = env.air.RelativeHumidity;  
                app.SPLEditField.Value = env.SPL;
                app.MEditField.Value = env.M;

            else     
                % On définie arbitrairement la valeur des champs d'écriture
                app.fminEditField.Value = 1;
                app.maxEditField.Value = 5000;
                app.maxEditField.Value = 5000;
                app.TemperatureEditField.Value = 20;
                app.StaticPressureEditField.Value = 100000;
                app.RelativeHumidityEditField.Value = 20;
                app.SPLEditField.Value = 100;
                app.MEditField.Value = 0;
            end
        end

        % Button pushed function: ContinueButton
        function ContinueButtonPushed(app, event)

            env = create_environnement(app.TemperatureEditField.Value, ...
                app.StaticPressureEditField.Value, ...
                app.RelativeHumidityEditField.Value, ...
                app.Env.fmin, app.Env.fmax, app.Env.points, ...
                'Root', app.Env.Root, ...
                'SPL', app.SPLEditField.Value, ...
                'M', app.MEditField.Value);

            app = app.update_environnement_parameters(env);

            % On ferme la fenêtre secondaire
            app.UIFigure.Visible = "off";
            
            % Au premier lancement, le programme passe par cette boucle
            if isempty(app.MainApp)
                % On lance l'application
                app.MainApp = Main_App_classe(app);
            end
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [697.666666666667 397.666666666667 300 398];
            app.UIFigure.Name = 'EPC Bell Presettings App';

            % Create ContinueButton
            app.ContinueButton = uibutton(app.UIFigure, 'push');
            app.ContinueButton.ButtonPushedFcn = createCallbackFcn(app, @ContinueButtonPushed, true);
            app.ContinueButton.Position = [180 11 100 23];
            app.ContinueButton.Text = 'Continue';

            % Create CLabel
            app.CLabel = uilabel(app.UIFigure);
            app.CLabel.Position = [241 196 25 22];
            app.CLabel.Text = '°C';

            % Create TemperatureEditFieldLabel
            app.TemperatureEditFieldLabel = uilabel(app.UIFigure);
            app.TemperatureEditFieldLabel.HorizontalAlignment = 'right';
            app.TemperatureEditFieldLabel.Position = [52 196 73 22];
            app.TemperatureEditFieldLabel.Text = 'Temperature';

            % Create TemperatureEditField
            app.TemperatureEditField = uieditfield(app.UIFigure, 'numeric');
            app.TemperatureEditField.AllowEmpty = 'on';
            app.TemperatureEditField.Position = [135 196 100 22];
            app.TemperatureEditField.Value = [];

            % Create PaLabel
            app.PaLabel = uilabel(app.UIFigure);
            app.PaLabel.Position = [242 166 25 22];
            app.PaLabel.Text = 'Pa';

            % Create StaticPressureEditFieldLabel
            app.StaticPressureEditFieldLabel = uilabel(app.UIFigure);
            app.StaticPressureEditFieldLabel.HorizontalAlignment = 'right';
            app.StaticPressureEditFieldLabel.WordWrap = 'on';
            app.StaticPressureEditFieldLabel.Position = [41 161 84 22];
            app.StaticPressureEditFieldLabel.Text = 'Static Pressure';

            % Create StaticPressureEditField
            app.StaticPressureEditField = uieditfield(app.UIFigure, 'numeric');
            app.StaticPressureEditField.AllowEmpty = 'on';
            app.StaticPressureEditField.Position = [135 161 100 22];
            app.StaticPressureEditField.Value = [];

            % Create SPLLabel
            app.SPLLabel = uilabel(app.UIFigure);
            app.SPLLabel.Position = [238 88 25 22];
            app.SPLLabel.Text = ' dB';

            % Create SPLEditFieldLabel
            app.SPLEditFieldLabel = uilabel(app.UIFigure);
            app.SPLEditFieldLabel.HorizontalAlignment = 'right';
            app.SPLEditFieldLabel.Position = [25 90 99 22];
            app.SPLEditFieldLabel.Text = 'SPL';

            % Create SPLEditField
            app.SPLEditField = uieditfield(app.UIFigure, 'numeric');
            app.SPLEditField.AllowEmpty = 'on';
            app.SPLEditField.Position = [134 90 100 22];
            app.SPLEditField.Value = [];

            % Create EnvironnementparametersLabel
            app.EnvironnementparametersLabel = uilabel(app.UIFigure);
            app.EnvironnementparametersLabel.HorizontalAlignment = 'center';
            app.EnvironnementparametersLabel.FontWeight = 'bold';
            app.EnvironnementparametersLabel.Position = [71 349 160 22];
            app.EnvironnementparametersLabel.Text = 'Environnement parameters';

            % Create RelativeHumidityLabel
            app.RelativeHumidityLabel = uilabel(app.UIFigure);
            app.RelativeHumidityLabel.Position = [244 128 25 22];
            app.RelativeHumidityLabel.Text = '%';

            % Create RelativeHumidityEditField_2Label
            app.RelativeHumidityEditField_2Label = uilabel(app.UIFigure);
            app.RelativeHumidityEditField_2Label.HorizontalAlignment = 'right';
            app.RelativeHumidityEditField_2Label.Position = [26 123 99 22];
            app.RelativeHumidityEditField_2Label.Text = 'Relative Humidity';

            % Create RelativeHumidityEditField
            app.RelativeHumidityEditField = uieditfield(app.UIFigure, 'numeric');
            app.RelativeHumidityEditField.AllowEmpty = 'on';
            app.RelativeHumidityEditField.Position = [135 123 100 22];
            app.RelativeHumidityEditField.Value = [];

            % Create MLabel
            app.MLabel = uilabel(app.UIFigure);
            app.MLabel.Position = [238 49 25 22];
            app.MLabel.Text = '';

            % Create MEditFieldLabel
            app.MEditFieldLabel = uilabel(app.UIFigure);
            app.MEditFieldLabel.HorizontalAlignment = 'right';
            app.MEditFieldLabel.Position = [26 49 99 22];
            app.MEditFieldLabel.Text = 'M';

            % Create MEditField
            app.MEditField = uieditfield(app.UIFigure, 'numeric');
            app.MEditField.AllowEmpty = 'on';
            app.MEditField.Position = [135 49 100 22];
            app.MEditField.Value = [];

            % Create fminEditFieldLabel
            app.fminEditFieldLabel = uilabel(app.UIFigure);
            app.fminEditFieldLabel.HorizontalAlignment = 'right';
            app.fminEditFieldLabel.Position = [88 308 31 22];
            app.fminEditFieldLabel.Text = 'f min';

            % Create fminEditField
            app.fminEditField = uieditfield(app.UIFigure, 'numeric');
            app.fminEditField.AllowEmpty = 'on';
            app.fminEditField.Position = [134 308 100 22];
            app.fminEditField.Value = [];

            % Create fmaxEditFieldLabel
            app.fmaxEditFieldLabel = uilabel(app.UIFigure);
            app.fmaxEditFieldLabel.HorizontalAlignment = 'right';
            app.fmaxEditFieldLabel.Position = [86 271 34 22];
            app.fmaxEditFieldLabel.Text = 'f max';

            % Create fmaxEditField
            app.fmaxEditField = uieditfield(app.UIFigure, 'numeric');
            app.fmaxEditField.AllowEmpty = 'on';
            app.fmaxEditField.Position = [135 271 100 22];
            app.fmaxEditField.Value = [];

            % Create pointsEditFieldLabel
            app.pointsEditFieldLabel = uilabel(app.UIFigure);
            app.pointsEditFieldLabel.HorizontalAlignment = 'right';
            app.pointsEditFieldLabel.Position = [83 235 37 22];
            app.pointsEditFieldLabel.Text = 'points';

            % Create pointsEditField
            app.pointsEditField = uieditfield(app.UIFigure, 'numeric');
            app.pointsEditField.AllowEmpty = 'on';
            app.pointsEditField.Position = [135 235 100 22];
            app.pointsEditField.Value = [];

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = Environnement_App_classe(varargin)

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            % Execute the startup function
            runStartupFcn(app, @(app)startupFcn(app, varargin{:}))

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end